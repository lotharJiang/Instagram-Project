//
//  FindBluetooth.swift
//  Instagram Project
//
//  Created by LiuYuHan on 21/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit
import CoreBluetooth
import MultipeerConnectivity

struct bluetoothDevice {
    var peerID:MCPeerID?
    var name:String?
    var info:String?
}




class FindBluetooth: UITableViewController, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    
    
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    var connectedPeerID:MCPeerID?
    var serviceBrowser : MCNearbyServiceBrowser?
    var session:MCSession?
    
    
    var sendImage:UIImage?
    //var deviceArray:[bluetoothDevice] = [bluetoothDevice]()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var deviceList = [bluetoothDevice]()
    let ColorServiceType = "photo"
    
    override func viewDidLoad() {
        //print(myPeerId)
        super.viewDidLoad()
        self.title = "Select Device"
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.session?.delegate = self
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ColorServiceType)
        self.serviceBrowser!.delegate = self
        self.serviceBrowser!.startBrowsingForPeers()
        
        self.activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
    }

    // MARK: - Table view data source
    @objc func refresh(){
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return deviceList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.setSelected(false, animated: true)
        
        let peripheral = deviceList[indexPath.row]
        cell.textLabel!.text = peripheral.name
        cell.detailTextLabel!.text = peripheral.info
        //cell.detailTextLabel!.text = deviceArray[indexPath.row].info
        return cell
    }
    
    
   
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.connectedPeerID = self.deviceList[indexPath.row].peerID
        
        serviceBrowser!.stopBrowsingForPeers()
        serviceBrowser!.invitePeer(self.connectedPeerID!, to: self.session!, withContext: nil, timeout: 30)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("connected")
        case .connecting:
            print("commencting")
        default:
            print("not connected")
        }
        
        if state == .connected{
            DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            }
            let imageData = UIImagePNGRepresentation(self.sendImage!)
            do{
                try self.session?.send(imageData!, toPeers: [self.connectedPeerID!], with: .reliable)
            }
            catch{
                print(error)
            }
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if String(data: data, encoding: .utf8) == "RECEIVED"{
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            let alert = UIAlertController(title: "Success", message: "", preferredStyle: .alert);
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            });
            alert.addAction(okAction);
            DispatchQueue.main.async{
                self.present(alert,animated:true,completion:{
                    DispatchQueue.main.async{
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let blueD:bluetoothDevice = bluetoothDevice(peerID:peerID, name: peerID.displayName, info: "\(info ?? ["no":"no"])")
        self.deviceList.append(blueD)
        self.tableView.reloadData()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPEER")
    }
}
