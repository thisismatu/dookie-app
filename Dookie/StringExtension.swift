//
//  StringExtension.swift
//  Dookie
//
//  Created by Mathias Lindholm on 14.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation

extension String {
    public var toDate: Date? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: self)
    }

    public var isFirebasePushId: Bool {
        let allowed = CharacterSet(charactersIn: "-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz")
        if self.rangeOfCharacter(from: allowed.inverted) == nil && self.characters.count == 20 {
            return true
        } else {
            return false
        }
    }
}
