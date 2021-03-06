//
//  InviteCell.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 12/31/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class InviteCell: UITableViewCell {
    var invite: Invite?
    var invitesController: InvitesController?
    var gameDisplayVC: GameDisplayTableVC?
    var declineBtn: UIButton =
    {
        let db = UIButton(type: .system)
        db.translatesAutoresizingMaskIntoConstraints = false
        db.setTitle("✘", for: UIControl.State.normal)
        db.backgroundColor = .white
        db.setTitleColor(.red, for: .normal)
        db.titleLabel?.font = UIFont.boldSystemFont(ofSize: 35)
        
        return db
        
        
    }()
    var acceptBtn: UIButton =
    {
        let ab = UIButton(type: UIButton.ButtonType.system)
        ab.translatesAutoresizingMaskIntoConstraints = false
        ab.setTitle("✔︎", for: UIControl.State.normal)
        ab.setTitleColor(.green, for: .normal)
        ab.titleLabel?.font = UIFont.boldSystemFont(ofSize: 35)
        ab.backgroundColor = .white
        ab.setTitleColor(.black, for: .normal)
        return ab
        
        
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white

        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        
        addSubview(declineBtn)
        declineBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        declineBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        declineBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        declineBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        declineBtn.addTarget(self, action: #selector(declineBtnPressed), for: .touchUpInside)
        addSubview(acceptBtn)
        acceptBtn.rightAnchor.constraint(equalTo: declineBtn.leftAnchor, constant: -20).isActive = true
        acceptBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        acceptBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        acceptBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        acceptBtn.addTarget(self, action: #selector(acceptBtnPressed), for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func acceptBtnPressed() {
        if invite != nil {

            Fire.dataService.createGame(invite: invite!){
                self.gameDisplayVC?.newGameSet = true 
            }
        }
        
        removeInviteFromInviteController()
      
    
     }
    func removeInviteFromInviteController() {
        if let iC = invitesController, let iCInvites = iC.invites {
            print("in removeInviteFromController()")
            if iCInvites.count == 1 {
                print("count is 1, so deleting only invitation!")
                iC.invites?.removeAll()
             /*   DispatchQueue.main.async {
                    iC.tableView.reloadData()
                } */
            }
            
            else {
            for (n,invite) in iCInvites.enumerated() {
                if self.invite?.inviteID == invite.inviteID {
                    iC.invites?.remove(at: n)
                    /*DispatchQueue.main.async {
                        iC.tableView.reloadData()
                    } */
                    
                }
            }
            }
            
        }
    }
    @objc func declineBtnPressed(){
        if invite != nil {
        Fire.dataService.declineInvitation(invite: invite!)
        removeInviteFromInviteController()
        }
    }
    
}
