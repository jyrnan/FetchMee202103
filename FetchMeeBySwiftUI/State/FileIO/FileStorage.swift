//
//  FileStorage.swift
//  FetchMee
//
//  Created by jyrnan on 2021/2/24.
//  Copyright © 2021 jyrnan. All rights reserved.
//



import Foundation

@propertyWrapper
struct FileStorage<T: Codable> {
    var value: T?

    let directory: FileManager.SearchPathDirectory
    let fileName: String
    
    /// 初始化函数，可以提供
    /// - Parameters:
    ///   - directory: 文件保存路径
    ///   - fileName: 文件名
    ///   - defaultValue: 初始化的可选值
    init(directory: FileManager.SearchPathDirectory, fileName: String, defaultValue: T? = nil) {
        value = try? FileHelper.loadJSON(from: directory, fileName: fileName)
        
        //如果读取本地文件不成功，则value可能保持nil，如果有缺省值，则赋予缺省值
        if value == nil, defaultValue != nil {
            value = defaultValue
        }
        self.directory = directory
        self.fileName = fileName
    }

    var wrappedValue: T? {
        set {
            value = newValue
            if let value = newValue {
                try? FileHelper.writeJSON(value, to: directory, fileName: fileName)
            } else {
                try? FileHelper.delete(from: directory, fileName: fileName)
            }
        }

        get { value }
    }
}

