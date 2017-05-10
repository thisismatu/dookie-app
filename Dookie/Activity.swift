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
    let key: String
    let time: Date
    let type: [String]
    let uid: String
}

extension Activity {
    init?(_ snapshot: FIRDataSnapshot) {
        guard let date = snapshot.json["time"].stringValue.toDate else { return nil }
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.time = date
        self.type = snapshot.json["type"].arrayValue.map { $0.stringValue }
        self.uid = snapshot.json["uid"].stringValue
    }

    init(time: Date, type: [String]) {
        self.key = ""
        self.ref = nil
        self.time = time
        self.type = type
        self.uid = Defaults[.uid]
    }

    func toAnyObject() -> Any {
        return [
            "time": time.toString,
            "type": type,
            "uid": Defaults[.uid]
        ]
    }
}
