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
    var asd: UIView!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var illustration: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showHideContents()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentTable()
    }

    private func presentTable(animated: Bool? = false) {
        if Defaults.hasKey(.pet) && !Defaults.hasKey(.login) {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Table") {
                self.present(vc, animated: false, completion: nil)
                Defaults.remove(.login)
            }
        }
    }

    private func showHideContents() {
        if Defaults.hasKey(.pet) && Defaults.hasKey(.login) {
            self.stackView.isHidden = false
            self.illustration.isHidden = false
        } else if Defaults.hasKey(.pet) && !Defaults.hasKey(.login) {
            self.stackView.isHidden = true
            self.illustration.isHidden = true
        } else {
            self.stackView.isHidden = false
            self.illustration.isHidden = false
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        Defaults.remove(.login)
        presentTable(animated: true)
    }
}
