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
    let appstoreUrl = "itms://itunes.apple.com/us/app/simplepin/xxxx"
    var ref: DatabaseReference!
    var petRef: DatabaseReference!
    var userRef: DatabaseReference!
    var tableHeaderHeight: CGFloat = 200.0
    var inactivePets = [String]()
    var petButtons = [(key: String, value: Bool)]()
    var petName = String()
    var petEmoji = String()

    @IBOutlet weak var editCell: UITableViewCell!
    @IBOutlet weak var inviteCell: UITableViewCell!
    @IBOutlet weak var shareCell: UITableViewCell!
    @IBOutlet weak var manageCell: UITableViewCell!
    @IBOutlet weak var feedbackCell: UITableViewCell!
    @IBOutlet weak var rateCell: UITableViewCell!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var petEmojiButton: UIButton!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var headerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        petRef = ref.child("pets/" + Defaults[.pid])
        userRef = ref.child("users/" + Defaults[.uid])
        versionLabel.text = getVersionNumber()
        setupHeaderView()
        updateHeaderView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let user = User.init(snapshot) else { return }
            Defaults[.premium] = user.premium
            self.inactivePets = user.getInactivePets()
        })

        petRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let pet = Pet.init(snapshot) else { return }
            self.petName = pet.name
            self.petEmoji = pet.emoji
            self.petButtons = pet.buttons
            let emoji = pet.emoji.isEmpty ? "+" : pet.emoji.emojiUnescapedString
            self.petNameLabel.text = pet.name
            self.petEmojiButton.setTitle(emoji, for: .normal)
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Defaults[.navTint] = getNavigationBarTint()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        userRef.removeAllObservers()
        petRef.removeAllObservers()
        ref.removeAllObservers()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.contentView.backgroundColor = .white
        header.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold)
        header.textLabel?.text = header.textLabel?.text?.capitalized
        header.textLabel?.textColor = .dookieGray
        header.textLabel?.textAlignment = .left
        header.textLabel?.frame = header.frame
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        switch cell {
        case inviteCell:
            sendInviteEmail()
        case shareCell:
            copyShareUrlPrompt()
        case manageCell:
            if Defaults[.premium] {
                self.performSegue(withIdentifier: "showManageEmojis", sender: self)
            } else {
                upgradePremiumAlert()
            }
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

    private func getNavigationBarTint() -> UIColor {
        guard let color = navigationController?.navigationBar.barTintColor else { return .groupTableViewBackground }
        return color
    }

    private func upgradePremiumAlert() {
        let alert = UIAlertController(title: "This is a premium feature", message: "Upgrade to Dookie premium to access custom emojis and other premium features.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "showPremium", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func setupHeaderView() {
        navigationController?.navigationBar.barTintColor = .groupTableViewBackground
        tableHeaderHeight = view.frame.width/2
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
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
        let subject: String = "Join \(petName) on Dookie \(petEmoji.emojiUnescapedString)"
        let bodyArray: [String] = [
            "<p>Hello,</p>",
            "<p>I’d like you to join \(petName) on <a href='https://dookie.me'>Dookie</a>.</p>",
            "<a href='dookie://\(Defaults[.pid])' style='display: inline-block; background-color: #7cb342; color: #ffffff; font-weight: 600; padding: 12px 24px; margin: 16px 0; text-decoration: none; border-radius: 9999px;'>Join \(petName) on Dookie</a>",
            "<p>Dookie is the easiest way to keep track of your pet’s eating and walking habits. <a href='https://dookie.me'>Get the app</a>.</p>",
            "<p>Happy tracking!</p>",
            "<p>🐶</p>",
            "<p style='color: #999999;'>If the link isn’t working, copy this code for manual entry: <strong>\(Defaults[.pid])</strong></p>"
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

    private func copyShareUrlPrompt() {
        let alert = UIAlertController(title: "What do you want to copy?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "App share link", style: .default, handler: { _ in
            UIPasteboard.general.string = "dookie://" + Defaults[.pid]
        }))
        alert.addAction(UIAlertAction(title: "Web share link", style: .default, handler: { _ in
            UIPasteboard.general.string = "https://dookie.me/app/?petId=" + Defaults[.pid]
        }))
        alert.addAction(UIAlertAction(title: "Just the pet ID", style: .default, handler: { _ in
            UIPasteboard.general.string = Defaults[.pid]
        }))
        self.present(alert, animated: true, completion: nil)
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
        alert.addAction(UIAlertAction(title: "Leave \(petName)", style: .default, handler: { _ in
            self.leavePet()
        }))
        alert.addAction(UIAlertAction(title: "Delete \(petName)", style: .destructive, handler: { _ in
            self.deletePetPrompt()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func deletePetPrompt() {
        let alert = UIAlertController(title: "Delete \(petName)?", message: "This action cannot be undone", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.petRef.removeValue()
            self.leavePet()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func leavePet() {
        let updatedPetArray = petArray.filter { $0 != Defaults[.pid] }
        self.userRef.child("current").removeValue()
        if let nextPet = updatedPetArray.first {
            self.userRef.updateChildValues(["current": nextPet, "pets": updatedPetArray])
        } else {
            self.userRef.child("pets").removeValue()
        }
        Defaults.remove(.pid)
        self.performSegue(withIdentifier: "leavePet", sender: self)
    }
}
