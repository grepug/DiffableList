//
//  List.swift
//  
//
//  Created by Kai on 2022/3/15.
//

import Foundation

public struct DLList {
    public var sections: [DLSection]
    
    var storedOnTapAction: ((IndexPath) -> Void)?
    
    public init(@ListBuilder sections: @escaping () -> [DLSection]) {
        self.sections = sections()
    }
    
    public func onTap(perform action: @escaping (IndexPath) -> Void) -> Self {
        var me = self
        me.storedOnTapAction = action
        
        return me
    }
}
