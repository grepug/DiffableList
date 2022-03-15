//
//  ViewController.swift
//  DiffableListExample
//
//  Created by Kai on 2022/3/15.
//

import UIKit
import DiffableList
import SwiftUI

class ViewController: UIViewController {
    lazy var listView = makeListView()
    
    var data: [String] = ["1", "2"].shuffled() {
        didSet {
            setupListContent()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        view.addSubview(listView)
        
        navigationItem.rightBarButtonItem = .init(title: "reload", primaryAction: .init { _ in
            self.data = self.data.shuffled()
        })
    }
    
    func makeListView() -> DiffableListView {
        let listView = DiffableListView(frame: view.bounds)
        
        
        return listView
    }
    
    func setupListContent() {
        let list = DLList {
            for i in ["1000", "1001"] {
                Section {
                    HeaderCell {
                        Text("我是头部 \(i)")
                    }
                    .tag(i)
                    
                    for j in self.data {
                        Cell {
                            Text("haha \(j)")
                                .color(.green)
                            SecondaryText("mgj", color: .red)
                        }
                        .accessories([.disclosureIndicator()])
                        .tag(i + "101" + j)
                        
                        Cell(toParentVC: self) {
                            SwiftUI.Text("\(j)")
                                .frame(height: 200)
                        }
                        .tag(i + "100" + j)
                    }
                    
                }
                .tag(i)
            }
        }
        
        print(list)
        
        listView.content = list
    }
    
}

extension Cell {
    init<Content: View>(toParentVC parentVC: UIViewController, @ViewBuilder content: @escaping () -> Content) {
        self.init(using: SwiftUIWrapperCellConfiguration(toParentVC: parentVC, content: content))
    }
}
