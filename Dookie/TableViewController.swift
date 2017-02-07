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
    var activitiesArray = [Activity]()

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference(withPath: Defaults[.secret])
        dogRef = ref.child("dog")
        activitiesRef = ref.child("activities")
        self.navigationItem.title = Defaults[.name]
    }

    override func viewWillAppear(_ animated: Bool) {
        ref.queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { snapshot in
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
            var tmp = [Activity]()
            for child in snapshot.children {
                guard let object = child as? FIRDataSnapshot else { return }
                guard let activityItem = Activity.init(object) else { return }
                let isDateInToday = Calendar.current.isDateInToday(activityItem.time)

                switch isDateInToday {
                case true:
                    tmp.append(activityItem)
                case false:
                    self.activitiesRef.child(activityItem.key).removeValue()
                }

                self.activitiesArray = tmp.sorted(by: { $0.time > $1.time })
                UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
            }
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
        return activitiesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let activityItem = activitiesArray[indexPath.row]

        switch indexPath.row {
        case 0:
            cell.configure(activityItem, defaults: Defaults[.uid], margins: [32, 0])
        case self.tableView(tableView, numberOfRowsInSection: 0) - 1:
            cell.configure(activityItem, defaults: Defaults[.uid], margins: [0, 32])
        default:
            cell.configure(activityItem, defaults: Defaults[.uid])
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let activityItem = activitiesArray[indexPath.row]
            activityItem.ref?.removeValue()
        }
    }

    // MARK: - View controller custom methods

    func logout() {
        self.activitiesArray.removeAll()
        Defaults.remove(.secret)
        Defaults.remove(.name)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    func showEmptyState() {
        if activitiesArray.count == 0 {
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
            self.tableView.backgroundView = nil
        }
    }

    func shouldMerge(_ type: Int) -> Bool {
        guard let latest = activitiesArray.first else { return false }
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
        for activityItem in self.activitiesArray {
            if snapshot.key == activityItem.key {
                return index
            }
            index += 1
        }
        return -1
    }

    // MARK: - Actions

    @IBAction func buttonWalk(_ sender: UIBarButtonItem) {
        let activityItem = Activity(time: Date(), type: 5)
        self.ref.child("activities").childByAutoId().setValue(activityItem.toAnyObject())
    }

    @IBAction func buttonPoop(_ sender: UIBarButtonItem) {
        if !shouldMerge(1) {
            let activityItem = Activity(time: Date(), type: 1)
            self.ref.child("activities").childByAutoId().setValue(activityItem.toAnyObject())
        }
    }

    @IBAction func buttonPee(_ sender: UIBarButtonItem) {
        if !shouldMerge(2) {
            let activityItem = Activity(time: Date(), type: 2)
            self.ref.child("activities").childByAutoId().setValue(activityItem.toAnyObject())
        }
    }

    @IBAction func buttonFood(_ sender: UIBarButtonItem) {
        let activityItem = Activity(time: Date(), type: 4)
        self.ref.child("activities").childByAutoId().setValue(activityItem.toAnyObject())
    }

    @IBAction func shareDogButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: Defaults[.name], message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Copy ID", style: .default, handler: { _ in
            UIPasteboard.general.string = Defaults[.secret]
        }))
        alert.addAction(UIAlertAction(title: "Invite others", style: .default, handler: { _ in
            let subject = "Join \(Defaults[.name]) on Dookie"
            let body = "0. Get the app at https://dookie.me/\n1. Open Dookie App\n2. Choose 'Join a shared dog'\n3. Enter the code below\n\n<b>\(Defaults[.secret])</b>\n\n🐶"
            guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                  let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
            if let url = URL(string: "mailto:?subject=\(encodedSubject)&body=\(encodedBody)") {
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
