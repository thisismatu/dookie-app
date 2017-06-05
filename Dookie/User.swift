//
//  User.swift
//  Dookie
//
//  Created by Mathias Lindholm on 02.06.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase
import SwiftyUserDefaults

struct User {
    let ref: DatabaseReference?
    let id: String
    let premium: Bool
    let pets: [String: Bool]
}

extension User {
    init?(_ snapshot: DataSnapshot) {
        guard let dict = snapshot.json["pets"].dictionaryObject as? [String: Bool] else { return nil }
        self.ref = snapshot.ref
        self.id = snapshot.ref.key
        self.premium = snapshot.json["premium"].boolValue
        self.pets = dict
    }
}
