//
//  photoCollectionCell.swift
//  Instagram Project
//
//  Created by LiuYuHan on 13/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class photoCollectionCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView! = UIImageView()
    var image:UIImage?
    
    public func display() {
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.imageView.image = self.image
        self.addSubview(imageView)
    }
    
    
}
