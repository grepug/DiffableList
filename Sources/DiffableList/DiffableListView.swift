//
//  File.swift
//  
//
//  Created by Kai on 2022/3/14.
//

import UIKit

public class DiffableListView: UICollectionView, UICollectionViewDelegate {
    public lazy var diffableDataSource = makeDataSource()
    var content: DLList = DLList {}
    
    private unowned var sectionProviderWrapper: SectionProviderWrapper
    private var appliedSnapshotSectionIds = Set<SectionIdentifier>()
    
    public init(frame: CGRect) {
        let sectionProviderWrapper = SectionProviderWrapper()
        let layout = UICollectionViewCompositionalLayout { sectionIndex, env in
            sectionProviderWrapper.sectionProvider(sectionIndex, env)
        }
        self.sectionProviderWrapper = sectionProviderWrapper
        
        super.init(frame: frame, collectionViewLayout: layout)
        
        delegate = self
        
        setupLayout()
        setupSupplementaryViewProvider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        sectionProviderWrapper.sectionProvider = { [unowned self] sectionIndex, env in
            let section = self.content.sections[sectionIndex]
            
            guard !section.cells.isEmpty else {
                return .empty
            }
            
            var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            
            if section._supplementaryTypes.contains(.header) {
                listConfig.headerMode = .firstItemInSection
            }
            
            if section._supplementaryTypes.contains(.footer) {
                listConfig.footerMode = .supplementary
            }
            
            listConfig.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
                let cellConvertible = self.cellConvertible(at: indexPath)
                
                if let cell = cellConvertible as? DLCell {
                    return .init(actions: cell.storedTrailingSwipeActions ?? [])
                }
                    
                return nil
            }
            
            return .list(using: listConfig, layoutEnvironment: env)
        }
    }
}

public extension DiffableListView {
    func setContent(_ list: DLList, animating: Bool = true) {
        content = list
        applySnapshot(animating: animating)
    }
    
    func indexPath<T: Hashable>(forItemIdentifier id: T) -> IndexPath? {
        diffableDataSource.indexPath(for: id.hashValue.description)
    }
}

extension DiffableListView {
    func applySnapshot(animating: Bool) {
        var appliedSectionIds = Set<SectionIdentifier>()
        let prevAppliedSectionIds = appliedSnapshotSectionIds
        
        for section in content.sections {
            var snapshot = diffableDataSource.snapshot(for: section.id)
            snapshot.deleteAll()
            
            for cell in section.cells {
                snapshot.append([cell.id], to: cell.parentId)
                
                if let parentId = cell.parentId {
                    snapshot.expand([parentId])
                }
            }
            
            appliedSectionIds.insert(section.id)
            appliedSnapshotSectionIds.insert(section.id)
            diffableDataSource.apply(snapshot, to: section.id, animatingDifferences: animating)
        }
        
        let notAppliedSectionIds = prevAppliedSectionIds.subtracting(appliedSectionIds)
        
        for sectionId in notAppliedSectionIds {
            var snapshot = diffableDataSource.snapshot(for: sectionId)
            snapshot.deleteAll()
            
            appliedSnapshotSectionIds.insert(sectionId)
            diffableDataSource.apply(snapshot, to: sectionId, animatingDifferences: animating)
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> {
        let cellConfig = makeCellConfig()
        
        return .init(collectionView: self) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellConfig, for: indexPath, item: itemIdentifier)
        }
    }
    
    func setupSupplementaryViewProvider() {
        let footerConfig = makeFooterSupplementaryViewConfig()
        
        diffableDataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: footerConfig,
                                                                  for: indexPath)
        }
    }
    
    func makeCellConfig() -> UICollectionView.CellRegistration<UICollectionViewListCell, ItemIdentifier> {
        .init { [unowned self] cell, indexPath, itemIdentifier in
            let cellConvertible = self.content.sections[indexPath.section].cells[indexPath.item]
            
            guard cellConvertible.id == itemIdentifier else {
                fatalError()
            }
            
            cell.contentConfiguration = cellConvertible.configuration
            
            if let theCell = cellConvertible as? DLCell {
                cell.accessories = theCell.storedAccessories
            }
        }
    }
    
    func makeFooterSupplementaryViewConfig() -> UICollectionView.SupplementaryRegistration<UICollectionReusableView> {
        .init(elementKind: UICollectionView.elementKindSectionFooter) { supplementaryView, elementKind, indexPath in
            
        }
    }
    
    func cellConvertible(at indexPath: IndexPath) -> CellConvertible {
        content.sections[indexPath.section].cells[indexPath.item]
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellConvertible = cellConvertible(at: indexPath)
        
        if let cell = cellConvertible as? DLCell {
            cell.storedDidSelectedAction?(indexPath)
        }
        
        content.storedOnTapAction?(indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let cellConvertible = cellConvertible(at: indexPath)
        
        if let cell = cellConvertible as? DLCell {
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

extension NSCollectionLayoutSection {
    static var empty: NSCollectionLayoutSection {
        NSCollectionLayoutSection(group: .horizontal(layoutSize: .init(widthDimension: .absolute(0.01), heightDimension: .absolute(0.01)), subitem: .init(layoutSize: .init(widthDimension: .absolute(0.01), heightDimension: .absolute(0.01))), count: 1))
    }
}
