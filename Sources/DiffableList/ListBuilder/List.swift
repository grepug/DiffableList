//
//  List.swift
//  
//
//  Created by Kai on 2022/3/15.
//

import UIKit

public struct DLList {
    public var sections: [DLSection]
    
    var storedAppearance: UICollectionLayoutListConfiguration.Appearance = .insetGrouped
    var storedOnTapAction: ((IndexPath) -> Void)?
    var storedDefaultBackgroundConfiguration: UIBackgroundConfiguration?
    var storedHideBottomSeparator: Bool = false
    var storedCanReorderHandler: ((IndexPath?, ItemIdentifier) -> Bool)?
    var storedDidRecorderHandler: ((NSDiffableDataSourceTransaction<SectionIdentifier, ItemIdentifier>) -> Void)?
    
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
    
    public func hideBottomSeparator(_ isTrue: Bool = true) -> Self {
        var me = self
        me.storedHideBottomSeparator = isTrue
        return me
    }
    
    public func canReorder(_ handler: @escaping (IndexPath?, ItemIdentifier) -> Bool) -> Self {
        var me = self
        me.storedCanReorderHandler = handler
        return me
    }
    
    public func didRecorder(_ handler: @escaping (NSDiffableDataSourceTransaction<SectionIdentifier, ItemIdentifier>) -> Void) -> Self {
        var me = self
        me.storedDidRecorderHandler = handler
        return me
    }
    
    public func appearance(_ appearance: UICollectionLayoutListConfiguration.Appearance) -> Self {
        var me = self
        me.storedAppearance = appearance
        return me
    }
}
