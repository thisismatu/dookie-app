//
//  EditEmojisViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 30.06.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Firebase
import Emoji
import ISEmojiView

class EditEmojisViewController: UITableViewController {
    let emojiView = ISEmojiView()
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
        navigationController?.setToolbarHidden(false, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "asdasd", for: indexPath)
        let emoji = buttons[indexPath.row]

        cell.textLabel?.text = emoji.emojiUnescapedString
        cell.detailTextLabel?.text = merge.contains(emoji) ? "Group" : "Don't group"
        cell.detailTextLabel?.textColor = merge.contains(emoji) ? .dookieBlue : .dookieGray

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            buttons.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // TODO: adding of emojis
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = buttons[indexPath.row]
        let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Done", style: .default, handler: { _ in
            if let field = alert.textFields?[0] {
                guard let text = field.text else { return }
                self.buttons[indexPath.row] = text.emojiEscapedString
                self.tableView.reloadData()
            }
        })
        alert.addTextField(configurationHandler: { textField in
                textField.text = item.emojiUnescapedString
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: { _ in
            self.tableView.setEditing(false, animated: true)
        })

    }

    // MARK: - Actions

    @IBAction func editButtonPressed(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            editButton.title = "Done"
            editButton.style = .done
        } else {
            editButton.title = "Edit"
            editButton.style = .plain
        }
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        if buttons.count < 6 {
            print("TODO: adding of emojis")
        }
        else {
            let alert = UIAlertController(title: "You can have up to 6 emojis", message: "Remove some before adding new ones.", preferredStyle: .alert)
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
