//
//  ViewController.swift
//  DiffableListExample
//
//  Created by Kai on 2022/3/15.
//

import UIKit
import DiffableList
import SwiftUI

struct Item {
    let id = UUID()
    let value: String
    let color: Color
    var height: CGFloat = 44
}

class ViewController: DiffableListViewController {
    var data: [Item] = [
        .init(value: "1", color: .red, height: 55),
        .init(value: "2", color: .green, height: 69),
        .init(value: "3", color: .blue, height: 12),
        .init(value: "4", color: .brown, height: 59),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = .init(title: "Reload", primaryAction: .init { _ in
            self.data = self.data.shuffled()
            self.reload()
        })
        
        reload(animating: false)
    }
    
    func makeListView() -> DiffableListView {
        let listView = DiffableListView(frame: view.bounds)
        
        
        return listView
    }
    
    override var list: DLList {
        DLList { [unowned self] in
            DLSection {
                for item in self.data {
                    DLCell(using: .swiftUI(movingTo: self, content: {
                        Text(item.value)
                            .foregroundColor(item.color)
                            .frame(height: item.height)
                    }))
                    .tag(item.id)
                }
            }
            .tag(0)
        }
    }
}
