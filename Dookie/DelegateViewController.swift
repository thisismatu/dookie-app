//
//  DelegateViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 05.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class DelegateViewController: UIViewController {

    private lazy var table: UINavigationController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "Table") as! UINavigationController
        self.add(vc)
        return vc
    }()

    private lazy var login: UINavigationController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "Login") as! UINavigationController
        self.add(vc)
        return vc
    }()

    private func add(_ vc: UIViewController) {
        addChildViewController(vc)
        view.addSubview(vc.view)
        vc.view.frame = self.view.bounds
        vc.didMove(toParentViewController: self)
    }

    private func remove(_ vc: UIViewController) {
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }

    private func updateView() {
        switch Defaults.hasKey(.secret) {
        case true:
            remove(login)
            add(table)
        case false:
            remove(table)
            add(login)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("update"), object: nil, queue: .main) { _ in
            self.updateView()
        }
    }
}
