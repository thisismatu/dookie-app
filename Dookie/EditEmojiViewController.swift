//
//  EditEmojiViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 03.07.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Emoji
import ISEmojiView

protocol EditEmojiDelegate {
    func passDataBack(_ string: String, _ bool: Bool, _ int: Int)
}

class EditEmojiViewController: UITableViewController, UITextFieldDelegate, ISEmojiViewDelegate {
    let emojiView = ISEmojiView()
    var delegate: EditEmojiDelegate?
    var passedString = String()
    var passedBool = Bool()
    var passedInt = Int()
    var isAdding = Bool()

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var addButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = isAdding ? "Add" : "Edit"
        addButton.isEnabled = isAdding ? true : false
        addButton.tintColor = isAdding ? .dookieGray : .clear

        emojiView.delegate = self
        emojiView.collectionView.backgroundColor = .white
        textField.delegate = self
        textField.inputView = emojiView
        textField.text = passedString.emojiUnescapedString
        toggle.isOn = passedBool
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let emoji = textField.text?.emojiEscapedString {
            if !emoji.isEmpty {
                self.delegate?.passDataBack(emoji, toggle.isOn, passedInt)
            }
        }
    }

    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        textField.text = ""
        textField.insertText(emoji)
    }

    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        textField.deleteBackward()
    }
}
