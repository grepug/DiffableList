//
//  TextFieldCellConfiguration.swift
//  
//
//  Created by Kai on 2022/3/22.
//

import UIKit

import UIKit

struct TextFieldCellConfiguration: UIContentConfiguration {
    var text: String
    var placeholder: String?
    var font: UIFont?
    var color: UIColor?
    var paddings: UIEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
    var height: CGFloat = 44
    var valueDidChange: ((String) -> Void)?
    var editingDidEnd: ((String) -> Void)?
    
    func makeContentView() -> UIView & UIContentView {
        View(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}

extension TextFieldCellConfiguration {
    class View: UIView & UIContentView {
        typealias Config = TextFieldCellConfiguration
        
        lazy var textField: UITextField = {
            let textField = UITextField()
            
            return textField
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

extension TextFieldCellConfiguration.View {
    func setupViews(config: Config) {
        addSubview(textField)
        
        textField.delegate = self
        textField.addDoneButton()
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: config.paddings.top),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: config.paddings.left),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -config.paddings.bottom),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -config.paddings.right),
            textField.heightAnchor.constraint(equalToConstant: config.height - config.paddings.top - config.paddings.bottom)
        ])
    }
    
    func apply(config: Config) {
        textField.text = config.text
        textField.placeholder = config.placeholder
        
        if let font = config.font {
            textField.font = font
        }
        
        if let color = config.color {
            textField.textColor = color
        }
    }
}

extension TextFieldCellConfiguration.View: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        (configuration as! Config).editingDidEnd?(textField.text ?? "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        (configuration as! Config).valueDidChange?(textField.text ?? "")
        return true
    }
}
