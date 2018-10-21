//
//  photoInRangeCell.swift
//  Instagram Project
//
//  Created by LiuYuHan on 21/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

struct photoInRangeCellData {
    var username:String?
    var receivedImage:UIImage?
}

class photoInRangeCell: UITableViewCell {

    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var receivedImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
