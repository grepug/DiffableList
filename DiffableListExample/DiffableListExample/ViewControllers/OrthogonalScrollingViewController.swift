//
//  OrthogonalScrollingViewController.swift
//  DiffableListExample
//
//  Created by Kai on 2022/5/25.
//

import DiffableList
import UIKit
import SwiftUI

class OrthogonalScrollingViewController: DiffableListViewController {
    override var list: DLList {
        DLList { [unowned self] in
            DLSection { [unowned self] in
                DLCell(using: .swiftUI(movingTo: self, content: {
                    Color.red
                        .cornerRadius(12)
                }))
                .tag("0")
                .backgroundConfiguration(.clear())
                
                DLCell(using: .swiftUI(movingTo: self, content: {
                    Color.green
                        .cornerRadius(12)
                }))
                .tag("1")
                .backgroundConfiguration(.clear())
                
                DLCell(using: .swiftUI(movingTo: self, content: {
                    Color.blue
                        .cornerRadius(12)
                }))
                .tag("2")
                .backgroundConfiguration(.clear())
            }
            .tag("0")
            .layout { env in
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(167),
                                                      heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.94),
                                                       heightDimension: .absolute(160))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging
                
                section.contentInsets = .init(top: 0, leading: 8, bottom: 8, trailing: 8)
                return section
            }
            
            DLSection {
                DLCell(using: .swiftUI(movingTo: self, content: {
                    Text("近7天每日进度")
                        .font(.title2.weight(.medium))
                }))
                .tag("7daysHeader")
                .backgroundConfiguration(.clear())
                
                DLCell(using: .swiftUI(movingTo: self, content: {
                    Color.red
                        .cornerRadius(12)
                }))
                .tag("7days")
                .backgroundConfiguration(.clear())
                
                DLCell(using: .swiftUI(movingTo: self, content: {
                    Text("近7天每日进度")
                        .font(.title2.weight(.medium))
                }))
                .tag("7daysHeader2")
                .backgroundConfiguration(.clear())
                
                DLCell(using: .swiftUI(movingTo: self, content: {
                    Color.green
                        .cornerRadius(12)
                }))
                .tag("7days2")
                .backgroundConfiguration(.clear())
            }
            .tag("1")
            
            DLSection { [unowned self] in
                DLCell(using: .swiftUI(movingTo: self, content: {
                    Color.red
                        .cornerRadius(12)
                }))
                .tag("7days0")
                .backgroundConfiguration(.clear())
                
                DLCell(using: .swiftUI(movingTo: self, content: {
                    Color.blue
                        .cornerRadius(12)
                }))
                .tag("7days200")
                .backgroundConfiguration(.clear())
            }
            .tag("2")
            .header(using: .swiftUI(movingTo: self, content: {
                HStack {
                    Text("待改进的问题")
                        .font(.title2.weight(.medium))
                    Spacer()
                    Button {
                        
                    } label: {
                        Label("添加", systemImage: "plus")
                    }
                }
                .padding(.leading)
            }))
            .footer(using: .swiftUI(movingTo: self, content: {
                Color.orange
                    .frame(height: 50)
            }))
            
            DLSection {
                DLCell {
                    DLText("hi")
                }
                .tag("haha")
            }
            .tag("3")
            .footer(using: .swiftUI(movingTo: self, content: {
                Color.green
                    .frame(height: 50)
            }))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "复盘"
        reload(animating: false)
        listView.customSectionProvider = { [unowned self] in sectionLayoutProvider(sectionIndex: $0, env: $1) }
    }
}

extension OrthogonalScrollingViewController {
    func sectionLayoutProvider(sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?  {
        switch sectionIndex {
        case 1:
            let titleItemSize = NSCollectionLayoutSize(widthDimension: .absolute(167),
                                                       heightDimension: .fractionalHeight(0.2))
            let titleItem = NSCollectionLayoutItem(layoutSize: titleItemSize)
            let contentItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                         heightDimension: .fractionalHeight(0.8))
            let contentItem = NSCollectionLayoutItem(layoutSize: contentItemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.94),
                                                   heightDimension: .absolute(200))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [titleItem, contentItem])
            group.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .paging
            
            section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            return section
            
        case 2:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                         heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.94),
                                                   heightDimension: .absolute(200))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            group.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .paging
            section.contentInsets = .init(top: 8, leading: 8, bottom: 0, trailing: 8)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .absolute(44))
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                     elementKind: DiffableListView.reusableContentViewHeaderKind,
                                                                     alignment: .top)
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize,
                                                                     elementKind: DiffableListView.reusableContentViewFooterKind,
                                                                     alignment: .bottom)
            
            section.boundarySupplementaryItems = [header, footer]
            
            return section
        default: return nil
        }
    }
}
