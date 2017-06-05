//
//  AddPetViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 05.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class AddPetViewController: UIViewController, UITextFieldDelegate {
    var ref: DatabaseReference!
    var petRef: DatabaseReference!
    var userRef: DatabaseReference!

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        petRef = ref.child("pets")
        userRef = ref.child("users/" + Defaults[.uid])
        textField.delegate = self
        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        userRef.removeAllObservers()
        petRef.removeAllObservers()
        ref.removeAllObservers()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addButtonPressed(self)
        return true
    }

    // MARK: - Actions
    
    @IBAction func addButtonPressed(_ sender: Any) {
        guard let name = textField.text?.trimmingCharacters(in: .whitespaces) else { return }

        switch !name.isEmpty {
        case true:
            let pet = PetNew.init(name)
            petRef.childByAutoId().setValue(pet.toAnyObject(), withCompletionBlock: { (error, reference) in
                self.userRef.child("pets/" + reference.key).setValue(true)
                self.performSegue(withIdentifier: "addPet", sender: self)
            })
        case false: return
        }
    }
}
