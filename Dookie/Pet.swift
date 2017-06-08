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

struct PetNew {
    let ref: DatabaseReference?
    let pid: String
    var name: String
    var emoji: String
    var buttons: [String]
    var merge: [String]
}

extension PetNew {
    init?(_ snapshot: DataSnapshot) {
        self.ref = snapshot.ref
        self.pid = snapshot.ref.key
        self.name = snapshot.json["name"].stringValue
        self.emoji = snapshot.json["emoji"].stringValue
        self.buttons = snapshot.json["buttons"].arrayValue.map { $0.stringValue }
        self.merge = snapshot.json["merge"].arrayValue.map { $0.stringValue }
    }

    init(_ name: String, _ pid: String) {
        self.ref = nil
        self.pid = pid
        self.name = name
        self.emoji = ""
        self.buttons = [":stew:", ":droplet:", ":poop:"]
        self.merge = [":droplet:", ":poop:"]
    }

    func toAnyObject() -> [AnyHashable: Any] {
        return [
            "pid": self.pid,
            "name": self.name,
            "emoji": self.emoji,
            "buttons": self.buttons,
            "merge": self.merge
        ]
    }
}
