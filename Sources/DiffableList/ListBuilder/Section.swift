//
//  File.swift
//  
//
//  Created by Kai on 2022/3/15.
//

import Foundation

public protocol SectionConvertible {
    func asSection() -> [Section]
}

extension Array: SectionConvertible where Element == Section {
    public func asSection() -> [Section] {
        self
    }
}

public struct Section: SectionConvertible, Identifiable {
    public var id = UUID().uuidString
    public var cells: [CellConvertible]
    
    public init(@ListBuilder cells: @escaping () -> [CellConvertible]) {
        self.cells = cells()
    }
    
    public func asSection() -> [Section] {
        [self]
    }
    
    public func tag<ID: Hashable>(_ id: ID) -> Self {
        var me = self
        me.id = id.hashValue.description
        return me
    }
}
