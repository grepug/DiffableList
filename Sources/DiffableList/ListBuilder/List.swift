//
//  List.swift
//  
//
//  Created by Kai on 2022/3/15.
//

import Foundation

public struct List {
    public var sections: [Section]
    
    var storedOnTapAction: ((IndexPath) -> Void)?
    
    public init(@ListBuilder sections: @escaping () -> [Section]) {
        self.sections = sections()
    }
    
    public func onTap(perform action: @escaping (IndexPath) -> Void) -> Self {
        var me = self
        me.storedOnTapAction = action
        
        return me
    }
}
