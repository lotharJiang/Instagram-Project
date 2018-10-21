//
//  commentTVC.swift
//  Instagram Project
//
//  Created by LiuYuHan on 21/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class commentTVC: UITableViewController {

    var commentArray:[commentCellData]=[commentCellData]()
    var loginUser:String?
    var postID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "All Comments"
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.tableView.allowsSelection = false
        //self.tableView.separatorStyle = .none
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Refreshing")
        refreshData()
    }

    // MARK: - Table view data source

    @objc func refreshData(){
        self.commentArray.removeAll()
        self.loadData()
    }
    
    func loadData(){
        //http
        let url = NSURL(string:"http://115.146.84.191:3333/api/acquireComment/\(postID!)")
        let request = NSMutableURLRequest(url:url! as URL);
        request.httpMethod = "GET";
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            if let anError = error {
                print("\(anError)")
                DispatchQueue.main.async(execute:{
                    let errorAlert = UIAlertController(title: "Error", message: "Load data error. Please check your network settings and try again.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    errorAlert.addAction(action)
                    self.present(errorAlert,animated: true,completion: nil)
                })
            }
            if (data != nil){
                //let receiveString = String(data: data!, encoding: String.Encoding.utf8)
                //print("Received:"+receiveString!+"\n\n\n")
                do {
                    let json:NSDictionary = try JSONSerialization.jsonObject(with: data!) as! NSDictionary
                    let jsonData:NSArray = json["data"]! as! NSArray
                    for jsonObject in jsonData{
                        let jsonObj:NSDictionary = jsonObject as! NSDictionary
                        var aCommentCellData:commentCellData = commentCellData()
                        
                        aCommentCellData.commentUserName = jsonObj["commentUser"] as? String
                        aCommentCellData.commentContent = jsonObj["comment"] as? String
                        
                        
                        self.commentArray.append(aCommentCellData)
                        //"[postID, portrait, isLike, date, username, photo, likes, commentContent, commentUser]"
                    }
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Json Error: \(error)")
                }
            }
        }
        task.resume()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commentArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! commentCell
        let cellData:commentCellData = self.commentArray[indexPath.row]
        cell.usernameLabel.text = "\(cellData.commentUserName!) said:"
        cell.commentTextView.text = cellData.commentContent
        return cell
    }

}
