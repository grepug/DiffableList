//
//  SwiftUIWrapperCellConfiguration.swift
//  Vision 3 (iOS)
//
//  Created by Kai on 2022/2/14.
//

import UIKit
import SwiftUI

public struct SwiftUIWrapperCellConfiguration<Content: View>: UIContentConfiguration {
    var content: Content
    var parentVC: () -> UIViewController
    
    public init(toParentVC parentVC: @autoclosure @escaping () -> UIViewController,
         @ViewBuilder content: @escaping () -> Content) {
        self.parentVC = parentVC
        self.content = content()
    }
    
    public func makeContentView() -> UIView & UIContentView {
        SwiftUIWrapperCellConfigurationView(configuration: self)
    }
    
    public func updated(for state: UIConfigurationState) -> SwiftUIWrapperCellConfiguration {
        self
    }
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
        
        applyConfiguration()
    }
    
    deinit {
        print("deinit", "wrapper")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyConfiguration() {
        let config = configuration as! Configuration<Content>
        let parentVC = config.parentVC()
        let requiringVCMove = hostingVC.parent != parentVC
        
        hostingVC.rootView = config.content
        hostingVC.view.backgroundColor = .clear
        hostingVC.view.clipsToBounds = true
        hostingVC.view.invalidateIntrinsicContentSize()
        
        if requiringVCMove {
            parentVC.addChild(hostingVC)
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
            hostingVC.didMove(toParent: parentVC)
        }
    }
}
