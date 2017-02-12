//
//  SettingsViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 10.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Firebase

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var ref: FIRDatabaseReference!
    var petRef: FIRDatabaseReference!
    let appstoreUrl = "itms://itunes.apple.com/us/app/simplepin/xxxx"
    let feedbackUrl = "mailto:mathias.lindholm@gmail.com?subject=Dookie%20Feedback"
    var inviteUrl: String {
        let subject = "Join \(Defaults[.name]) on Dookie"
        let body = "You have been invited to join \(Defaults[.name]) on Dookie. Dookie is a simple way to share your pet's eating and walking habits with other family members. If you don't have the app, you can get it at <a href='https://dookie.me'>dookie.me</a>.\n\nTo join \(Defaults[.name]) on Dookie, follow these easy steps:\n<ol><li>Open the Dookie app</li><li>Choose <b>Join a shared pet</b></li><li>Enter the code below in the thext filed</li></ol>\n<b>\(Defaults[.secret])</b>\n<span style='color:grey'>Tip: remember to copy the whole pet ID (including the dashes)</span>\n\nHappy tracking!\n\n\u{1f436}"
        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return "" }
        return "mailto:?subject=\(encodedSubject)&body=\(encodedBody)"
    }

    @IBOutlet weak var renameCell: UITableViewCell!
    @IBOutlet weak var petIdCell: UITableViewCell!
    @IBOutlet weak var rateCell: UITableViewCell!
    @IBOutlet weak var inviteCell: UITableViewCell!
    @IBOutlet weak var feedbackCell: UITableViewCell!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference(withPath: Defaults[.secret])
        petRef = ref.child("pet")
        setButtonTitles(Defaults[.name])
        versionLabel.text = getVersionNumber()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        petRef.observe(.value, with: { snapshot in
            let name = snapshot.json["name"].stringValue
            self.setButtonTitles(name)
            Defaults[.name] = name
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        ref.removeAllObservers()
        petRef.removeAllObservers()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        switch cell {
        case renameCell:
            showRenamePet()
        case petIdCell:
            copyPetId()
        case inviteCell:
            openUrl(inviteUrl)
        case rateCell:
            openUrl(appstoreUrl)
        case feedbackCell:
            openUrl(feedbackUrl)
        default: break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func getVersionNumber() -> String {
        guard let number = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        return "Dookie v \(number)"
    }

    func copyPetId() {
        UIPasteboard.general.string = Defaults[.secret]
    }

    func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }

    func setButtonTitles(_ name: String) {
        renameCell.textLabel?.text = "\u{0270f}    Rename \(name)"
        logoutButton.setTitle("Leave \(name)", for: .normal)
        deleteButton.setTitle("Delete \(name)", for: .normal)
    }

    func showRenamePet() {
        let alert = UIAlertController(title: "Rename \(Defaults[.name])", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
            let textField = alert.textFields![0] as UITextField
            if let name = textField.text, !name.isEmpty {
                self.petRef.updateChildValues(["name": name])
            }
        }))
        alert.addTextField { (textField) in
            textField.placeholder = "Pet's Name"
            textField.textAlignment = .center
            textField.text = Defaults[.name]
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func logoutButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Leave \(Defaults[.name])?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Leave", style: .default, handler: { _ in
            self.appDelegate?.leavePet()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Delete \(Defaults[.name])?", message: "This action cannot be undone", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.appDelegate?.deletePet()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
