//
//  TableViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 30.01.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class TableViewController: UITableViewController {
    var ref: FIRDatabaseReference!
    var dogRef: FIRDatabaseReference!
    var activitiesRef: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle?
    var items = [Activity]()

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference(withPath: Defaults[.secret])
        dogRef = ref.child("dog")
        activitiesRef = ref.child("activities")
        self.navigationItem.title = Defaults[.name]
    }

    override func viewWillAppear(_ animated: Bool) {
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                let alert = UIAlertController(title: "This dog doesn't exist", message: "Uh-oh, it seems that your dog has been deleted. You can recreate the dog in the next view.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: { _ in
                    self.logout()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        })

        dogRef.observeSingleEvent(of: .value, with: { snapshot in
            let name = snapshot.json["name"].stringValue
            self.navigationItem.title = name
            Defaults[.name] = name
        })

        activitiesRef.observe(.value, with: { snapshot in
            for item in snapshot.json {
                guard let date = item.1["time"].stringValue.toDate else { return }
                if !Calendar.current.isDateInToday(date) {
                    self.activitiesRef.child(item.0).removeValue()
                }
            }
        })

        activitiesRef.observe(.childAdded, with: { snapshot in
            guard let activity = Activity.init(snapshot) else { return }
            self.items.insert(activity, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        })

        activitiesRef.observe(.childChanged, with: { snapshot in
            guard let activity = Activity.init(snapshot) else { return }
            let index = self.indexOfMessage(snapshot)
            self.items[index] = activity
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        })

        activitiesRef.observe(.childRemoved, with: { snapshot in
            let index = self.indexOfMessage(snapshot)
            self.items.remove(at: index)
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        })

    }

    override func viewWillDisappear(_ animated: Bool) {
        activitiesRef.removeAllObservers()
        dogRef.removeAllObservers()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showEmptyState()
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.item]

        cell.textLabel?.text = item.time.formatDate(.none, .short)
        cell.detailTextLabel?.text = getEmoji(item.type)

        if Defaults[.uid] == item.uid {
            cell.textLabel?.textColor = .blue
            cell.detailTextLabel?.textColor = .blue
        } else {
            cell.textLabel?.textColor = .darkGray
            cell.detailTextLabel?.textColor = .darkGray
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = items[indexPath.item]
            item.ref?.removeValue()
        }
    }

    // MARK: - View controller custom methods

    func logout() {
        self.items.removeAll()
        Defaults.remove(.secret)
        Defaults.remove(.name)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    func showEmptyState() {
        if items.count == 0 {
            self.tableView.separatorStyle = .none
            let label = UILabel()
            label.frame.size.height = 48
            label.frame.size.width = tableView.frame.size.width
            label.center = tableView.center
            label.center.y = (tableView.frame.size.height/2)-label.frame.size.height
            label.numberOfLines = 2
            label.textColor = UIColor.gray
            label.text = "No activities today, maybe time for a walk?"
            label.textAlignment = .center
            label.font = label.font.withSize(15)
            label.tag = 1
            self.tableView.backgroundView = label
        } else {
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundView = nil
        }
    }

    func shouldMerge(_ type: Int) -> Bool {
        guard let latest = items.first else { return false }
        let minago = Calendar.current.dateComponents([.minute], from: latest.time, to: Date()).minute ?? 0
        if minago < 30 && (1...2 ~= latest.type) && type != latest.type {
            latest.ref?.updateChildValues([
                "type": 3,
                "time": Date().toString
            ])
            return true
        } else {
            return false
        }
    }

    func indexOfMessage(_ snapshot: FIRDataSnapshot) -> Int {
        var index = 0
        for item in self.items {
            if snapshot.key == item.key {
                return index
            }
            index += 1
        }
        return -1
    }

    func getEmoji(_ item: Int) -> String {
        switch item {
        case 1:
            return "💩"
        case 2:
            return "💧"
        case 3:
            return "💩💧"
        case 4:
            return "🍲"
        default:
            return "🐶"
        }
    }

    // MARK: - Actions

    @IBAction func buttonWalk(_ sender: UIBarButtonItem) {
        let activity = Activity(time: Date(), type: 5)
        self.ref.child("activities").childByAutoId().setValue(activity.toAnyObject())
    }

    @IBAction func buttonPoop(_ sender: UIBarButtonItem) {
        if !shouldMerge(1) {
            let activity = Activity(time: Date(), type: 1)
            self.ref.child("activities").childByAutoId().setValue(activity.toAnyObject())
        }
    }

    @IBAction func buttonPee(_ sender: UIBarButtonItem) {
        if !shouldMerge(2) {
            let activity = Activity(time: Date(), type: 2)
            self.ref.child("activities").childByAutoId().setValue(activity.toAnyObject())
        }
    }

    @IBAction func buttonFood(_ sender: UIBarButtonItem) {
        let activity = Activity(time: Date(), type: 4)
        self.ref.child("activities").childByAutoId().setValue(activity.toAnyObject())
    }

    @IBAction func shareDogButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: Defaults[.name], message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { _ in
            if let url = URL(string: "mailto:?subject=Join%20Dookie&body=1.%20Open%20Dookie%20App%0A2.%20Choose%20%22Join%20a%20shared%20dog%22%0A3.%20Enter%20the%20code%20below%0A%0A%3Cb%3E\(Defaults[.secret])%3C%2Fb%3E%0A%0A%F0%9F%90%B6") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Leave shared dog", style: .destructive, handler: { _ in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Delete shared dog", style: .destructive, handler: { _ in
            let alert = UIAlertController(title: "Delete shared dog?", message: "This cannot be undone", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.ref.removeValue()
                self.logout()
            }))
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
