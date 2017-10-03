//
//  LoginViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 04.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class LoginViewController: UIViewController {
    var ref: DatabaseReference!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var illustration: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Defaults[.pets].isEmpty {
            self.cancelButton.isEnabled = true
            self.cancelButton.tintColor = .dookieDarkGray
        } else {
            self.cancelButton.isEnabled = false
            self.cancelButton.tintColor = .clear
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ref.removeAllObservers()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        let userPetsRef = ref.child("userPets/" + Defaults[.uid])
        userPetsRef.updateChildValues([Defaults[.pid]: true])
        self.performSegue(withIdentifier: "restorePet", sender: self)
    }
}
