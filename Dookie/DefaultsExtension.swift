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
    subscript(key: DefaultsKey<[String: Bool]>) -> [String: Bool] {
        get { return unarchive(key) ?? [:] }
        set { archive(key, newValue) }
    }
}

extension DefaultsKeys {
    static let pid = DefaultsKey<String>("pid")
    static let name = DefaultsKey<String>("name")
    static let emoji = DefaultsKey<String>("emoji")
    static let buttons = DefaultsKey<[String]>("buttons")
    static let merge = DefaultsKey<[String]>("merge")
    static let pets = DefaultsKey<[String: Bool]>("pets")

    static let uid = DefaultsKey<String>("uid")
    static let premium = DefaultsKey<Bool>("premium")
}
