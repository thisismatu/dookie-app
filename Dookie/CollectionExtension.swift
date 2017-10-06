//
//  CollectionExtension.swift
//  Dookie
//
//  Created by Mathias Lindholm on 06.10.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {

    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
