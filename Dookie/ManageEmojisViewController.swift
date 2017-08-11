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
    var buttons = Defaults[.buttons]
    var merge = Defaults[.merge]

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
        UIView.animate(withDuration: 0.1, animations: {
            self.navigationController?.navigationBar.barTintColor = .groupTableViewBackground
            self.navigationController?.navigationBar.layoutIfNeeded()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let emoji = buttons[indexPath.row]

        cell.textLabel?.text = emoji.emojiUnescapedString
        cell.detailTextLabel?.text = merge.contains(emoji) ? "Group" : "Don't group"
        cell.detailTextLabel?.textColor = merge.contains(emoji) ? .dookieBlue : .dookieDarkGray

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
            buttons.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let item = buttons[fromIndexPath.row]
        buttons.remove(at: fromIndexPath.row)
        buttons.insert(item, at: to.row)
    }

    // MARK: - EditEmojiDelegate

    func passDataBack(_ string: String, _ bool: Bool, _ int: Int) {
        if buttons.indices.contains(int) {
            let old = buttons[int]
            buttons[int] = string
            if let index = merge.index(of: old) {
                merge.remove(at: index)
            }
        } else {
            buttons.append(string)
        }

        if bool {
            merge.append(string)
        }

        tableView.reloadData()
    }

    func deleteItem(_ int: Int) {
        if buttons.indices.contains(int) {
            let old = buttons[int]
            buttons.remove(at: int)
            if let index = merge.index(of: old) {
                merge.remove(at: index)
            }
        }

        tableView.reloadData()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditEmoji" {
            let vc = segue.destination as! EditEmojiViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let selected = buttons[indexPath.row]
                vc.isAdding = false
                vc.passedString = selected
                vc.passedBool = merge.contains(selected)
                vc.passedInt = indexPath.row
                vc.delegate = self
            }
        } else if segue.identifier == "showAddEmoji" {
            let vc = segue.destination as! EditEmojiViewController
            vc.isAdding = true
            vc.passedInt = self.tableView.numberOfRows(inSection: 0) + 1
            vc.delegate = self
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
        if buttons.count < 6 {
            performSegue(withIdentifier: "showAddEmoji", sender: self)
        } else {
            let alert = UIAlertController(title: "Emoji limit reached", message: "You can have up to 6 emojis. Remove some before adding new ones.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        tableView.setEditing(false, animated: true)
        Defaults[.buttons] = buttons
        Defaults[.merge] = merge
        petRef.updateChildValues(["buttons" : buttons, "merge": merge])
        performSegue(withIdentifier: "editPet", sender: self)
    }
}
