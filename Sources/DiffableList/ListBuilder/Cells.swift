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
    var itemId: UUID? { get set }
    var itemTitle: String? { get set }
    var parentId: ItemIdentifier? { get set }
    var configuration: UIContentConfiguration { get }
    var name: String? { get set }
    
    func asCell() -> [CellConvertible]
}

public extension CellConvertible {
    func tag<ID: Hashable>(_ id: ID) -> Self {
        var me = self
        me.id = id.itemIdentifier
        
        return me
    }
    
    func child<ID: Hashable>(of id: ID) -> Self {
        var me = self
        me.parentId = id.itemIdentifier

        return me
    }
}

public struct DLCell: CellConvertible {
    public var id = UUID().uuidString
    public var parentId: ItemIdentifier?
    public var configuration: UIContentConfiguration
    public var name: String?
    public var itemId: UUID?
    public var itemTitle: String?
    
    var storedBackgroundConfiguration: UIBackgroundConfiguration?
    var storedContextMenu: UIContextMenuConfiguration?
    var storedAccessories: [UICellAccessory?] = []
    var storedDidSelectedAction: ((IndexPath) -> Void)?
    var storedLeadingSwipeActions: [UIContextualAction]?
    var storedTrailingSwipeActions: [UIContextualAction]?
    var storedDidEndDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
    var storedDisablingHighlight: Bool?
    var storedIndentLevel: Int?
    
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
    
    public init(using dlConfiguration: DLContentConfiguration) {
        self.configuration = dlConfiguration.contentConfiguration
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
    
    public func swipeLeadingActions(_ actions: [UIContextualAction]) -> Self {
        var me = self
        me.storedLeadingSwipeActions = actions
        
        return me
    }
    
    public func accessories(_ items: [UICellAccessory?]) -> Self {
        var cell = self
        cell.storedAccessories = items
        
        return cell
    }
    
    public func onTap(perform action: @escaping (IndexPath) -> Void) -> Self {
        var me = self
        me.storedDidSelectedAction = action
        
        return me
    }
    
    public func onDisapear(perform action: @escaping (UICollectionViewCell, IndexPath) -> Void) -> Self {
        var me = self
        me.storedDidEndDisplay = action
        
        return me
    }
    
    public func disableHighlight(_ disabled: Bool = true) -> Self {
        var me = self
        me.storedDisablingHighlight = disabled
        return me
    }
    
    public func backgroundConfiguration(_ configuration: UIBackgroundConfiguration) -> Self {
        var me = self
        me.storedBackgroundConfiguration = configuration
        return me
    }
    
    public func indentLevel(_ level: Int) -> Self {
        var me = self
        me.storedIndentLevel = level
        return me
    }
    
    public func name(_ name: String) -> Self {
        var me = self
        me.name = name
        return me
    }
    
    public func itemId(_ id: UUID?) -> Self {
        var me = self
        me.itemId = id
        return me
    }
    
    public func itemTitle(_ title: String?) -> Self {
        var me = self
        me.itemTitle = title
        return me
    }
}

public struct DLText: Hashable, CellConfigurationConvertible {
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

public struct DLImage: CellConfigurationConvertible {
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
    public var itemTitle: String? {
        get { nil }
        set {}
    }
    
    public var name: String? {
        get { first?.name ?? "" }
        set {}
    }
    
    public var isCollapsed: Bool {
        get { false }
        set {}
    }
    
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
        set {}
    }
    
    public var itemId: UUID? {
        get { nil }
        set {}
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
            return .sidebarHeader()
        }
    }
}
