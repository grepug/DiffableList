//
//  ContentConfigurations+Utils.swift
//  
//
//  Created by Kai on 2022/3/21.
//

import UIKit
import SwiftUI

public struct DLContentConfiguration {
    let contentConfiguration: UIContentConfiguration
}

public extension DLContentConfiguration {
    static func swiftUI<Content: View>(movingTo parent: @autoclosure @escaping () -> UIViewController, @ViewBuilder content: @escaping () -> Content ) -> Self {
        .init(contentConfiguration: SwiftUIWrapperCellConfiguration(toParentVC: parent(), content: content))
    }
    
    static func header(_ title: String, using config: UIListContentConfiguration = .compactibleProminentInsetGroupedHeader()) -> Self {
        var config = config
        config.text = title
        
        return .init(contentConfiguration: config)
    }
    
    static func footer(_ title: String, using config: UIListContentConfiguration = .groupedFooter()) -> Self {
        var config = config
        config.text = title
        
        return .init(contentConfiguration: config)
    }
    
    static func segmentControl(items: [String], selectedIndex: Int, paddings: UIEdgeInsets? = nil, action: @escaping (Int) -> Void) -> Self {
        let config = SegmentControlCellConfiguration(items: items,
                                                     selectedIndex: selectedIndex,
                                                     edgeInsets: paddings ?? .init(top: 16, left: 0, bottom: 16, right: 0),
                                                     action: action)
        
        return .init(contentConfiguration: config)
    }
}

