//
//  DefaultsExtension.swift
//  Dookie
//
//  Created by Mathias Lindholm on 14.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension UserDefaults {
    subscript(key: DefaultsKey<UIColor>) -> UIColor {
        get { return unarchive(key) ?? .clear }
        set { archive(key, newValue) }
    }
}

extension DefaultsKeys {
    static let pid = DefaultsKey<String>("pid")
    static let uid = DefaultsKey<String>("uid")
    static let premium = DefaultsKey<Bool>("premium")
    static let navTint = DefaultsKey<UIColor>("navTint")
}
