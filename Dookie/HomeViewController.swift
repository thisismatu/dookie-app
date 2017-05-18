//
//  HomeViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 18.05.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class HomeViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let identifier = Defaults.hasKey(.pet) ? "Table" : "Login"
        DispatchQueue.main.async {
            let vc: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {}
}
