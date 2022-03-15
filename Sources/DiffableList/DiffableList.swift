//
//  DiffableList.swift
//  
//
//  Created by Kai on 2022/3/14.
//

import SwiftUI

//struct DiffableList<Item: DataElement>: UIViewControllerRepresentable {
//    typealias UIViewControllerType = DiffableListViewController
//    
//    @Binding var data: [Item]
//    @ListBuilder var listContent: ([Item]) -> List
//    
//    func makeUIViewController(context: Context) -> UIViewControllerType {
//        .init()
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        let listContent = listContent(data)
//        
//        uiViewController.listContent = listContent
//    }
//}

struct MyView {
    @ListBuilder
    var hahah: List {
        List {
            Section {
                Cell {
                    Text("1")
                }
            }
            
            for i in [[0], [1], [2]] {
                Section {
                    for j in i {
                        Cell {
                            Text("\(j)")
                        }
                    }
                }
            }
        }
    }
}
