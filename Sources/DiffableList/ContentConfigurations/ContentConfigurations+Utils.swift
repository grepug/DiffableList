//
//  ContentConfigurations+Utils.swift
//  
//
//  Created by Kai on 2022/3/21.
//

import UIKit
import SwiftUI

public struct DLContentConfiguration {
    public init(contentConfiguration: UIContentConfiguration) {
        self.contentConfiguration = contentConfiguration
    }
    
    public let id = UUID()
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
    
    static func textField(text: String, placeholder: String? = nil, font: UIFont? = nil, color: UIColor? = nil, keyboardType: UIKeyboardType = .default, paddings: UIEdgeInsets? = nil, height: CGFloat = 44, valueDidChange: ((String) -> Void)? = nil, editingDidEnd: ((String) -> Void)? = nil) -> Self {
        let config = TextFieldCellConfiguration(text: text,
                                                placeholder: placeholder,
                                                font: font,
                                                color: color,
                                                keyboard: keyboardType,
                                                paddings: paddings ?? .init(top: 8, left: 16, bottom: 8, right: 16),
                                                height: height,
                                                valueDidChange: valueDidChange,
                                                editingDidEnd: editingDidEnd)
        return .init(contentConfiguration: config)
    }
    
    static func datePicker(labelText: String, date: Date, mode: UIDatePicker.Mode = .date, valueDidChange: ((Date) -> Void)? = nil) -> Self {
        let config = DatePickerInlineCellConfiguration(date: date, text: labelText, mode: mode, action: valueDidChange)
        
        return .init(contentConfiguration: config)
    }
}

