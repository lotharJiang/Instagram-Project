//
//  commentCell.swift
//  Instagram Project
//
//  Created by LiuYuHan on 21/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

struct commentCellData {
    var commentUserName:String?
    var commentContent:String?
}


class commentCell: UITableViewCell {

    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
