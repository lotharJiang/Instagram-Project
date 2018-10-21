//
//  DiscoveryCell.swift
//  Instagram Project
//
//  Created by LiuYuHan on 14/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

struct discoveryCellData {
    var followerPortrait:String?
    var followerUsername:String?
    var followOrNot:Bool?
}

class DiscoveryCell: UITableViewCell {

    
    @IBOutlet var portrait: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var followButton: UIButton!
    var potraitImage:UIImage?
    
    
    
    var parentTVC: Discovery?
    //var friendList:[discoveryCellData] = [discoveryCellData]()
    var loginUser:String = String()
    var followingUser:String = String()
    
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
        self.portrait.backgroundColor = UIColor.gray
        self.portrait.layer.masksToBounds = true
        self.portrait.layer.cornerRadius = self.portrait.frame.width / 2.0
        self.portrait.image = self.potraitImage
        //self.addSubview(potrait)
    }
    
    @IBAction func followAction(_ sender: Any) {
        let followorUnfollow:Bool = self.followButton.isSelected
        //isselected -> true -> follow api
        //notselected -> unfollow -> unfollow api
        
        self.followButton.isSelected = self.followButton.isSelected ? false : true
        //self.followButton.isEnabled = false
        
        var url = NSURL(string:"http://115.146.84.191:3333/api/follow")
        if followorUnfollow {
            url = NSURL(string:"http://115.146.84.191:3333/api/follow")
        }
        else{
            url = NSURL(string:"http://115.146.84.191:3333/api/unfollow")
        }
        let request = NSMutableURLRequest(url:url! as URL)
        request.httpMethod = "POST"
        let postString = "userEmail=\(loginUser)&followingID=\(self.usernameLabel.text!)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            if let anError = error {
                print("\(anError)")
            }
        }
        task.resume()
    }
    
}
