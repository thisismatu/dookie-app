//
//  Activity.swift
//  Dookie
//
//  Created by Mathias Lindholm on 01.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase
import SwiftyUserDefaults

struct Activity {
    let ref: FIRDatabaseReference?
    let date: Date
    let type: [String]
    let uid: String
}

extension Activity {
    init?(_ snapshot: FIRDataSnapshot) {
        guard let date = snapshot.json["date"].stringValue.toDate else { return nil }
        self.ref = snapshot.ref
        self.date = date
        self.type = snapshot.json["type"].arrayValue.map { $0.stringValue }
        self.uid = snapshot.json["uid"].stringValue
    }

    init(date: Date, type: [String]) {
        self.ref = nil
        self.date = date
        self.type = type
        self.uid = Defaults[.uid]
    }

    func toAnyObject() -> Any {
        return [
            "date": self.date.toString,
            "type": self.type,
            "uid": self.uid
        ]
    }
}
