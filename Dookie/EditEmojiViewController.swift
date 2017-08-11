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
    func deleteItem(_ int: Int)
}

class EditEmojiViewController: UITableViewController, UITextFieldDelegate, ISEmojiViewDelegate {
    let emojiView = ISEmojiView()
    var delegate: EditEmojiDelegate?
    var passedString = String()
    var passedBool = Bool()
    var passedInt = Int()
    var isAdding = Bool()

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mergeSwitch: UISwitch!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = isAdding ? "New emoji" : "Emoji details"
        addButton.isEnabled = isAdding ? true : false
        addButton.tintColor = isAdding ? .dookieGray : .clear
        deleteButton.isEnabled = isAdding ? false : true
        deleteButton.tintColor = isAdding ? .clear : .dookieDestructive

        emojiView.delegate = self
        emojiView.collectionView.backgroundColor = .white
        textField.delegate = self
        textField.inputView = emojiView
        textField.text = passedString.emojiUnescapedString
        mergeSwitch.isOn = passedBool
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let emoji = textField.text ?? ""
        if !emoji.isEmpty && !isAdding {
            self.delegate?.passDataBack(emoji, mergeSwitch.isOn, passedInt)
        }
    }

    // MARK: - UITextField & ISEmojiView delegate

    func textFieldDidChange(_ textField: UITextField) {
        validateInput()
    }

    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        textField.text = ""
        textField.insertText(emoji)
    }

    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        textField.deleteBackward()
    }

    // MARK: - Actions

    @IBAction func addButtonPressed(_ sender: Any) {
        let emoji = textField.text ?? ""
        if !emoji.isEmpty {
            self.delegate?.passDataBack(emoji, mergeSwitch.isOn, passedInt)
            self.performSegue(withIdentifier: "deleteAddEmoji", sender: self)
        }
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.deleteItem(passedInt)
        textField.text = nil
        performSegue(withIdentifier: "deleteAddEmoji", sender: self)
    }

    // MARK: - View controller private methods

    private func validateInput() {
        let emoji = textField.text ?? ""
        addButton.isEnabled = !emoji.isEmpty
    }
}
