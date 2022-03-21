//
//  File.swift
//  
//
//  Created by Kai on 2022/3/21.
//

import UIKit

import UIKit

struct SegmentControlCellConfiguration: UIContentConfiguration {
    var items: [String]
    var selectedIndex: Int = 0
    var edgeInsets: UIEdgeInsets = .zero
    var action: (Int) -> Void
    
    func makeContentView() -> UIView & UIContentView {
        View(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}

extension SegmentControlCellConfiguration {
    class View: UIView & UIContentView {
        typealias Config = SegmentControlCellConfiguration
        
        lazy var segmentControl: UISegmentedControl = {
            let config = configuration as! Config
            let control = UISegmentedControl(items: config.items)
            
            control.selectedSegmentIndex = 0
            
            return control
        }()
        
        var configuration: UIContentConfiguration {
            didSet {
                let config = configuration as! Config
                
                apply(config: config)
            }
        }
        
        init(configuration: Config) {
            self.configuration = configuration
            super.init(frame: .zero)
            
            setupViews(config: configuration)
            apply(config: configuration)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension SegmentControlCellConfiguration.View {
    func setupViews(config: Config) {
        addSubview(segmentControl)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: topAnchor, constant: config.edgeInsets.top),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: config.edgeInsets.left),
            segmentControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -config.edgeInsets.bottom),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -config.edgeInsets.right)
        ])
    }
    
    func apply(config: Config) {
        config.items.enumerated().forEach { index, item in
            segmentControl.setTitle(item, forSegmentAt: index)
        }
        
        segmentControl.selectedSegmentIndex = config.selectedIndex
        
        let identifier = UIAction.Identifier("segmentControl")
        
        segmentControl.addAction(.init(identifier: identifier) { action in
            let segmentControl = action.sender as! UISegmentedControl
            config.action(segmentControl.selectedSegmentIndex)
        }, for: .valueChanged)
    }
}

