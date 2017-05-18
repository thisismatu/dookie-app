//
//  LoginViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 04.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class LoginViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var illustration: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showHideCancelButton()
    }

    private func showHideCancelButton() {
        if Defaults.hasKey(.petArray) && !Defaults.hasKey(.pet)  {
            cancelButton.isEnabled = true
            cancelButton.tintColor = .dookieGray
        } else {
            cancelButton.isEnabled = false
            cancelButton.tintColor = .clear
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        PetManager.shared.restore()
        self.performSegue(withIdentifier: "restorePet", sender: self)
    }
}
