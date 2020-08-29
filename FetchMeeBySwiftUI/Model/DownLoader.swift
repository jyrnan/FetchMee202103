//
//  DownLoader.swift
//  FetchMee
//
//  Created by yoeking on 2020/8/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation
import SwiftUI


typealias DownloaderCH = (URL) -> Void

class Downloader : NSObject {
    let config : URLSessionConfiguration
    lazy var session : URLSession = {
        return URLSession(configuration: config, delegate: DownloderDelegate(), delegateQueue: .main )
    }()
    init(configuation config:URLSessionConfiguration) {
        self.config = config
        super.init()
    }
    
    @discardableResult
    func download(url: URL, completionHandler ch: @escaping DownloaderCH) -> URLSessionTask {
        
        let task = self.session.downloadTask(with: url)
        // ... store the comletion fucntion
        let del = self.session.delegate as! DownloderDelegate
        del.appendHandler(ch, task: task)
        task.resume()
        return task
    }
    
    
    deinit {
        self.session.invalidateAndCancel()
    }
}

class DownloderDelegate: NSObject, URLSessionDownloadDelegate {
    private var handlers = [Int: DownloaderCH]()
    
    func appendHandler(_ ch: @escaping DownloaderCH, task: URLSessionTask) -> Void {
        self.handlers[task.taskIdentifier] = ch
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //TODO: 保存数据

        //获取数据URL提取handler并执行
        let ch = self.handlers[downloadTask.taskIdentifier]
        ch?(location)
    }
    
}
