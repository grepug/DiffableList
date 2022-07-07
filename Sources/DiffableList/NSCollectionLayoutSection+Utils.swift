//
//  File.swift
//  
//
//  Created by Kai on 2022/6/17.
//

import UIKit

public extension NSCollectionLayoutSection {
    static var empty: NSCollectionLayoutSection {
        NSCollectionLayoutSection(group: .horizontal(layoutSize: .init(widthDimension: .absolute(0.01), heightDimension: .absolute(0.01)), subitem: .init(layoutSize: .init(widthDimension: .absolute(0.01), heightDimension: .absolute(0.01))), count: 1))
    }
    
    static func singleColumn(height: NSCollectionLayoutDimension,
                             sectionInsets: NSDirectionalEdgeInsets = .zero) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: height), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInsets
        
        return section
    }
    
    static func listWithSupplymentaryFooter(env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.footerMode = .supplementary
        let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: env)
        
        return section
    }
}
