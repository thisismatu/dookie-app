//
//  HomeViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 18.05.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import SwiftyUserDefaults

class HomeViewController: UIViewController {
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Auth.auth().signInAnonymously { (user, error) in
            if let user = user {
                Defaults[.uid] = user.uid
                self.getUserPets()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ref.removeAllObservers()
    }

    private func getUserPets() {
        let userRef = self.ref.child("users/" + Defaults[.uid])
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            let pets = snapshot.json["pets"].arrayValue.map { $0.stringValue }
            let current = snapshot.json["current"].stringValue
            if let result = pets.first(where: { $0 == current }) {
                Defaults[.pid] = result
                self.showNext("Table")
                return
            }
            self.showNext("Login")
        })
    }

    private func showNext(_ identifier: String) {
        DispatchQueue.main.async {
            let vc: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {}
}
