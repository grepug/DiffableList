//
//  File.swift
//  
//
//  Created by Kai on 2022/6/13.
//

import UIKit
import OSLog

@available(iOS 15.0, *)
extension DiffableListView {
    func collectLogsBeforeTermination() {
        guard let logString = getLogString() else {
            return
        }
        
        UIPasteboard.general.string = logString
        
        let title = "发生了一个未知错误"
        let message = "错误信息已经复制，请发给开发者"
        let vc = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        vc.addAction(.init(title: "OK", style: .default, handler: { _ in
            fatalError()
        }))
        
        parentViewController?.present(vc, animated: true)
    }
    
    private func getLogString() -> String? {
        guard let store = try? OSLogStore(scope: .currentProcessIdentifier) else {
            return nil
        }
        
        let position = store.position(timeIntervalSinceLatestBoot: 1)
        
        guard let entries = try? store
            .getEntries(at: position) else {
            return nil
        }
        
        let messages = entries.compactMap { $0 as? OSLogEntryLog }
            .filter { $0.subsystem == Bundle.main.bundleIdentifier! }
            .map { "[\($0.date.formatted())] [\($0.category)] \($0.composedMessage)" }
            .joined(separator: "\n")
        
        return messages
    }
}
