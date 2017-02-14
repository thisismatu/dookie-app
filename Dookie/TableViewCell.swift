//
//  TableViewCell.swift
//  Dookie
//
//  Created by Mathias Lindholm on 06.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Emoji

class TableViewCell: UITableViewCell {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var lineTop: UIView!
    @IBOutlet weak var lineBottom: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ item: Activity, defaults: String, hideTop: Bool, hideBottom: Bool) {
        timeLabel.text = item.time.formatDate(.none, .short)
        typeLabel.text = item.type.joined().emojiUnescapedString
        lineTop.isHidden = hideTop
        lineBottom.isHidden = hideBottom

        if item.uid == defaults {
            indicator.layer.borderColor = tintColor.cgColor
        } else {
            indicator.layer.borderColor = UIColor.lightGray.cgColor
        }

        if Calendar.current.isDateInYesterday(item.time) {
            stackView.alpha = 0.5
        } else {
            stackView.alpha = 1.0
        }
    }
}
