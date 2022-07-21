//
//  ToggleCellConfiguration.swift
//  
//
//  Created by Kai on 2022/7/21.
//

import UIKit
import SwiftUI

public extension DLContentConfiguration {
    static func toggle<Object: ObservableObject>(movingTo parentVC: @escaping @autoclosure () -> UIViewController, object: Object, isOn: ReferenceWritableKeyPath<Object, Bool>, text: LocalizedStringKey, handler: @escaping (Bool) -> Bool) -> DLContentConfiguration {
        return .swiftUI(movingTo: parentVC()) {
            ToggleView(object: object, isOn: isOn, text: text, vc: parentVC, handler: handler)
        }
    }
    
    private struct ToggleView<Object: ObservableObject>: View {
        @ObservedObject var object: Object
        var isOn: ReferenceWritableKeyPath<Object, Bool>
        var text: LocalizedStringKey = "action_enable"
        var vc: () -> UIViewController
        var handler: (Bool) -> Bool
        
        var body: some View {
            let isOnBinding = Binding<Bool> {
                object[keyPath: isOn]
            } set: {
                object[keyPath: isOn] = $0
            }
            
            HStack {
                Text(text)
                Spacer()
                Toggle("", isOn: isOnBinding.intercepted(handler))
            }
            .padding(.horizontal)
            .frame(height: 44)
        }
    }
}

extension Binding {
    func intercepted(_ handler: @escaping (Value) -> Bool) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                if handler(newValue) {
                    self.wrappedValue = newValue
                }
            }
        )
    }
}
