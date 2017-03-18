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
        showHideContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentTable()
    }

    private func presentTable(animated: Bool = false) {
        if Defaults.hasKey(.pet) {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Table") {
                self.present(vc, animated: animated, completion: nil)
            }
        }
    }

    private func showHideContent() {
        stackView.isHidden = Defaults.hasKey(.pet)
        illustration.isHidden = Defaults.hasKey(.pet)
        if Defaults.hasKey(.petArray) {
            cancelButton.isEnabled = true
            cancelButton.tintColor = .dookieGray
        } else {
            cancelButton.isEnabled = false
            cancelButton.tintColor = .clear
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        PetManager.shared.restore()
        presentTable(animated: true)
    }
}
