//
//  Cells.swift
//  
//
//  Created by Kai on 2022/3/15.
//

import UIKit

public protocol CellConfigurationConvertible {
    func configure(using configuration: inout UIListContentConfiguration)
    func asCellConfiguration() -> [CellConfigurationConvertible]
}

public protocol CellConvertible {
    var id: ItemIdentifier { set get }
    var parentId: ItemIdentifier? { get set }
    var configuration: UIContentConfiguration { get }
    
    func asCell() -> [CellConvertible]
}

public extension CellConvertible {
    func tag<ID: Hashable>(_ id: ID) -> Self {
        var me = self
        me.id = id.hashValue.description
        return me
    }
    
    func child<ID: Hashable>(of id: ID) -> Self {
        var me = self
        me.parentId = id.hashValue.description
        return me
    }
}

public struct DLCell: CellConvertible {
    public var id = UUID().uuidString
    public var parentId: ItemIdentifier?
    public var configuration: UIContentConfiguration
    
    var backgroundConfiguration: UIBackgroundConfiguration?
    var storedContextMenu: UIContextMenuConfiguration?
    var storedAccessories: [UICellAccessory] = []
    var storedDidSelectedAction: ((IndexPath) -> Void)?
    var storedTrailingSwipeActions: [UIContextualAction]?
    var storedDidEndDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
    
    public func asCell() -> [CellConvertible] {
        [self]
    }
    
    public init(using configuration: UIListContentConfiguration = .cell(),
         @ListBuilder properties: @escaping () -> [CellConfigurationConvertible]) {
        let properties = properties()
        var cellConfig = configuration
        
        for config in properties {
            config.configure(using: &cellConfig)
        }
        
        self.configuration = cellConfig
    }
    
    public init(using dlConfiguration: DLContentConfiguration,
                backgroundConfiguration: UIBackgroundConfiguration? = nil) {
        self.configuration = dlConfiguration.contentConfiguration
        self.backgroundConfiguration = backgroundConfiguration
    }
    
    public func contextMenu(_ menu: [UIMenuElement]) -> Self {
        var cell = self
        cell.storedContextMenu = .init(identifier: id as NSCopying,
                                       previewProvider: nil,
                                       actionProvider: { _ in
                .init(children: menu)
        })
        
        return cell
    }
    
    public func swipeTrailingActions(_ actions: [UIContextualAction?]?) -> Self {
        var me = self
        me.storedTrailingSwipeActions = actions?.compactMap { $0 }
        
        return me
    }
    
    public func swipeTrailingActions(_ actions: [UIContextualAction]) -> Self {
        var me = self
        me.storedTrailingSwipeActions = actions
        
        return me
    }
    
    public func accessories(_ items: [UICellAccessory]) -> Self {
        var cell = self
        cell.storedAccessories = items
        
        return cell
    }
    
    public func onTap(action: @escaping (IndexPath) -> Void) -> Self {
        var me = self
        me.storedDidSelectedAction = action
        
        return me
    }
    
    public func onDisapear(perform action: @escaping (UICollectionViewCell, IndexPath) -> Void) -> Self {
        var me = self
        me.storedDidEndDisplay = action
        
        return me
    }
}

public struct Text: Hashable, CellConfigurationConvertible {
    var text: String
    var attributedText: NSAttributedString?
    var _color: UIColor?
    var _font: UIFont?
    var isSecondary: Bool = false
    
    public init(_ text: String) {
        self.text = text
    }
    
    public func asCellConfiguration() -> [CellConfigurationConvertible] {
        [self]
    }
    
    public init(attributedString: NSAttributedString) {
        self.text = ""
        self.attributedText = attributedString
    }
    
    public func font(_ font: UIFont) -> Self {
        var _self = self
        _self._font = font
        return _self
    }
    
    public func color(_ color: UIColor) -> Self {
        var _self = self
        _self._color = color
        return _self
    }
    
    public func secondary() -> Self {
        var me = self
        me.isSecondary = true
        return me
    }
        
    public func configure(using configuration: inout UIListContentConfiguration) {
        if isSecondary {
            if let attributedText = attributedText {
                configuration.secondaryAttributedText = attributedText
            } else {
                let prevText = configuration.secondaryText ?? ""
                let wrapString = prevText.isEmpty ? "" : "\n"
                
                configuration.secondaryText = prevText + wrapString + text
            }
            
            if let color = _color {
                configuration.secondaryTextProperties.color = color
            }
            
            if let font = _font {
                configuration.secondaryTextProperties.font = font
            }
        } else {
            if let attributedText = attributedText {
                configuration.attributedText = attributedText
            } else {
                configuration.text = text
            }
            
            if let color = _color {
                configuration.textProperties.color = color
            }
            
            if let font = _font {
                configuration.textProperties.font = font
            }
        }
    }
}

public struct Image: CellConfigurationConvertible {
    var image: UIImage
    var uiColor: UIColor?
    
    public init(_ image: UIImage) {
        self.image = image
    }
    
    public init(systemName: String) {
        self.image = .init(systemName: systemName)!
    }
    
    public func asCellConfiguration() -> [CellConfigurationConvertible] {
        [self]
    }
    
    public func configure(using configuration: inout UIListContentConfiguration) {
        var image = image
        
        if let uiColor = uiColor {
            image = image.withTintColor(uiColor, renderingMode: .alwaysOriginal)
        }
        
        configuration.image = image
    }
    
    public func color(_ uiColor: UIColor) -> Self {
        var me = self
        me.uiColor = uiColor
        
        return me
    }
}

extension Array: CellConvertible where Element == CellConvertible {
    public func asCell() -> [CellConvertible] {
        self
    }
    
    public var id: String {
        get { UUID().uuidString }
        set {}
    }
    
    public var parentId: String? {
        get { UUID().uuidString }
        set {}
    }
    
    public var configuration: UIContentConfiguration {
        get { UIListContentConfiguration.cell() }
        set { }
    }
}

extension Array: CellConfigurationConvertible where Element == CellConfigurationConvertible {
    public func configure(using configuration: inout UIListContentConfiguration) {}
    public func asCellConfiguration() -> [CellConfigurationConvertible] { self }
}

public extension UIListContentConfiguration {
    static func compactibleProminentInsetGroupedHeader() -> UIListContentConfiguration {
        if #available(iOS 15.0, *) {
            return .prominentInsetGroupedHeader()
        } else {
            return .groupedHeader()
        }
    }
}
