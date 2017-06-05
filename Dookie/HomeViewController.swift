//
//  HomeViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 18.05.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class HomeViewController: UIViewController {
    var ref: DatabaseReference!
    var userRef: DatabaseReference!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        userRef = ref.child("users/" + Defaults[.uid])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userRef.child("pets").observeSingleEvent(of: .value, with: { snapshot in
            let dict = snapshot.json.dictionaryObject as? [String: Bool]
            print(dict)
            if let result = dict?.first(where: { $0.value == true }) {
                print(result)
                Defaults[.pid] = result.key
                self.showNext("Table")
            }
            self.showNext("Login")
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        userRef.removeAllObservers()
        ref.removeAllObservers()
    }

    private func showNext(_ identifier: String) {
        DispatchQueue.main.async {
            let vc: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {}
}
