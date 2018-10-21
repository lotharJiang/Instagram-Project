//
//  Profile.swift
//  Instagram Project
//
//  Created by LiuYuHan on 13/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class Profile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var portrait: UIImageView!
    @IBOutlet var postNoLabel: UILabel!
    @IBOutlet var followerNoLabel: UILabel!
    @IBOutlet var followingNoLabel: UILabel!
    @IBOutlet var photoDisplayView: UIView!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    
    var refreshControl: UIRefreshControl!
    var photoCollectionVC:PhotoCollection?
    var loginUser:String = String()
    var parentVC:Login?
    
    
    var uploadAlertController:UIAlertController!
    var imagePickerController:UIImagePickerController!
    var originalImage:UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.refreshControl = UIRefreshControl()
        self.scrollView.refreshControl!.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.scrollView.refreshControl!.attributedTitle = NSAttributedString(string: "Refreshing")
        
        self.loginUser = (self.tabBarController as! tabBar).loginUser
        self.parentVC = (self.tabBarController as! tabBar).parentVC
        self.title = self.loginUser
        
        self.portrait.backgroundColor = UIColor.gray
        self.portrait.layer.masksToBounds = true
        self.portrait.layer.cornerRadius = self.portrait.frame.width / 2.0
        
        self.photoCollectionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoCollection") as? PhotoCollection
        self.photoCollectionVC?.parentVC = self
        self.photoCollectionVC?.loginUser = loginUser
    self.photoDisplayView.addSubview(self.photoCollectionVC!.view)
        
        //let (postNo, followerNo, followingNo) = self.requestStatus()
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            self.requestStatus()
        }
        globalQueue.async {
            self.requestPortrait()
        }
        
        self.initImagePickerController()
        //self.postNoLabel.text = "\(postNo)"
        //self.followerNoLabel.text = "\(followerNo)"
        //self.followingNoLabel.text = "\(followingNo)"
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func refreshData(){
        self.refreshStatus()
        photoCollectionVC?.requestPhotoArray()
        self.scrollView.refreshControl!.endRefreshing()
    }
    
    func refreshStatus(){
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            self.requestStatus()
        }
        globalQueue.async {
            self.requestPortrait()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
        photoCollectionVC?.collectionView?.performBatchUpdates({
            photoCollectionVC?.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
        }, completion: nil)
        */
        //photoCollectionVC?.requestPhotoArray()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestStatus() {//}-> (Int, Int, Int) {
//        var postNo:Int = 0
//        var followerNo:Int = 0
//        var followingNo:Int = 0
        
        let url = NSURL(string:"http://115.146.84.191:3333/api/acquireUserInfo/\(self.loginUser)")
        let request = NSMutableURLRequest(url:url! as URL);
        request.httpMethod = "GET";
        //let postString="\(self.loginUser)"
        
        //request.httpBody = postString.data(using: .utf8);
        
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
                //print("Received:"+receiveString!)
                let stringPart = receiveString!.split(separator: ",")
                if stringPart.count == 3 {
                    DispatchQueue.main.async { //
                    self.postNoLabel.text = "\(stringPart[0])"
                    self.followerNoLabel.text = "\(stringPart[1])"
                    self.followingNoLabel.text = "\(stringPart[2])"
                    }
                    //postNo = Int(stringPart[0])!
                    //followerNo = Int(stringPart[1])!
                    //followingNo = Int(stringPart[2])!
                }
            }
        }
        task.resume()
        
        //return (postNo, followerNo, followingNo)
    }

    func requestPortrait() {//}-> (String){
        //var portraitURLString = String()
        
        let url = NSURL(string:"http://115.146.84.191:3333/api/acquirePortrait/\(self.loginUser)")
        let request = NSMutableURLRequest(url:url! as URL);
        request.httpMethod = "GET";
        //let postString="\(self.loginUser)"
        
        //request.httpBody = postString.data(using: .utf8);
        
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
                //print("Received:"+receiveString!)
                if let receive = receiveString{
                    let portraitOriginal:UIImage? = ImageProcess().convertToImageFrom(URLString: receive)
                    DispatchQueue.main.async { //
                    self.portrait.image = portraitOriginal
                    }
                }
            }
        }
        task.resume()
        //return portraitURLString
    }
    
    
    
    @IBAction func logOut(_ sender: Any) {
        let userdefault = UserDefaults.standard
        userdefault.setValue(nil, forKey: "LoginUser")
        userdefault.synchronize()
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! Login
        self.present(loginVC, animated: false, completion: nil)
    }
    
    
    @IBAction func uploadPortrait(_ sender: UITapGestureRecognizer) {
        self.initAlertController()
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showphoto" {
            let destinationVC:ShowPhoto = segue.destination as! ShowPhoto
            destinationVC.image = sender as? UIImage
            destinationVC.displayPhoto()
        }
    }
    
    
    
    
    //camera
    func initAlertController()
    {
        weak var blockSelf = self
        self.uploadAlertController = UIAlertController(title:nil, message: nil, preferredStyle:UIAlertControllerStyle.actionSheet)
        self.uploadAlertController.view.tintColor = UIColor.blue
        let takePhoto = UIAlertAction(title:"Take Photo", style:UIAlertActionStyle.default) { (action:UIAlertAction)in
            blockSelf?.actionAction(action: action)
        }
        let photoLib = UIAlertAction(title:"Choose From Library", style:UIAlertActionStyle.default) { (action:UIAlertAction)in
            blockSelf?.actionAction(action: action)
        }
        
        let cancel = UIAlertAction(title:"Cancel", style:UIAlertActionStyle.cancel)
        self.uploadAlertController?.addAction(takePhoto)
        self.uploadAlertController?.addAction(photoLib)
        self.uploadAlertController?.addAction(cancel)
        self.present(self.uploadAlertController, animated: true, completion: nil)
    }
    
    func initImagePickerController()
    {
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = true
    }
    
    func actionAction(action:UIAlertAction)
    {
        if action.title == "Take Photo" {
            self.getImageFromPhotoLib(type: .camera)
        }
        else if action.title == "Choose From Library"
        {
            self.getImageFromPhotoLib(type: .photoLibrary)
            
        }
    }
    
    func getImageFromPhotoLib(type:UIImagePickerControllerSourceType)
    {
        self.imagePickerController.sourceType = type
        
        if type == .camera {
            self.imagePickerController.showsCameraControls = true
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.cameraDevice = .front
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.present(self.imagePickerController, animated: true, completion:nil)
        }
    }
    
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [String :Any])
    {
        let type:String = (info[UIImagePickerControllerMediaType]as!String)
        if type=="public.image"
        {
            let img = info[UIImagePickerControllerOriginalImage]as?UIImage
            self.originalImage = ImageProcess().sacleImageTo(image: img, size: self.portrait.frame.size)
            self.portrait.image = self.originalImage
            if picker.sourceType == .camera{
                UIImageWriteToSavedPhotosAlbum(self.portrait.image!, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
            }
            picker.dismiss(animated:true, completion:{
                self.uploadPortrait()
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        picker.dismiss(animated:true, completion:nil)
    }
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if let error = error{
            print(error.localizedDescription)
        }
    }
    
    
    func uploadPortrait(){
        //upload
    }
    
    
}
