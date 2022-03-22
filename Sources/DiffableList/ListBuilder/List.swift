//
//  List.swift
//  
//
//  Created by Kai on 2022/3/15.
//

import UIKit

@available(iOS 14.5, *)
public struct DLList {
    public var sections: [DLSection]
    
    var storedOnTapAction: ((IndexPath) -> Void)?
    var storedDefaultBackgroundConfiguration: UIBackgroundConfiguration?
    var storedItemSeparatorHandler: UICollectionLayoutListConfiguration.ItemSeparatorHandler?
    
    public init(@ListBuilder sections: @escaping () -> [DLSection]) {
        self.sections = sections()
    }
    
    public func onTap(perform action: @escaping (IndexPath) -> Void) -> Self {
        var me = self
        me.storedOnTapAction = action
        return me
    }
    
    public func defaultBackgroundConfiguration(_ configuration: UIBackgroundConfiguration) -> Self {
        var me = self
        me.storedDefaultBackgroundConfiguration = configuration
        return me
    }
    
    public func itemSeparatorHandler(_ handler: @escaping UICollectionLayoutListConfiguration.ItemSeparatorHandler) -> Self {
        var me = self
        me.storedItemSeparatorHandler = handler
        return me
    }
}
