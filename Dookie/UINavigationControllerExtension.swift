//
//  UINavigationControllerExtension.swift
//  Dookie
//
//  Created by Mathias Lindholm on 11.08.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit

extension UINavigationController {
    func animateNavigationBar(to color: UIColor) {
        UIView.animate(withDuration: 0.1, animations: {
            self.navigationBar.barTintColor = color
            self.navigationBar.layoutIfNeeded()
        })
    }
}
