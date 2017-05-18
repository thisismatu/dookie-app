//
//  Pet.swift
//  Dookie
//
//  Created by Mathias Lindholm on 15.03.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase
import SwiftyUserDefaults

class Pet: NSObject, NSCoding {
    let id: String
    var name: String
    var emoji: String
    var buttons: [String]
    var merge: [String]

    init?(_ snapshot: FIRDataSnapshot) {
        guard let id = snapshot.ref.parent?.key else { return nil }
        self.id = id
        self.name = snapshot.json["name"].stringValue
        self.emoji = snapshot.json["emoji"].stringValue
        self.buttons = snapshot.json["buttons"].arrayValue.map { $0.stringValue }
        self.merge = snapshot.json["merge"].arrayValue.map { $0.stringValue }
    }

    init(id: String = "", name: String = "", emoji: String = "", buttons: [String] = [":stew:", ":droplet:", ":poop:"], merge: [String] = [":droplet:", ":poop:"]) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.buttons = buttons
        self.merge = merge
    }

    required convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: "id") as? String,
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let emoji = aDecoder.decodeObject(forKey: "emoji") as? String,
            let buttons = aDecoder.decodeObject(forKey: "buttons") as? [String],
            let merge = aDecoder.decodeObject(forKey: "merge") as? [String] else { return nil }
        self.init(id: id, name: name, emoji: emoji, buttons: buttons, merge: merge)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.emoji, forKey: "emoji")
        aCoder.encode(self.buttons, forKey: "buttons")
        aCoder.encode(self.merge, forKey: "merge")
    }

    func toAnyObject() -> Any {
        return [
            "name": self.name,
            "emoji": self.emoji,
            "buttons": self.buttons,
            "merge": self.merge
        ]
    }
}

class PetManager {
    static let shared = PetManager()
    public private(set) var current = Pet()

    func add(_ pet: Pet) {
        var array = Defaults[.petArray]
        if let i = array.index(where: { $0.id == pet.id }) {
            array[i] = pet
        } else {
            array.append(pet)
        }
        Defaults[.petArray] = array
        Defaults[.pet] = pet
        self.current = pet
    }

    func remove() {
        let pet = Defaults[.pet]
        var array = Defaults[.petArray]
        if let i = array.index(where: { $0.id == pet.id }), array.count > 1 {
            array.remove(at: i)
            Defaults[.petArray] = array
            Defaults[.pet] = array[0]
            self.current = array[0]
        } else {
            Defaults.remove(.petArray)
            Defaults.remove(.pet)
            self.current = Pet()
        }
    }

    func delete() {
        let petRef = FIRDatabase.database().reference(withPath: Defaults[.pet].id)
        petRef.removeValue()
        self.remove()
    }

    func restore() {
        self.add(current)
    }
}
