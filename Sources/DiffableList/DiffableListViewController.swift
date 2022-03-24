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
    
    var collapsedItemIdentifiers: Set<ItemIdentifier> {
        get { listView.collapsedItemIdentifiers }
        set { listView.collapsedItemIdentifiers = newValue }
    }
    
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
        let cachedCollapsedItemIdentifiers = collapsedItemIdentifiers
        
        if applyingSnapshot {
            collapsedItemIdentifiers.removeAll()
        }
        
        listView.setContent(list,
                            applyingSnapshot: applyingSnapshot,
                            collapsedItemIdentifiers: cachedCollapsedItemIdentifiers,
                            animating: animating)
        
        if applyingSnapshot {
            collapsedItemIdentifiers = cachedCollapsedItemIdentifiers
        }
    }
    
    public func cellExpanded(_ identifier: ItemIdentifier) -> Bool {
        !collapsedItemIdentifiers.contains(identifier) &&
        !collapsedItemIdentifiers.contains(identifier.hashValue.description)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.sectionSnapshotHandlers.willExpandItem = { [unowned self] identifier in
            self.insertOrRemoveCollapsedIdentifier(identifier)
        }
        
        dataSource.sectionSnapshotHandlers.willCollapseItem = { [unowned self] identifier in
            self.insertOrRemoveCollapsedIdentifier(identifier, expanding: false)
        }
    }
}

@available(iOS 14.5, *)
private extension DiffableListViewController {
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> {
        listView.diffableDataSource
    }
    
    func insertOrRemoveCollapsedIdentifier(_ identifier: ItemIdentifier, expanding: Bool = true) {
        if expanding {
            collapsedItemIdentifiers.remove(identifier)
        } else {
            collapsedItemIdentifiers.insert(identifier)
        }
        
        reload(applyingSnapshot: false)
    }
}
