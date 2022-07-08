//
//  File.swift
//  
//
//  Created by Kai on 2022/3/14.
//

import UIKit

public class DiffableListView: UICollectionView, UICollectionViewDelegate {
    public lazy var diffableDataSource = makeDataSource()
    private(set) var content: DLList = DLList {}
    var prevContent: DLList = DLList {}
    var currentApplyingSection: SectionIdentifier?
    
    unowned var sectionProviderWrapper: SectionProviderWrapper
    var appliedSnapshotSectionIds = Set<SectionIdentifier>()
    public var customSectionProvider: UICollectionViewCompositionalLayoutSectionProvider?
    
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
            let section = content.sections[sectionIndex]
            
            guard !section.cells.isEmpty else {
                return .empty
            }
            
            if let customSectionProvider = customSectionProvider {
                if let section = customSectionProvider(sectionIndex, env) {
                    return section
                }
            }
            
            if let section = section.storedLayout?(env) {
                return section
            }
            
            var listConfig = UICollectionLayoutListConfiguration(appearance: content.storedAppearance)
            
            if #available(iOS 14.5, *), content.storedHideBottomSeparator {
                listConfig.itemSeparatorHandler = { indexPath, config in
                    var config = config
                    config.bottomSeparatorVisibility = .hidden
                    
                    return config
                }
            }
            
            if section.headerText != nil {
                listConfig.headerMode = .supplementary
            } else if section.isFirstCellAsHeader {
                listConfig.headerMode = .firstItemInSection
            }
            
            if section.footerText != nil {
                listConfig.footerMode = .supplementary
            }
            
            if let listBgColor = section.storedListBackgroundColor {
                listConfig.backgroundColor = listBgColor
            }
            
            if #available(iOS 15.0, *) {
                if let padding = section.storedHeaderTopPadding {
                    listConfig.headerTopPadding = padding
                }
            }
            
            listConfig.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
                let cellConvertible = cellConvertible(at: indexPath)
                
                if let cell = cellConvertible as? DLCell {
                    return .init(actions: cell.storedTrailingSwipeActions ?? [])
                }
                    
                return nil
            }
            
            listConfig.leadingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
                let cellConvertible = cellConvertible(at: indexPath)
                
                if let cell = cellConvertible as? DLCell {
                    return .init(actions: cell.storedLeadingSwipeActions ?? [])
                }
                    
                return nil
            }
            
            if let mutatingListConfig = section.storedMutatingListConfig,
               let mutatedListConfig = mutatingListConfig(listConfig) {
                listConfig = mutatedListConfig
            }
            
            let layoutSection = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: env)
            
            return layoutSection
        }
    }
}

public extension DiffableListView {
    func indexPath<T: Hashable>(forItemIdentifier id: T) -> IndexPath? {
        diffableDataSource.indexPath(for: id.itemIdentifier)
    }
    
    func forceReloadData() {
        let snapshot = diffableDataSource.snapshot()
        
        if #available(iOS 15.0, *) {
            diffableDataSource.applySnapshotUsingReloadData(snapshot)
        } else {
        }
    }
}

extension DiffableListView {
    func setContent(_ list: DLList, applyingSnapshot: Bool = true,
                    collapsedItemIdentifiers: Set<ItemIdentifier> = [],
                    animating: Bool = true,
                    makingSnapshotsCompletion completion: (() -> Void)? = nil) {
        if #unavailable(iOS 15.0) {
            if applyingSnapshot {
                prevContent = content
            }
        }
        
        content = list

        if applyingSnapshot {
            applySnapshot(animating: animating,
                          collapsedItemIdentifiers: collapsedItemIdentifiers,
                          makingSnapshotsCompletion: completion)
        }
        
        setupReorderHandler()
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
        let headerContentViewConfig = makeHeaderLabelSupplementaryContentViewConfig()
        let footerContentViewConfig = makeFooterLabelSupplementaryContentViewConfig(kind: UICollectionView.elementKindSectionFooter)
        let footerContentViewConfig2 = makeFooterLabelSupplementaryContentViewConfig(kind: DiffableListView.reusableContentViewFooterKind)
        
        diffableDataSource.supplementaryViewProvider = { [unowned self] collectionView, elementKind, indexPath in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerLabelConfig, for: indexPath)
            case UICollectionView.elementKindSectionFooter:
                if content.sections[indexPath.section].footerContentConfiguration == nil {
                    return collectionView.dequeueConfiguredReusableSupplementary(using: footerLabelConfig, for: indexPath)
                }
                
                return collectionView.dequeueConfiguredReusableSupplementary(using: footerContentViewConfig, for: indexPath)
            case DiffableListView.reusableContentViewHeaderKind:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerContentViewConfig, for: indexPath)
            case DiffableListView.reusableContentViewFooterKind:
                return collectionView.dequeueConfiguredReusableSupplementary(using: footerContentViewConfig2, for: indexPath)
            default: break
            }
            
            return nil
        }
    }
    
    func setupReorderHandler() {
        if let canReorder = content.storedCanReorderHandler {
            diffableDataSource.reorderingHandlers.canReorderItem = { [unowned self] identifier in
                guard parentViewController?.isEditing == true else {
                    return false
                }
                
                let indexPath = self.diffableDataSource.indexPath(for: identifier)
                
                return canReorder(indexPath, identifier)
            }
        }
        
        if let didRecorder = content.storedDidRecorderHandler {
            diffableDataSource.reorderingHandlers.willReorder = didRecorder
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        /// 如果第一个 cell 是 header，则不允许
        if proposedIndexPath.item == 0 && content.sections[proposedIndexPath.section].isFirstCellAsHeader {
            return originalIndexPath
        }

        if originalIndexPath.section != proposedIndexPath.section {
            return originalIndexPath
        }
        
        return proposedIndexPath
    }
    
    func makeCellConfig() -> UICollectionView.CellRegistration<UICollectionViewListCell, ItemIdentifier> {
        .init { [unowned self] cell, indexPath, itemIdentifier in
            guard let cellConvertible = cellConvertible(at: indexPath) else {
                logger.fault("""
                    cellConvertible indexPath not valid
                    at: \(String(describing: self.parentViewController), privacy: .public)
                """)
                
//                if #available(iOS 15, *) {
//                    collectLogsBeforeTermination()
//
//                    return
//                } else {
                    fatalError()
//                }
            }
            
            guard cellConvertible.id == itemIdentifier else {
                let sections: [[String]] = content.sections.map { section in
                    section.cells.map { cell in
                        """
                        id: \(cell.id)
                        name: \(cell.name ?? "<No Name>")
                        parentId: \(cell.parentId ?? "<No Parent>")
                        itemTitle: \(cell.itemTitle ?? "<No Item Title>")
                        """
                    }
                }
                
                logger.fault("""
                    cellConvertible inconsistant
                    at: \(String(describing: self.parentViewController), privacy: .public)
                    name: \(cellConvertible.name ?? "<No Name>", privacy: .public)
                    id: \(cellConvertible.id, privacy: .public)
                    sectionCount: \(self.content.sections.count, privacy: .public)
                    details: \(sections.description, privacy: .public)
                """)

//                if #available(iOS 15, *) {
//                    collectLogsBeforeTermination()
//
//                    return
//                } else {
                    fatalError()
//                }
            }
            
            let content = currentContent(at: indexPath)
            
            if let backgroundConfiguration = content.storedDefaultBackgroundConfiguration {
                cell.backgroundConfiguration = backgroundConfiguration
            }
            
            if let theCell = cellConvertible as? DLCell {
                cell.accessories = theCell.storedAccessories.compactMap { $0 }
                
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
    
    func makeHeaderLabelSupplementaryContentViewConfig() -> UICollectionView.SupplementaryRegistration<ReusableContentView> {
        .init(elementKind: DiffableListView.reusableContentViewHeaderKind) { [unowned self] supplementaryView, elementKind, indexPath in
            let section = section(at: indexPath)
            
            supplementaryView.contentConfiguration = section.headerContentConfiguration?.contentConfiguration
        }
    }
    
    func makeFooterLabelSupplementaryContentViewConfig(kind: String) -> UICollectionView.SupplementaryRegistration<ReusableContentView> {
        .init(elementKind: kind) { [unowned self] supplementaryView, elementKind, indexPath in
            let section = section(at: indexPath)
            
            supplementaryView.contentConfiguration = section.footerContentConfiguration?.contentConfiguration
        }
    }
    
    func makeFooterLabelSupplementaryViewConfig() -> UICollectionView.SupplementaryRegistration<LabelResuableView> {
        .init(elementKind: UICollectionView.elementKindSectionFooter) { [unowned self] supplementaryView, elementKind, indexPath in
            let section = self.section(at: indexPath)
            
            supplementaryView.config(text: section.footerText!)
        }
    }
    
    func indexForSection(_ section: SectionIdentifier) -> Int {
        let sectionCount = content.sections.count
        
        for index in 0..<sectionCount {
            if content.sections[index].id == section {
                return index
            }
        }
        
        return 0
    }
    
    func currentContent(at indexPath: IndexPath) -> DLList {
        if #unavailable(iOS 15.0) {
            if let section = currentApplyingSection,
               indexForSection(section) < indexPath.section &&
                !prevContent.sections.isEmpty {
                return prevContent
            }
        }
        
        return content
    }
    
    func cellConvertible(at indexPath: IndexPath) -> CellConvertible? {
        currentContent(at: indexPath).sections.at(indexPath.section)?.cells.at(indexPath.item)
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
        
        if let firstResponder = firstResponder {
            firstResponder.resignFirstResponder()
        }
        
        if let cell = cellConvertible as? DLCell {
            if let action = cell.storedDidSelectedAndDeselectAction {
                action(indexPath)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    collectionView.deselectItem(at: indexPath, animated: true)
                }
            } else if let action = cell.storedDidSelectedAction {
                action(indexPath)
            }
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
        
        if let cell = cellConvertible as? DLCell {
            if let disabled = cell.storedDisablingHighlight {
                return !disabled
            }
            
            if cell.storedDidSelectedAction != nil ||
                cell.storedDidSelectedAndDeselectAction != nil {
                return true
            }
            
            return false
        }
        
        return true
    }
}

class SectionProviderWrapper {
    var sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { _, _ in
        nil
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
