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
    var boxLocs =  [BoxLoc]() 
    var currentPlayerID: String! 
    var player1: Player!
    var player2: Player!
    var board: Board!
    var gameID: String!
    var tilesLeft: Int!
    var gameOver: Bool
    var lastTurnPassed: Bool
    var numSequentialPlaysWithNoTilesUsed: Int = 0
    var currentTurnPassed: Bool
    var lastUpdated: Int
    var singlePlayerMode: Bool
    var timeSelection: TimeSelection
    var selectedPlayerTiles =  [Tile]()
  //  var playsThisTurn = [Play]()
    var lastPlayerToMove: Int  = 0
    var lastScoreIncrement: Int = 0
    var lastPlayerUsedAllTiles: Bool = false
   var justUpdatedGamePlays = false
    var resignedPlayerNum: Int = 0
    
    init(currentPlayerID: String, player1: Player, player2: Player,
         board: Board, gameID: String, tilesLeft: Int,
         gameOver: Bool = false, lastTurnPassed: Bool = false ,
         lastUpdated: Int =  Int(NSDate().timeIntervalSince1970),
         singlePlayerMode: Bool = false,
         timeSelection: TimeSelection = .untimed,
         currentTurnPassed: Bool = true,
         selectedPlayerTiles: [Tile] = [Tile](),
         lastPlayerToMove: Int = 0,
         numSequentialPlaysWithNoTilesUsed: Int = 0 ,
         lastScoreIncrement: Int = 0,
         lastPlayerUsedAllTiles:Bool = false,
         justUpdatedGamePlays:Bool = false,
        boxLocs: [BoxLoc] = [BoxLoc](),
        resignedPlayerNum: Int = 0
    //     playsThisTurn: [Play] = [Play]()
        
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
        self.lastPlayerToMove = lastPlayerToMove
        self.lastScoreIncrement = lastScoreIncrement
       self.lastPlayerUsedAllTiles = lastPlayerUsedAllTiles
        self.justUpdatedGamePlays = justUpdatedGamePlays
        self.numSequentialPlaysWithNoTilesUsed = numSequentialPlaysWithNoTilesUsed
        self.boxLocs = boxLocs
        self.resignedPlayerNum = resignedPlayerNum
        
      //  self.playsThisTurn = playsThisTurn
        
    }
    init() {
        currentPlayerID = ""
        player1 = Player()
        player2 = Player()
        board = Board()
        gameID = ""
        tilesLeft = 80
        timeSelection = .untimed
        gameOver = false
        lastTurnPassed =  false
        lastUpdated =  Int(NSDate().timeIntervalSince1970)
        singlePlayerMode = false
        currentTurnPassed = true
        selectedPlayerTiles = [Tile]()
        lastPlayerToMove = 0
        lastScoreIncrement = 0
        numSequentialPlaysWithNoTilesUsed = 0 
        lastPlayerUsedAllTiles = false
      // playsThisTurn = [Play]()
        justUpdatedGamePlays = false 
        player1.tileRack.setUpPlayerTileRack(player: 1)
        player2.tileRack.setUpPlayerTileRack(player: 2)
        boxLocs = [BoxLoc]()
        resignedPlayerNum = 0
    }
    
  
    func boxLocIsNew(bL: BoxLoc) -> Bool {
        showBoxLocs()
        for boxLoc in self.boxLocs {
            if bL.row == boxLoc.row && bL.col == boxLoc.col {
                print("Already have box at location:\(boxLoc.row),\(boxLoc.col)")
             return false
            
            }
        }
        
        return true
        
    }
    
    func convertBoxLocsToDict() -> [String: Any] {
        var boxLocsAsDict = [String: Any]()
        
        for boxLoc in boxLocs {
            boxLocsAsDict[boxLoc.boxID] = boxLoc.convertToDict()
        }
        
        return boxLocsAsDict
    }
    
    func convertBoxLocsDictToBoxLocs(boxLocsDict: [String: Any]) {
        for boxLoc in boxLocsDict.values {
            if let bL = boxLoc as? [String:Any] {
            boxLocs.append(BoxLoc.init(fromDict: bL))
            }
        }
    }
    
    func showBoxLocs() {
        if boxLocs.count > 0 {
        print("Showing box locs, if any:")
        for box in boxLocs {
            print("Game has a box centered at: row \(box.row),\(box.col) player1viewed:\(box.player1Viewed) player2viewed:\(box.player2Viewed)")
        }
        }
        else {
            print("game doesn't have any boxes!")
        }
    }
    
 
}
