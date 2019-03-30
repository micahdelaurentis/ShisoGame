//
//  ShisoGame.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 9/10/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
enum TimeSelection: Int {
    case twoMinute = 2
    case fiveMinute = 5
    case tenMinute = 10
    case untimed = 0
}
class Game {

    var currentPlayerID: String! 
    var player1: Player!
    var player2: Player!
    var board: Board!
    var gameID: String!
    var tilesLeft: Int!
    var gameOver: Bool
    var lastTurnPassed: Bool
    var currentTurnPassed: Bool
    var lastUpdated: Int
    var singlePlayerMode: Bool
    var timeSelection: TimeSelection
    var selectedPlayerTiles =  [Tile]()
    
    init(currentPlayerID: String, player1: Player, player2: Player,
         board: Board, gameID: String, tilesLeft: Int,
         gameOver: Bool = false, lastTurnPassed: Bool = false , lastUpdated: Int =  Int(NSDate().timeIntervalSince1970),
         singlePlayerMode: Bool = false,
         timeSelection: TimeSelection = .untimed,
         currentTurnPassed: Bool = true,
         selectedPlayerTiles: [Tile] = [Tile]()
        
        )
 
    {
        self.currentPlayerID = currentPlayerID
        self.player1 = player1
        self.player2 = player2
        self.board = board
        self.gameID = gameID
        self.tilesLeft = tilesLeft
        self.gameOver = gameOver
        self.lastTurnPassed = lastTurnPassed
        self.lastUpdated = lastUpdated
        self.singlePlayerMode = singlePlayerMode
        self.timeSelection = timeSelection
        self.currentTurnPassed = currentTurnPassed
        self.selectedPlayerTiles = selectedPlayerTiles

    }
    init() {
        currentPlayerID = ""
        player1 = Player()
        player2 = Player()
        board = Board()
        gameID = ""
        tilesLeft = 15
        timeSelection = .untimed
        gameOver = false
        lastTurnPassed =  false
        lastUpdated =  Int(NSDate().timeIntervalSince1970)
        singlePlayerMode = false
        currentTurnPassed = true
        selectedPlayerTiles = [Tile]()
    }
  
}
