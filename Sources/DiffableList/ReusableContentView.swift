//
//  ReusableContentView.swift
//  
//
//  Created by Kai on 2022/5/26.
//

import UIKit

class ReusableContentView: UICollectionReusableView {
    var contentView: UIView
    var contentConfiguration: UIContentConfiguration? {
        didSet {
            config()
        }
    }
    
    override init(frame: CGRect) {
        contentView = .init(frame: frame)
        super.init(frame: frame)
        
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func config() {
        guard let contentConfiguration = contentConfiguration else {
            return
        }
        
        contentView.removeFromSuperview()
        
        let newView = contentConfiguration.makeContentView()
        addSubview(newView)
        
        newView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: topAnchor),
            newView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newView.bottomAnchor.constraint(equalTo: bottomAnchor),
            newView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        contentView = newView
    }
}

public extension DiffableListView {
    static var reusableContentViewKind: String {
        "ReusableContentViewKind"
    }
}
