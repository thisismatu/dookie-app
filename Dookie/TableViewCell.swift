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
    @IBOutlet weak var lineTop: NSLayoutConstraint!
    @IBOutlet weak var lineBottom: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ item: Activity, defaults: String, margins: [Int]? = nil) {
        timeLabel.text = item.time.formatDate(.none, .short)
        typeLabel.text = item.type.toEmoji

        if item.uid == defaults {
            indicator.layer.borderColor = tintColor.cgColor
        } else {
            indicator.layer.borderColor = UIColor.gray.cgColor
        }

        if let margins = margins {
            lineTop.constant = CGFloat(margins.first ?? 0)
            lineBottom.constant = CGFloat(margins.last ?? 0)
        }
    }
}
