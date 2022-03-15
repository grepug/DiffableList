//
//  File.swift
//  
//
//  Created by Kai on 2022/3/14.
//

import UIKit

public class DiffableListView: UICollectionView, UICollectionViewDelegate {
    lazy var diffableDataSource = makeDataSource()
    public var content: List = List {} {
        didSet {
            applySnapshot()
        }
    }
    
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

extension DiffableListView {
    func applySnapshot() {
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
            
            diffableDataSource.apply(snapshot, to: section.id)
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
            } else if let theCell = cellConvertible as? HeaderCell {
                cell.accessories = [.outlineDisclosure()]
            }
        }
    }
}

class SectionProviderWrapper {
    var sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { _, _ in
        nil
    }
}
