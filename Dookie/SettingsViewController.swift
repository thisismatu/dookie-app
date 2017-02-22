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
import MessageUI

class SettingsViewController: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var ref: FIRDatabaseReference!
    var petRef: FIRDatabaseReference!
    let appstoreUrl = "itms://itunes.apple.com/us/app/simplepin/xxxx"

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
            sendInviteEmail()
        case rateCell:
            openUrl(appstoreUrl)
        case feedbackCell:
            sendFeedbackEmail()
        default: break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - MFMailComposeViewController delegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - View controller private methods

    private func sendFeedbackEmail() {
        let subject: String = "Dookie Feedback"
        let recipient: [String] = ["mathias.lindholm@gmail.com"]
        configureEmail(subject, body: "", recipients: recipient, html: false)
    }

    private func sendInviteEmail() {
        let subject: String = "Join \(Defaults[.name]) on Dookie 🐶"
        let bodyArray: [String] = [
            "<p>Hello,</p>",
            "<p>I'd like you to join \(Defaults[.name]) on <a href='https://dookie.me'>Dookie</a>.</p>",
            "<a href='dookie://\(Defaults[.secret])' style='display: inline-block; background-color: #7cb342; color: #ffffff; font-weight: 600; padding: 12px 24px; margin: 16px 0; text-decoration: none; border-radius: 9999px;'>Join \(Defaults[.name]) on Dookie</a>",
            "<p>Dookie is the easiest way to keep track of your pet's eating and walking habits. <a href='https://dookie.me'>Get the app</a>.</p>",
            "<p>Happy tracking!</p>",
            "<p>🐶</p>",
            "<p style='color: #999999;'>If the link isn't working, copy this code for manual entry: <strong>\(Defaults[.secret])</strong></p>"
        ]
        configureEmail(subject, body: bodyArray.joined(), recipients: [], html: true)
    }

    private func configureEmail(_ subject: String, body: String, recipients: [String], html: Bool) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(recipients)
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: html)
            present(mail, animated: true)
        } else {
            print("Mail services are not available")
            return
        }
    }

    private func getVersionNumber() -> String {
        guard let number = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String  else { return "" }
        return "Dookie v\(number) (\(build))"
    }

    private func copyPetId() {
        UIPasteboard.general.string = Defaults[.secret]
        let alert = UIAlertController(title: "✔️\n\nCopied", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true) {
            let deadline = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }

    private func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }

    private func setButtonTitles(_ name: String) {
        renameCell.textLabel?.text = "\u{0270f}    Rename \(name)"
        logoutButton.setTitle("Leave \(name)", for: .normal)
        deleteButton.setTitle("Delete \(name)", for: .normal)
    }

    private func showRenamePet() {
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

    // MARK: - Actions

    @IBAction func logoutButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Leave \(Defaults[.name])?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { _ in
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
