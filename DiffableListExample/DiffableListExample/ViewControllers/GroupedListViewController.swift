//
//  GroupedListViewController.swift
//  DiffableListExample
//
//  Created by Kai on 2022/7/12.
//

import DiffableList

class GroupedListViewController: DiffableListViewController {
    enum Section: String, CaseIterable {
        case a, b
    }
    
    var items: [Section: [String]] = [.a: ["A"], .b: ["B", "C"]]
    
    override var list: DLList {
        DLList { [unowned self] in
            for section in Section.allCases {
                DLSection {
                    DLCell(using: .header("Section \(section.rawValue)"))
                        .tag("section \(section.rawValue)")
                    
                    for item in self.items[section] ?? [] {
                        DLCell {
                            DLText("\(item)")
                        }
                        .tag(item)
                    }
                }
                .tag(section)
                .firstCellAsHeader()
            }
        }
    }
    
    var step = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reload(animating: false)
        
        navigationItem.rightBarButtonItem = .init(title: "Reload", primaryAction: .init { [unowned self] _ in
            if step == 0 {
                items = [.a: ["A", "B"], .b: ["C"]]
            } else if step == 1 {
                items = [.a: ["A", "B", "D"], .b: []]
            } else if step == 2 {
                items = [.a: ["A"], .b: ["B"]]
            }
            
            step += 1
            reload()
        })
    }
}
