//
//  PostCell.swift
//  Instagram Project
//
//  Created by LiuYuHan on 2/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

struct postCellData {
    var postID:String?
    var username:String?
    var location:String?
    var portait:String?
    var photo:String?
    var isLike:Bool?
    var likes:Int?
    var commentUser:String?
    var commentContent:String?
    var date:Int?
    var likeUserNames:String?
}

class PostCell: UITableViewCell, UITextFieldDelegate {

    var loginUser: String = String()
    var postID: String = String()
    
    @IBOutlet var potrait: UIImageView!// = UIImageView()
    @IBOutlet var userName: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var postPhoto: UIImageView!// = UIImageView()
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var viewMoreButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    var potraitImage: UIImage?
    var postPhotoImage: UIImage?
    var parentTVC: UITableViewController?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func likeAction(_ sender: Any) {
        self.likeButton.isSelected = self.likeButton.isSelected ? false : true
        
        let url = NSURL(string:"http://115.146.84.191:3333/api/like")
        let request = NSMutableURLRequest(url:url! as URL)
        request.httpMethod = "POST"
        let postString = "userEmail=\(loginUser)&postID=\(postID)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            if let anError = error {
                print("\(anError)")
            }
        }
        task.resume()
    }
    
    @IBAction func commentAction(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Leave a comment...", preferredStyle: .alert)
        let action = UIAlertAction(title: "Send", style: .default, handler: {
            action in
            //HTTP
            let url = NSURL(string:"http://115.146.84.191:3333/api/postComment")
            let request = NSMutableURLRequest(url:url! as URL);
            request.httpMethod = "POST";
            let postString="userEmail=\(self.loginUser)&postID=\(self.postID)&comment=\(alert.textFields?.first?.text ?? " ")"
            
            request.httpBody = postString.data(using: .utf8);
                
            let task = URLSession.shared.dataTask(with: request as URLRequest){
                data, response, error in
                    if let anError = error {
                        print("error: "+(anError.localizedDescription))
                    }
                if let parent = self.parentTVC{
                    if parent is Userfeed{
                        (parent as! Userfeed).refreshData()
                    }
                    if parent is Following{
                        (parent as! Following).refreshData()
                    }
                }
                }
            task.resume()
        })
        alert.addAction(action);
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addTextField(configurationHandler: {textfield in
            textfield.placeholder = "Something you want to say...";
            textfield.returnKeyType = .send
            textfield.clearsOnBeginEditing = true
            textfield.delegate = self
        })
        self.parentTVC?.present(alert,animated:true,completion:nil);
    }
    
    @IBAction func viewMoreAction(_ sender: Any) {
        let comment:commentTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "commentTVC") as! commentTVC
        comment.loginUser = self.loginUser
        comment.postID = self.postID
        self.parentTVC?.navigationController?.pushViewController(comment, animated: true)
    }
    
    func displaypotraitImage(){
        //self.potrait.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        self.potrait.backgroundColor = UIColor.gray
        self.potrait.layer.masksToBounds = true
        self.potrait.layer.cornerRadius = self.potrait.frame.width / 2.0
        self.potrait.image = self.potraitImage
        //self.addSubview(potrait)
    }
    
    func displaypostPhotoImage(){
        //self.postPhoto.frame = CGRect(x: 0, y: 70, width: self.frame.width, height: self.frame.width)
        self.postPhoto.image = self.postPhotoImage
        //self.addSubview(postPhoto)
    }
    
    
}
