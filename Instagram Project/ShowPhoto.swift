//
//  ShowPhoto.swift
//  Instagram Project
//
//  Created by LiuYuHan on 14/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class ShowPhoto: UIViewController {

    @IBOutlet var imageView: UIImageView! = UIImageView()
    @IBOutlet var tapRecognizor: UITapGestureRecognizer!
    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func tapOnImage(_ sender: UITapGestureRecognizer) {
        
        if tapRecognizor.numberOfTouches == 1 {
            //print("touched")
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func displayPhoto() {
        imageView.center = self.view.center
        imageView.frame.size = image!.size
        
        //imageView.frame = CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!)
        print(imageView.frame)
        self.imageView.image = image
        self.view .addSubview(imageView)
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
