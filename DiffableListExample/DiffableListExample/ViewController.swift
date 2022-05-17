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
//            self.data = self.data.shuffled()
            self.reload()
        })
        
        reload(animating: false)
    }
    
    override var cachedCollapsedItemIdentifiersKey: String? {
        "hello"
    }
    
    override var collapseAllByDefault: Bool { true }
    
    override var list: DLList {
        DLList { [unowned self] in
            DLSection {
                DLCell(using: .header("Header"))
                    .tag("header")
                    .accessories([.outlineDisclosure()])
                
                DLCell {
                    DLText("B")
                }
                .tag("B")
                .child(of: "header")
                .accessories([.outlineDisclosure()])
                
                DLCell {
                    DLText("B1")
                }
                .tag("B1")
                .child(of: "B")
                
                DLCell {
                    DLText("A")
                    DLText("A".hashValue.description)
                        .secondary()
                }
                .tag("A")
                .child(of: "header")
                .accessories([.outlineDisclosure()])
                
                DLCell {
                    DLText("A1")
                    DLText("A1".hashValue.description)
                        .secondary()
                }
                .tag("A1")
                .child(of: "A")
                .accessories([.outlineDisclosure()])
                
                DLCell {
                    DLText("A11")
                    DLText("A11".hashValue.description)
                        .secondary()
                }
                .tag("A11")
                .child(of: "A1")
                .accessories([.outlineDisclosure()])
                
                DLCell {
                    DLText("A111")
                    DLText("A111".hashValue.description)
                        .secondary()
                }
                .tag("A111")
                .child(of: "A11")
            }
            .tag(0)
            .firstCellAsHeader()
        }
    }
}
