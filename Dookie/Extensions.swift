//
//  Extensions.swift
//  Dookie
//
//  Created by Mathias Lindholm on 04.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON
import SwiftyUserDefaults

extension Date {
    public var toString: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: self)
    }

    func formatDate(_ date: DateFormatter.Style, _ time: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = date
        formatter.timeStyle = time
        return formatter.string(from: self)
    }

    public var hoursAgo: Int {
        guard let minutesAgo = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute else { return 0 }
        let hoursAgo = minutesAgo / 60
        return hoursAgo
    }
}

extension String {
    public var toDate: Date? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: self)
    }
}

extension FIRDataSnapshot {
    var json : JSON {
        return JSON(self.value ?? "")
    }
}

extension DefaultsKeys {
    static let uid = DefaultsKey<String>("uid")
    static let name = DefaultsKey<String>("name")
    static let secret = DefaultsKey<String>("secret")
}
