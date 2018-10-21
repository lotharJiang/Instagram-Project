//
//  PhotoCollection.swift
//  Instagram Project
//
//  Created by LiuYuHan on 13/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

struct photoData {
    var photoID:String
    var photoURLString:String
}

private let reuseIdentifier = "Cell"

class PhotoCollection: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var parentVC:Profile?
    var loginUser:String = String()
    var photoArray:[photoData] = [photoData]()
    
    let imageLoadQueu = OperationQueue()
    var imageOps = [(Item, Operation?)]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.performSelector(onMainThread:#selector(requestPhotoArray), with: nil, waitUntilDone: true)
        
        
        
        self.requestPhotoArray()
        
        //print(photoArray)
        
        /*
        for i in 1...10{
            var urlString = String()
            if i % 2 == 0{
            urlString = "http://115.146.84.191/UserPost/1538830927423.png"
            }
            else{
                urlString = "http://115.146.84.191/UserPost/test.jpg"
            }
            let tmp:photoData = photoData(photoID: "\(i)", photoURLString: urlString)
            photoArray.append(tmp)
        }
        */
        imageLoadQueu.maxConcurrentOperationCount = 4
        imageLoadQueu.qualityOfService = .userInitiated
        
//        imageOps = Item.creatItems(count: photoArray.count).map({ (images) -> (Item, Operation?) in
//            return (images, nil)
//        })
        //print(imageOps)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(photoCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView?.reloadData()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        //self.requestPhotoArray()
    }
    
    func refreshData() {
        //print(self.photoArray)
        imageOps.removeAll()
        imageOps = Item.creatItems(count: photoArray.count).map({ (images) -> (Item, Operation?) in
            return (images, nil)
        })
        self.collectionView?.reloadData()
    }
    
    @objc func requestPhotoArray(){
        self.photoArray.removeAll()
        let url = NSURL(string:"http://115.146.84.191:3333/api/acquireUserPosts/\(self.loginUser)")
        let request = NSMutableURLRequest(url:url! as URL);
        request.httpMethod = "GET";
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            if let anError = error {
                print("\(anError.localizedDescription)")
                DispatchQueue.main.async(execute:{
                    let errorAlert = UIAlertController(title: "Error", message: "Unable to load data. Please check your network settings and try again", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    errorAlert.addAction(action)
                    self.present(errorAlert,animated: true,completion: nil)
                })
            }
            if data != nil {
                let receiveString = String(data: data!, encoding: String.Encoding.utf8)
                print("Received:"+receiveString!)
                
                let stringPart = receiveString!.split(separator: ",")
                for i in 0..<stringPart.count{
                    let tmp:photoData = photoData(photoID: "\(i)", photoURLString: String(stringPart[i]))
                    self.photoArray.append(tmp)
                }
                DispatchQueue.main.async { //
                    self.refreshData()
                }
            }
        }
        task.resume()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageOps.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! photoCollectionCell
        cell.imageView.image = nil
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width / 4.0, height: self.view.frame.size.width / 4.0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        
        let cell = collectionView.cellForItem(at: indexPath) as! photoCollectionCell
        let photo = cell.image
        self.parentVC?.performSegue(withIdentifier: "showphoto", sender: photo)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! photoCollectionCell
        let (item, operation) = imageOps[indexPath.row]
        operation?.cancel()
        weak var weakCell = cell
        
        let newOp = ImageLoadOperation(forItem: item, urlStr: photoArray[indexPath.row].photoURLString) { (image) in
            DispatchQueue.main.async {
                weakCell?.image = image
                weakCell?.display()
            }
        }
        imageLoadQueu.addOperation(newOp)
        imageOps[indexPath.row] = (item, newOp)
    }
    
    
    
    // MARK: UICollectionViewDelegate



    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
