//
//  ImageLoadOperation.swift
//  Instagram Project
//
//  Created by LiuYuHan on 14/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class ImageLoadOperation: Operation{
    let item: Item
    var dataTask: URLSessionDataTask?
    var urlString : String = String()
    let complete: (UIImage?) -> Void
    
    init(forItem: Item, urlStr:String, execute: @escaping (UIImage?) -> Void) {
        item = forItem
        complete = execute
        urlString = urlStr
        super.init()
    }
    
    fileprivate var _executing : Bool = false
    
    override var isExecuting: Bool {
        get { return _executing }
        set {
            if newValue != _executing {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    fileprivate var _finished : Bool = false
    override var isFinished: Bool {
        get { return _finished }
        set {
            if newValue != _finished {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    
    
    override var isAsynchronous: Bool {
        get {
            return true
        }
    }
    
    override func start() {
        if !isCancelled {
            isExecuting = true
            isFinished = false
            startOperation()
        } else {
            isFinished = true
        }
        
        if let url = item.imageUrl(urlString: urlString) {
            let urlRequest = NSMutableURLRequest(url: url)
            urlRequest.cachePolicy = .reloadRevalidatingCacheData
            urlRequest.httpMethod = "GET"
            let dataTask = URLSession.shared.dataTask(with: urlRequest as URLRequest, completionHandler:{[weak self](data, response, error) in
                if let data = data {
                    //print("URL: \(data)")
                    let image = UIImage(data: data)
                    self?.endOperationWith(image: image)
                } else {
                    self?.endOperationWith(image: nil)
                }
            })
            dataTask.resume()
        } else {
            self.endOperationWith(image: nil)
        }
    }
    
    override func cancel() {
        if !isCancelled {
            cancelOperation()
        }
        super.cancel()
        completeOperation()
    }
    
    func startOperation() {
        completeOperation()
    }
    
    func cancelOperation() {
        dataTask?.cancel()
    }
    
    func completeOperation() {
        if isExecuting && !isFinished {
            isExecuting = false
            isFinished = true
        }
    }
    
    func endOperationWith(image: UIImage?) {
        if !isCancelled {
            complete(image)
            completeOperation()
        }
    }
}
