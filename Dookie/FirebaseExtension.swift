//
//  FirebaseExtension.swift
//  Dookie
//
//  Created by Mathias Lindholm on 14.02.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

extension FIRDataSnapshot {
    var json : JSON {
        return JSON(self.value ?? "")
    }
}
