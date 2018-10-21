//
//  ImageProcess.swift
//  Instagram Project
//
//  Created by LiuYuHan on 13/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class ImageProcess: NSObject {
    public func convertToDataFrom(URLString url:String) -> Data? {
        let anURL = URL(string: url)
        if let goodURL = anURL{
            let data = try! Data(contentsOf: goodURL)
            //print(data)
            return data
        }
        else{
            return nil
        }
    }
    
    public func convertToImageFrom(URLString url:String) -> UIImage? {
        if let data = convertToDataFrom(URLString: url)
        {
            let image = UIImage(data: data)
            return image!
        }
        else{
            return nil
        }
    }
    
    public func sacleImageTo(URLString url:String, size:CGSize) -> UIImage?{
        if let tmpImage = self.convertToImageFrom(URLString: url)
        {
            UIGraphicsBeginImageContext(size);
            tmpImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let scaleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return scaleImage!
        }
        else{
            return nil
        }
    }
    
    public func sacleImageTo(image:UIImage?, size:CGSize) -> UIImage?{
        if let tmpImage = image
        {
            UIGraphicsBeginImageContext(size);
            tmpImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let scaleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return scaleImage!
        }
        else{
            return nil
        }
    }
}
