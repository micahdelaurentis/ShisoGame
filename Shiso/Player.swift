//
//  Player.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 9/10/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
class Player {
   
    var score: Int = 0 
    var userID: String!
    var player1: Bool!
    var userName: String!
    var imageURL: String?
    var tileRack: TileRack!
    
    init(score: Int, userID: String, player1: Bool, userName: String, imageURL: String?, tileRack: TileRack) {
        self.score = score
        self.userID = userID
        self.player1 = player1
        self.userName = userName
        self.tileRack = tileRack
      
       
        if let imageURL = imageURL {
            self.imageURL = imageURL
        }
           }
    
    
   init() {

        self.score = 0
        self.userName = ""
        self.imageURL = ""
        self.userID = ""
        self.tileRack = TileRack()
        self.player1 = false
    }
    
    
    
    
}
