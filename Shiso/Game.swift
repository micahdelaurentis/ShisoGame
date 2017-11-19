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
  
    init(currentPlayerID: String, player1: Player, player2: Player, board: Board, gameID: String) {
        self.currentPlayerID = currentPlayerID
        self.player1 = player1
        self.player2 = player2
        self.board = board
        self.gameID = gameID
    }
    init() {
        currentPlayerID = ""
        player1 = Player()
        player2 = Player()
        board = Board()
        gameID = ""
    }
    
    
}
