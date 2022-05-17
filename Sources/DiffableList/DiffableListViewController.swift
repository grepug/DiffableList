//
//  File.swift
//  
//
//  Created by Kai on 2022/3/17.
//

import UIKit

open class DiffableListViewController: UIViewController {
    lazy public var listView = makeListView()
    
    lazy var collapsedItemIdentifiers: Set<ItemIdentifier> = {
        if let cacheKey = cachedCollapsedItemIdentifiersKey,
            let cachedIdentifiers = UserDefaults.standard.stringArray(forKey: cacheKey) {
            return Set(cachedIdentifiers)
        }
        
        return []
    }() {
        didSet {
            if let cacheKey = cachedCollapsedItemIdentifiersKey {
                UserDefaults.standard.set(Array(collapsedItemIdentifiers), forKey: cacheKey)
            }
        }
    }
    
    open var cachedCollapsedItemIdentifiersKey: String? { nil }
    
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
        
        return listView
    }
    
    open var list: DLList {
        DLList {}
    }
    
    open func reload(applyingSnapshot: Bool = true, animating: Bool = true) {
        let cachedCollapsedItemIdentifiers = collapsedItemIdentifiers
        
        if applyingSnapshot {
            /// apply snapshot 的时候必须所有不管是否折叠的 cell 都要 apply 进去，因此暂时将折叠的 ids 清空，这样在生成 list 的时候就是所有 cell
            collapsedItemIdentifiers.removeAll()
        }
        
        listView.setContent(filteredList,
                            applyingSnapshot: applyingSnapshot,
                            collapsedItemIdentifiers: cachedCollapsedItemIdentifiers,
                            animating: animating,
                            makingSnapshotsCompletion: { [unowned self] in
            self.collapsedItemIdentifiers = cachedCollapsedItemIdentifiers
            
            /// apply snapshot 之后，重新生成 list，过滤掉折叠的 cell，以便在 dequeue cell 的时候，根据 indexPath 获取的是正确的 cell
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
