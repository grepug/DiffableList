//
//  File.swift
//  
//
//  Created by Kai on 2022/5/9.
//

import UIKit

public extension UICellAccessory {
    static func menuButton(menu: UIMenu, image: UIImage? = .init(systemName: "ellipsis")) -> UICellAccessory {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.menu = menu
        button.sizeToFit()
        
        return .customView(configuration: .init(customView: button,
                                                placement: .trailing(displayed: .always),
                                                maintainsFixedSize: true))
    }
    
    static func imageButton(image: UIImage, tintColor: UIColor? = nil, action: @escaping () -> Void) -> UICellAccessory {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.sizeToFit()
        button.addAction(.init { _ in
            action()
        }, for: .touchUpInside)
        
        return .customView(configuration: .init(customView: button,
                                                placement: .trailing(displayed: .always),
                                                tintColor: tintColor,
                                                maintainsFixedSize: true))
    }
    
    static func label(_ text: String,
                      placement: UICellAccessory.Placement = .trailing(displayed: .always),
                      color: UIColor? = .secondaryLabel,
                      font: UIFont = .systemFont(ofSize: UIFont.labelFontSize)) -> UICellAccessory {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = font
        
        return .customView(configuration: .init(customView: label,
                                                placement: placement))
    }
    
    static func image(_ uiImage: UIImage,
                      placement: UICellAccessory.Placement = .trailing(displayed: .always)) -> UICellAccessory {
        let imageView = UIImageView(image: uiImage)
        
        return .customView(configuration: .init(customView: imageView,
                                                placement: placement))
    }
    
    static func toggle(isOn: Bool, placement: UICellAccessory.Placement = .trailing(displayed: .always), action: @escaping (Bool) -> Void) -> UICellAccessory {
        let toggleView = UISwitch()
        
        toggleView.isOn = isOn
        
        toggleView.addAction(.init { _ in
            action(toggleView.isOn)
        }, for: .valueChanged)
        
        return .customView(configuration: .init(customView: toggleView,
                                                placement: placement))
    }
    
    static func progressIndicator() -> UICellAccessory {
        let progressView = UIActivityIndicatorView()
        progressView.startAnimating()
        
        return .customView(configuration: .init(customView: progressView, placement: .trailing(displayed: .always)))
    }
}
