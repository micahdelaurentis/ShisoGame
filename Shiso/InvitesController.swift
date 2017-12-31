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
    
    var tableView = UITableView()
    var invites = ["a","b","c"]
    var backBtn: UIButton = {
        let bb = UIButton()
        bb.frame = CGRect(origin: CGPoint(x: 10, y: 30), size: CGSize(width: 70, height: 30))
        bb.backgroundColor = .yellow
        bb.setTitle("🔙", for: .normal)
        
        return bb
    }()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Fire.dataService.loadInvites()
        
        view.backgroundColor = .white
        
        
        
        tableView = UITableView(frame: CGRect(x: view.frame.midX - 150, y: view.frame.midY - 150, width: 300, height: 300), style: UITableViewStyle.plain)
        tableView.delegate  = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        let header = UIView()
        header.backgroundColor = .lightGray
        header.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        let headerTitle = UILabel(frame: CGRect(origin: CGPoint(x: header.frame.midX - 50, y: header.frame.midY - 15) , size: CGSize(width: 100, height: 30)))
        headerTitle.text = "Challenges"
        headerTitle.font = UIFont.boldSystemFont(ofSize: 18)
        header.addSubview(headerTitle)
        tableView.tableHeaderView = header
        view.addSubview(tableView)
        view.addSubview(backBtn)
        
        backBtn.addTarget(self, action: #selector(backBtnPushed), for: .touchUpInside)
        
    }
    func backBtnPushed() {
     self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inviteCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        inviteCell.textLabel?.text = invites[indexPath.row]
        return inviteCell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invites.count
    }
    
}
