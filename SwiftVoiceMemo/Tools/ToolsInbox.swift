//
//  ToolsInbox.swift
//  SwiftVoiceMemo
//
//  Created by 王嘉宁 on 2017/10/1.
//  Copyright © 2017年 jianing. All rights reserved.
//

import Foundation
import UIKit

/// 简洁创建CGRect
func Rect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) -> CGRect{
    return CGRect(x: x, y: y, width: width, height: height)
}

func Rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect{
    return CGRect(x: x, y: y, width: width, height: height)
}

func Rect(_ x: Double, _ y: Double, _ width: Double, _ height: Double) -> CGRect{
    return CGRect(x: x, y: y, width: width, height: height)
}

/// 获取 documents 目录路径
func getDocumentsDirectoryURL(with fileName: String) -> URL? {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let url = documentsDirectory.appendingPathComponent(fileName)
    guard !FileManager.default.fileExists(atPath: url.absoluteString) else {
        log("soundfile \(url.absoluteString) exists", .error)
        return nil
    }
    return url
}
