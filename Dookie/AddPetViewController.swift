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
    var ref: FIRDatabaseReference!

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        ref = FIRDatabase.database().reference()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
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
            ref.childByAutoId().child("pet").setValue(["name": name], withCompletionBlock: { (error, reference) in
                if let secret = reference.parent?.key {
                    Defaults[.secret] = secret
                    let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: Bundle.main)
                    if let vc = storyboard?.instantiateViewController(withIdentifier: "Table") {
                        self.present(vc, animated: true, completion: nil)
                        _ = self.navigationController?.popToRootViewController(animated: false)
                    }
                }
            })
        case false: return
        }
    }
}
