//
//  List.swift
//  
//
//  Created by Kai on 2022/3/15.
//

import Foundation

public struct List {
    public var sections: [Section]
    
    public init(@ListBuilder sections: @escaping () -> [Section]) {
        self.sections = sections()
    }
}
