//
//  CameraPost.swift
//  Instagram Project
//
//  Created by LiuYuHan on 14/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

enum FilterType:Int{
    case ORIGINAL = 0, VIVID, MONO, VAGUE;
}


class CameraPost: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate,UIPopoverPresentationControllerDelegate {
    
    
    var loginUser:String = String()
    @IBOutlet var filterTypeLabel: UILabel!
    @IBOutlet var filterStepper: UIStepper!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet var swipeRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var displayImageView: UIImageView!
    @IBOutlet var brightSlider: UISlider!
    @IBOutlet var contrastSlider: UISlider!
    
    
    
    
    var uploadAlertController:UIAlertController!
    var imagePickerController:UIImagePickerController!
    var originalImage:UIImage?
    var currentFilterType:FilterType = .ORIGINAL
    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation!
    var lock = NSLock()
    let activityIncicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Post"
        let tabBarCtl:tabBar = self.tabBarController as! tabBar
        self.loginUser = tabBarCtl.loginUser
        
        //location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 50 //m
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        
        self.initAlertController()
        //self.initAlertController()
        self.initImagePickerController()
        //commentTextView.clearsOnInsertion = true
        commentTextView.delegate = self
        
        self.editButtonItem.title = "Done"
        self.editButtonItem.style = .done
        self.editButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16)], for: UIControlState.normal)
        self.editButtonItem.target = self
        self.editButtonItem.action = #selector(doneAction)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        // Do any additional setup after loading the view.
        
        activityIncicator.center = self.view.center
        self.view .addSubview(activityIncicator)
        
        
        
    }
    
    @IBAction func tapResponse(_ sender: UITapGestureRecognizer) {
        //print("touched")
        self.commentTextView.resignFirstResponder()
        if tapRecognizer.numberOfTouches == 1{
            retake()
        }
    }
    
    
    @IBAction func swipeResponse(_ sender: Any) {
        print("swiped")
        if self.displayImageView.image != nil{
            let bluetoothTVC:FindBluetooth = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FindBluetooth") as! FindBluetooth
            bluetoothTVC.sendImage = self.displayImageView.image
            self.navigationController?.pushViewController(bluetoothTVC, animated: true)
        }
    }
    
    
    @IBAction func changeFilterType(_ sender: UIStepper) {
        let value:Int = Int(exactly: filterStepper.value)!
        currentFilterType = FilterType(rawValue: value)!
        if originalImage != nil {
            switch currentFilterType {
            case .ORIGINAL:
                filterTypeLabel.text = "ORIGINAL"
                self.displayImageView.image = originalImage
                break
            case .VIVID:
                filterTypeLabel.text = "VIVID"
                self.displayImageView.image = vividImage(original: originalImage!)
                break
            case .MONO:
                filterTypeLabel.text = "MONO"
                self.displayImageView.image = monoImage(original: originalImage!)
                break
            default:
                filterTypeLabel.text = "VAGUE"
                self.displayImageView.image = vagueImage(original: originalImage!)
                break
            }
        }
        else{
        switch currentFilterType {
        case .ORIGINAL:
            filterTypeLabel.text = "ORIGINAL"
            //self.displayImageView.image = originalImage
            break
        case .VIVID:
            filterTypeLabel.text = "VIVID"
            //self.displayImageView.image = vividImage(original: originalImage!)
            break
        case .MONO:
            filterTypeLabel.text = "MONO"
            //self.displayImageView.image = monoImage(original: originalImage!)
            break
        default:
            filterTypeLabel.text = "VAGUE"
            //self.displayImageView.image = vagueImage(original: originalImage!)
            break
        }
        }
    }
    
    func retake(){
        self.initAlertController()
    }
    
    @objc func doneAction(){
        //var imageDataString:String?
        //let path:String? = Bundle.main.path(forResource: "tmpImage", ofType: "jpeg")
        self.activityIncicator.startAnimating()
        if self.displayImageView.image != nil{
            let imageData = UIImagePNGRepresentation(self.displayImageView.image!)
                //UIImageJPEGRepresentation(self.displayImageView.image!,0.5)
            let commentText:String = commentTextView.text
            if commentText == ""{
                
            }
            let url = NSURL(string:"http://115.146.84.191:3333/api/postIns")
            let request = NSMutableURLRequest(url:url! as URL)
            request.httpMethod = "POST"
            
            var lati:CLLocationDegrees = CLLocationDegrees(exactly: 0.0)!
            var logi:CLLocationDegrees = CLLocationDegrees(exactly: 0.0)!
            if currentLocation != nil{
                lati = ((currentLocation as CLLocation).coordinate.latitude)
                logi = ((currentLocation as CLLocation).coordinate.longitude)
            }
            
            let boundary:String = "-------------------21212222222222222222222"
            request.setValue("multipart/form-data;boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let body = NSMutableData()
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\("userEmail")\"\r\n".data(using: .utf8)!)
            body.append("Content-Type:text/plain;charset=utf-8\r\n\r\n".data(using: .utf8)!)
            body.append("\(loginUser)\r\n".data(using: .utf8)!)
            
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\("comment")\"\r\n".data(using: .utf8)!)
            body.append("Content-Type:text/plain;charset=utf-8\r\n\r\n".data(using: .utf8)!)
            body.append("\(commentText)\r\n".data(using: .utf8)!)
            
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\("lat")\"\r\n".data(using: .utf8)!)
            body.append("Content-Type:text/plain;charset=utf-8\r\n\r\n".data(using: .utf8)!)
            body.append("\(lati)\r\n".data(using: .utf8)!)
            
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\("log")\"\r\n".data(using: .utf8)!)
            body.append("Content-Type:text/plain;charset=utf-8\r\n\r\n".data(using: .utf8)!)
            body.append("\(logi)\r\n".data(using: .utf8)!)
            
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"postPic\"; filename=\"tmpImage.png\"\r\n".data(using: .utf8)!)
            body.append("Content-Type:application/octet-stream\r\n\r\n".data(using: .utf8)!)
            
            body.append(imageData!)
            body.append("\r\n--\(boundary)".data(using: .utf8)!)
            
            request.httpBody = body as Data
            
            let task = URLSession.shared.dataTask(with: request as URLRequest){
                data, response, error in
                DispatchQueue.main.async {
                    self.activityIncicator.stopAnimating()
                }
                if let anError = error {
                    print("\(anError)")
                    let alert = UIAlertController(title: "Error", message: "\(anError.localizedDescription)", preferredStyle: .alert);
                    let okAction = UIAlertAction(title: "Try again", style: .default, handler: nil);
                    alert.addAction(okAction);
                    self.present(alert,animated:true,completion:nil)
                }
                else{
                    let receiveString = String(data: data!, encoding: String.Encoding.utf8)
                    print("Received:"+receiveString!)
                    let alert = UIAlertController(title: "Success", message: "Post successfully.", preferredStyle: .alert);
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil);
                    alert.addAction(okAction);
                    DispatchQueue.main.async {
                        self.present(alert,animated:true,completion:{
                            DispatchQueue.main.async {
                                self.tabBarController?.selectedIndex = 0
                            }
                        })
                    }
                }
            }
            task.resume()
            
        }
        else{
            self.activityIncicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "You have to take a photo", preferredStyle: .alert);
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil);
            alert.addAction(okAction);
            self.present(alert,animated:true,completion:nil)
        }
    }
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if let error = error{
            print(error.localizedDescription)
        }
    }
    
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
            let overlayView:UIImageView = UIImageView(image: UIImage(named: "330.png"))
            overlayView.frame = CGRect(x: 0, y: 120, width: self.imagePickerController.view.frame.size.width, height: self.imagePickerController.view.frame.size.height-310)
            //overlayView.frame = self.imagePickerController.view.frame
            overlayView.backgroundColor = UIColor.clear
            self.imagePickerController.cameraOverlayView = overlayView
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
            self.originalImage = ImageProcess().sacleImageTo(image: img, size: self.displayImageView.frame.size)
            self.displayImageView.image = self.originalImage
            if picker.sourceType == .camera{
                UIImageWriteToSavedPhotosAlbum(self.displayImageView.image!, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
            }
            picker.dismiss(animated:true, completion:nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        picker.dismiss(animated:true, completion:nil)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bluetoothDevice" {
            //let popoverViewController = segue.destination
            
            
            
        }
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.formSheet
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        self.commentTextView.frame.origin.y += 260
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.commentTextView.frame.origin.y -= 250
        self.commentTextView.text = ""
        return true
    }
    
    private func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text.contains("\n") {
            self.view.endEditing(true)
            return false
        }
        return true
    }
    
    
    func vagueImage(original:UIImage?) -> UIImage? {
        if let tmp = original{
        let inputImage =   CIImage(image: tmp)
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(inputImage, forKey:kCIInputImageKey)
        filter.setValue(2, forKey: kCIInputRadiusKey)
        let outputCIImage = filter.outputImage!
        let rect = CGRect(origin: CGPoint.zero, size: tmp.size)
        let cgImage = context.createCGImage(outputCIImage, from: rect)
        return UIImage(cgImage: cgImage!)
        }
        else{
            return nil
        }
    }
    
    func vividImage(original:UIImage?) -> UIImage?{
        if let tmp = original{
        let inputImage =  CIImage(image: tmp)
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(inputImage, forKey:kCIInputImageKey)
        filter.setValue(0.05, forKey: kCIInputBrightnessKey)
        filter.setValue(0.9, forKey: kCIInputSaturationKey)
        let outputCIImage = filter.outputImage!
        let rect = CGRect(origin: CGPoint.zero, size: tmp.size)
        let cgImage = context.createCGImage(outputCIImage, from: rect)
        return UIImage(cgImage: cgImage!)
        }
        else{
            return nil
        }
    }
    
    func adjustBrightness(original:UIImage?, brightness:Float) -> UIImage?{
        if let tmp = original{
            let inputImage =  CIImage(image: tmp)
            let filter = CIFilter(name: "CIColorControls")!
            filter.setValue(inputImage, forKey:kCIInputImageKey)
            filter.setValue(brightness, forKey: kCIInputBrightnessKey)
            //filter.setValue(0.9, forKey: kCIInputSaturationKey)
            let outputCIImage = filter.outputImage!
            let rect = CGRect(origin: CGPoint.zero, size: tmp.size)
            let cgImage = context.createCGImage(outputCIImage, from: rect)
            return UIImage(cgImage: cgImage!)
        }
        else{
            return nil
        }
    }
    
    func adjustContrast(original:UIImage?, contrast:Float) -> UIImage?{
        if let tmp = original{
            let inputImage =  CIImage(image: tmp)
            let filter = CIFilter(name: "CIColorControls")!
            filter.setValue(inputImage, forKey:kCIInputImageKey)
            filter.setValue(contrast, forKey: kCIInputContrastKey)
            //filter.setValue(0.9, forKey: kCIInputSaturationKey)
            let outputCIImage = filter.outputImage!
            let rect = CGRect(origin: CGPoint.zero, size: tmp.size)
            let cgImage = context.createCGImage(outputCIImage, from: rect)
            return UIImage(cgImage: cgImage!)
        }
        else{
            return nil
        }
    }
    
    func adjustBrightnessAndContrast(original:UIImage?,brighteness:Float, contrast:Float) -> UIImage?{
        if let tmp = original{
            let inputImage =  CIImage(image: tmp)
            let filter = CIFilter(name: "CIColorControls")!
            filter.setValue(inputImage, forKey:kCIInputImageKey)
            filter.setValue(contrast, forKey: kCIInputContrastKey)
            filter.setValue(brighteness, forKey: kCIInputBrightnessKey)
            let outputCIImage = filter.outputImage!
            let rect = CGRect(origin: CGPoint.zero, size: tmp.size)
            let cgImage = context.createCGImage(outputCIImage, from: rect)
            return UIImage(cgImage: cgImage!)
        }
        else{
            return nil
        }
    }
    
    
    func monoImage(original:UIImage?) -> UIImage?{
        if let tmp = original{
        let inputImage = CIImage(image: tmp)
        let filter = CIFilter(name:"CISepiaTone")!
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0.8, forKey: "inputIntensity")
        let outputCIImage = filter.outputImage!
        let rect = CGRect(origin: CGPoint.zero, size: tmp.size)
        let cgImage = context.createCGImage(outputCIImage, from: rect)
        return UIImage(cgImage: cgImage!)
        }
        else{
            return nil
        }
        
    }
    
    @IBAction func brightSliderAction(_ sender: Any) {
        if originalImage != nil{
            self.displayImageView.image = self.adjustBrightnessAndContrast(original: originalImage!, brighteness: self.brightSlider.value, contrast: 1-self.contrastSlider.value)
        }
    }
    
    
    @IBAction func contrastSliderAction(_ sender: Any) {
        if originalImage != nil{
            self.displayImageView.image = self.adjustBrightnessAndContrast(original: originalImage!, brighteness: self.brightSlider.value, contrast: 1-self.contrastSlider.value)
        }
    }
    
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


