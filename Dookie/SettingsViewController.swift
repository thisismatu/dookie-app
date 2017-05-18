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

class SettingsViewController: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let appstoreUrl = "itms://itunes.apple.com/us/app/simplepin/xxxx"
    var ref: FIRDatabaseReference!
    var petRef: FIRDatabaseReference!
    var tableHeaderHeight: CGFloat = 200.0

    @IBOutlet weak var editCell: UITableViewCell!
    @IBOutlet weak var inviteCell: UITableViewCell!
    @IBOutlet weak var shareCell: UITableViewCell!
    @IBOutlet weak var feedbackCell: UITableViewCell!
    @IBOutlet weak var rateCell: UITableViewCell!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var petEmojiButton: UIButton!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var headerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = .groupTableViewBackground
        ref = FIRDatabase.database().reference(withPath: PetManager.shared.current.id)
        petRef = ref.child("pet")

        petEmojiButton.setTitle(petEmoji(), for: .normal)
        petNameLabel.text = PetManager.shared.current.name
        versionLabel.text = getVersionNumber()

        tableHeaderHeight = view.frame.width/2
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
        updateHeaderView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        petRef.observe(.value, with: { snapshot in
            if Defaults.hasKey(.pet) {
                guard let pet = Pet.init(snapshot) else { return }
                PetManager.shared.add(pet)
                self.petNameLabel.text = PetManager.shared.current.name
                self.petEmojiButton.setTitle(self.petEmoji(), for: .normal)
            }
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        petRef.removeAllObservers()
        ref.removeAllObservers()
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
        case inviteCell:
            sendInviteEmail()
        case shareCell:
            copyShareURL()
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

    // MARK: - Actions

    @IBAction func unwindToSettings(_ segue: UIStoryboardSegue) {}

    @IBAction func leaveButtonPressed(_ sender: Any) {
        self.leavePetPrompt()
    }

    // MARK: - View controller private methods

    private func petEmoji() -> String {
        if PetManager.shared.current.emoji.emojiUnescapedString.isEmpty {
            return "+"
        }
        return PetManager.shared.current.emoji.emojiUnescapedString
    }

    private func updateHeaderView() {
        let offset = tableView.contentOffset.y
        var headerRect = CGRect(x: 0, y: -tableHeaderHeight, width: tableView.bounds.width, height: tableHeaderHeight)

        switch offset {
        case _ where offset <= -tableHeaderHeight:
            headerRect.origin.y = offset
            headerRect.size.height = -offset
        case _ where offset <= 0:
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationController?.navigationBar.barTintColor = .groupTableViewBackground
                self.navigationController?.navigationBar.layoutIfNeeded()
            })
        default:
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationController?.navigationBar.barTintColor = .white
                self.navigationController?.navigationBar.layoutIfNeeded()
            })
        }

        headerView.frame = headerRect
    }

    private func sendFeedbackEmail() {
        let subject: String = "Dookie Feedback"
        let recipient: [String] = ["mathias.lindholm@gmail.com"]
        configureEmail(subject, body: "", recipients: recipient, html: false)
    }

    private func sendInviteEmail() {
        let subject: String = "Join \(PetManager.shared.current.name) on Dookie \(PetManager.shared.current.emoji)"
        let bodyArray: [String] = [
            "<p>Hello,</p>",
            "<p>I’d like you to join \(PetManager.shared.current.name) on <a href='https://dookie.me'>Dookie</a>.</p>",
            "<a href='dookie://\(PetManager.shared.current.id)' style='display: inline-block; background-color: #7cb342; color: #ffffff; font-weight: 600; padding: 12px 24px; margin: 16px 0; text-decoration: none; border-radius: 9999px;'>Join \(PetManager.shared.current.name) on Dookie</a>",
            "<p>Dookie is the easiest way to keep track of your pet’s eating and walking habits. <a href='https://dookie.me'>Get the app</a>.</p>",
            "<p>Happy tracking!</p>",
            "<p>🐶</p>",
            "<p style='color: #999999;'>If the link isn’t working, copy this code for manual entry: <strong>\(PetManager.shared.current.id)</strong></p>"
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

    private func copyShareURL() {
        UIPasteboard.general.string = "dookie://" + PetManager.shared.current.id
        let alert = UIAlertController(title: ":heavy_check_mark:".emojiUnescapedString + "\n\nShare URL Copied", message: nil, preferredStyle: .alert)
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

    private func leavePetPrompt() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Leave \(PetManager.shared.current.name)", style: .default, handler: { _ in
            self.appDelegate?.leavePet()
        }))
        alert.addAction(UIAlertAction(title: "Delete \(PetManager.shared.current.name)", style: .destructive, handler: { _ in
            self.deletePetPrompt()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func deletePetPrompt() {
        let alert = UIAlertController(title: "Delete \(PetManager.shared.current.name)?", message: "This action cannot be undone", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.appDelegate?.deletePet()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
