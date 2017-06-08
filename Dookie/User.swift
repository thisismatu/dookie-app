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
}

extension User {
    init?(_ snapshot: DataSnapshot) {
        self.ref = snapshot.ref
        self.uid = snapshot.key
        self.premium = snapshot.json["premium"].boolValue
    }

    init() {
        self.ref = nil
        self.uid = Defaults[.uid]
        self.premium = Defaults[.premium]
    }

    func toAnyObject() -> [AnyHashable: Any] {
        return [
            "premium": self.premium
        ]
    }
}

struct UserPet {
    let ref: DatabaseReference?
    let pid: String
    let current: Bool
}

extension UserPet {
    init?(_ snapshot: DataSnapshot) {
        self.ref = snapshot.ref
        self.pid = snapshot.json[0].stringValue
        self.current = snapshot.json[1].boolValue
    }

    init(_ pid: String) {
        self.ref = nil
        self.pid = pid
        self.current = true
    }

    func toAnyObject() -> [AnyHashable: Any] {
        return [
            self.pid: self.current
        ]
    }
}
