//
//  UIViewControllerExtension.swift
//  Dookie
//
//  Created by Mathias Lindholm on 10.03.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
}
