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
    var userPetsRef: DatabaseReference!
    var connectedRef: DatabaseReference!
    var activitiesRef: DatabaseReference!
    var activitiesArray = [[Activity]]()
    var petsArray = [Pet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        petRef = ref.child("pets/" + Defaults[.pid])
        userRef = ref.child("users/" + Defaults[.uid])
        userPetsRef = ref.child("userPets/" + Defaults[.uid])
        activitiesRef = ref.child("activities")
        connectedRef = Database.database().reference(withPath: ".info/connected")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        connectedRef.observe(.value, with: { snapshot in
            // Do something when connected?
        })

        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let user = User.init(snapshot) else { return }
            Defaults[.premium] = user.premium
        })

        userPetsRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let dict = snapshot.value as? [String: Bool] else { return }
            Defaults[.pets] = dict
        })

        petRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                guard let pet = Pet.init(snapshot) else { return }
                Defaults[.name] = pet.pid
                Defaults[.name] = pet.name
                Defaults[.emoji] = pet.emoji
                Defaults[.buttons] = pet.buttons
                Defaults[.merge] = pet.merge
                self.navigationItem.title = pet.name
                self.setupToolbar()
            } else {
                let alert = UIAlertController(title: "This pet doesn’t exist", message: "It seems that your pet has been deleted. You can recreate the pet in the next view.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: { _ in
                    self.leavePet()
                }))
                self.present(alert, animated: true, completion: nil)
            }
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
        connectedRef.removeAllObservers()
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
        header.textLabel?.textColor = .lightGray
        header.textLabel?.font = UIFont.systemFont(ofSize: 15)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .center
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ActivityTableViewCell
        let activity = activitiesArray[indexPath.section][indexPath.row]

        switch indexPath.row {
        case 0:
            if self.activitiesArray[indexPath.section].count == 1 {
                cell.configure(activity, defaults: Defaults[.uid], hideTop: true, hideBottom: true)
            } else {
                cell.configure(activity, defaults: Defaults[.uid], hideTop: true, hideBottom: false)
            }
        case self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1:
            cell.configure(activity, defaults: Defaults[.uid], hideTop: false, hideBottom: true)
        default:
            cell.configure(activity, defaults: Defaults[.uid], hideTop: false, hideBottom: false)
        }

        return cell
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
                if !self.mergeActivity(item) {
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
        self.userPetsRef.child(Defaults[.pid]).removeValue()
        if let nextPet = Defaults[.pets].first(where: { $0.value == false }) {
            self.userPetsRef.child(nextPet.key).setValue(true)
        }
        Defaults.remove(.pid)
        Defaults.remove(.name)
        Defaults.remove(.emoji)
        Defaults.remove(.pets)
        Defaults.remove(.buttons)
        Defaults.remove(.merge)
        self.performSegue(withIdentifier: "switchPet", sender: self)
    }

    private func showEmptyState(_ show: Bool) {
        if show {
            let label = UILabel()
            label.frame.size.height = 48
            label.frame.size.width = tableView.frame.size.width
            label.center = tableView.center
            label.numberOfLines = 2
            label.textColor = .dookieLightGray
            label.text = "No activities today, time for a walk?"
            label.textAlignment = .center
            label.font = label.font.withSize(15)
            self.tableView.backgroundView = label
        } else {
            self.tableView.backgroundView = nil
        }
    }

    private func setupToolbar() {
        var items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
        for item in Defaults[.buttons] {
            items.append(UIBarButtonItem(title: item.emojiUnescapedString, style: .plain, target: self, action: #selector(self.barButtonPressed(_:))))
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        self.setToolbarItems(items, animated: true)
    }

    @objc private func barButtonPressed(_ item: UIBarButtonItem) {
        guard let type = item.title?.emojiEscapedString else { return }
        let item = Activity.init(date: Date(), type: [type])
        if !mergeActivity(item) {
            self.activitiesRef.childByAutoId().setValue(item.toAnyObject())
        }
    }

    private func mergeActivity(_ activity: Activity) -> Bool {
        guard let today = activitiesArray.first else { return false }
        let nearby = today
            .filter { $0.ref != activity.ref }
            .filter { activity.date.secondsAgo-1800...activity.date.secondsAgo+1800 ~= $0.date.secondsAgo }

        var firstTwo = [Activity]()
        if let above = nearby.filter({ $0.date.secondsAgo <= activity.date.secondsAgo}).last {
            firstTwo.append(above)
        }
        if let below = nearby.filter({ $0.date.secondsAgo >= activity.date.secondsAgo}).first {
            firstTwo.append(below)
        }

        if let first = firstTwo.first(where: { Set($0.type + activity.type).isSubset(of: Set(Defaults[.merge])) }) {
            let new = Activity.init(date: activity.date, type: first.type + activity.type)
            first.ref?.updateChildValues(new.toAnyObject())
            activity.ref?.removeValue()
            return true
        }

        return false
    }

    // MARK: - Actions

    @IBAction func unwindToTable(_ segue: UIStoryboardSegue) {}

    @IBAction func switchButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Switch Pet", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add/Join Pet", style: .default, handler: { _ in
            self.userPetsRef.updateChildValues([Defaults[.pid]: false])
            self.performSegue(withIdentifier: "switchPet", sender: self)
        }))

        let inactive = Defaults[.pets].filter { $0.value == false }
        for pet in inactive {
            self.ref.child("pets/" + pet.key).observeSingleEvent(of: .value, with: { snapshot in
                guard let pet = Pet.init(snapshot) else { return }
                let name = pet.name + (pet.emoji.isEmpty ? "" : " " + pet.emoji.emojiUnescapedString)
                alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                    self.userPetsRef.updateChildValues([Defaults[.pid]: false, pet.pid: true])
                    self.performSegue(withIdentifier: "switchPet", sender: self)
                }))
            })
        }

        self.present(alert, animated: true, completion: nil)
    }
}
