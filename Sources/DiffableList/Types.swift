//
//  File.swift
//  
//
//  Created by Kai on 2022/3/14.
//

import Foundation
import UIKit

public typealias SectionIdentifier = String
public typealias ItemIdentifier = String

//public typealias DLList = List
//public typealias DLText = Text
//public typealias DLCell = Cell
//public typealias DLSection = Section

public extension Hashable {
    var itemIdentifier: String {
        if let string = self as? String {
            return string
        }
        
        return hashValue.description
    }
    
    var sectionIdentifer: String {
        itemIdentifier
    }
}
