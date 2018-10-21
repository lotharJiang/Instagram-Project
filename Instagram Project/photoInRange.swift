//
//  photoInRange.swift
//  Instagram Project
//
//  Created by LiuYuHan on 21/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//

import UIKit
import CoreBluetooth
import MultipeerConnectivity

class photoInRange: UITableViewController,MCNearbyServiceAdvertiserDelegate, MCSessionDelegate{
    
    
    
    let ColorServiceType = "photo"
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    var serviceAdvertiser : MCNearbyServiceAdvertiser?
    var session:MCSession?
    
    var imageArray = [photoInRangeCellData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.session?.delegate = self
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)
        self.serviceAdvertiser!.delegate = self
        self.serviceAdvertiser!.startAdvertisingPeer()
    }

    // MARK: - Table view data source

    @objc func refresh(){
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return imageArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! photoInRangeCell
        let imageCellData:photoInRangeCellData = imageArray[indexPath.row]
        let comtUserAttribute = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 13)]
        let comtContentAttribute = [NSAttributedStringKey.foregroundColor:UIColor.gray]
        let usernameLabelText = NSMutableAttributedString(string: imageCellData.username ?? "", attributes: comtUserAttribute)
        usernameLabelText.append(NSAttributedString(string: " sent you:", attributes: comtContentAttribute))
        cell.usernameLabel.attributedText = usernameLabelText

        cell.receivedImageView.image = imageCellData.receivedImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Received Image"
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        serviceAdvertiser!.stopAdvertisingPeer()
        
        invitationHandler(true,self.session)
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("start transmission")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        if let error = error {
            print(error)
        }
        else{
            
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        var imageCellData = photoInRangeCellData()
        imageCellData.receivedImage = UIImage(data: data)
        imageCellData.username = peerID.displayName
        self.imageArray.append(imageCellData)
        do{
            try self.session?.send("RECEIVED".data(using: .utf8)!, toPeers: [peerID], with: .reliable)
        }catch{
            print(error)
        }
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
}
