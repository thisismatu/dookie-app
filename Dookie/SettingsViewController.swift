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
import Emoji
import ISEmojiView

class SettingsViewController: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate, ISEmojiViewDelegate {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var ref: FIRDatabaseReference!
    var petRef: FIRDatabaseReference!
    let appstoreUrl = "itms://itunes.apple.com/us/app/simplepin/xxxx"
    let emojiView = ISEmojiView()
    private let tableHeaderHeight: CGFloat = 200.0

    @IBOutlet weak var renameCell: UITableViewCell!
    @IBOutlet weak var inviteCell: UITableViewCell!
    @IBOutlet weak var feedbackCell: UITableViewCell!
    @IBOutlet weak var rateCell: UITableViewCell!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petIdButton: UIButton!
    @IBOutlet weak var petEmojiTextField: UITextField!
    @IBOutlet weak var headerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference(withPath: Defaults[.secret])
        petRef = ref.child("pet")

        emojiView.delegate = self
        emojiView.collectionView.backgroundColor = .groupTableViewBackground

        petEmojiTextField.delegate = self
        petEmojiTextField.inputView = emojiView
        petEmojiTextField.text = Defaults[.emoji].emojiUnescapedString
        petNameLabel.text = Defaults[.name]
        petIdButton.setTitle(Defaults[.secret], for: .normal)
        versionLabel.text = getVersionNumber()

        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
        navigationController?.navigationBar.isTranslucent = true

        updateHeaderView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        petRef.observe(.value, with: { snapshot in
            Defaults[.name] = snapshot.json["name"].stringValue
            Defaults[.emoji] = snapshot.json["emoji"].stringValue
            self.petNameLabel.text = Defaults[.name]
            self.petEmojiTextField.text = Defaults[.emoji].emojiUnescapedString
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        ref.removeAllObservers()
        petRef.removeAllObservers()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.systemFont(ofSize: 15)
        header.textLabel?.text = header.textLabel?.text?.capitalized
        header.textLabel?.frame = header.frame
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        switch cell {
        case renameCell:
            showRenamePet()
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

    // MARK: - UITextField & ISEmojiView delegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        emojiView.collectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .left, animated: false)
    }

    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        petEmojiTextField.text = ""
        petEmojiTextField.insertText(emoji)
        petEmojiTextField.resignFirstResponder()
        petRef.updateChildValues(["emoji": emoji.emojiEscapedString])
    }

    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        petEmojiTextField.deleteBackward()
    }

    // MARK: - MFMailComposeViewController delegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction func leaveButtonPressed(_ sender: UIBarButtonItem) {
        self.leavePet()
    }

    @IBAction func petIdButtonPressed(_ sender: UIButton) {
        self.copyPetId()
    }

    // MARK: - View controller private methods

    private func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -tableHeaderHeight, width: tableView.bounds.width, height: tableHeaderHeight)
        if tableView.contentOffset.y < -tableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
    }

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
        let alert = UIAlertController(title: "✔️\n\nPet ID Copied", message: nil, preferredStyle: .alert)
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

    private func leavePet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Leave \(Defaults[.name])", style: .default, handler: { _ in
            self.appDelegate?.leavePet()
        }))
        alert.addAction(UIAlertAction(title: "Delete \(Defaults[.name])", style: .destructive, handler: { _ in
            self.deletePet()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func deletePet() {
        let alert = UIAlertController(title: "Delete \(Defaults[.name])?", message: "This action cannot be undone", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.appDelegate?.deletePet()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
