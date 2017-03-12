//
//  EditPetViewController.swift
//  Dookie
//
//  Created by Mathias Lindholm on 11.03.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Firebase
import Emoji
import ISEmojiView

class EditPetViewController: UITableViewController, UITextFieldDelegate, ISEmojiViewDelegate {
    var ref: FIRDatabaseReference!
    var petRef: FIRDatabaseReference!
    let emojiView = ISEmojiView()

    @IBOutlet weak var emojiTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference(withPath: Defaults[.secret])
        petRef = ref.child("pet")

        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        emojiTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        emojiView.delegate = self
        emojiView.collectionView.backgroundColor = .white
        emojiTextField.delegate = self
        emojiTextField.inputView = emojiView
        emojiTextField.text = Defaults[.emoji].emojiUnescapedString
        nameTextField.delegate = self
        nameTextField.text = Defaults[.name]
        validateInputs()
    }

    override func viewDidAppear(_ animated: Bool) {
        emojiTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        ref.removeAllObservers()
        petRef.removeAllObservers()
    }

    // MARK: - UITextField & ISEmojiView delegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        emojiView.collectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .left, animated: false)
    }

    func textFieldDidChange(_ textField: UITextField) {
        validateInputs()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveButtonPressed(self)
        return true
    }

    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        emojiTextField.text = ""
        emojiTextField.insertText(emoji)
    }

    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        emojiTextField.deleteBackward()
    }

    // MARK: - Actions

    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let name = nameTextField.text,
            let emoji = emojiTextField.text?.emojiEscapedString else { return }
        self.petRef.updateChildValues(["name": name, "emoji": emoji]) { (error, reference) in
            self.performSegue(withIdentifier: "editPet", sender: self)
        }
    }

    // MARK: - View controller private methods

    private func validateInputs() {
        let name = nameTextField.text ?? ""
        let emoji = emojiTextField.text ?? ""
        if !name.isEmpty && !emoji.isEmpty {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}
