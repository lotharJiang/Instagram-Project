//
//  Following.swift
//  Instagram Project
//
//  Created by LiuYuHan on 13/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit


class Following: UITableViewController {

    var tabBarCtl:tabBar?
    var loginUser:String = String()
    var postArray = [postCellData]()
    var loadMoreView:UIView?
    var loadMoreEnable = true
    var activityViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let imageLoadQueu = OperationQueue()
    var imageOps = [(Item, Operation?)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginUser = tabBarCtl!.loginUser
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Refreshing")
        
        
        self.tableView.isScrollEnabled = true
        self.tableView.allowsSelection = false
        self.setupInfiniteScrollingView()
        self.tableView.tableFooterView = self.loadMoreView
        self.tableView.separatorStyle = .none
        
    imageLoadQueu.maxConcurrentOperationCount = 4
        imageLoadQueu.qualityOfService = .userInitiated
        
        refreshData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func updateImageOps() {
        //print(self.photoArray)
        imageOps.removeAll()
        imageOps = Item.creatItems(count: postArray.count * 2).map({ (images) -> (Item, Operation?) in
            return (images, nil)
        })
        DispatchQueue.main.async {
            self.activityViewIndicator.stopAnimating()
            self.tableView.reloadData()
        }
        
    }
    
    
    private func setupInfiniteScrollingView() {
        self.loadMoreView = UIView(frame: CGRect(x:0, y:self.tableView.contentSize.height,width:self.tableView.bounds.size.width, height:60))
        self.loadMoreView!.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.loadMoreView!.backgroundColor = UIColor.clear
        
        activityViewIndicator.color = UIColor.darkGray
        let indicatorX = self.view.frame.width/2-activityViewIndicator.frame.width/2
        let indicatorY = self.loadMoreView!.frame.size.height/2-activityViewIndicator.frame.height/2
        activityViewIndicator.frame = CGRect(x:indicatorX,y:indicatorY,width:activityViewIndicator.frame.width,height:activityViewIndicator.frame.height)
        activityViewIndicator.startAnimating()
        self.loadMoreView!.addSubview(activityViewIndicator)
    }
    
    @objc func refreshData(){
        self.postArray.removeAll()
        //Load new data to postArray
        loadDataFromIndex(startIndex: 0)
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
    
    func loadDataFromIndex(startIndex:Int){
        //load 10 data from index to postArray (sorted by time)
        var postID = "-1"
        if startIndex != 0 {
            postID = self.postArray[startIndex].postID ?? "-1"
        }
        let url = NSURL(string:"http://115.146.84.191:3333/api/acquireLatestFollowing/\(loginUser)/\(postID)")
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
                        var aPostCellData:postCellData = postCellData()
                        aPostCellData.postID = "\(jsonObj["postID"] as? Int ?? 0)"
                        aPostCellData.username = jsonObj["username"] as? String
                        aPostCellData.location = jsonObj["location"] as? String
                        aPostCellData.portait = jsonObj["portrait"] as? String
                        aPostCellData.photo = jsonObj["photo"] as? String
                        aPostCellData.isLike = jsonObj["isLike"] as? Bool
                        aPostCellData.likes = jsonObj["likes"] as? Int
                        aPostCellData.commentUser = jsonObj["commentUser"] as? String
                        aPostCellData.commentContent = jsonObj["commentContent"] as? String
                        aPostCellData.date = jsonObj["date"] as? Int
                        /*
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
                         
                         */
                        print(aPostCellData)
                        self.postArray.append(aPostCellData)
                        //"[postID, portrait, isLike, date, username, photo, likes, commentContent, commentUser]"
                    }
                    self.updateImageOps()
                    //whether we have more data
                    self.loadMoreEnable = self.postArray.count >= 10
                    print(self.postArray.count)
                    print("\(self.loadMoreEnable)")
                    //self.tableView?.reloadData()
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return postArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PostCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        let cellData:postCellData = self.postArray[indexPath.row]
        cell.loginUser = self.loginUser
        cell.postID = cellData.postID ?? "0"
        cell.parentTVC = self
        cell.userName.text = cellData.username
        cell.location.text = cellData.location
        cell.likeLabel.text = "\(cellData.likes ?? 0) likes"
        let comtUserAttribute = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 13)]
        let comtContentAttribute = [NSAttributedStringKey.foregroundColor:UIColor.gray]
        let commentText = NSMutableAttributedString(string: cellData.commentUser ?? "", attributes: comtUserAttribute)
        if cellData.commentUser == nil{
            commentText.append(NSAttributedString(string: cellData.commentContent ?? "No one left a comment...", attributes: comtContentAttribute))
        }else{
            commentText.append(NSAttributedString(string: ": "+(cellData.commentContent ?? "No one left a comment..."), attributes: comtContentAttribute))
        }
        
        cell.commentLabel.attributedText = commentText
        
        if cellData.commentUser == nil{
            cell.viewMoreButton.isHidden = true
        }else{
            cell.viewMoreButton.isHidden = false
        }
        
        if cellData.isLike! == true{
            cell.likeButton.isSelected = true
        }else{
            cell.likeButton.isSelected = false
        }
        
        
        if (cellData.date ?? 0) >= 24 {
            cell.dateLabel.text = "\((cellData.date ?? 0) / 24) days ago"
        }
        else{
            cell.dateLabel.text = "\(cellData.date ?? 0) hours ago"
        }
        // Scroll to the last row, load more data
        if (loadMoreEnable && indexPath.row == self.postArray.count-1) {
            loadMoreData()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! PostCell
        let (item1, operation1) = imageOps[2*indexPath.row]
        let (item2, operation2) = imageOps[2*indexPath.row + 1]
        operation1?.cancel()
        operation2?.cancel()
        weak var weakCell = cell
        
        let newOp1 = ImageLoadOperation(forItem: item1, urlStr: postArray[indexPath.row].portait!) { (image) in
            DispatchQueue.main.async {
                weakCell?.potraitImage = image
                weakCell?.displaypotraitImage()
            }
        }
        print(postArray[indexPath.row].photo!)
        let newOp2 = ImageLoadOperation(forItem: item2, urlStr: postArray[indexPath.row].photo!) { (image) in
            DispatchQueue.main.async {
                weakCell?.postPhotoImage = image
                weakCell?.displaypostPhotoImage()
            }
        }
        imageLoadQueu.addOperation(newOp1)
        imageLoadQueu.addOperation(newOp2)
        imageOps[2*indexPath.row] = (item1, newOp1)
        imageOps[2*indexPath.row + 1] = (item2, newOp2)
    }
    
    func loadMoreData(){
        loadMoreEnable = false
        self.activityViewIndicator.startAnimating()
        let currentRow = self.postArray.count
        let startIndex = currentRow + 1
        loadDataFromIndex(startIndex: startIndex)
        let newRow = self.postArray.count
        self.tableView.reloadData()
        self.loadMoreEnable = newRow - currentRow >= 10
    }

}
