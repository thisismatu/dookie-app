//
//  ManageEmojisViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 30.06.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Firebase
import Emoji

class ManageEmojisViewController: UITableViewController, EditEmojiDelegate {
    var ref: DatabaseReference!
    var petRef: DatabaseReference!
    var petButtons = [(key: String, value: Bool)]()

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        petRef = ref.child("pets/" + Defaults[.pid])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = nil

        petRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let pet = Pet.init(snapshot) else { return }
            self.petButtons = pet.buttons
            self.tableView.reloadData()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        petRef.removeAllObservers()
        ref.removeAllObservers()
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            self.navigationController?.animateNavigationBar(to: Defaults[.navTint])
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petButtons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = Array(petButtons)[indexPath.row]

        cell.textLabel?.text = item.key.emojiUnescapedString
        cell.detailTextLabel?.text = item.value ? "Group" : "Don’t group"
        cell.detailTextLabel?.textColor = item.value ? .dookieBlue : .dookieGray
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteButton(at: indexPath.row)
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let item = petButtons[fromIndexPath.row]
        petButtons.remove(at: fromIndexPath.row)
        petButtons.insert(item, at: to.row)
    }

    // MARK: - EditEmojiDelegate

    func updateButton(at index: Int, _ button: (String, Bool)) {
        let keys = petButtons.flatMap { $0.key }
        if keys.indices.contains(index) {
            petButtons[index] = button
        } else {
            petButtons.append(button)
        }
        UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
    }

    func deleteButton(at index: Int) {
        if petButtons.indices.contains(index) {
            petButtons.remove(at: index)
        }
        UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditEmoji" {
            let vc = segue.destination as? EditEmojiViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                vc?.emoji = petButtons[indexPath.row].key
                vc?.merge = petButtons[indexPath.row].value
                vc?.index = indexPath.row
                vc?.delegate = self
            }
        } else if segue.identifier == "showAddEmoji" {
            let vc = segue.destination as? EditEmojiViewController
            vc?.index = self.tableView.numberOfRows(inSection: 0)
            vc?.delegate = self
        }
    }

    // MARK: - Actions

    @IBAction func unwindToManage(_ segue: UIStoryboardSegue) {}

    @IBAction func editButtonPressed(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            editButton.image = UIImage(named: "ic_done")
        } else {
            editButton.image = UIImage(named: "ic_shuffle")
        }
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        if petButtons.count < 6 {
            performSegue(withIdentifier: "showAddEmoji", sender: self)
        } else {
            let alert = UIAlertController(title: "Emoji limit reached", message: "You can have up to 6 emojis. Remove some before adding new ones.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        tableView.setEditing(false, animated: true)
        let toArray = petButtons.map { [$0: $1] }
        petRef.child("buttons").setValue(toArray)
        performSegue(withIdentifier: "editPet", sender: self)
    }
}
