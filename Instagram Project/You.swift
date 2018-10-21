//
//  You.swift
//  Instagram Project
//
//  Created by LiuYuHan on 13/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class You: UITableViewController {

    var tabBarCtl:tabBar?
    var loginUser:String = String()
    var followerArray:[followerCellData] = [followerCellData]()
    var loadMoreView:UIView?
    var loadMoreEnable = true
    var activityViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let imageLoadQueu = OperationQueue()
    var imageOps = [(Item, Operation?)]()
    var lastLikeID:Int = -1
    var lastFollowID:Int = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarCtl:tabBar = self.tabBarController as! tabBar
        self.loginUser = tabBarCtl.loginUser
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Refreshing")
        
        
        self.tableView.isScrollEnabled = true
        self.tableView.allowsSelection = false
        self.setupInfiniteScrollingView()
        self.tableView.tableFooterView = self.loadMoreView
        self.tableView.separatorStyle = .none
        
        self.refreshControl!.beginRefreshing()
        refreshData()
    }
    
    func updateImageOps() {
        //print(self.photoArray)
        imageOps.removeAll()
        imageOps = Item.creatItems(count: followerArray.count * 2).map({ (images) -> (Item, Operation?) in
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
        self.followerArray.removeAll()
        //Load new data to postArray
        loadDataFromIndex(startIndex: 0)
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
    
    func loadDataFromIndex(startIndex:Int){
        //load 20 data from index to postArray (sorted by time)
        let url = NSURL(string:"http://115.146.84.191:3333/api/acquireLatestActionFromFollower/\(loginUser)/\(lastLikeID)/\(lastFollowID)")
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
                        var aFollowerCellData:followerCellData = followerCellData()
                        aFollowerCellData.followerPortrait = jsonObj["memberPortrait"] as? String
                        aFollowerCellData.likePhoto = jsonObj["postPic"] as? String
                        
                        if (jsonObj["event"] as? String) == "like"{
                            aFollowerCellData.eventString = .Like
                        }else{
                            aFollowerCellData.eventString = .Following
                        }
                        
                        aFollowerCellData.followerUsername = jsonObj["userEmail"] as? String
                        //aFollowerCellData.time = jsonObj["postID"] as? Int ?? 0
                        
                        print(aFollowerCellData)
                        self.followerArray.append(aFollowerCellData)
                        //"[postID, portrait, isLike, date, username, photo, likes, commentContent, commentUser]"
                    }
                    self.updateImageOps()
                    //whether we have more data
                    self.loadMoreEnable = self.followerArray.count >= 10
                    //print(self.postArray.count)
                    //print("\(self.loadMoreEnable)")
                    //self.tableView?.reloadData()
                } catch {
                    print("Json Error: \(error)")
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
        return followerArray.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "News"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowerCell
        let cellData:followerCellData = self.followerArray[indexPath.row]
        
        cell.loginUser = self.loginUser
        //cell.postID = cellData.postID ?? "0"
        cell.parentTVC = self
        //cell.followerPortait.image = UIImage(data: cellData.followerPortrait as Data)
        
        if (cellData.time ?? 0) >= 24 {
            cell.timeLabel.text = "\((cellData.time ?? 0) / 24) days ago"
        }
        else{
            cell.timeLabel.text = "\(cellData.time ?? 0) hours ago"
        }
        
        let userAttribute = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 14)]
        let eventContentAttribute = [NSAttributedStringKey.foregroundColor:UIColor.gray]
        let eventText = NSMutableAttributedString(string: cellData.followerUsername! + " ", attributes: userAttribute)
        eventText.append(NSAttributedString(string: cellData.eventString!.rawValue, attributes: eventContentAttribute))
        cell.eventLabel.attributedText = eventText
        
        if cellData.eventString == .Like {
            cell.likedPhoto.isHidden = false
            //cell.likedPhoto.image = UIImage(data: cellData.likePhoto as Data)
        }else{
            cell.likedPhoto.isHidden = true
        }
        
        if (loadMoreEnable && indexPath.row == self.followerArray.count-1) {
            loadMoreData()
        }
 
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! FollowerCell
        let (item1, operation1) = imageOps[2*indexPath.row]
        let (item2, operation2) = imageOps[2*indexPath.row + 1]
        operation1?.cancel()
        operation2?.cancel()
        weak var weakCell = cell
        
        let newOp1 = ImageLoadOperation(forItem: item1, urlStr: followerArray[indexPath.row].followerPortrait!) { (image) in
            DispatchQueue.main.async {
                weakCell?.potraitImage = image
                weakCell?.displaypotraitImage()
            }
        }
        //print(postArray[indexPath.row].photo!)
        let newOp2 = ImageLoadOperation(forItem: item2, urlStr: followerArray[indexPath.row].likePhoto!) { (image) in
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
        let currentRow = self.followerArray.count
        let startIndex = currentRow + 1
        loadDataFromIndex(startIndex: startIndex)
        let newRow = self.followerArray.count
        self.tableView.reloadData()
        self.loadMoreEnable = newRow - currentRow >= 20
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
