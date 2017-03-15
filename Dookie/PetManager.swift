//
//  PetManager.swift
//  Dookie
//
//  Created by Mathias Lindholm on 15.03.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase
import SwiftyUserDefaults

struct Pet {
    let id: String
    let name: String
    let emoji: String

    init(id: String, name: String, emoji: String) {
        self.id = id
        self.name = name
        self.emoji = emoji
    }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.emoji = json["emoji"].stringValue
    }

    init?(_ snapshot: FIRDataSnapshot) {
        guard let key = snapshot.ref.parent?.key else { return nil }
        self.id = key
        self.name = snapshot.json["name"].stringValue
        self.emoji = snapshot.json["emoji"].stringValue
    }

    func toDict() -> [String: String] {
        return [
            "id": id,
            "name": name,
            "emoji": emoji
        ]
    }
}

class PetManager {
    static let shared = PetManager()
    public private(set) var current: Pet!
    public private(set) var all = [Pet]()

    init() {
        current = getCurrentPet()
        all = getAllPets()
    }

    func getCurrentPet() -> Pet {
        let json = JSON(Defaults[.currentPet])
        let pet = Pet.init(json)
        print(pet)
        return pet
    }

    func getAllPets() -> [Pet] {
        let all = Defaults[.allPets].map {
            Pet.init(JSON($0))
        }
        print(all)
        return all
    }

    func addPet(id: String, name: String, emoji: String) {
        let pet = Pet.init(id: id, name: name, emoji: emoji)
        current = pet
        Defaults[.currentPet] = pet.toDict()
        if let i = all.index(where: { $0.id == id }) {
            all[i] = pet
            Defaults[.allPets][i] = all[i].toDict()
        } else {
            all.append(pet)
            Defaults[.allPets] = all.map { $0.toDict() }
        }
        print(Defaults[.currentPet], Defaults[.allPets])
    }

    func addPet(_ snapshot: FIRDataSnapshot) {
        guard let pet = Pet.init(snapshot) else { return }
        current = pet
        Defaults[.currentPet] = pet.toDict()
        if let i = all.index(where: { $0.id == pet.id }) {
            all[i] = pet
            Defaults[.allPets][i] = all[i].toDict()
        } else {
            all.append(pet)
            Defaults[.allPets] = all.map { $0.toDict() }
        }
        print(Defaults[.currentPet], Defaults[.allPets])
    }

    func removePet(_ id: String) {
        Defaults.remove(.currentPet)
        if let i = all.index(where: { $0.id == id }) {
            all.remove(at: i)
            Defaults[.allPets].remove(at: i)
        }
    }
}
