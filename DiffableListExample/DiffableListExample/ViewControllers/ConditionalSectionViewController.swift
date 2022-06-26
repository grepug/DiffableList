//
//  ConditionalSectionViewController.swift
//  DiffableListExample
//
//  Created by Kai on 2022/6/24.
//

import UIKit
import DiffableList

class ConditionalSectionViewController: DiffableListViewController {
    var showingFirstSection = false
    
    override var list: DLList {
        DLList { [unowned self] in
            if self.showingFirstSection {
                DLSection {
                    DLCell {
                        DLText("First Section")
                    }
                    .tag("first")
                }
                .tag("first")
            }
            
            DLSection {
                DLCell {
                    DLText("Second Section")
                }
                .tag("second")
            }
            .tag("second")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reload(animating: false)
        navigationItem.rightBarButtonItem = .init(title: "Reload", primaryAction: .init { [unowned self] _ in
            showingFirstSection.toggle()
            reload()
        })
    }
}
