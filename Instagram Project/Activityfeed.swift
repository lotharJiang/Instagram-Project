//
//  Activityfeed.swift
//  Instagram Project
//
//  Created by LiuYuHan on 13/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit

class Activityfeed: UIViewController {

    @IBOutlet var segmentControl: UISegmentedControl!
    var followingTVC:Following = UIStoryboard(name: "Main", bundle:
        nil).instantiateViewController(withIdentifier: "Following") as! Following
    var youTVC:You = UIStoryboard(name: "Main", bundle:
        nil).instantiateViewController(withIdentifier: "You") as! You
    var currentTVC:UITableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followingTVC.tabBarCtl = self.tabBarController as? tabBar
        youTVC.tabBarCtl = self.tabBarController as? tabBar
        currentTVC = youTVC
        self.segmentControl.selectedSegmentIndex = 1
        self.addChildViewController(youTVC)
        self.view.addSubview(youTVC.view)
        youTVC.didMove(toParentViewController: self)
        
        print(self.childViewControllers)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source

    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch self.segmentControl.selectedSegmentIndex {
        case 0:
            self.replace(oldVC: self.currentTVC!, byNewVC: self.followingTVC)
        default:
            self.replace(oldVC: self.currentTVC!, byNewVC: self.youTVC)
        }
        
        
    }
    
    func replace(oldVC old:UITableViewController, byNewVC new:UITableViewController){
        self.addChildViewController(new)
        print(self.childViewControllers)
        self.transition(from: old, to: new, duration: 0.0, options: .curveEaseIn, animations: nil) { (finished) in
            if finished{
                old.willMove(toParentViewController: nil)
                old.view.removeFromSuperview()
                old.removeFromParentViewController()
                print(self.childViewControllers)
                new.didMove(toParentViewController: self)
                self.view.addSubview(new.view)
                self.currentTVC = new
            }
        }
        
        
        
        
        
        
        self.currentTVC = new
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
