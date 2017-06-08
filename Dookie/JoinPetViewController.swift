//
//  JoinPetViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 05.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class JoinPetViewController: UIViewController, UITextFieldDelegate {
    var ref: DatabaseReference!
    var userPetsRef: DatabaseReference!

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        userPetsRef = ref.child("userPets/" + Defaults[.uid])
        textField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkPasteboard), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPasteboard()
        textField.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        userPetsRef.removeAllObservers()
        ref.removeAllObservers()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        joinButtonPressed(self)
        return true
    }

    @objc private func checkPasteboard() {
        guard let pasteboard = UIPasteboard.general.string else { return }
        if pasteboard.isFirebaseUID {
            textField.text = pasteboard
        }
    }

    @IBAction func joinButtonPressed(_ sender: Any) {
        guard let id = textField.text?.trimmingCharacters(in: .whitespaces) else { return }

        switch !id.isEmpty {
        case true:
            let petRef = ref.child("pets/" + id)
            petRef.observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    let userPet = UserPet.init(id)
                    self.userPetsRef.updateChildValues(userPet.toAnyObject())
                    self.performSegue(withIdentifier: "joinPet", sender: self)
                } else {
                    let alert = UIAlertController(title: "Couldn’t find this pet", message: "The Pet ID you entered doesn't match any existing pet. Please check that you’ve entered the whole ID.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        case false: return
        }
    }
}
