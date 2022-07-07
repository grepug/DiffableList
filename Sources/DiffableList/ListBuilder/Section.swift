//
//  File.swift
//  
//
//  Created by Kai on 2022/3/15.
//

import Foundation
import UIKit

public protocol SectionConvertible {
    func asSection() -> [DLSection]
}

extension Array: SectionConvertible where Element == DLSection {
    public func asSection() -> [DLSection] {
        self
    }
}

public struct DLSection: SectionConvertible, Identifiable {
    public var id = UUID().uuidString
    public var cells: [CellConvertible]
    var isFirstCellAsHeader: Bool = false
    var headerText: String?
    var headerContentConfiguration: DLContentConfiguration?
    var footerContentConfiguration: DLContentConfiguration?
    var footerText: String?
    var storedHeaderTopPadding: CGFloat?
    var storedLayout: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?)?
    var storedListBackgroundColor: UIColor?
    var storedMutatingListConfig: ((UICollectionLayoutListConfiguration) -> UICollectionLayoutListConfiguration?)?
    
    public init(@ListBuilder cells: @escaping () -> [CellConvertible]) {
        self.cells = cells()
    }
    
    public func asSection() -> [DLSection] {
        [self]
    }
    
    public func tag<ID: Hashable>(_ id: ID) -> Self {
        var me = self
        me.id = id.sectionIdentifer
        return me
    }
    
    public func firstCellAsHeader(_ isTrue: Bool = true) -> Self {
        var me = self
        me.isFirstCellAsHeader = isTrue
        return me
    }
    
    public func header(_ text: String) -> Self {
        var me = self
        me.headerText = text
        return me
    }
    
   public func header(using contentConfiguration: DLContentConfiguration) -> Self {
        var me = self
        me.headerContentConfiguration = contentConfiguration
        return me
   }
    
    public func footer(using contentConfiguration: DLContentConfiguration?) -> Self {
        var me = self
        
        if let contentConfiguration = contentConfiguration {
            me.footerContentConfiguration = contentConfiguration
        }
        
        return me
    }
    
    public func footer(_ text: String) -> Self {
        var me = self
        me.footerText = text
        return me
    }
    
    public func headerTopPadding(_ top: CGFloat) -> Self {
        var me = self
        me.storedHeaderTopPadding = top
        return me
    }
    
    public func layout(_ layout: @escaping (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?) -> Self {
        var me = self
        me.storedLayout = layout
        return me
    }
    
    public func listBackgroundColor(_ color: UIColor) -> Self {
        var me = self
        me.storedListBackgroundColor = color
        return me
    }
    
    public func listConfig(mutatingListConfig: ((UICollectionLayoutListConfiguration) -> UICollectionLayoutListConfiguration?)?) -> Self {
        var me = self
        me.storedMutatingListConfig = mutatingListConfig
        return me
    }
}

public extension DLSection {
    struct SupplementaryTypes: OptionSet {
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public let rawValue: Int
        
        public static let header = SupplementaryTypes(rawValue: 1 << 0)
        public static let footer = SupplementaryTypes(rawValue: 1 << 1)

        public static let all: SupplementaryTypes = [.header, .footer]
    }
}

