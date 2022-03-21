//
//  File.swift
//  
//
//  Created by Kai on 2022/3/15.
//

import Foundation

@resultBuilder
public struct ListBuilder {
    static func buildBlock() -> [DLSection] {
        []
    }
}

public extension ListBuilder {
    static func buildBlock(_ components: SectionConvertible...) -> [DLSection] {
        components.flatMap { $0.asSection() }
    }
    
    static func buildBlock(_ components: CellConvertible...) -> [CellConvertible] {
        components.flatMap { $0.asCell() }
    }
    
    static func buildBlock(_ components: CellConfigurationConvertible...) -> [CellConfigurationConvertible] {
        components.flatMap { $0.asCellConfiguration() }
    }

    static func buildBlock(_ components: [CellConfigurationConvertible]) -> [CellConfigurationConvertible] {
        components.flatMap { $0.asCellConfiguration() }
    }
    
    static func buildArray(_ components: [[CellConvertible]]) -> [CellConvertible] {
        components.flatMap { $0.flatMap { $0.asCell() } }
    }
    
    static func buildArray(_ components: [[SectionConvertible]]) -> [DLSection] {
        components.flatMap { $0.flatMap { $0.asSection() } }
    }
    
    static func buildBlock(_ components: DLList) -> DLList {
        components
    }
    
    static func buildOptional(_ component: [SectionConvertible]?) -> [DLSection] {
        (component ?? []).flatMap { $0.asSection() }
    }
    
    static func buildOptional(_ component: [CellConvertible]?) -> [CellConvertible] {
        (component ?? []).flatMap { $0.asCell() }
    }
    
    static func buildEither(first component: [CellConvertible]) -> [CellConvertible] {
        component.flatMap { $0.asCell() }
    }
    
    static func buildEither(second component: [CellConvertible]) -> [CellConvertible] {
        component.flatMap { $0.asCell() }
    }
    
    static func buildOptional(_ component: [CellConfigurationConvertible]?) -> [CellConfigurationConvertible] {
        (component ?? []).flatMap { $0.asCellConfiguration() }
    }
    
    static func buildEither(first component: [CellConfigurationConvertible]) -> [CellConfigurationConvertible] {
        component.flatMap { $0.asCellConfiguration() }
    }
    
    static func buildEither(second component: [CellConfigurationConvertible]) -> [CellConfigurationConvertible] {
        component.flatMap { $0.asCellConfiguration() }
    }
    
    static func buildArray(_ components: [CellConfigurationConvertible]) -> [CellConfigurationConvertible] {
        components.flatMap { $0.asCellConfiguration() }
    }
}
