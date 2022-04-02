//
//  File.swift
//  
//
//  Created by Kai on 2022/3/14.
//

import UIKit

@available(iOS 14.5, *)
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
            
            listConfig.itemSeparatorHandler = self.content.storedItemSeparatorHandler
            
            if section.headerText != nil {
                listConfig.headerMode = .supplementary
            } else if section.isFirstCellAsHeader {
                listConfig.headerMode = .firstItemInSection
            }
            
            if section.footerText != nil {
                listConfig.footerMode = .supplementary
            }
            
            if #available(iOS 15.0, *) {
                if let padding = section.storedHeaderTopPadding {
                    listConfig.headerTopPadding = padding
                }
            } else {
                
            }
            
            listConfig.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
                let cellConvertible = self.cellConvertible(at: indexPath)
                
                if let cell = cellConvertible as? DLCell {
                    return .init(actions: cell.storedTrailingSwipeActions ?? [])
                }
                    
                return nil
            }
            
            let layoutSection = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: env)
            
            return layoutSection
        }
    }
}

@available(iOS 14.5, *)
public extension DiffableListView {
    func indexPath<T: Hashable>(forItemIdentifier id: T) -> IndexPath? {
        diffableDataSource.indexPath(for: id.hashValue.description)
    }
    
    func forceReloadData() {
        let snapshot = diffableDataSource.snapshot()
        
        if #available(iOS 15.0, *) {
            diffableDataSource.applySnapshotUsingReloadData(snapshot)
        } else {
        }
    }
}

@available(iOS 14.5, *)
extension DiffableListView {
    func setContent(_ list: DLList, applyingSnapshot: Bool = true,
                    collapsedItemIdentifiers: Set<ItemIdentifier> = [],
                    animating: Bool = true,
                    makingSnapshotsCompletion completion: (() -> Void)? = nil) {
        content = list
        
        if applyingSnapshot {
            applySnapshot(animating: animating,
                          collapsedItemIdentifiers: collapsedItemIdentifiers,
                          makingSnapshotsCompletion: completion)
        }
        
        setupReorderHandler()
    }
    
//    func applySnapshot2() {
//        var snapshot = diffableDataSource.snapshot()
//        snapshot.appendItems(<#T##identifiers: [ItemIdentifier]##[ItemIdentifier]#>, toSection: <#T##SectionIdentifier?#>)
//
//        snapshot.deleteSections(<#T##identifiers: [SectionIdentifier]##[SectionIdentifier]#>)
//    }
    
    func applySnapshot(animating: Bool, collapsedItemIdentifiers: Set<ItemIdentifier>, makingSnapshotsCompletion: (() -> Void)? = nil) {
        var appliedSectionIds = Set<SectionIdentifier>()
        let prevAppliedSectionIds = appliedSnapshotSectionIds
        var snapshots: [(SectionIdentifier, NSDiffableDataSourceSectionSnapshot<ItemIdentifier>)] = []
        
        for section in content.sections {
            var snapshot = diffableDataSource.snapshot(for: section.id)
            snapshot.deleteAll()
            
            for cell in section.cells {
                snapshot.append([cell.id], to: cell.parentId)
                
                if let parentId = cell.parentId {
                    if collapsedItemIdentifiers.contains(parentId) {
                        snapshot.collapse([parentId])
                    } else {
                        snapshot.expand([parentId])
                    }
                }
            }
            
            appliedSectionIds.insert(section.id)
            appliedSnapshotSectionIds.insert(section.id)
            snapshots.append((section.id, snapshot))
        }
        
        let notAppliedSectionIds = prevAppliedSectionIds.subtracting(appliedSectionIds)
        
        for sectionId in notAppliedSectionIds {
            var snapshot = diffableDataSource.snapshot(for: sectionId)
            snapshot.deleteAll()
            
            appliedSnapshotSectionIds.insert(sectionId)
            snapshots.append((sectionId, snapshot))
        }
        
        makingSnapshotsCompletion?()
        
        for (section, snapshot) in snapshots {
            let isFirstAppling = !prevAppliedSectionIds.contains(section)
            let isSnapshotChanged = diffableDataSource.snapshot(for: section).items != snapshot.items
            
            if isFirstAppling || isSnapshotChanged {
                diffableDataSource.apply(snapshot, to: section, animatingDifferences: animating)
            }
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> {
        let cellConfig = makeCellConfig()
        
        return .init(collectionView: self) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellConfig, for: indexPath, item: itemIdentifier)
        }
    }
    
    func setupSupplementaryViewProvider() {
        let headerLabelConfig = makeHeaderLabelSupplementaryViewConfig()
        let footerLabelConfig = makeFooterLabelSupplementaryViewConfig()
        
        diffableDataSource.supplementaryViewProvider = { [unowned self] collectionView, elementKind, indexPath in
            let section = self.section(at: indexPath)
                
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                if section.headerText != nil {
                    return collectionView.dequeueConfiguredReusableSupplementary(using: headerLabelConfig, for: indexPath)
                }
            case UICollectionView.elementKindSectionFooter:
                if section.footerText != nil {
                    return collectionView.dequeueConfiguredReusableSupplementary(using: footerLabelConfig, for: indexPath)
                }
            default: break
            }
            
            return nil
        }
    }
    
    func setupReorderHandler() {
        if let canReorder = content.storedCanReorderHandler {
            diffableDataSource.reorderingHandlers.canReorderItem = { [unowned self] identifier in
                let indexPath = self.diffableDataSource.indexPath(for: identifier)
                
                return canReorder(indexPath, identifier)
            }
        }
        
        if let didRecorder = content.storedDidRecorderHandler {
            diffableDataSource.reorderingHandlers.didReorder = didRecorder
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {

        if originalIndexPath.section == proposedIndexPath.section {
            return proposedIndexPath
        }
        
        return originalIndexPath
    }
    
    func makeCellConfig() -> UICollectionView.CellRegistration<UICollectionViewListCell, ItemIdentifier> {
        .init { [unowned self] cell, indexPath, itemIdentifier in
            guard let cellConvertible = self.cellConvertible(at: indexPath) else {
                fatalError()
            }
            
            guard cellConvertible.id == itemIdentifier else {
                print("@@ cellConvertible inconsistant", indexPath)
                
                fatalError()
            }
            
            if let backgroundConfiguration = content.storedDefaultBackgroundConfiguration {
                cell.backgroundConfiguration = backgroundConfiguration
            }
            
            if let theCell = cellConvertible as? DLCell {
                cell.accessories = theCell.storedAccessories
                
                if let backgroundConfiguration = theCell.storedBackgroundConfiguration {
                    cell.backgroundConfiguration = backgroundConfiguration
                }
                
                if let level = theCell.storedIndentLevel {
                    cell.indentationLevel = level
                }
            }
            
            cell.contentConfiguration = cellConvertible.configuration
        }
    }
    
    func makeHeaderLabelSupplementaryViewConfig() -> UICollectionView.SupplementaryRegistration<LabelResuableView> {
        .init(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] supplementaryView, elementKind, indexPath in
            let section = self.section(at: indexPath)
            
            supplementaryView.config(text: section.headerText!)
        }
    }
    
    func makeFooterLabelSupplementaryViewConfig() -> UICollectionView.SupplementaryRegistration<LabelResuableView> {
        .init(elementKind: UICollectionView.elementKindSectionFooter) { [unowned self] supplementaryView, elementKind, indexPath in
            let section = self.section(at: indexPath)
            
            supplementaryView.config(text: section.footerText!)
        }
    }
    
    func cellConvertible(at indexPath: IndexPath) -> CellConvertible? {
        content.sections.at(indexPath.section)?.cells.at(indexPath.item)
    }
    
    func section(at indexPath: IndexPath) -> DLSection {
        content.sections[indexPath.section]
    }
    
    func itemExpanded(_ id: ItemIdentifier, at indexPath: IndexPath) -> Bool {
        let sectionId = section(at: indexPath).id
        let snapshot = diffableDataSource.snapshot(for: sectionId)
        
        return snapshot.isExpanded(id)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellConvertible = cellConvertible(at: indexPath)!
        
        if let cell = cellConvertible as? DLCell {
            cell.storedDidSelectedAction?(indexPath)
        }
        
        content.storedOnTapAction?(indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let cellConvertible = cellConvertible(at: indexPath)!
        
        if let cell = cellConvertible as? DLCell {
            return cell.storedContextMenu
        }

        return nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cellConvertible = cellConvertible(at: indexPath)
        
        if let cell = cellConvertible as? DLCell, let disabled = cell.storedDisablingHighlight {
            return !disabled
        }
        
        return true
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

extension Array {
    func at(_ index: Int) -> Element? {
        if count > index && index >= 0 {
            return self[index]
        }
        
        return nil
    }
}
