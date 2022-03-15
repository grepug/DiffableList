//
//  File.swift
//  
//
//  Created by Kai on 2022/3/15.
//

import Foundation

@resultBuilder
public struct ListBuilder {
    static func buildBlock() -> [Section] {
        []
    }
}

public extension ListBuilder {
    static func buildBlock(_ components: SectionConvertible...) -> [Section] {
        components.flatMap { $0.asSection() }
    }
    
    static func buildBlock(_ components: CellConvertible...) -> [CellConvertible] {
        components.flatMap { $0.asCell() }
    }
    
    static func buildBlock(_ components: CellConfigurationConvertible...) -> [CellConfigurationConvertible] {
        components
    }
    
    static func buildArray(_ components: [[CellConvertible]]) -> [CellConvertible] {
        components.flatMap { $0.flatMap { $0.asCell() } }
    }
    
    static func buildArray(_ components: [[SectionConvertible]]) -> [Section] {
        components.flatMap { $0.flatMap { $0.asSection() } }
    }
    
    static func buildBlock(_ components: List) -> List {
        components
    }
}
