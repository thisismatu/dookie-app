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
    var userRef: DatabaseReference!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var illustration: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        userRef = ref.child("users/" + Defaults[.uid])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let user = User.init(snapshot) else { return }
            self.cancelButton.isEnabled = !user.pets.isEmpty
            self.cancelButton.tintColor = !user.pets.isEmpty ? .dookieGray : .clear
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ref.removeAllObservers()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        userRef.child("current").setValue(Defaults[.pid])
        self.performSegue(withIdentifier: "restorePet", sender: self)
    }
}
