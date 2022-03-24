//
//  File.swift
//  
//
//  Created by Kai on 2022/3/17.
//

import UIKit

@available(iOS 14.5, *)
open class DiffableListViewController: UIViewController {
    lazy public var listView = makeListView()
    var collapsedItemIdentifiers: Set<ItemIdentifier> = []
    
    func makeListView() -> DiffableListView {
        let listView = DiffableListView(frame: view.bounds)
        view.addSubview(listView)
        
        listView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: view.topAnchor),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        return listView
    }
    
    open var list: DLList {
        DLList {}
    }
    
    open func reload(applyingSnapshot: Bool = true, animating: Bool = true) {
        /// 暂时性处理：在 reload 之前清空已折叠的 identifiers，若需要完美处理，需要在 applySnapshot 处，
        /// 使用 snapshot.expand() / collapse() API 处理
        collapsedItemIdentifiers.removeAll()
        
        listView.setContent(list, applyingSnapshot: applyingSnapshot, animating: animating)
    }
    
    public func cellExpanded(_ identifier: ItemIdentifier) -> Bool {
        !collapsedItemIdentifiers.contains(identifier)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.sectionSnapshotHandlers.willExpandItem = { [unowned self] identifier in
            self.insertOrRemoveCollapsedIdentifiers(parent: identifier)
        }
        
        dataSource.sectionSnapshotHandlers.willCollapseItem = { [unowned self] identifier in
            self.insertOrRemoveCollapsedIdentifiers(parent: identifier, expanding: false)
        }
    }
}

@available(iOS 14.5, *)
private extension DiffableListViewController {
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> {
        listView.diffableDataSource
    }
    
    func itemIdentifiers(ofParent identifier: ItemIdentifier) -> [ItemIdentifier] {
        guard let parentIndexPath = dataSource.indexPath(for: identifier) else { return [] }
        
        let sectionIdentifier = list.sections[parentIndexPath.section].id
        let sectionSnapshot = dataSource.snapshot(for: sectionIdentifier)
        let snapshot = sectionSnapshot.snapshot(of: identifier)
        
        return snapshot.items
    }
    
    func insertOrRemoveCollapsedIdentifiers(parent identifier: ItemIdentifier, expanding: Bool = true) {
        let itemIdentifiers = itemIdentifiers(ofParent: identifier)
        
        itemIdentifiers.forEach { id in
            if expanding {
                collapsedItemIdentifiers.remove(id)
            } else {
                collapsedItemIdentifiers.insert(id)
            }
        }
        
        reload(applyingSnapshot: false)
    }
}
