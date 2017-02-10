//
//  SettingsViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 10.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    let appstoreUrl = "itms://itunes.apple.com/us/app/simplepin/xxxx"
    let feedbackUrl = "mailto:mathias.lindholm@gmail.com?subject=Dookie%20Feedback"
    var inviteUrl: String {
        let subject = "Join \(Defaults[.name]) on Dookie"
        let body = "You have been invited to join \(Defaults[.name]) on Dookie. Dookie is a simple way to share your pet's eating and walking habits with other family members. If you don't have the app, you can get it at <a href='https://dookie.me'>dookie.me</a>.\n\nTo join \(Defaults[.name]) on Dookie, follow these easy steps:\n<ol><li>Open the Dookie app</li><li>Choose <b>Join a shared pet</b></li><li>Enter the code below in the thext filed</li></ol>\n<b>\(Defaults[.secret])</b>\n<span style='color:grey'>Tip: remember to copy the whole pet ID (including the dashes)</span>\n\nHappy tracking!\n\n\u{1f436}"
        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return "" }
        return "mailto:?subject=\(encodedSubject)&body=\(encodedBody)"
    }


    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var petIdCell: UITableViewCell!
    @IBOutlet weak var rateCell: UITableViewCell!
    @IBOutlet weak var inviteCell: UITableViewCell!
    @IBOutlet weak var feedbackCell: UITableViewCell!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var petIdLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.text = Defaults[.name]
        versionLabel.text = getVersionNumber()
        petIdLabel.text = Defaults[.secret]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        switch cell {
        case petIdCell:
            copyPetId()
            print(Defaults[.secret])
        case inviteCell:
            openUrl(inviteUrl)
            print(inviteUrl)
        case rateCell:
            openUrl(appstoreUrl)
            print(appstoreUrl)
        case feedbackCell:
            openUrl(feedbackUrl)
            print(feedbackUrl)
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

    @IBAction func logoutButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "logout", sender: self)
        print("Logout")
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "delete", sender: self)
        print("Delete")
    }
}
