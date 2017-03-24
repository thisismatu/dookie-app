//
//  PremiumViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 21.03.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit

class PremiumViewController: UIViewController {
    var isRainingConfetti = false

    @IBOutlet weak var confettiView: SAConfettiView!
    @IBOutlet weak var buyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = nil
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        UIView.animate(withDuration: 0.1, animations: {
            self.navigationController?.navigationBar.barTintColor = .groupTableViewBackground
            self.navigationController?.navigationBar.layoutIfNeeded()
        })
    }

    @IBAction func buyButtonPressed(_ sender: Any) {
        confettiView.startConfetti()
        UIView.animate(withDuration: 0.2, animations: {
            self.buyButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.buyButton.setTitle("Thanks, you're awesome!", for: .normal)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.buyButton.transform = CGAffineTransform.identity
            }, completion: { _ in
                self.confettiView.stopConfetti()
            })
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
