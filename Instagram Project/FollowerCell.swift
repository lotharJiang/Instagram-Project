//
//  FollowerCell.swift
//  Instagram Project
//
//  Created by LiuYuHan on 13/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

enum followEvent : String {
    case Like = "liked your photo"
    case Following = "started following you"
}

struct followerCellData {
    var followerPortrait:String?
    var followerUsername:String?
    var eventString:followEvent?
    var time:Int?
    var likePhoto:String?
}


class FollowerCell: UITableViewCell {

    var loginUser: String = String()
    var parentTVC: You?
    var postID: String = String()
    
    @IBOutlet var followerPortait: UIImageView!
    @IBOutlet var eventLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var likedPhoto: UIImageView!
    
    
    
    var potraitImage:UIImage?
    var postPhotoImage:UIImage?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func displaypotraitImage(){
        //self.potrait.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        self.followerPortait.backgroundColor = UIColor.gray
        self.followerPortait.layer.masksToBounds = true
        self.followerPortait.layer.cornerRadius = self.followerPortait.frame.width / 2.0
        self.followerPortait.image = self.potraitImage
        //self.addSubview(potrait)
    }
    
    func displaypostPhotoImage(){
        //self.postPhoto.frame = CGRect(x: 0, y: 70, width: self.frame.width, height: self.frame.width)
        self.likedPhoto.backgroundColor = UIColor.gray
        self.likedPhoto.layer.masksToBounds = true
        self.likedPhoto.layer.cornerRadius = self.likedPhoto.frame.width / 5.0
        self.likedPhoto.image = self.postPhotoImage
        //self.addSubview(postPhoto)
    }
    
    
    
}
