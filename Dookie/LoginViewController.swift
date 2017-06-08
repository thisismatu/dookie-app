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
    var userPetsRef: DatabaseReference!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var illustration: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        userPetsRef = ref.child("userPets/" + Defaults[.uid])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Defaults[.pets].isEmpty {
            self.cancelButton.isEnabled = true
            self.cancelButton.tintColor = .dookieGray
        } else {
            self.cancelButton.isEnabled = false
            self.cancelButton.tintColor = .clear
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        userPetsRef.removeAllObservers()
        ref.removeAllObservers()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.userPetsRef.child(Defaults[.pid]).setValue(true) { (error, reference) in
            self.performSegue(withIdentifier: "restorePet", sender: self)
        }
    }
}
