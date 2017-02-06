//
//  TableViewCell.swift
//  Dookie
//
//  Created by Mathias Lindholm on 06.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var indicator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ time: Date, _ type: Int, _ uid: String, _ defaults: String) {
        timeLabel.text = time.formatDate(.none, .short)
        typeLabel.text = type.toEmoji

        if uid == defaults {
            indicator.layer.borderColor = tintColor.cgColor
        } else {
            indicator.layer.borderColor = UIColor.gray.cgColor
        }
    }
}
