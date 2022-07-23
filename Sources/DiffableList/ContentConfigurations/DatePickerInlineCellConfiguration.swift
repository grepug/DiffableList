//
//  File.swift
//  
//
//  Created by Kai on 2022/4/1.
//

import UIKit

struct DatePickerInlineCellConfiguration: UIContentConfiguration {
    var date: Date
    var text: String
    var mode: UIDatePicker.Mode = .dateAndTime
    var action: ((Date) -> Void)?
    
    func makeContentView() -> UIView & UIContentView {
        View(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> DatePickerInlineCellConfiguration {
        self
    }
}

extension DatePickerInlineCellConfiguration {
    class View: UIView & UIContentView {
        typealias Config = DatePickerInlineCellConfiguration
        
        var configuration: UIContentConfiguration {
            get {
                currentConfiguration
            }
            
            set {
                let config = newValue as! Config
                
                apply(config: config)
            }
        }
        
        var currentConfiguration: Config
        
        lazy var datePicker = UIDatePicker()
        lazy var label = UILabel()
        
        init(configuration: Config) {
            self.currentConfiguration = configuration
            super.init(frame: .zero)
            
            setupViews(config: configuration)
            apply(config: configuration)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

private extension DatePickerInlineCellConfiguration.View {
    func setupViews(config: Config) {
        let container = UIStackView()
        addSubview(container)
        
        container.axis = .horizontal
        container.addArrangedSubview(label)
        container.addArrangedSubview(datePicker)
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = config.mode
        datePicker.addAction(.init { action in
            let sender = action.sender as! UIDatePicker
                
            config.action?(sender.date)
        }, for: .valueChanged)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func apply(config: Config) {
        currentConfiguration = config
        datePicker.date = config.date
        datePicker.datePickerMode = config.mode
        label.text = config.text
    }
}
