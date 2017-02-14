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
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: self)
    }

    public var minutesAgo: Int {
        guard let minute = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute else { return 0 }
        return minute
    }

    func formatDate(_ date: DateFormatter.Style, _ time: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = date
        formatter.timeStyle = time
        return formatter.string(from: self)
    }
}
