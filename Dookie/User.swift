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
    let uid: String
    let premium: Bool
    let pets: [String]
    let current: String
}

extension User {
    init?(_ snapshot: DataSnapshot) {
        self.ref = snapshot.ref
        self.uid = snapshot.key
        self.premium = snapshot.json["premium"].boolValue
        self.pets = snapshot.json["pets"].arrayValue.map { $0.stringValue }
        self.current = snapshot.json["current"].stringValue
    }

    func toAnyObject() -> [AnyHashable: Any] {
        return [
            "uid": self.uid,
            "premium": self.premium,
            "pets": self.pets,
            "current": self.current
        ]
    }
}
