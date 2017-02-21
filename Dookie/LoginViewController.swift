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
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var illustration: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.shouldPresentTable), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        shouldPresentTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.stackView.isHidden = Defaults.hasKey(.secret)
        self.illustration.isHidden = Defaults.hasKey(.secret)
    }

    @objc private func shouldPresentTable() {
        if Defaults.hasKey(.secret) {
            let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Table") {
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
}
