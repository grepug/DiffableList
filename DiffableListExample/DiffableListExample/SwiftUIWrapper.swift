//
//  SwiftUIWrapperCellConfiguration.swift
//  Vision 3 (iOS)
//
//  Created by Kai on 2022/2/14.
//

import UIKit
import SwiftUI

struct SwiftUIWrapperCellConfiguration<Content: View>: UIContentConfiguration {
    var content: Content
    var parentVC: UIViewController
    
    init(toParentVC parentVC: UIViewController,
         @ViewBuilder content: @escaping () -> Content) {
        self.parentVC = parentVC
        self.content = content()
    }
    
    func makeContentView() -> UIView & UIContentView {
        SwiftUIWrapperCellConfigurationView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> SwiftUIWrapperCellConfiguration {
        self
    }
}

extension SwiftUIWrapperCellConfiguration {
    
}

class SwiftUIWrapperCellConfigurationView<Content: View>: UIView & UIContentView {
    typealias Configuration = SwiftUIWrapperCellConfiguration
    
    private let hostingVC = UIHostingController<Content?>(rootView: nil)
    
    var configuration: UIContentConfiguration {
        didSet {
            applyConfiguration()
        }
    }
    
    init(configuration: Configuration<Content>) {
        self.configuration = configuration
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyConfiguration() {
        let config = configuration as! Configuration<Content>
        let requiringVCMove = hostingVC.parent != config.parentVC
        
        hostingVC.rootView = config.content
        hostingVC.view.invalidateIntrinsicContentSize()
        
        if requiringVCMove {
            config.parentVC.addChild(hostingVC)
        }
        
        if !subviews.contains(hostingVC.view) {
            addSubview(hostingVC.view)
                
            hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingVC.view.topAnchor.constraint(equalTo: topAnchor),
                hostingVC.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                hostingVC.view.bottomAnchor.constraint(equalTo: bottomAnchor),
                hostingVC.view.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
        
        if requiringVCMove {
            hostingVC.didMove(toParent: config.parentVC)
        }
    }
}
