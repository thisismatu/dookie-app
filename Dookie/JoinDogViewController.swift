//
//  JoinDogViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 05.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class JoinDogViewController: UIViewController {
    var ref: FIRDatabaseReference!

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
    }
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        guard let secret = textField.text?.trimmingCharacters(in: .whitespaces) else { return }

        switch !secret.isEmpty {
        case true:
            ref.child(secret).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    Defaults[.secret] = secret
                    let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: Bundle.main)
                    if let vc = storyboard?.instantiateViewController(withIdentifier: "Table") {
                        self.present(vc, animated: true, completion: nil)
                        _ = self.navigationController?.popToRootViewController(animated: false)
                    }
                } else {
                    let alert = UIAlertController(title: "Couldn't find this dog", message: "It seems that the ID you entered doesn't match any dog. Please check you pasted the whole ID or go back and create a new dog.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        case false: return
        }
    }
}
