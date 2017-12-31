//
//  Invite.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 12/16/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import Firebase

struct Invite {
    var inviteID: String
    var senderID: String
    var senderUserName: String
    var receiverID: String
    var receiverUserName: String
    var timestamp: Int
    var status: String = ""
    
    
    
    init(inviteID: String, senderID: String, receiverID: String, receiverUserName: String, senderUserName: String) {
        self.senderID = senderID
        self.receiverID = receiverID
        self.timestamp = Int(NSDate().timeIntervalSince1970)
        self.receiverUserName = receiverUserName
        self.senderUserName = senderUserName
        self.inviteID = inviteID
 
    }
    
    init?(dict: [String:Any]){
  
        if let inviteID = dict[GameConstants.InviteID] as? String {
            self.inviteID = inviteID
        }
        else {
            print("could not get inviteID as key")
            return nil
        }
        if let senderID = dict[GameConstants.Invite_senderID] as? String {
           self.senderID = senderID
        }
        else {
            print("could not get senderID as key")
            
            return nil
        }
        if let senderUserName = dict[GameConstants.Invite_senderName] as? String {
            
            self.senderUserName = senderUserName
        }
        else {
            print("could not get senderUserName as key")
            
            return nil
        }
        
        if let receiverID  = dict[GameConstants.Invite_ReceiverID] as? String {
            self.receiverID = receiverID
        }
        else {
            print("could not get receiverID as key")
            
            return nil
        }
        if let receiverUserName = dict[GameConstants.Invite_receiverName] as? String {
            self.receiverUserName = receiverUserName
        }
        else {
            print("could not get receiverName as key")
            
            return nil
        }
        if let timestamp = dict[GameConstants.Invite_timestamp] as? Int {
            self.timestamp = timestamp
        }
        else {
            self.timestamp = Int(NSDate().timeIntervalSince1970)
        }
        
        if let status = dict[GameConstants.Invite_status] as? String {
            self.status = status
        }
        else {
            status = GameConstants.Invite_statusPending
        }
        
    }
    
    
}
