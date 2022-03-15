//
//  File.swift
//  
//
//  Created by Kai on 2022/3/14.
//

import UIKit

public class DiffableListView: UICollectionView, UICollectionViewDelegate {
    lazy var diffableDataSource = makeDataSource()
    var content: List = List {}
    
    private unowned var sectionProviderWrapper: SectionProviderWrapper
    
    public init(frame: CGRect) {
        let sectionProviderWrapper = SectionProviderWrapper()
        let layout = UICollectionViewCompositionalLayout { sectionIndex, env in
            sectionProviderWrapper.sectionProvider(sectionIndex, env)
        }
        self.sectionProviderWrapper = sectionProviderWrapper
        
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        sectionProviderWrapper.sectionProvider = { sectionIndex, env in
            var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            listConfig.headerMode = .firstItemInSection
            
            return .list(using: listConfig, layoutEnvironment: env)
        }
    }
}

public extension DiffableListView {
    func setContent(_ list: List, animating: Bool = true) {
        content = list
        applySnapshot(animating: animating)
    }
}

extension DiffableListView {
    func applySnapshot(animating: Bool) {
        for section in content.sections {
            var snapshot = diffableDataSource.snapshot(for: section.id)
            snapshot.deleteAll()
            var headerId: ItemIdentifier?
            
            for cell in section.cells {
                if let cell = cell as? HeaderCell {
                    headerId = cell.id
                    snapshot.append([cell.id])
                } else {
                    snapshot.append([cell.id], to: headerId)
                    
                    if let headerId = headerId {
                        snapshot.expand([headerId])
                    }
                }
            }
            
            diffableDataSource.apply(snapshot, to: section.id, animatingDifferences: animating)
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> {
        let cellConfig = makeCellConfig()
        
        return .init(collectionView: self) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellConfig, for: indexPath, item: itemIdentifier)
        }
    }
    
    func makeCellConfig() -> UICollectionView.CellRegistration<UICollectionViewListCell, ItemIdentifier> {
        .init { [unowned self] cell, indexPath, itemIdentifier in
            let cellConvertible = self.content.sections[indexPath.section].cells[indexPath.item]
            
            guard cellConvertible.id == itemIdentifier else {
                fatalError()
            }
            
            cell.contentConfiguration = cellConvertible.configuration
            
            if let theCell = cellConvertible as? Cell {
                cell.accessories = theCell.storedAccessories
            } else if let _ = cellConvertible as? HeaderCell {
                cell.accessories = [.outlineDisclosure()]
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellConvertible = content.sections[indexPath.section].cells[indexPath.item]
        
        if let cell = cellConvertible as? Cell {
            cell.storedDidSelectedAction?()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let cellConvertible = content.sections[indexPath.section].cells[indexPath.item]
        
        if let cell = cellConvertible as? Cell {
            return cell.storedContextMenu
        }

        return nil
    }
}

class SectionProviderWrapper {
    var sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { _, _ in
        nil
    }
}
