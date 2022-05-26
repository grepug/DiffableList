//
//  ListViewController.swift
//  DiffableListExample
//
//  Created by Kai on 2022/5/25.
//

import DiffableList
import UIKit

class EntryViewController: DiffableListViewController {
    override var list: DLList {
        DLList {
            DLSection {
                DLCell {
                    DLText("OrthogonalScrollingViewController")
                }
                .tag("orthog")
                .accessories([.disclosureIndicator()])
                .onTap { [unowned self] _ in
                    let vc = OrthogonalScrollingViewController()
                    navigationController?.pushViewController(vc, animated: true)
                }
                
                DLCell {
                    DLText("ListViewController")
                }
                .tag("list")
                .accessories([.disclosureIndicator()])
                .onTap { [unowned self] _ in
                    let vc = ListViewController()
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "List View Example"
        navigationController?.navigationBar.prefersLargeTitles = true
        reload(animating: false)
        
        let vc = OrthogonalScrollingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
