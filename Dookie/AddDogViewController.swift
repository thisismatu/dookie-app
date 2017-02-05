//
//  AddDogViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 05.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class AddDogViewController: UIViewController {
    var ref: FIRDatabaseReference!

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        guard let name = textField.text?.trimmingCharacters(in: .whitespaces) else { return }

        switch !name.isEmpty {
        case true:
            ref.childByAutoId().child("dog").setValue(["name": name], withCompletionBlock: { (error, reference) in
                if let secret = reference.parent?.key {
                    Defaults[.secret] = secret
                    let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: Bundle.main)
                    if let vc = storyboard?.instantiateViewController(withIdentifier: "Table") {
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            })
        case false: return
        }
    }
}
