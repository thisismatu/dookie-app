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
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var ref: FIRDatabaseReference!
    var petRef: FIRDatabaseReference!
    var activitiesRef: FIRDatabaseReference!
    var activitiesArray = [[Activity]]()
    var allowedToMerge = [":droplet:", ":poop:"]

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference(withPath: Defaults[.pet].id)
        petRef = ref.child("pet")
        activitiesRef = ref.child("activities")
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        navigationItem.title = Defaults[.pet].name
        setupToolbar()
        didBecomeActive()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        petRef.observe(.value, with: { snapshot in
            if snapshot.exists() && Defaults.hasKey(.pet) {
                let pet = Pet.init(Defaults[.pet].id, snapshot)
                PetManager.shared.add(pet)
                self.navigationItem.title = Defaults[.pet].name
                self.setupToolbar()
            } else {
                let alert = UIAlertController(title: "This pet doesn’t exist", message: "It seems that your pet has been deleted. You can recreate the pet in the next view.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: { _ in
                    self.appDelegate?.leavePet()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        })

        activitiesRef.observe(.value, with: { snapshot in
            guard let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            let all = snapshots.flatMap { Activity.init($0) }
            let today = all
                .filter { Calendar.current.isDateInToday($0.time) }
                .sorted { $0.time > $1.time }
            let yesterday = all
                .filter { Calendar.current.isDateInYesterday($0.time) }
                .sorted { $0.time > $1.time }
            self.activitiesArray = [today, yesterday]

            let bothArrays = today.isEmpty && yesterday.isEmpty
            self.showEmptyState(bothArrays)

            UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activitiesRef.removeAllObservers()
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
        let activityItem = activitiesArray[indexPath.section][indexPath.row]

        switch indexPath.row {
        case 0:
            if self.activitiesArray[indexPath.section].count == 1 {
                cell.configure(activityItem, defaults: Defaults[.uid], hideTop: true, hideBottom: true)
            } else {
                cell.configure(activityItem, defaults: Defaults[.uid], hideTop: true, hideBottom: false)
            }
        case self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1:
            cell.configure(activityItem, defaults: Defaults[.uid], hideTop: false, hideBottom: true)
        default:
            cell.configure(activityItem, defaults: Defaults[.uid], hideTop: false, hideBottom: false)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: ":wastebasket:".emojiUnescapedString) { (action, indexPath) in
            let activityItem = self.activitiesArray[indexPath.section][indexPath.row]
            activityItem.ref?.removeValue()
        }
        delete.backgroundColor = .white

        let edit = UITableViewRowAction(style: .normal, title: ":clock3:".emojiUnescapedString) { (action, indexPath) in
            let activityItem = self.activitiesArray[indexPath.section][indexPath.row]
            let alert = UIAlertController(title: "Change time", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
            let frame = CGRect(x: 10, y: 55, width: 250, height: 160)
            let picker: UIDatePicker = UIDatePicker(frame: frame)
            picker.datePickerMode = .time
            picker.date = activityItem.time
            picker.maximumDate = Date()
            alert.view.addSubview(picker)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                if !self.mergeWithNearby(activityItem, for: indexPath, at: picker.date) {
                    activityItem.ref?.updateChildValues(["time": picker.date.toString])
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

    @objc private func didBecomeActive() {
        let all = activitiesArray.flatMap { $0 }
        _ = removeOldActivities(from: all)
    }

    private func removeOldActivities(from array: [Activity]) -> [Activity] {
        _ = array
            .filter { $0.time.minutesAgo > 1440 }
            .map { self.activitiesRef.child($0.key).removeValue() }
        let new = array
            .filter { $0.time.minutesAgo < 1440 }
        return new
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
        for item in Defaults[.pet].buttons {
            items.append(UIBarButtonItem(title: item.emojiUnescapedString, style: .plain, target: self, action: #selector(self.barButtonPressed(_:))))
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        self.setToolbarItems(items, animated: true)
    }

    @objc private func barButtonPressed(_ item: UIBarButtonItem) {
        guard let type = item.title?.emojiEscapedString else { return }
        if !mergeWithLatest([type]) {
            let activityItem = Activity(time: Date(), type: [type])
            self.activitiesRef.childByAutoId().setValue(activityItem.toAnyObject())
        }
    }

    private func mergeWithLatest(_ newType: [String]) -> Bool {
        guard let latest = activitiesArray.first?.first else { return false }
        let tmp = latest.type + newType
        let allElemsContained = Set(tmp).isSubset(of: Set(allowedToMerge))

        if latest.time.minutesAgo < 30 && allElemsContained {
            latest.ref?.updateChildValues(["type": tmp, "time": Date().toString])
            return true
        } else {
            return false
        }
    }

    private func mergeWithNearby(_ current: Activity, for indexPath: IndexPath, at date: Date) -> Bool {
        let nearby = activitiesArray[indexPath.section]
            .filter { $0.key != current.key }
            .filter { date.minutesAgo-30...date.minutesAgo+30 ~= $0.time.minutesAgo }
            .filter { Set($0.type + current.type).isSubset(of: Set(allowedToMerge)) }

        if let first = nearby.first {
            first.ref?.updateChildValues(["type": first.type + current.type ])
            current.ref?.removeValue()
            return true
        } else {
            return false
        }
    }

    // MARK: - Actions

    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {}

    @IBAction func switchButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Switch Pet", message: nil, preferredStyle: .actionSheet)
        let filteredPets = Defaults[.petArray].filter { $0.id != Defaults[.pet].id }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add/Join Pet", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "backToLogin", sender: self)
            Defaults.remove(.pet)
        }))

        for pet in filteredPets {
            let name = pet.name + (pet.emoji.isEmpty ? "" : " " + pet.emoji.emojiUnescapedString)
            alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                self.performSegue(withIdentifier: "switchPet", sender: self)
                PetManager.shared.add(pet)
            }))
        }

        self.present(alert, animated: true, completion: nil)
    }
}
