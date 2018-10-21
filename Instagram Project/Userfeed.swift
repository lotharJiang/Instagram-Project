//
//  Userfeed.swift
//  Instagram Project
//
//  Created by LiuYuHan on 2/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit
import CoreLocation

enum sortType {
    case Time
    case Location
}

class Userfeed: UITableViewController, CLLocationManagerDelegate {
    
    var loginUser:String = String()
    var postArray = [postCellData]()
    var loadMoreView:UIView?
    var loadMoreEnable = true
    var currentSortType:sortType = .Time
    var activityViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let imageLoadQueu = OperationQueue()
    var imageOps = [(Item, Operation?)]()
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation!
    var lock = NSLock()
    
    
    var currentTen:NSMutableArray?
    //var lastPostID:String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarCtl:tabBar = self.tabBarController as! tabBar
        self.loginUser = tabBarCtl.loginUser
        //print("\(self.loginUser)")
        
        self.title = "Instagram"
        
        //location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 50 //m
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Refreshing")
        
        
        self.tableView.isScrollEnabled = true
        self.tableView.allowsSelection = false
        self.setupInfiniteScrollingView()
        self.tableView.tableFooterView = self.loadMoreView
        self.tableView.separatorStyle = .none
        
        self.editButtonItem.title = "Sort By Location"
        self.editButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12)], for: UIControlState.normal)
        self.editButtonItem.style = .plain
        self.editButtonItem.target = self
        self.editButtonItem.action = #selector(sortButtonAction)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        currentTen = NSMutableArray()
        
        imageLoadQueu.maxConcurrentOperationCount = 4
        imageLoadQueu.qualityOfService = .userInitiated
        
        //self.refreshControl!.beginRefreshing()
        refreshData()
    }

    override func viewDidAppear(_ animated: Bool) {
        //self.refreshData()
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
    
    @objc func sortButtonAction(){
        if self.editButtonItem.title == "Sort By Location"{
            self.editButtonItem.title = "Sort By Time"
            self.currentSortType = .Location
            self.postArray.removeAll()
            loadDataFromIndex(startIndex: 0)
        }
        else{
            self.editButtonItem.title = "Sort By Location"
            self.postArray.removeAll()
            self.currentSortType = .Time
            loadDataFromIndex(startIndex: 0)
        }
        self.tableView.reloadData()
    }
    
    
    
    @objc func refreshData(){
        self.postArray.removeAll()
        //Load new data to postArray
        loadDataFromIndex(startIndex: 0)
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
    
    func loadDataFromIndex(startIndex:Int){
        var postID = "-1"
        if startIndex != 0 {
            postID = self.postArray[startIndex].postID ?? "-1"
        }
        
        if currentSortType == .Location {
            var lati:CLLocationDegrees = CLLocationDegrees(exactly: 0.0)!
            var logi:CLLocationDegrees = CLLocationDegrees(exactly: 0.0)!
            
            if currentLocation != nil{
                lati = ((currentLocation as CLLocation).coordinate.latitude)
                logi = ((currentLocation as CLLocation).coordinate.longitude)
            }
            
            //load 10 data from index to postArray (sorted by location)
            
            var url = NSURL(string:"http://115.146.84.191:3333/api/acquireLatestPostsByLocation/")
            
            if postID == "-1"{//Refresh
                url = NSURL(string:"http://115.146.84.191:3333/api/acquireLatestPostsByLocation/")
            }else{//Load More
                url = NSURL(string:"http://115.146.84.191:3333/api/acquireOldPostsByLocation/")
            }
            
            let request = NSMutableURLRequest(url:url! as URL);
            request.httpMethod = "POST";
            let postString = "userEmail=\(loginUser)&lat=\(lati)&lon=\(logi)&lastPostID=\(postID)&postID=\(self.currentTen)"
            request.httpBody = postString.data(using: .utf8)
            
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
                    self.currentTen?.removeAllObjects()
                    do {
                        let json:NSDictionary = try JSONSerialization.jsonObject(with: data!) as! NSDictionary
                        let jsonData:NSArray = json["data"]! as! NSArray
                        for jsonObject in jsonData{
                            
                            
                            let jsonObj:NSDictionary = jsonObject as! NSDictionary
                            var aPostCellData:postCellData = postCellData()
                            aPostCellData.postID = "\(jsonObj["postID"] as? Int ?? 0)"
                            self.currentTen?.add(aPostCellData.postID!)
                            aPostCellData.username = jsonObj["username"] as? String
                            aPostCellData.location = jsonObj["location"] as? String
                            aPostCellData.portait = jsonObj["portrait"] as? String
                            aPostCellData.photo = jsonObj["photo"] as? String
                            aPostCellData.isLike = jsonObj["isLike"] as? Bool
                            aPostCellData.likes = jsonObj["likes"] as? Int
                            aPostCellData.commentUser = jsonObj["commentUser"] as? String
                            aPostCellData.commentContent = jsonObj["commentContent"] as? String
                            aPostCellData.date = jsonObj["date"] as? Int
                            aPostCellData.likeUserNames = jsonObj["likeUser"] as? String
                            //print(aPostCellData)
                            self.postArray.append(aPostCellData)
                        }
                        //self.lastPostID = self.currentTen?.lastObject as! String
                        self.updateImageOps()
                        //whether we have more data
                        self.loadMoreEnable = self.postArray.count >= 10
                    } catch {
                        print("Json Error: \(error)")
                    }
                }
            }
            task.resume()
            
        }
            
            
            
        else if currentSortType == .Time{
            //load 10 data from index to postArray (sorted by time)
            let url = NSURL(string:"http://115.146.84.191:3333/api/acquireLatestPostsByTime/\(loginUser)/\(postID)")
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
                            aPostCellData.likeUserNames = jsonObj["likeUser"] as? String
                            //print(aPostCellData)
                            self.postArray.append(aPostCellData)
                            //"[postID, portrait, isLike, date, username, photo, likes, commentContent, commentUser]"
                        }
                        self.updateImageOps()
                        //whether we have more data
                        self.loadMoreEnable = self.postArray.count >= 10
                    } catch {
                        print("Json Error: \(error)")
                    }
                }
            }
            task.resume()
            
        }
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
        if cellData.likeUserNames != nil{
            cell.likeLabel.text = "\(cellData.likes ?? 0) likes: \(cellData.likeUserNames!)"
        }
        else{
            cell.likeLabel.text = "\(cellData.likes ?? 0) likes"
        }
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
        //print(postArray[indexPath.row].photo!)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lock.lock()
        currentLocation = locations.last
        //print("\(currentLocation.coordinate.latitude)")
        //print("\(currentLocation.coordinate.longitude)")
        lock.unlock()
        //locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error Location！！\(error)")
    }
    
    
}
