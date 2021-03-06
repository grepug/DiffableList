//
//  FooterResuableView.swift
//  
//
//  Created by Kai on 2022/3/21.
//

import UIKit

class LabelResuableView: UICollectionReusableView {
    private lazy var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(text: String, uppercased: Bool = false) {
        label.text = uppercased ? text.uppercased() : text
    }
}
