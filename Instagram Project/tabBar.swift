//
//  tabBar.swift
//  Instagram Project
//
//  Created by LiuYuHan on 12/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class tabBar: UITabBarController {
    
    var parentVC:Login?
    var loginUser:String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
