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
    var current = true

    init?(_ snapshot: FIRDataSnapshot) {
        guard let id = snapshot.ref.parent?.key else { return nil }
        self.id = id
        self.name = snapshot.json["name"].stringValue
        self.emoji = snapshot.json["emoji"].stringValue
        self.buttons = snapshot.json["buttons"].arrayValue.map { $0.stringValue }
        self.merge = snapshot.json["merge"].arrayValue.map { $0.stringValue }
    }

    init(_ id: String, _ name: String = "", _ emoji: String = "", _ buttons: [String] = [":stew:", ":droplet:", ":poop:"], _ merge: [String] = [":droplet:", ":poop:"]) {
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
        self.init(id, name, emoji, buttons, merge)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.emoji, forKey: "emoji")
        aCoder.encode(self.buttons, forKey: "buttons")
        aCoder.encode(self.merge, forKey: "merge")
    }
}

class PetManager {
    static let shared = PetManager()

    func add(_ pet: Pet) {
        Defaults[.pet] = pet
        _ = Defaults[.petArray].map { $0.current = false }
        if let index = Defaults[.petArray].index(where: { $0.id == pet.id }) {
            Defaults[.petArray][index] = pet
        } else {
            Defaults[.petArray].append(pet)
        }
    }

    func remove(_ pet: Pet) {
        if Defaults[.petArray].count > 1 {
            if let index = Defaults[.petArray].index(where: { $0.id == pet.id }) {
                Defaults[.petArray].remove(at: index)
                Defaults[.pet] = Defaults[.petArray][0]
                Defaults[.pet].current = true
            }
        } else {
            Defaults.remove(.pet)
            Defaults.remove(.petArray)
        }
    }

    func restore() {
        if let current = Defaults[.petArray].filter({ $0.current == true }).first {
            self.add(current)
        }
    }
}
