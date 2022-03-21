//
//  File.swift
//  
//
//  Created by Kai on 2022/3/17.
//

import UIKit

open class DiffableListViewController: UIViewController {
    lazy public var listView = makeListView()
    
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
        
//        listView.contentInset.top = 16
        
        return listView
    }
}
