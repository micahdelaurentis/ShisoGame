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
    var plays = [Play]()
    var playerN: Int  {
        return  player1 == true ? 1 : 2
    }
    
    init(score: Int, userID: String, player1: Bool, userName: String, imageURL: String?, tileRack: TileRack, plays: [Play] = [Play]()) {
        self.score = score
        self.userID = userID
        self.player1 = player1
        self.userName = userName
        self.tileRack = tileRack
        self.plays = plays
       
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
        self.plays = [Play]()
    }
    
    func convertPlaysDictToPlays(playsDict: [String:Any])  {
        var gamePlays = [Play]()
        
        for val in playsDict.values {
            if let valAsPlayDict = val as? [String:Any] {
                gamePlays.append(Play.init(fromDict: valAsPlayDict))
            }
        }
        
        
        self.plays =  gamePlays
    }
    
//    
//    func convertPlaysToDict() -> [String: Any] {
//        var dict = [String:Any]()
//        
//        for play in plays {
//            print("convert plays to dict...for play \(play.playID)")
//            dict["\(play.playID)"] =  play.convertPlayToDict()
//        }
//        return dict
//    }
    func showPlays() {
        print("\(userName) is player \(playerN) has \(plays.count) plays")
    }
}
