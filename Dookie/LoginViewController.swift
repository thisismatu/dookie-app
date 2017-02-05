//
//  LoginViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 04.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class LoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true

        if Defaults.hasKey(.secret) {
            let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Table") {
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
}
