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
import Emoji

class TableViewController: UITableViewController {
    var ref: DatabaseReference!
    var petRef: DatabaseReference!
    var userRef: DatabaseReference!
    var activitiesRef: DatabaseReference!
    var activitiesArray = [[Activity]]()
    var petButtons = [(key: String, value: Bool)]()
    var inactivePets = [String]()

    @IBOutlet weak var switchButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        petRef = ref.child("pets/" + Defaults[.pid])
        userRef = ref.child("users/" + Defaults[.uid])
        activitiesRef = ref.child("activities")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let user = User.init(snapshot) else { return }
            Defaults[.premium] = user.premium
            self.inactivePets = user.getInactivePets()
        })

        petRef.observe(.value, with: { snapshot in
            guard let pet = Pet.init(snapshot) else { return }
            self.petButtons = pet.buttons
            self.navigationItem.title = pet.name
            self.setupToolbar()
        })

        petRef.observe(.childRemoved, with: { snapshot in
            self.petRemovedAlert()
        })

        activitiesRef.queryOrdered(byChild: "pid").queryEqual(toValue: Defaults[.pid]).observe(.value, with: { snapshot in
            guard let snapshots = snapshot.children.allObjects as? [DataSnapshot] else { return }
            let all = snapshots
                .flatMap { Activity.init($0) }
                .sorted { $0.date > $1.date }
            let today = all.filter { Calendar.current.isDateInToday($0.date) }
            let yesterday = all.filter { Calendar.current.isDateInYesterday($0.date) }
            self.activitiesArray = [today, yesterday]

            let areBothEmpty = today.isEmpty && yesterday.isEmpty
            self.showEmptyState(areBothEmpty)

            UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activitiesRef.removeAllObservers()
        userRef.removeAllObservers()
        petRef.removeAllObservers()
        ref.removeAllObservers()
    }

    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return activitiesArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activitiesArray[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            guard !activitiesArray[section].isEmpty else { return nil }
            return "Today"
        case 1:
            guard !activitiesArray[section].isEmpty else { return nil }
            return "Yesterday"
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.contentView.backgroundColor = .white
        header.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold)
        header.textLabel?.textColor = .dookieGray
        header.textLabel?.textAlignment = .left
        header.textLabel?.frame = header.frame
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if activitiesArray[section].isEmpty {
            return 0.0
        }
        return 32.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let activity = activitiesArray[indexPath.section][indexPath.row]
        if indexPath.row == 0, indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FirstActivityCell", for: indexPath) as! FirstActivityTableViewCell
            let isOnly = self.activitiesArray[indexPath.section].count == 1
            cell.configure(activity, hideBottom: isOnly)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityTableViewCell
            switch indexPath.row {
            case 0:
                let isOnly = self.activitiesArray[indexPath.section].count == 1
                cell.configure(activity, hideTop: true, hideBottom: isOnly)
            case self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1:
                cell.configure(activity, hideTop: false, hideBottom: true)
            default:
                cell.configure(activity, hideTop: false, hideBottom: false)
            }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: ":wastebasket:".emojiUnescapedString) { (action, indexPath) in
            let activity = self.activitiesArray[indexPath.section][indexPath.row]
            activity.ref?.removeValue()
        }
        delete.backgroundColor = .white

        let edit = UITableViewRowAction(style: .normal, title: ":clock3:".emojiUnescapedString) { (action, indexPath) in
            let activity = self.activitiesArray[indexPath.section][indexPath.row]
            let alert = UIAlertController(title: "Change time", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
            let frame = CGRect(x: 10, y: 55, width: 250, height: 160)
            let picker: UIDatePicker = UIDatePicker(frame: frame)
            picker.datePickerMode = .time
            picker.date = activity.date
            picker.maximumDate = Date()
            alert.view.addSubview(picker)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                let item = Activity.init(ref: activity.ref, date: picker.date, type: activity.type)
                if !self.nearbyActivities(item) {
                    activity.ref?.updateChildValues(item.toAnyObject())
                }
            }))
            self.present(alert, animated: true, completion: { _ in
                self.tableView.setEditing(false, animated: true)
            })
        }
        edit.backgroundColor = .clear

        return [delete, edit]
    }

    // MARK: - View controller private methods

    private func leavePet() {
        let updatedPetArray = petArray.filter { $0 != Defaults[.pid] }
        self.userRef.child("current").removeValue()
        if let nextPet = updatedPetArray.first {
            self.userRef.updateChildValues(["current": nextPet, "pets": updatedPetArray])
        } else {
            self.userRef.child("pets").removeValue()
        }
        Defaults.remove(.pid)
        self.performSegue(withIdentifier: "switchPet", sender: self)
    }

    private func showEmptyState(_ show: Bool) {
        let label = UILabel(frame: tableView.frame)
        label.numberOfLines = 0
        label.textColor = .dookieGray
        label.textAlignment = .center
        label.text = "No activities today, time for a walk?"
        self.tableView.backgroundView = show ? label : nil
    }

    private func setupToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var items = [flexibleSpace]
        petButtons.forEach {
            let attributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .title3)]
            let button = UIBarButtonItem(title: $0.key.emojiUnescapedString, style: .plain, target: self, action: #selector(self.barButtonPressed(_:)))
            button.setTitleTextAttributes(attributes, for: .normal)
            items.append(button)
            items.append(flexibleSpace)
        }
        self.setToolbarItems(items, animated: true)
    }

    @objc private func barButtonPressed(_ item: UIBarButtonItem) {
        guard let type = item.title?.emojiEscapedString else { return }
        let activity = Activity.init(date: Date(), type: [type])
        if !nearbyActivities(activity) {
            item.isEnabled = false
            self.activitiesRef.childByAutoId().setValue(activity.toAnyObject(), withCompletionBlock: { (error, reference) in
                item.isEnabled = true
            })
        }
    }

    private func nearbyActivities(_ activity: Activity) -> Bool {
        guard let today = activitiesArray.first else { return false }
        var tmp = [Activity]()
        if let index = today.index(where: { $0.ref == activity.ref }) {
            if let before = today[safe: index-1] { tmp.append(before) }
            if let after = today[safe: index+1] { tmp.append(after) }
            return mergeActivity(tmp, activity)
        } else if today.count > 0 {
            if let after = today[safe: 0] { tmp.append(after) }
            return mergeActivity(tmp, activity)
        }
        return false
    }

    private func mergeActivity(_ array: [Activity], _ activity: Activity) -> Bool {
        let allowedToMerge = petButtons.filter({ $0.value }).flatMap({ $0.key })
        print(allowedToMerge)
        let filtered = array
            .filter { abs($0.date.timeIntervalSince(activity.date)) < 2400 }
            .filter { Set($0.type + activity.type).isSubset(of: Set(allowedToMerge)) }
            .sorted { abs($0.0.date.timeIntervalSince(activity.date)) < abs($0.1.date.timeIntervalSince(activity.date)) }
        if let first = filtered.first {
            let new = Activity.init(date: activity.date, type: first.type + activity.type)
            first.ref?.updateChildValues(new.toAnyObject())
            activity.ref?.removeValue()
            return true
        }
        return false
    }

    private func switchPetAlert() {
        let alert = UIAlertController(title: "Switch or add a pet", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add another pet", style: .default, handler: { _ in
            self.userRef.child("current").removeValue()
            self.performSegue(withIdentifier: "switchPet", sender: self)
        }))
        inactivePets.forEach {
            self.ref.child("pets/" + $0).observeSingleEvent(of: .value, with: { snapshot in
                guard let pet = Pet.init(snapshot) else { return }
                let name = pet.name + (pet.emoji.isEmpty ? "" : " " + pet.emoji.emojiUnescapedString)
                alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                    self.userRef.child("current").setValue(pet.pid)
                    self.performSegue(withIdentifier: "switchPet", sender: self)
                }))
            })
        }
        self.present(alert, animated: true, completion: nil)
    }

    private func upgradePremiumAlert() {
        let alert = UIAlertController(title: "This is a premium feature", message: "Upgrade to Dookie premium to access multiple pets and other premium features.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "showSettings", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func petRemovedAlert() {
        let alert = UIAlertController(title: "This pet doesn’t exist", message: "It seems that your pet has been deleted. You can recreate the pet in the next view.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: { _ in
            self.leavePet()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction func unwindToTable(_ segue: UIStoryboardSegue) {}

    @IBAction func switchButtonPressed(_ sender: Any) {
        if Defaults[.premium] {
            switchPetAlert()
        } else {
            upgradePremiumAlert()
        }
    }
}
