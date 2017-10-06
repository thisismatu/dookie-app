//
//  DateExtension.swift
//  Dookie
//
//  Created by Mathias Lindholm on 14.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation

extension Date {
    public var toString: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.string(from: self)
    }

    public var secondsAgo: Int {
        guard let second = Calendar.current.dateComponents([.second], from: self, to: Date()).second else { return 0 }
        return second
    }

    func formatDate(_ date: DateFormatter.Style, _ time: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = date
        formatter.timeStyle = time
        return formatter.string(from: self)
    }
}
