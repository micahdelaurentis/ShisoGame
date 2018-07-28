//
//  ShisoGame.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 9/10/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation

class Game {

    var currentPlayerID: String! 
    var player1: Player!
    var player2: Player!
    var board: Board!
    var gameID: String!
    var tilesLeft: Int!
    var gameOver: Bool
    var lastTurnPassed: Bool
    var lastUpdated: Int
    var singlePlayerMode: Bool
    init(currentPlayerID: String, player1: Player, player2: Player, board: Board, gameID: String, tilesLeft: Int,
         gameOver: Bool = false, lastTurnPassed: Bool , lastUpdated: Int =  Int(NSDate().timeIntervalSince1970),
         singlePlayerMode: Bool = false) {
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
    }
    init() {
        currentPlayerID = ""
        player1 = Player()
        player2 = Player()
        board = Board()
        gameID = ""
        tilesLeft = 5
        gameOver = false
        lastTurnPassed = false
        lastUpdated =  Int(NSDate().timeIntervalSince1970)
        singlePlayerMode = false
    }
    
    
}
