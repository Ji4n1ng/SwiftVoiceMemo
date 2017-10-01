//
//  CellIdentifierExtension.swift
//  SwiftVoiceMemo
//
//  Created by 王嘉宁 on 2017/10/1.
//  Copyright © 2017年 jianing. All rights reserved.
//

import UIKit

extension NSObject {
    static var className: String {
        get {
            return self.description().components(separatedBy: ".").last!
        }
    }
}

extension UITableView {
    
    /// - Usage:
    /// - let cell = tableView.dequeueCell(MyCell)
    func dequeueCell<T: UITableViewCell>(_ cell: T.Type) -> T {
        return dequeueReusableCell(withIdentifier: T.className) as! T
    }
}
