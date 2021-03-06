//
//  File.swift
//  
//
//  Created by Kai on 2022/3/17.
//

import UIKit
import os

fileprivate extension Logger {
    static let vc = Logger(subsystem: "diffable.list", category: "diffable.list.DiffableListViewController")
}

open class DiffableListViewController: UIViewController {
    lazy public var listView = makeListView()
    
    lazy var collapsedItemIdentifiers: Set<ItemIdentifier> = {
        if let cacheKey = cachedCollapsedItemIdentifiersKey,
            let cachedIdentifiers = UserDefaults.standard.stringArray(forKey: cacheKey) {
            
            Logger.vc.info("cachedIdentifiers, \(cachedIdentifiers)")
            
            return Set(cachedIdentifiers)
        }
        
        Logger.vc.info("initial cachedIdentifers, []")
        
        if let collapseAllByDefaultAndExcludedIds = collapseAllByDefaultAndExcludedIds {
            var ids = allParentIdentifiers
            ids = ids.subtracting(collapseAllByDefaultAndExcludedIds)
            
            Logger.vc.info("initial parentIds cachedIdentifers, \(ids)")
            
            return ids
        }
        
        return []
    }() {
        didSet {
            if let cacheKey = cachedCollapsedItemIdentifiersKey {
                Logger.vc.info("did set cachedIdentifiers, \(self.collapsedItemIdentifiers)")
                
                UserDefaults.standard.set(Array(collapsedItemIdentifiers), forKey: cacheKey)
            }
        }
    }
    
    open var cachedCollapsedItemIdentifiersKey: String? { nil }
    open var collapseAllByDefaultAndExcludedIds: Set<ItemIdentifier>? { nil }
    
    open func makeListView() -> DiffableListView {
        let listView = DiffableListView(frame: view.bounds)
        view.addSubview(listView)
        
        listView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: view.topAnchor),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        Logger.vc.info("did make list view")
        
        return listView
    }
    
    open var list: DLList {
        DLList {}
    }
    
    open var canReload: Bool {
        true
    }
    
    open func reload(applyingSnapshot: Bool = true, animating: Bool = true) {
        guard canReload else {
            Logger.vc.log("reload denied!")
            return
        }
        
        let cachedCollapsedItemIdentifiers = collapsedItemIdentifiers
        
        if applyingSnapshot {
            /// apply snapshot ?????????????????????????????????????????? cell ?????? apply ????????????????????????????????? ids ???????????????????????? list ????????????????????? cell
            collapsedItemIdentifiers.removeAll()
        }
        
        listView.setContent(filteredList,
                            applyingSnapshot: applyingSnapshot,
                            collapsedItemIdentifiers: cachedCollapsedItemIdentifiers,
                            animating: animating,
                            makingSnapshotsCompletion: { [unowned self] in
            self.collapsedItemIdentifiers = cachedCollapsedItemIdentifiers
            
            /// apply snapshot ????????????????????? list????????????????????? cell???????????? dequeue cell ?????????????????? indexPath ????????????????????? cell
            self.listView.setContent(self.filteredList, applyingSnapshot: false)
        })
    }
    
    public func becomeFirstResponder(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let textField = self.listView.cellForItem(at: indexPath)?.subviews(ofType: UITextField.self).first(where: { $0.textInputContextIdentifier == nil }) {
                if textField.text?.isEmpty != false {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    public func becomeFirstResponderForTextView(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let textField = self.listView.cellForItem(at: indexPath)?.subviews(ofType: UITextView.self).first {
                if textField.text?.isEmpty != false {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    public func setTopPadding() {
        if #available(iOS 15.0, *) {
            listView.contentInset.top = 16
        }
    }
    
    public func collapseItem(_ identifier: ItemIdentifier) {
        collapsedItemIdentifiers.insert(identifier)
    }
    
    public func collapseItem<T: Hashable>(withTag tag: T) {
        collapsedItemIdentifiers.insert(tag.itemIdentifier)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.backgroundColor = .systemGroupedBackground
        
        dataSource.sectionSnapshotHandlers.willExpandItem = { [unowned self] identifier in
            self.insertOrRemoveCollapsedIdentifier(identifier)
        }
        
        dataSource.sectionSnapshotHandlers.willCollapseItem = { [unowned self] identifier in
            self.insertOrRemoveCollapsedIdentifier(identifier, expanding: false)
        }
    }
    
    open override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        listView.isEditing = editing
    }
}

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
    
    func cellExpanded(_ identifier: ItemIdentifier?) -> Bool {
        guard let identifier = identifier else {
            return true
        }
        
        return !collapsedItemIdentifiers.contains(identifier) &&
        !collapsedItemIdentifiers.contains(identifier.itemIdentifier)
    }
    
    var allParentIdentifiers: Set<ItemIdentifier> {
        let ids = list.sections.flatMap { section in
            section.cells.compactMap { cell in
                cell.parentId
            }
        }
        
        return Set(ids)
    }
    
    var filteredList: DLList {
        let sections = list.sections.map { section -> DLSection in
            var collapsedParentIds = Set<ItemIdentifier>()
            
            let cells = section.cells.compactMap { cell -> CellConvertible? in
                if let parentId = cell.parentId,
                   collapsedParentIds.contains(parentId) {
                    collapsedParentIds.insert(cell.id)
                    
                    return nil
                }
                
                if cellExpanded(cell.parentId) {
                    return cell
                }
                
                collapsedParentIds.insert(cell.id)
                
                return nil
            }
            
            var section = section
            section.cells = cells
            
            return section
        }
        
        var list = list
        list.sections = sections
        
        return list
    }
}
