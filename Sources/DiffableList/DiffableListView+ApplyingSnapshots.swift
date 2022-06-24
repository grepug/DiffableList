//
//  File.swift
//  
//
//  Created by Kai on 2022/6/24.
//

import UIKit

extension DiffableListView {
    func applySnapshot(animating: Bool, collapsedItemIdentifiers: Set<ItemIdentifier>, makingSnapshotsCompletion: (() -> Void)? = nil) {
        var currentAppliedSectionIds = Set<SectionIdentifier>()
        let prevAppliedSectionIds = appliedSnapshotSectionIds
        var snapshots: [(SectionIdentifier, NSDiffableDataSourceSectionSnapshot<ItemIdentifier>)] = []
        
        logger.debug("content.sections count \(self.content.sections.count)")
        
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
            
            currentAppliedSectionIds.insert(section.id)
            snapshots.append((section.id, snapshot))
        }
        
        appliedSnapshotSectionIds = currentAppliedSectionIds
        
        let notAppliedSectionIds = prevAppliedSectionIds.subtracting(currentAppliedSectionIds)
        let newSectionIds = currentAppliedSectionIds.subtracting(prevAppliedSectionIds)
        
        var snapshot = diffableDataSource.snapshot()
        
        logger.debug("prevAppliedSectionIds \(prevAppliedSectionIds.description, privacy: .public)")
        logger.debug("currentAppliedSectionIds \(currentAppliedSectionIds.description, privacy: .public)")
        logger.debug("newSectionIds \(newSectionIds.description, privacy: .public)")
        logger.debug("deleting sections \(notAppliedSectionIds.description, privacy: .public)")
        
        var sectionIdsToDelete = notAppliedSectionIds
        
        if !newSectionIds.isEmpty {
            sectionIdsToDelete.formUnion(currentAppliedSectionIds)
        }
        
        if !sectionIdsToDelete.isEmpty {
            snapshot.deleteSections(Array(sectionIdsToDelete))
        }
        
        makingSnapshotsCompletion?()

        if !sectionIdsToDelete.isEmpty {
            diffableDataSource.apply(snapshot, animatingDifferences: animating)
        }
        
        for (section, snapshot) in snapshots {
            let isFirstAppling = !prevAppliedSectionIds.contains(section)
            let prevSnapshot = diffableDataSource.snapshot(for: section)
            let isSnapshotChanged = snapshotsAreChanged(prev: prevSnapshot, current: snapshot)
            
            if isFirstAppling || isSnapshotChanged {
                currentApplyingSection = section
                
                logger.log("""
                    before applying changes with section: \(section, privacy: .public),
                    isFirstApplying: \(isFirstAppling.description, privacy: .public),
                    isSnapshotChanged: \(isSnapshotChanged.description, privacy: .public)
                    at: \(String(describing: self.parentViewController), privacy: .public)
                    """)
                
                diffableDataSource.apply(snapshot, to: section, animatingDifferences: animating) {
                    logger.log("after applying changes with section: \(section, privacy: .public)")
                }
            }
        }
    }
    
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemIdentifier>
    
    func snapshotsAreChanged(prev snapshotA: SectionSnapshot, current snapshotB: SectionSnapshot) -> Bool {
        if snapshotA.items != snapshotB.items {
            return true
        }
        
        for item in snapshotA.items {
            if !snapshotB.items.contains(item) {
                return true
            }
            
            if snapshotA.isExpanded(item) != snapshotB.isExpanded(item) {
                return true
            }
        }
        
        return false
    }
}
