//
//  InviteCell.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 12/31/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import UIKit
class InviteCell: UITableViewCell {
    var invite: Invite?
    var declineBtn: UIButton =
    {
        let db = UIButton(type: .system)
        db.translatesAutoresizingMaskIntoConstraints = false
        db.setTitle("✘", for: UIControlState.normal)
        db.backgroundColor = .red
        return db
        
        
    }()
    var acceptBtn: UIButton =
    {
        let ab = UIButton(type: .system)
        ab.translatesAutoresizingMaskIntoConstraints = false
        ab.setTitle("✔︎", for: UIControlState.normal)
        ab.backgroundColor = .green
        return ab
        
        
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .yellow
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        
        addSubview(declineBtn)
        declineBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        declineBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        declineBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        declineBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
   
        addSubview(acceptBtn)
        acceptBtn.rightAnchor.constraint(equalTo: declineBtn.leftAnchor, constant: -10).isActive = true
        acceptBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        acceptBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        acceptBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        acceptBtn.addTarget(self, action: #selector(acceptBtnPressed), for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func acceptBtnPressed(completion: ()-> Void) {
        if invite != nil {
            Fire.dataService.createGame(invite: invite!)
        }
        completion()
    
    }
    func declineBtnPressed(){
        
    }
    
}
