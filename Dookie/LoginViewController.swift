//
//  LoginViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 04.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation
import Firebase
import SwiftyUserDefaults

class LoginViewController: UIViewController {
    var ref: FIRDatabaseReference!

    @IBOutlet weak var newTextField: UITextField!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var sharedTextField: UITextField!
    @IBOutlet weak var sharedButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
    }

    override func viewDidDisappear(_ animated: Bool) {
        newTextField.text = ""
        sharedTextField.text = ""
    }

    @IBAction func newButtonPressed(_ sender: Any) {
        guard let name = newTextField.text else { return }
        if !name.isEmpty {
            ref.childByAutoId().child("dog").setValue(["name": name], withCompletionBlock: { (error, reference) in
                if let secret = reference.parent?.key {
                    Defaults[.secret] = secret
                    //self.ref.child(secret).child("owners").child(Defaults[.uid]).setValue(true)
                    self.performSegue(withIdentifier: "Login", sender: nil)
                }
            })
        }
    }

    @IBAction func sharedButtonPressed(_ sender: Any) {
        guard let secret = sharedTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
        if !secret.isEmpty {
            ref.child(secret).observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.json.isEmpty {
                    Defaults[.secret] = secret
                    //self.ref.child(secret).child("owners").child(Defaults[.uid]).setValue(true)
                    self.performSegue(withIdentifier: "Login", sender: nil)
                }
            })
        }
    }
}
