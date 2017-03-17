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

    init(_ id: String, _ name: String, _ emoji: String) {
        self.id = id
        self.name = name
        self.emoji = emoji
    }

    init(_ id: String, _ snapshot: FIRDataSnapshot) {
        self.id = id
        self.name = snapshot.json["name"].stringValue
        self.emoji = snapshot.json["emoji"].stringValue
    }

    required convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: "id") as? String,
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let emoji = aDecoder.decodeObject(forKey: "emoji") as? String else { return nil }
        self.init(id, name, emoji)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.emoji, forKey: "emoji")
    }
}