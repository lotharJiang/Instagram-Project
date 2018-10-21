//
//  Discovery.swift
//  Instagram Project
//
//  Created by LiuYuHan on 14/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class Discovery: UITableViewController, UISearchBarDelegate  {
    @IBOutlet var searchBar: UISearchBar!
    var loginUser:String = String()
    var recommendArray:[discoveryCellData] = [discoveryCellData]()
    var loadMoreView:UIView?
    var loadMoreEnable = true
    var activityViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let imageLoadQueu = OperationQueue()
    var imageOps = [(Item, Operation?)]()
    var isSearching:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Discovery"
        let tabBarCtl:tabBar = self.tabBarController as! tabBar
        self.loginUser = tabBarCtl.loginUser
        
        self.editButtonItem.title = "Photo In Range"
        self.editButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12)], for: UIControlState.normal)
        self.editButtonItem.style = .plain
        self.editButtonItem.target = self
        self.editButtonItem.action = #selector(rightButtonAction)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        self.searchBar.delegate = self
        self.tableView.isUserInteractionEnabled = true
        
        
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func updateImageOps() {
        //print(self.photoArray)
        imageOps.removeAll()
        imageOps = Item.creatItems(count: recommendArray.count).map({ (images) -> (Item, Operation?) in
            return (images, nil)
        })
        DispatchQueue.main.async {
            self.activityViewIndicator.stopAnimating()
            self.tableView.reloadData()
        }
        
    }
    
    @objc func rightButtonAction(){
        let photoInRangeTVC:photoInRange = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "photoInRange") as! photoInRange
        self.navigationController?.pushViewController(photoInRangeTVC, animated: true)
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
        self.recommendArray.removeAll()
        //Load new data to postArray
        loadDataFromIndex(startIndex: 0)
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
    
    func loadDataFromIndex(startIndex:Int){
        //load 20 data from index to postArray (sorted by time)
        let url = NSURL(string:"http://115.146.84.191:3333/api/suggestedUser/\(loginUser)")
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
                    self.present(errorAlert,animated: false,completion: nil)
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
                        var aRecommandCellData:discoveryCellData = discoveryCellData()
                        aRecommandCellData.followerPortrait = jsonObj["profilePic"] as? String
                        aRecommandCellData.followerUsername = jsonObj["userEmail"] as? String
                        aRecommandCellData.followOrNot = false
                        
                        print(aRecommandCellData)
                        self.recommendArray.append(aRecommandCellData)
                    }
                    self.updateImageOps()
                    //whether we have more data
                    self.loadMoreEnable = self.recommendArray.count >= 10
                } catch {
                    print("Json Error: \(error)")
                }
            }
            
            
            
        }
        task.resume()
    }

    // MARK: - Table view data source
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recommendArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiscoveryCell
        cell.loginUser = self.loginUser
        
        cell.parentTVC = self
        let cellData:discoveryCellData = self.recommendArray[indexPath.row]
        cell.usernameLabel.text = cellData.followerUsername
        //print(cellData.followerUsername)
        //print(cellData.followOrNot)
        
        if (cellData.followOrNot!){
            cell.followButton.isSelected = false
        }else{
            cell.followButton.isSelected = true
        }
        
        if cellData.followerUsername == loginUser {
            cell.followButton.isHidden = true
        }
        else{
            cell.followButton.isHidden = false
        }
        
        // Configure the cell...
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! DiscoveryCell
        let (item1, operation1) = imageOps[indexPath.row]
        operation1?.cancel()
        weak var weakCell = cell
        
        let newOp1 = ImageLoadOperation(forItem: item1, urlStr: recommendArray[indexPath.row].followerPortrait!) { (image) in
            DispatchQueue.main.async {
                weakCell?.potraitImage = image
                weakCell?.displaypotraitImage()
            }
        }
        imageLoadQueu.addOperation(newOp1)
        imageOps[indexPath.row] = (item1, newOp1)
    }

    
    func loadMoreData(){
        loadMoreEnable = false
        self.activityViewIndicator.startAnimating()
        let currentRow = self.recommendArray.count
        let startIndex = currentRow + 1
        loadDataFromIndex(startIndex: startIndex)
        let newRow = self.recommendArray.count
        self.tableView.reloadData()
        self.loadMoreEnable = newRow - currentRow >= 20
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.resignFirstResponder()
        if(searchBar.text == "" ){
            self.isSearching = false
            refreshData()//redisplay recommand users
        }else{
            self.isSearching = true
            self.searchAction(userName: searchBar.text!)
        }
    }
    
    
    func searchBarTextDidEndEditing (_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
    }
    
    func searchAction(userName:String) {
        recommendArray.removeAll()
        
        let url = NSURL(string:"http://115.146.84.191:3333/api/searchUser/\(loginUser)/\(userName)")
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
                        var aRecommandCellData:discoveryCellData = discoveryCellData()
                        aRecommandCellData.followerPortrait = jsonObj["profilePic"] as? String
                        aRecommandCellData.followerUsername = jsonObj["email"] as? String
                        aRecommandCellData.followOrNot = jsonObj["isFollow"] as? Bool
                        
                        print(aRecommandCellData)
                        self.recommendArray.append(aRecommandCellData)
                    }
                    self.updateImageOps()
                    //whether we have more data
                    self.loadMoreEnable = self.recommendArray.count >= 10
                } catch {
                    print("Json Error: \(error)")
                }
            }
            
            
            
        }
        task.resume()
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching {
            return "Search Result"
        }
        else{
            return "Suggested User"
        }
    }
}
