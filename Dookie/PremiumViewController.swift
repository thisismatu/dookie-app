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

    @IBOutlet weak var unlockPremiumStackView: UIStackView!
    @IBOutlet weak var premiumUnlockedStackView: UIStackView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var subscriptionButton: UIButton!
    @IBOutlet weak var confettiView: SAConfettiView!
    @IBOutlet weak var restoreButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = nil
        shouldShowPremiumUnlocked()
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

    // MARK: - View controller private methods

    private func animatePremiumUnlocked() {
        unlockPremiumStackView.spacing = 0.0
        unlockPremiumStackView.isHidden = true
        premiumUnlockedStackView.spacing = 16.0
        premiumUnlockedStackView.alpha = 0.0
        premiumUnlockedStackView.isHidden = false

        UIView.animate(withDuration: 0.5, animations: {
            self.premiumUnlockedStackView.alpha = 1.0
        }, completion: { _ in
            self.confettiView.startConfetti()
            let deadline = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.confettiView.stopConfetti()
            }
        })
    }

    private func shouldShowPremiumUnlocked() {
        let hasPremium = false // TODO: update to real
        if hasPremium {
            unlockPremiumStackView.spacing = 0.0
            unlockPremiumStackView.isHidden = true
            premiumUnlockedStackView.spacing = 16.0
            premiumUnlockedStackView.isHidden = false
        } else {
            unlockPremiumStackView.spacing = 16.0
            unlockPremiumStackView.isHidden = false
            premiumUnlockedStackView.spacing = 0.0
            premiumUnlockedStackView.isHidden = true
        }
    }

    // MARK: - Actions

    @IBAction func buyButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Your In-App Purchase", message: "This is just a test", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Buy", style: .default, handler: { _ in
            self.animatePremiumUnlocked()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func subscriptionButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
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
