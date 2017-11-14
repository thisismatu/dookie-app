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

struct Pet {
    let ref: DatabaseReference?
    let pid: String
    var name: String
    var emoji: String
    var buttons: [(key: String, value: Bool)]
}

extension Pet {
    init?(_ snapshot: DataSnapshot) {
        let array = snapshot.json["buttons"].arrayValue.flatMap {
            $0.dictionaryObject as? [String: Bool]
        }
        self.ref = snapshot.ref
        self.pid = snapshot.ref.key
        self.name = snapshot.json["name"].stringValue
        self.emoji = snapshot.json["emoji"].stringValue
        self.buttons = array.flatMap { $0 }
    }

    init(_ name: String, _ pid: String) {
        self.ref = nil
        self.pid = pid
        self.name = name
        self.emoji = ""
        self.buttons = [
            (":stew:", false),
            (":droplet:", true),
            (":poop:", true)
        ]
    }

    func toAnyObject() -> [AnyHashable: Any] {
        return [
            "pid": self.pid,
            "name": self.name,
            "emoji": self.emoji,
            "buttons": self.buttons.map { [$0: $1] }
        ]
    }
}
