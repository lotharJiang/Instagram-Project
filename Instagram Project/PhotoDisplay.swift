//
//  PhotoDisplay.swift
//  Instagram Project
//
//  Created by LiuYuHan on 13/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class PhotoDisplay: UIView{
    
    
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
 

    
    public func convertToDataFrom(URLString url:String) -> Data {
        let anURL = URL(string: url)
        let data = try! Data(contentsOf: anURL!)
        return data
    }
    
}
