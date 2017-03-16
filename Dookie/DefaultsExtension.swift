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
    subscript(key: DefaultsKey<Pet>) -> Pet {
        get { return unarchive(key) ?? Pet("","","") }
        set { archive(key, newValue) }
    }
}

extension DefaultsKeys {
    static let uid = DefaultsKey<String>("uid")
    static let pet = DefaultsKey<Pet>("pet")
}
