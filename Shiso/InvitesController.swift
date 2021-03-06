//
//  InvitesController.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 12/30/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit



class InvitesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
  //  var tableView = UITableView()
    var invites: [Invite]? {
        didSet {
            print("item added/dropped from invites in Invites Controller. Count is: \(invites?.count)")
            DispatchQueue.main.async {
                print("re-loading data")
                self.tableView.reloadData()
                
            }
        }
    }
    var backBtn: UIButton = {
        let bb = UIButton()
        bb.frame = CGRect(origin: CGPoint(x: 10, y: 30), size: CGSize(width: 50, height: 50))
        bb.layer.cornerRadius = 3
        bb.backgroundColor = .white
        
        bb.setImage(UIImage(named: "homeBtnImage"), for: .normal)
        
        return bb
    }()

   var tableView: UITableView  = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    var headerTitle = UILabel()
    var nChallenges: Int = 0 {
        didSet {
            headerTitle.text = "Challenges (\(nChallenges))"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
         Fire.dataService.loadInvites {
           
        (loadedInvites)
            in
             print("Loaded invites....")
            //print("in closure with loaded invites: \(loadedInvites)")
            if let inviteList = loadedInvites {
                self.nChallenges = inviteList.count
                print("loadedInvites count= \(loadedInvites?.count) invite list count: \(inviteList.count)")
                self.invites = inviteList
                self.invites?.sort(by: { (invite1, invite2)
                    in
                    
                    invite1.timestamp > invite2.timestamp
                    
                })
                
             
              /*  if loadedInvites?.count == 0 {
                    let noChallengesLbl = UILabel()
                    noChallengesLbl.text = "You have 0 challenges."
                    self.view.addSubview(noChallengesLbl)
                    noChallengesLbl.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 100)
                    noChallengesLbl.font = UIFont(name: GameConstants.FontArialBoldMT, size: 20)
                    let xPos = (self.view.frame.size.width - noChallengesLbl.frame.size.width)/2
                    noChallengesLbl.frame.origin.x = xPos
                    noChallengesLbl.frame.origin.y = self.tableView.frame.minY + noChallengesLbl.frame.size.height
                    
                    
                    
                }
              */
            }
            
           
        }
        view.addSubview(backBtn)
        print("presenting in view did load: \(presentingViewController)")
        backBtn.addTarget(self, action: #selector(backBtnPushed), for: .touchUpInside)
        
        
        view.backgroundColor = .blue
        
 /*
         tableView = UITableView(frame: CGRect(x: view.frame.midX - 150, y: view.frame.midY - 150, width: 300, height: 300), style: UITableView.Style.plain)
        */
        
        view.addSubview(tableView)
        
      
        tableView.delegate  = self
        tableView.dataSource = self
        tableView.register(InviteCell.self, forCellReuseIdentifier: "inviteCell")
         
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
           tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
           tableView.topAnchor.constraint(equalTo: backBtn.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
            
        let header = UIView()
        header.backgroundColor = .lightGray
        
        header.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
       // headerTitle = UILabel(frame: CGRect(origin: CGPoint(x: header.frame.midX, y: header.frame.midY ) , size: CGSize(width: 200, height: 30)))
        headerTitle = UILabel()
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(headerTitle)
        headerTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor).isActive = true
        headerTitle.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        headerTitle.widthAnchor.constraint(equalTo: header.widthAnchor).isActive = true
            headerTitle.heightAnchor.constraint(equalTo: header.heightAnchor).isActive = true
            
        headerTitle.text = "Challenges: \(invites?.count ?? 0)"
        headerTitle.font = UIFont.boldSystemFont(ofSize: 18)
        headerTitle.textAlignment = .center
        
        tableView.tableHeaderView = header
        
        
     
       
    }
   
    
    
    @objc func backBtnPushed() {
     self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inviteCell = tableView.dequeueReusableCell(withIdentifier: "inviteCell", for: indexPath) as! InviteCell
        inviteCell.invite = invites?[indexPath.row]
        let ts = inviteCell.invite!.timestamp
        let inviteDt = Date(timeIntervalSince1970: TimeInterval(ts))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let inviteDt_str = dateFormatter.string(from: inviteDt)
        
        inviteCell.textLabel?.text = "\(inviteCell.invite?.senderUserName ?? "N/A"): \(inviteDt_str)"
        inviteCell.invitesController = self
        if let presentingVC = self.presentingViewController as? GameDisplayTableVC {
            inviteCell.gameDisplayVC = presentingVC
        }
        return inviteCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invites?.count ?? 0
    }
     
    deinit {
        print("Invites VC GONE")
    }
    
}
