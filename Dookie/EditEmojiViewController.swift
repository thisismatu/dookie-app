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
    func updateButton(at index: Int, _ button: (String, Bool))
    func deleteButton(at int: Int)
}

class EditEmojiViewController: UITableViewController, UITextFieldDelegate, ISEmojiViewDelegate {
    let emojiView = ISEmojiView()
    var delegate: EditEmojiDelegate?
    var emoji = String()
    var merge = Bool()
    var index = Int()
    var isAdding = Bool()

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mergeSwitch: UISwitch!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        navigationItem.title = isAdding ? "New emoji" : "Emoji details"
        addButton.title = isAdding ? "Add" : "Done"
        deleteButton.isEnabled = isAdding ? false : true
        deleteButton.tintColor = isAdding ? .clear : .dookieDestructive
        emojiView.delegate = self
        emojiView.collectionView.backgroundColor = .white
        textField.delegate = self
        textField.inputView = emojiView
        textField.text = emoji.emojiUnescapedString
        mergeSwitch.isOn = merge
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    // MARK: - UITextField & ISEmojiView delegate

    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        textField.text = ""
        textField.insertText(emoji)
    }

    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        textField.deleteBackward()
    }

    func textFieldDidChange(_ textField: UITextField) {
        let emoji = textField.text ?? ""
        addButton.isEnabled = !emoji.isEmpty
    }

    // MARK: - Actions

    @IBAction func addButtonPressed(_ sender: Any) {
        guard let emoji = textField.text?.emojiEscapedString else { return }
        self.delegate?.updateButton(at: index, (emoji, mergeSwitch.isOn))
        self.performSegue(withIdentifier: "deleteAddEmoji", sender: self)
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.deleteButton(at: index)
        textField.text = nil
        performSegue(withIdentifier: "deleteAddEmoji", sender: self)
    }
}
