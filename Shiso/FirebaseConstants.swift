//
//  FirebaseConstants.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 9/16/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth


struct FirebaseConstants {
    static let FBRef = Database.database().reference()
    static let CurrentUserID = Auth.auth().currentUser?.uid
   
    static var CurrentUserPath: DatabaseReference? {
        if CurrentUserID != nil {
            return UsersNode.child("\(CurrentUserID!)")
        }
    return nil
    }
    
  
    static let UsersNode = FBRef.child("Users")
    static let GamesNode = FBRef.child("Games")
    
    static let ChallengesReceived = "challenges_received"
    static let ChallengesSent = "challenges_sent"
    static let GameBoardNode = GamesNode.child("Board") 
    static let UserName = "userName"
    static let UserID = "userID"
  
    static let UserEmail = "email"
    static let UserImageURL = "imageURL"
    static let UserTileRack = "tileRack"
    static let UserCurrentPlayer = "currentPlayer"
    static let UserPlayer1 = "Player1"
    static let UserScore = "score"

    static let UserCurrentGameID = "currentGameID"
   
    
    static let GamePlayersNode = "Players"
    static let GameCurrentPlayerID = "currentPlayerID"
    static let GameNew = "newGame"
    static let GameBoard = "gameBoard"
    static let GameID = "gameID"
    

    static let TileValue = "TileValue"
    static let TileRackPosition = "TileRackPosition"
    static let TileRow = "Row"
    static let TileCol = "Col"
    static let TilePlayer = "Player"
    static let TileHoldingValue = "HoldingValue"
    static let TileCurrentPositionX = "CurrentPositionX"
    static let TileCurrentPositionY = "CurrentPositionY"
    static let TileStartingPositionX = "StartingPositionX"
    static let TileStartingPositionY = "StartingPositionY"
    static let TileColor = "Color"
    static let TileBoardTileColor = "brown"
    static let TilePlayer1TileColor = "blue"
    static let TilePlayer2TileColor = "red"
    static let TileBonusTileColor = "green"
    static let TileTypeName = "Name"
}
