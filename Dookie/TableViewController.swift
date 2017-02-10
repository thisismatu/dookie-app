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
    var petRef: FIRDatabaseReference!
    var activitiesRef: FIRDatabaseReference!
    var connectedRef: FIRDatabaseReference!
    var activitiesArray = [Activity]()
    var allowedToMerge = [":droplet:", ":shit:"]

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference(withPath: Defaults[.secret])
        petRef = ref.child("pet")
        activitiesRef = ref.child("activities")
        connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        self.navigationItem.title = Defaults[.name]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ref.queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                let alert = UIAlertController(title: "This pet doesn't exist", message: "It seems that your pet has been deleted. You can recreate the pet in the next view.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: { _ in
                    self.logout()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        })

        petRef.observe(.value, with: { snapshot in
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
            }
            self.activitiesArray = tmp.sorted(by: { $0.time > $1.time })
            self.showEmptyState()
            UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
        })

        let deadline = DispatchTime.now()+5
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
            self.connectedRef.observe(.value, with: { snapshot in
                guard let connected = snapshot.value as? Bool, connected else {
                    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gray]
                    self.navigationItem.prompt = "You're offline"
                    return
                }
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
                self.navigationItem.prompt = nil
            })
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        activitiesRef.removeAllObservers()
        petRef.removeAllObservers()
        connectedRef.removeAllObservers()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activitiesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let activityItem = activitiesArray[indexPath.row]

        switch indexPath.row {
        case 0:
            if self.activitiesArray.count == 1 {
                cell.configure(activityItem, defaults: Defaults[.uid], margins: [32, 32])
            } else {
                cell.configure(activityItem, defaults: Defaults[.uid], margins: [32, 0])
            }
        case self.tableView(tableView, numberOfRowsInSection: 0) - 1:
            cell.configure(activityItem, defaults: Defaults[.uid], margins: [0, 32])
        default:
            cell.configure(activityItem, defaults: Defaults[.uid], margins: [0, 0])
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "🗑", handler: { (action, indexPath) in
            let activityItem = self.activitiesArray[indexPath.row]
            activityItem.ref?.removeValue()
        })
        delete.backgroundColor = .white
        return [delete]
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
            label.numberOfLines = 2
            label.textColor = .gray
            label.text = "No activities today, maybe time for a walk?"
            label.textAlignment = .center
            label.font = label.font.withSize(15)
            self.tableView.backgroundView = label
        } else {
            self.tableView.backgroundView = nil
        }
    }

    func shouldMerge(_ newType: String) -> Bool {
        guard let latest = activitiesArray.first else { return false }
        let minago = Calendar.current.dateComponents([.minute], from: latest.time, to: Date()).minute ?? 0

        var tmp = latest.type
        tmp.append(newType)
        let listSet = Set(allowedToMerge)
        let findListSet = Set(tmp)
        let allElemsContained = findListSet.isSubset(of: listSet)

        if minago < 20 && allElemsContained {
            latest.ref?.updateChildValues([
                "type": tmp,
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

    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {}

    @IBAction func buttonWalk(_ sender: UIBarButtonItem) {
        let type = ":tennis:"
        if !shouldMerge(type) {
            let activityItem = Activity(time: Date(), type: [type])
            self.ref.child("activities").childByAutoId().setValue(activityItem.toAnyObject())
        }
    }

    @IBAction func buttonPoop(_ sender: UIBarButtonItem) {
        let type = ":shit:"
        if !shouldMerge(type) {
            let activityItem = Activity(time: Date(), type: [type])
            self.ref.child("activities").childByAutoId().setValue(activityItem.toAnyObject())
        }
    }

    @IBAction func buttonPee(_ sender: UIBarButtonItem) {
        let type = ":droplet:"
        if !shouldMerge(type) {
            let activityItem = Activity(time: Date(), type: [type])
            self.ref.child("activities").childByAutoId().setValue(activityItem.toAnyObject())
        }
    }

    @IBAction func buttonFood(_ sender: UIBarButtonItem) {
        let type = ":stew:"
        if !shouldMerge(type) {
            let activityItem = Activity(time: Date(), type: [type])
            self.ref.child("activities").childByAutoId().setValue(activityItem.toAnyObject())
        }
    }

    @IBAction func sharePetButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: Defaults[.name], message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Copy pet ID", style: .default, handler: { _ in
            UIPasteboard.general.string = Defaults[.secret]
        }))
        alert.addAction(UIAlertAction(title: "Invite others", style: .default, handler: { _ in
            let subject = "Join \(Defaults[.name]) on Dookie"
            let body = "You have been invited to join \(Defaults[.name]) on Dookie. Dookie is a simple way to share your pet's eating and walking habits with other family members. If you don't have the app, you can get it at <a href='https://dookie.me'>dookie.me</a>.\n\nTo join \(Defaults[.name]) on Dookie, follow these easy steps:\n<ol><li>Open the Dookie app</li><li>Choose <b>Join a shared pet</b></li><li>Enter the code below in the thext filed</li></ol>\n<b>\(Defaults[.secret])</b>\n<span style='color:grey'>Tip: remember to copy the whole pet ID (including the dashes)</span>\n\nHappy tracking!\n\n\u{1f436}"
            guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                  let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
            if let url = URL(string: "mailto:?subject=\(encodedSubject)&body=\(encodedBody)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Leave shared pet", style: .destructive, handler: { _ in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Delete shared pet", style: .destructive, handler: { _ in
            let alert = UIAlertController(title: "Delete shared pet?", message: "This cannot be undone", preferredStyle: .actionSheet)
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
