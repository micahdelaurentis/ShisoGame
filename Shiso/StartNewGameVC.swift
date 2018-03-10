//
//  StartNewGameVC.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 2/19/18.
//  Copyright © 2018 Micah DeLaurentis. All rights reserved.
//

import Foundation
import UIKit

class StartNewGameVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
  
    var contacts = [String]()
    var mainVC: UIViewController?
    let contactCellID = "contactCellID"
    var backBtn: UIButton = {
        let bb = UIButton()
        bb.frame = CGRect(origin: CGPoint(x: 10, y: 30), size: CGSize(width: 70, height: 30))
        bb.backgroundColor = .yellow
        bb.setTitle("🔙", for: .normal)
        
        return bb
    }()
    


    override func viewDidLoad() {
        super.viewDidLoad()
       
        print("IN STARTNEWGAMEVC VIEW DID LOAD")
        mainVC = UIApplication.shared.keyWindow?.rootViewController
        if mainVC == nil {
            print("no main vc in start new game vc!")
        }
        else {
            print("main vc set to \(mainVC) in start new game vc")
        }
        tableView = UITableView(frame: CGRect(x: view.frame.midX - 150, y: view.frame.midY - 150, width: 300, height: 300), style: UITableViewStyle.plain)
        tableView.delegate  = self
        tableView.dataSource = self
        
        view.addSubview(tableView)

        view.addSubview(backBtn)
        

        backBtn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
        Fire.dataService.loadContacts { (contacts) in
            
            self.contacts = contacts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
          
        }
        
        
        tableView.backgroundColor = .white
    }
    func backBtnPressed() {
        
        self.dismiss(animated: false, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: contactCellID)
     
            let contact = contacts[indexPath.row]
            contactCell.textLabel?.text = contact
          /* let inviteBtn = UIButton(type: .system)
            inviteBtn.setTitle("Invite!", for: .normal)
            inviteBtn.frame.size = CGSize(width: 100, height: 30)
            inviteBtn.frame.origin.x = contactCell.frame.origin.x + contactCell.frame.size.width - inviteBtn.frame.size.width - 5
            contactCell.addSubview(inviteBtn) */
      
        return contactCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactName = contacts[indexPath.row]
        let msg = "Send \(contactName) an Invitation?"
        
        let alert = UIAlertController(title: "Challenge", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action) in
            
            Fire.dataService.postChallenge(opponentUserName: contactName, completion: { 
            
                let confirmationAction = UIAlertController(title: "Invitation successfully sent to \(contactName)!", message: nil, preferredStyle: .alert)
                self.present(confirmationAction, animated: true, completion: {(action)
                    in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.65, execute: {
                        confirmationAction.dismiss(animated: true, completion: nil)
                    })
                    
                    
                    /* UIView.animate(withDuration: 3.0, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                     confirmationAction.view.alpha = 0
                     confirmationAction.view.backgroundColor = .green
                     }, completion: {(done) in confirmationAction.dismiss(animated: true, completion: nil)}) */
                    
                })
            })
            
            
     
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    }


