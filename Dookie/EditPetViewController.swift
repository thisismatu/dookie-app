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
    let emojiView = ISEmojiView()
    var ref: DatabaseReference!
    var petRef: DatabaseReference!
    var petInfo = [String: String]()

    @IBOutlet weak var emojiTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        petRef = ref.child("pets/" + Defaults[.pid])

        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        emojiTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        let name = petInfo["name"] ?? ""
        let emoji = petInfo["emoji"] ?? ""
        emojiView.delegate = self
        emojiView.collectionView.backgroundColor = .white
        emojiTextField.delegate = self
        emojiTextField.inputView = emojiView
        emojiTextField.text = emoji.emojiUnescapedString
        nameTextField.delegate = self
        nameTextField.text = name
        validateInputs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emojiTextField.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        petRef.removeAllObservers()
        ref.removeAllObservers()
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            self.navigationController?.animateNavigationBar(to: Defaults[.navTint])
        }
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
        petRef.updateChildValues(["name": name, "emoji": emoji])
        performSegue(withIdentifier: "editPet", sender: self)
    }

    // MARK: - View controller private methods

    private func validateInputs() {
        let name = nameTextField.text ?? ""
        let emoji = emojiTextField.text ?? ""
        saveButton.isEnabled = !name.isEmpty && !emoji.isEmpty
    }
}
