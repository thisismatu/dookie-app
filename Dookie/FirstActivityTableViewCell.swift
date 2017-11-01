//
//  FirstActivityTableViewCell.swift
//  Dookie
//
//  Created by Mathias Lindholm on 02.11.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Emoji
import SwiftyUserDefaults

class FirstActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var lineBottom: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ item: Activity, hideBottom: Bool) {
        timeLabel.text = item.date.formatDate(.none, .short)
        timeLabel.textColor = .dookieDarkGray
        typeLabel.text = item.type.joined().emojiUnescapedString
        lineBottom.isHidden = hideBottom
        indicator.layer.borderColor = item.uid == Defaults[.uid] ? UIColor.dookieBlue.cgColor : UIColor.dookieLightGray.cgColor
    }
}
