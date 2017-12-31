//
//  GameplayScene.swift
//  Shiso
//

//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import SpriteKit
import Foundation
//import Gamekit 

class GameplayScene: SKScene {

    
    
    var game = Game() {
        didSet{
            print("game set in GameplayScene!!!")
        }
    }
    
    var currentUserIsCurrentPlayer: Bool {
        return game.currentPlayerID == FirebaseConstants.CurrentUserID
    }
    var player1: Player!
    var player2: Player!
    

    var nonDeleteSelectedPlayerTiles = [Tile]()
    var restartBtn = SKLabelNode(text: "restart")
    var saveBtn = SKSpriteNode(color: UIColor.black, size: CGSize(width: 50, height: 50))
    

    
    
    let wildCardPickOptions = ["", "0", "1", "2", "3" ,"4" ,"5", "6","7","8","9", "10", "11","12","13","14","15","16",
                               "17","18","19","20","21","22","23","24"]
    
    
    var wildCardPicker = WildCardPickerView()
    
    var tileCount = 20
    
    let tileRefreshBtn = SKLabelNode()
    
  
    
    
    var player1Score = 0
    var player2Score = 0
    
    var timer = Timer()
    var player1ScoreLbl = SKLabelNode()
    var player2ScoreLbl = SKLabelNode()
    
    let scoreLabel = SKLabelNode()
    var scoreIncrement = 0
    
    let doneTurnBtn = Tile()
    
    var canPlay: Bool = false
    var selectedPlayerTiles = [Tile]()
    var selectedPlayerTile: Tile?
    
    var deactivateGameNodes = false
    
    var tilesUsedThisTurn = [Tile]()
    var playBtnPushed = false
    var endGame = false
    
    
    let player1TileRack = TileRack()
    let player2TileRack = TileRack()
    
    var currentPlayerTileRack = TileRack()
    var currentUserTileRack = TileRack()
    var currentUserTileRackDisplay = SKSpriteNode()
    var currentPlayerTileRackDisplay = SKSpriteNode()
    
    var tileRack1 = SKSpriteNode()
    var tileRack2 = SKSpriteNode()
    
    
  
    var currentTileRack = SKSpriteNode() //not needed
    var currentTileRackDisplay = SKSpriteNode()
    var currentScoreLbl = SKLabelNode()
    

    var currentPlayer: Player!
    var currentPlayerN = Int()
 
    var currentPlayerScore = Int()
    
    
    var gameBoard: Board!
    var gameBoardDisplay = SKSpriteNode()
    
    var playBtn = Tile()
    var bingoLabel = SKLabelNode(text: "BINGO!!! + 10")
    var selectedGameBoardTiles = [Tile]() 
    var endOfGamePanel = SKSpriteNode()
    var yesBtn = SKLabelNode()
    var noBtn = SKLabelNode()
    var tileRefreshBtnTapped = false
    
    var recallBtn = SKLabelNode()

    var lastTouchedWildCardTile: Tile?

    var initializeGameCount: Int!
    
    func initializeGame () {
        
    gameBoard = game.board
    gameBoardDisplay = gameBoard.setUpBoard()
    gameBoardDisplay.name = GameConstants.GameBoardDisplayName
        
        player1 = game.player1
        player2 = game.player2
        print("player 1 is: \(player1.userName) player 2 is: \(player2.userName)")
    currentPlayer = player1.userID == game.currentPlayerID ? player1 : player2
    currentPlayerN = currentPlayer.player1 == true ? 1 : 2
   
        
        // setUpPlayerTiles()
       // currentUserTileRack = player1.userID == FirebaseConstants.CurrentUserID ? player1.tileRack : player2.tileRack
    
       // currentUserTileRack.setUpPlayerTileRack(player: currentPlayerN)
        
        player1ScoreLbl.text = "\(player1.userName!)'s score: \(player1.score)"
        player2ScoreLbl.text = "\(player2.userName!)'s score: \(player2.score)"
        
        currentScoreLbl = currentPlayerN == 1 ? player1ScoreLbl : player2ScoreLbl
        let otherScoreLbl = currentPlayerN == 1 ? player2ScoreLbl : player1ScoreLbl
        currentScoreLbl.fontColor = UIColor.green
        otherScoreLbl.fontColor =  UIColor.white
            
        currentPlayerTileRack = currentPlayer.tileRack
        currentPlayerTileRack.setUpPlayerTileRack(player: currentPlayerN)
        currentPlayerTileRackDisplay = currentPlayerTileRack.tileRack
        currentPlayerTileRackDisplay.name = GameConstants.TileRackDisplayName
      
       
        for child in self.children {
            if child.name == GameConstants.GameBoardDisplayName || child.name == GameConstants.TileRackDisplayName {
             child.removeFromParent()
            }
        }
        
    gameBoardDisplay.position = GameConstants.BoardPosition
    addChild(gameBoardDisplay)
        
    currentPlayerTileRackDisplay.position = GameConstants.TileRackDisplayPosition
    addChild(currentPlayerTileRackDisplay)
   
    }
    
    
    
    func showCurrentTileRack() {
        print("Showing currentUserTileRack...") 
        currentPlayerTileRack.showTileRack()
    }
    
    override func didMove(to view: SKView) {
        
        Fire.dataService.loadGame{ (loadedGame)
            in
            
            self.game = loadedGame
            
            self.initializeGame()
              print("done loading game")
        }
      
 
        

        
 
        
    restartBtn.fontSize = 40
    restartBtn.zPosition = 3
    restartBtn.position = CGPoint(x: -200, y: 400)
    addChild(restartBtn)
        
    saveBtn.zPosition = 3
    saveBtn.position = CGPoint(x: restartBtn.position.x + restartBtn.frame.size.width/2 + 30, y: restartBtn.position.y)
    addChild(saveBtn)

        
        playBtn.initializeTile(width: 200, height: 100, tileValueText: nil)
        playBtn.tileLabel.text = "Play!"
        playBtn.name = "Play"
        
        playBtn.position = CGPoint(x: -20, y: -250)
        playBtn.color = SKColor.green
        addChild(playBtn)
        
        
      //add score Labels
        player1ScoreLbl.position = CGPoint(x: -200, y: 600)
        player1ScoreLbl.zPosition = 2
        
        player1ScoreLbl.fontSize = 25
        player1ScoreLbl.fontName = "Arial"
        
        addChild(player1ScoreLbl)
        
       
        player2ScoreLbl.position = CGPoint(x: 200, y: 600)
        player2ScoreLbl.zPosition = 2
        player2ScoreLbl.text = "Player 2 Score: \(player2Score)"
        player2ScoreLbl.fontSize = 25
        player2ScoreLbl.fontName = "Arial"
        
        addChild(player2ScoreLbl)
        
        // add doneTurnBtn
        
    
        
        doneTurnBtn.initializeTile(width: GameConstants.TileRackDisplaySize.height, height: GameConstants.TileRackDisplaySize.height, tileValueText: nil)
        doneTurnBtn.position = CGPoint(x: playBtn.position.x, y: playBtn.position.y - playBtn.size.height/2 - 50)
        doneTurnBtn.name = "Done"
        doneTurnBtn.tileLabel.text = "Done"
        doneTurnBtn.color = UIColor.cyan
        addChild(doneTurnBtn)
        
        
        // add refresh button
        tileRefreshBtn.position = CGPoint(x: GameConstants.TileRackDisplayPosition.x + GameConstants.TileRackDisplaySize.width/2 + 50, y: GameConstants.TileRackDisplayPosition.y)
        tileRefreshBtn.zPosition = 2
        tileRefreshBtn.text = "♽"
        tileRefreshBtn.name = "Refresh"
        tileRefreshBtn.fontSize = 40
        addChild(tileRefreshBtn)
        
        
        bingoLabel.position = CGPoint(x: 0, y: 400)
        bingoLabel.fontName = "Arial"
        bingoLabel.fontSize = 50
        bingoLabel.fontColor = .green
        bingoLabel.zPosition = 2
        addChild(bingoLabel)
        bingoLabel.isHidden = true
        
        // add refresh button
        recallBtn.position = CGPoint(x: GameConstants.TileRackDisplayPosition.x  - GameConstants.TileRackDisplaySize.width/2 - 50, y: GameConstants.TileRackDisplayPosition.y)
        recallBtn.zPosition = 2
        recallBtn.text = "🔄"
        tileRefreshBtn.name = "RECALL"
        tileRefreshBtn.fontSize = 40
        addChild(recallBtn)
        
        
     
        wildCardPicker.initializePicker(tileColor: .lightGray)
        
        addChild(wildCardPicker)
        
        wildCardPicker.zPosition = 50
        wildCardPicker.isHidden = true
        
        }
    
    
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
      //  guard currentUserIsCurrentPlayer else {return}
        
        for touch in touches {
            
            let location = touch.location(in: currentPlayerTileRackDisplay)
            
            if let selectedTile = selectedPlayerTile, selectedPlayerTile?.tileLabel.text != "?",
             deactivateGameNodes == false ,
                selectedPlayerTiles.contains(selectedTile) {
                
                selectedTile.position = location
            }
            
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     /*
        guard currentUserIsCurrentPlayer else {
            print("You are not the current player!!")
            return
        }
       */
            for touch in touches {
            
                let location = touch.location(in: self)
            
            
       
        
            for tile in currentPlayerTileRack.playerTiles.values  {
                if nodes(at: location).contains(tile), deactivateGameNodes == false {
                  
                    playBtnPushed = false
                    selectedPlayerTile = tile
                    selectedPlayerTile?.tileLabel.fontColor = .black
                    if selectedPlayerTile?.tileLabel.text == GameConstants.TileWildCardSymbol{
                    
                        wildCardPicker.isHidden = false
                        deactivateGameNodes = true
                        
                    }
                    
                   
                    
                    
           
                
                  if !selectedPlayerTiles.contains(tile)  && tile.tileLabel.text != "?" {
                        selectedPlayerTiles.append(tile)
                        tilesUsedThisTurn.append(tile)
                    
                    }
                }
            }
                
            
               
                for node in nodes(at: location) {
                    if let touchedTile = node as? Tile, touchedTile.name == GameConstants.WildCardPickerViewTileName {
                      
                        if let lastTouched = lastTouchedWildCardTile {
                      
                            lastTouched.color = .lightGray
                        }
                        touchedTile.color = .green
                       lastTouchedWildCardTile = touchedTile
                        
                      wildCardPicker.showConfirmBtns()
                       
                        
                    }
                    
                    else if node.name == GameConstants.WildCardCheckTileName, lastTouchedWildCardTile != nil {
                       selectedPlayerTile?.setTileValue(value: lastTouchedWildCardTile!.getTileValue())
                      
                        selectedPlayerTile?.tileLabel.fontColor = .yellow
                        let expandTile = SKAction.scale(by: 2, duration: 0.2)
                        let shrinkTile = SKAction.scale(by: 1/2, duration: 1.0)
                        let expandAndShrink = SKAction.sequence([expandTile, shrinkTile])
                        selectedPlayerTile?.run(expandAndShrink){
                            self.selectedPlayerTile?.tileLabel.fontColor = .black
                        }
                        

                        
                        deactivateGameNodes = false
                        wildCardPicker.isHidden = true
                        wildCardPicker.hideConfirmBtns()
                        lastTouchedWildCardTile?.color = .lightGray
                    }
                    else if node.name == GameConstants.WildCardPickerExitBoxName {
                        deactivateGameNodes = false
                        wildCardPicker.isHidden = true
                        wildCardPicker.hideConfirmBtns()
                        lastTouchedWildCardTile?.color = .lightGray
                    }
                    else if node.name == GameConstants.WildCardXTileName {
                        wildCardPicker.hideConfirmBtns()
                        
                        if let lastTouched = lastTouchedWildCardTile {
                            
                            lastTouched.color = .lightGray
                        }
                        lastTouchedWildCardTile = nil
                        
                    }
                    
                }
                
                
                
               
                
        
            for node in nodes(at: location) {
                
                if let touchedTile = node as? Tile, touchedTile.name == GameConstants.TileBoardTileName, touchedTile.inSelectedPlayerTiles, deactivateGameNodes == false  {
                    let location1 = touch.location(in: currentTileRack)
                    
                    let row = touchedTile.row
                    let col = touchedTile.col
                    for tile in selectedPlayerTiles {
                        if tile.row == row && tile.col == col {
                            selectedPlayerTile = tile
                        }
                    }
                    
                    selectedPlayerTile?.position = location1
                    selectedPlayerTile?.isHidden = false
                    
                
                    
                    
                    if let holdVal = touchedTile.holdingValue, let holdCol = touchedTile.holdingColor {
                        touchedTile.setTileValue(value: holdVal)
                        touchedTile.color = holdCol
                        touchedTile.holdingValue = nil
                        touchedTile.holdingColor = nil
                     
                    }
                    else {
                       touchedTile.setTileValue(value: nil)
                       touchedTile.color = gameBoard!.bonusPointTiles.contains(touchedTile) ? SKColor.green : .brown
                    }
                
                    
                    touchedTile.inSelectedPlayerTiles = false
                 
                  
                }
            }
        
            if nodes(at: location).contains(playBtn)  && deactivateGameNodes == false {
                playBtnPushed = true
                play()
            }
            
            if nodes(at: location).contains(yesBtn) {
                
                if let view = self.view {
                    
                    if let scene = GameplayScene(fileNamed: "GameplayScene") {
                        scene.scaleMode = .aspectFill
                        view.presentScene(scene)
                    }
                    
                }
            }
            
            
            
            if nodes(at: location).contains(tileRefreshBtn) && tileRefreshBtnTapped == false && tilesUsedThisTurn.count == 0 {
                tileRefreshBtnTapped = true
                
                refreshTiles{
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)
                {
                    self.tileRefreshBtnTapped = false
                  
                    self.switchPlayers()
                    
                    
                }
                    
                }
            }
           
                if nodes(at: location).contains(saveBtn) {
                    
                  
                 Fire.dataService.saveGameData(game: game, completion: {
                    //....
                 })
                }
                
            if nodes(at: location).contains(restartBtn) {
                if let view = self.view {
                    
                    if let scene = GameplayScene(fileNamed: "GameplayScene") {
                        scene.scaleMode = .aspectFill
                        view.presentScene(scene)
                    }
                    
                }
            }
            
                if nodes(at: location).contains(recallBtn), selectedPlayerTiles.count > 0 {
                    for tile in selectedPlayerTiles {
                        tile.isHidden = false
                        let goHome = SKAction.move(to: tile.startingPosition, duration: 0.3)
                        let boardTile = gameBoard.getTile(atRow: tile.row, andCol: tile.col)
                        boardTile.inSelectedPlayerTiles = false
                        boardTile.player = nil
                        boardTile.col = -1
                        boardTile.row = -1
                        boardTile.setTileValue(value: nil)
                        boardTile.color = GameConstants.TileBoardTileColor
                        tile.run(goHome)
                        for (ind, turnTile) in tilesUsedThisTurn.enumerated() {
                            if turnTile == tile {
                                tilesUsedThisTurn.remove(at: ind)
                                break
                            }
                        }
                    }
                    selectedPlayerTiles.removeAll()
                    
                    
                }
        
   
            
                
            if nodes(at: location).contains(doneTurnBtn) && deactivateGameNodes == false {
                
                if endGame {
                    displayEndOfGamePanel()
                    break
                }
                
                if tileCount == 0 {
                    
                    endGame = true
                    turnDone()
                }
                
                if  playBtnPushed || selectedPlayerTiles.count == 0 {
                
                        turnDone()
                }
                
              
                    
                    
                    
                    
                    
            else  {
                    print("You didn't push play!!!")
                }
               
            }
        }
        
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //showSelectedTiles()
        //showTilesUsedThisTurn()
        /*
        guard currentUserIsCurrentPlayer else {
            return
        }*/
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
           
            
            var selectedTileOnBoard = false
            if let selectedTile = selectedPlayerTile, nodes(at: location).contains(selectedTile), deactivateGameNodes == false {
                
                
                for node in nodes(at: location) {
                    if let targetTile = node as? Tile {
                
                        if targetTile.name == GameConstants.TileBoardTileName  && targetTile.tileIsEmpty && selectedTile.name != GameConstants.TileDeleteTileName {
                            
                            selectedTileOnBoard = true
                            selectedTile.row = targetTile.row
                            selectedTile.col  = targetTile.col
                            print("selected tile value: \(selectedTile.getTileValue()) and rack position \(selectedTile.rackPosition)")
                           
                            
                            selectedTile.isHidden = true
                            
                            if gameBoard!.bonusPointTiles.contains(targetTile) {
                                targetTile.color = GameConstants.TileBonusTileColor
                            }
                            else {targetTile.color = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor :GameConstants.TilePlayer2TileColor}
                            
                            if let tileValue = selectedTile.getTileValue() {
            
                              targetTile.setTileValue(value: tileValue)
                            }
                            
                            //Added 10/21/2017:
                            targetTile.player = selectedTile.player
                            targetTile.rackPosition = selectedTile.rackPosition
                            targetTile.inSelectedPlayerTiles = true
                            
                            
                        }
                        
                         // END: if targetTile.name == "Board"  && targetTile.tileIsEmpty && !selectedTile.name == "DELETE"
                        else if targetTile.name == GameConstants.TileBoardTileName && targetTile.tileIsEmpty && selectedTile.name == GameConstants.TileDeleteTileName {
                            //return to original position
                            returnTileToRack(tile: selectedTile)
                        }
                        
                        else if targetTile.name == GameConstants.TileBoardTileName && !targetTile.tileIsEmpty && selectedTile.name == GameConstants.TileDeleteTileName
                            && !targetTile.inSelectedPlayerTiles /*&& !gameBoard!.startingTiles.contains(targetTile)*/
                        {
                            
                            
                            selectedTileOnBoard = true
                            selectedTile.row = targetTile.row
                            selectedTile.col  = targetTile.col
                            
                            selectedTile.isHidden = true
                            if let tileValue = targetTile.getTileValue() {
                                
                                targetTile.holdingValue = tileValue
                                targetTile.holdingColor = targetTile.color 
                            }
                            targetTile.setTileValue(value: nil)
                            targetTile.color = GameConstants.TileBoardTileColor
                            targetTile.player = nil
                            targetTile.inSelectedPlayerTiles = true
                            targetTile.rackPosition = selectedTile.rackPosition
                        
                                                       
                        }
                    }
                    
                }
                
                if !selectedTileOnBoard {
                    //showSelectedTiles()
                    returnTileToRack(tile: selectedTile)
                }
                
                
                
            }
            
        }
    }
    
    func removeTileFromArray(tile: Tile, array: inout [Tile]) {
        for (index, t) in array.enumerated() {
            if t == tile {
                array.remove(at: index)
            }
        }
    }
    func nodesContainsDeleteTile(nodeArray: [SKNode]) -> Bool {
        for node in nodeArray {
            if let tileNode = node as? Tile {
                if tileNode.name == GameConstants.TileDeleteTileName {
                    return true
                }
            }
        }
        return false
    }

    
    func returnTileToRack(tile: Tile) {
        tile.position = tile.startingPosition
        tile.row = -1
        tile.col = -1
        tile.inSelectedPlayerTiles = false
        
        
        if selectedPlayerTiles.count > 0 {
            for (i, selectedTile) in selectedPlayerTiles.enumerated() {
                if selectedTile == tile {
                    selectedPlayerTiles.remove(at: i)
                }
            }
            for (j, selectedTile) in tilesUsedThisTurn.enumerated() {
                if selectedTile == tile {
                    tilesUsedThisTurn.remove(at: j)
                }
            }
        }
     
        if selectedPlayerTile?.name != GameConstants.TileWildcardTileName {
         
            selectedPlayerTile = nil
        }
        
    }
    
    func createEndofGamePanel()  {
    
        endOfGamePanel = SKSpriteNode(color: .black, size: CGSize(width: 200, height: 200))
        endOfGamePanel.zPosition = 5
        endOfGamePanel.position = CGPoint(x: 0, y: 0)
        addChild(endOfGamePanel)
        
        let continueLabel = SKLabelNode(text: "Continue?")
        continueLabel.fontSize = 30
    
        endOfGamePanel.addChild(continueLabel)
        continueLabel.position = CGPoint(x: 0, y: 0)
        
        yesBtn = SKLabelNode(text: "Yes")
        endOfGamePanel.addChild(yesBtn)
        
        noBtn = SKLabelNode(text: "No")
        endOfGamePanel.addChild(noBtn)

        
        yesBtn.position = CGPoint(x: yesBtn.parent!.frame.minX + 25, y: yesBtn.parent!.frame.minY)
        noBtn.position = CGPoint(x: noBtn.parent!.frame.maxX - 25, y: noBtn.parent!.frame.minY)
       
    }
    
    func displayEndOfGamePanel() {
        
        createEndofGamePanel()
        if player1Score > player2Score {
            print("Game over! Player 1 is the winner! player 1 score: \(player1Score) player 2 score: \(player2Score)")
        }
        else if player2Score > player1Score {
            print("Game over! Player 1 is the winner! player 1 score: \(player1Score) player 2 score: \(player2Score)")

        }
        else {
            print("Game over! It's a tie!!!! Score: \(player1Score) to \(player2Score)")
        }
       
   
 
        
    }
    
    func showBingo() {
    
            
            currentPlayer.score += GameConstants.BingoPoints
            currentScoreLbl.text = "\(currentPlayer.userName!)'s score: \(currentPlayer.score)"
            bingoLabel.isHidden = false
            let moveBingoLabel: SKAction = SKAction.moveBy(x: 0, y: 270, duration: 2)
            let fade = SKAction.fadeOut(withDuration: 2)
            bingoLabel.run(fade)
            bingoLabel.run(moveBingoLabel){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                {
                    self.switchPlayers()
                }
            }
            bingoLabel.position = CGPoint(x: 0, y: 400)
            bingoLabel.alpha = 1.0
            
            
        
    }
    func turnDone() {
        if tilesUsedThisTurn.count == 7 {
            
            showBingo()
            
        }
        else {
            switchPlayers()
        }
        
    }
    
    func refreshTiles(completion: () -> ()) {
        print("in refreshTiles...tile count: \(tileCount)")
        for tile in currentPlayerTileRack.playerTiles.values {
            if tileCount > 0 {
            currentPlayerTileRack.removeAndReplaceTileFromRack(tile: tile, player: currentPlayerN)
            tileCount -= 1
            }
            
            else {
                break
            }
        }
 
       completion()
    }
    
    
    func switchPlayers() {
        
        refillTileRack()
        //showCurrentTileRack()
       
        
        selectedPlayerTiles.removeAll()
        selectedPlayerTile = nil
        tilesUsedThisTurn.removeAll()
        playBtnPushed = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            print("about to save...current player (player \(self.currentPlayerN)) score: \(self.currentPlayer.score) player 1 score: \(self.player1.score) player2 score = \(self.player2.score)")
             Fire.dataService.saveGameData(game: self.game, completion: nil)
        }

        
       
        
        
      
       

    }
    
  
    func play() {
        
        for tile in selectedPlayerTiles where tile.name != "DELETE" {
            nonDeleteSelectedPlayerTiles.append(tile)
        }
        
      let legalMove =  checkIfLegalMove()
        
      
        // if so, set values on board and remove tiles, if not alert user and return tiles
        // replace player tiles that were played
        
        if legalMove {
            print("Good!")
          
            
            for tile in selectedPlayerTiles {
                
                let row = tile.row
                let col = tile.col
                let gameBoardTile = gameBoard!.getTile(atRow: row, andCol: col)
                gameBoardTile.inSelectedPlayerTiles = false
                
                if tile.name == "DELETE" {
                   gameBoardTile.color = .brown
                    gameBoardTile.holdingValue = nil
                }
                
            }
          
            lightUpPlayedTiles {
                (tiles) in

                for tile in tiles {
                    tile.color = currentPlayerN == 1 ? .blue : .red
                }
                
                
            
                self.selectedPlayerTiles.removeAll()
                
                if self.tilesUsedThisTurn.count == 8 {
                   self.showBingo()
                }
            
            }
 
            
        }
        
        else {
            
            
            
            for tile in selectedPlayerTiles {
                
                //var deleteTileHere = false
                tile.isHidden = false
                let row = tile.row
                let col = tile.col
                
                if tile.isTileOnBoard() {
                    
                    
                    
                    let gameBoardTile = gameBoard?.getTile(atRow: row, andCol: col)
                    
    
                    if let holdVal = gameBoardTile!.holdingValue, let holdCol = gameBoardTile!.holdingColor {
                        gameBoardTile!.setTileValue(value: holdVal)
                        gameBoardTile!.color = holdCol
                    }
                    
                    else {
                        gameBoardTile!.setTileValue(value: nil)
                        gameBoardTile!.color = gameBoard!.bonusPointTiles.contains(gameBoardTile!) ? SKColor.green : .brown
                        
                    }
     
                    
                    
                    gameBoardTile!.inSelectedPlayerTiles = false
                }
            }
            
           
            resetSelectedPlayerTiles()
            
        }
        
        
         nonDeleteSelectedPlayerTiles.removeAll()
        
    }
    
  
    
    func lightUpPlayedTiles(completion: ([Tile]) -> ()) {
    
        var color: SKColor = SKColor()
        
        color = currentPlayerN == 1 ? SKColor.blue : SKColor.red
        
        
        
        let gameBoardTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
        
        let expandTile = SKAction.scale(by: 1.2, duration: 0.1)
        let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 0.0 , duration: 0.1)
        let changeBack = SKAction.colorize(with: color, colorBlendFactor: 0.0, duration: 0.1)

        let shrinkTile = SKAction.scale(by: 1/1.2, duration: 0.6)
        let wait = SKAction.wait(forDuration: 0.1)
        let seq = SKAction.sequence([ wait, shrinkTile, changeBack])
        
        calculateScore()
        let points = scoreIncrement
        
        for  (i,tile) in gameBoardTiles.enumerated() {
           tile.run(expandTile)
            tile.zPosition = 4
            tile.run(changeToYellow){
                tile.run(seq){
                    tile.zPosition = 2
                    if i == gameBoardTiles.count - 1 {
                        let loc = gameBoardTiles[i].position
                        self.showPoints(atLocation: loc, points: points)
                        
                    }
                    
                }
                
            }
        }
       
        
        completion(gameBoardTiles)
        
    }

    func lightUpTilesInSequence(atIndex index: Int) {
       
     

    let gameBoardTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
    
    
    let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 0.0 , duration: 0.3)
    
    let tile = gameBoardTiles[index]
   
        tile.run(changeToYellow){
            if index + 1 < gameBoardTiles.count {
             self.lightUpTilesInSequence(atIndex: index + 1)
            }
            else {
                return
            }
           }
    }
    
    func convertNonDeleteSelectedPlayerTilesIntoBoardTiles() -> [Tile] {
        var  gameBoardTiles = [Tile]()
        if selectedPlayerTiles.count > 0 {
        
            showSelectedTiles()
            for tile in selectedPlayerTiles {
                if tile.name != "DELETE" {
                    print("Tile val: \(tile.getTileValue()!) row: \(tile.row) col: \(tile.col)")
                        
                gameBoardTiles.append(gameBoard!.getTile(atRow: tile.row, andCol: tile.col))
                }
            }
        }
        return gameBoardTiles
    }
    
    func showPoints(atLocation location: CGPoint,points: Int) {
  
        let pointDisplay = SKLabelNode(text: "+ \(points)")
      
        pointDisplay.fontName = "AvenirNext-Bold"
        pointDisplay.fontSize = 50
        pointDisplay.fontColor = UIColor.green
        pointDisplay.position = CGPoint(x: location.x + 50, y: location.y)
       
    
        pointDisplay.zPosition = 2
        let movePointDisplay = SKAction.moveTo(y: location.y + 300, duration: 2)
        let fadePointDisplay = SKAction.fadeOut(withDuration: 2)
        
        addChild(pointDisplay)
        
        pointDisplay.run(movePointDisplay)
        pointDisplay.run(fadePointDisplay){
        pointDisplay.removeFromParent()
        
        }
    }
    
    
    func checkIfLegalMove() -> Bool  {
        if !checkIfLegalTilePath() {
            print("Not a legal tile path!!")
            return false
        }/*
        i think legal tile path takes care of this
        if !selectedTilesAllOnBoard() {
            print("All tiles not on board!")
            return false
        }
        */
        /* i think legal tile path takes care of this
        if !selectedTilesConnected() {
            print("All played tiles are not connected to other tiles on board!")
            return false
        }
        */
        
        if !tilesConnectedToBoardTileWithValue() {
            print("player tiles not connected to board tiles with value!!")
            return false
        }
        
        if !selectedTilesOnlyConnectedToThree() {
            return false
        }
        

      //  showSelectedTiles()
        return true
   
    }

    func checkIfLegalTilePath() -> Bool {
        
        let targetTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
        
        if targetTiles.count <= 1 {
            return true
        }
       
        else {
            return gameBoard!.checkIfLegalTilePath(targetTiles: targetTiles) 
        }
        
    }
    
    func selectedTilesInLine() -> (inLine: Bool, row: Bool, rowOrColIndex: Int?) {
        var rows = Set<Int>()
        var cols = Set<Int>()
        var inLine = true
        var row = false
        var rowOrColIndex: Int?
       
        
        for tile in nonDeleteSelectedPlayerTiles {
            if tile.isTileOnBoard() == false {
               inLine = false
            }
       
                rows.insert(tile.row)
                cols.insert(tile.col)
            
        }
        
        if inLine != false {
            inLine = rows.count == 1 || cols.count == 1
        }
        
            
        if inLine {
            row = rows.count == 1
        }
        if nonDeleteSelectedPlayerTiles.count > 0 {
            rowOrColIndex = row ? nonDeleteSelectedPlayerTiles[0].row : nonDeleteSelectedPlayerTiles[0].col
        }
      

        return (inLine, row, rowOrColIndex)
    }

    func selectedTilesConnected() -> Bool {
        
        if nonDeleteSelectedPlayerTiles.count == 0 && selectedPlayerTiles.count > 0 {
            return true
        }
        
        for tile in nonDeleteSelectedPlayerTiles {
            print("non delete tile: \(tile.getTileValue()!)")
        }
            
        var minVal = Int()
        var maxVal = Int()
    
        
        if selectedTilesInLine().inLine {
            let row = selectedTilesInLine().row
            let index = selectedTilesInLine().rowOrColIndex
            
            
            if row {
                
                nonDeleteSelectedPlayerTiles = nonDeleteSelectedPlayerTiles.sorted(by: {
                
                (tile1,tile2) -> Bool in return
                    
                    tile1.col < tile2.col
                    
                } )
                
                minVal = nonDeleteSelectedPlayerTiles.first!.col
                maxVal = nonDeleteSelectedPlayerTiles.last!.col
                
              //  print("min Col val: \(minVal) max: \(maxVal)")
               // print("row index: \(index!)")
                
                for i in minVal ... maxVal {
                   // print("value at (\(index!), \(i)) is \(gameBoard!.getTileValue(row: index!, col: i))")
                    
                    if !existsSelectedTileAtBoardLocation(row: index!, col: i) && gameBoard!.isTileValueEmpty(atRow: index!, andCol: i) {
                        return false
                    }
                }
             
                return true
                
            }
            else if !row  {
                
               nonDeleteSelectedPlayerTiles =  nonDeleteSelectedPlayerTiles.sorted(by: { $0.row < $1.row})
                
                minVal = nonDeleteSelectedPlayerTiles.first!.row
                maxVal = nonDeleteSelectedPlayerTiles.last!.row
                
                for i in minVal ... maxVal {
                    
                    if !existsSelectedTileAtBoardLocation(row: i, col: index!) && gameBoard!.isTileValueEmpty(atRow: i, andCol: index!) {
                        return false
                    }
                
                }
                return true
            }
            
        }
        
            return false
        }

   /* func showResultOfConnected() {
        if selectedTilesConnected() {
            print("tiles connected!")
        }
        else {
            print("tiles not connected!")
        }
    }
 */

    func selectedTilesAllOnBoard() -> Bool {
        
      
        if selectedPlayerTiles.count > 0 {
            
            for t in selectedPlayerTiles {
                
                if t.isTileOnBoard() == false {
                    return false
                }
                
            }
        }
        
        return true
    }
    
    func tilesConnectedToBoardTileWithValue() -> Bool {
     
        if nonDeleteSelectedPlayerTiles.count  == 0 && selectedPlayerTiles.count > 0 {
            return true
        }
        else {
            return gameBoard!.anyTilesTouchingOriginalBoardTilesWithValue(tiles: nonDeleteSelectedPlayerTiles)
        
        }
    }
    
        
    

    func existsSelectedTileAtBoardLocation(row: Int, col: Int) -> Bool {
        
        
        for tile in selectedPlayerTiles {
            if tile.row == row && tile.col == col {
                return true
            }
        }
        return false
    }

    
    func resetSelectedPlayerTiles() {
        
        for tile in selectedPlayerTiles {
           
            
            tile.position = tile.startingPosition
            tile.row = -1
            tile.col = -1
            tile.inSelectedPlayerTiles = false
            
            for (index,turnTile) in tilesUsedThisTurn.enumerated() {
                if turnTile == tile {
                    tilesUsedThisTurn.remove(at: index)
                }
            }
        }
        
        selectedPlayerTiles.removeAll()
        
    }
    
    func refillTileRack(){
    
        for tile in tilesUsedThisTurn {
            if tileCount > 0 {
             currentPlayerTileRack.removeAndReplaceTileFromRack(tile: tile, player:currentPlayerN)
             print("Finished remove and replace tile from rack")
             tileCount -= 1
             print("tile count: \(tileCount)")
            }
            else {
                print("no more tiles!!")
                break
            }
        }
        
    selectedPlayerTiles.removeAll()
    tilesUsedThisTurn.removeAll()
    
    print("refillTileRack finished!")
    //currentPlayerTileRack.showTileRack()
    }
    
    
    
    func tileIsOnlyConnectedToThree(tile: Tile) -> Bool {
      
        
        let row = tile.row
        let col = tile.col
        let boardTile = gameBoard!.getTile(atRow: row, andCol: col)
        
        if gameBoard!.isConnectedToValuedTilesBottom(tile: boardTile) {
            
            
            if gameBoard!.isConnectedToValuedTilesBottomTop(tile: tile) {
                if !checkMath(threeTiles: gameBoard!.getBottomTopConnectedValuedTiles(tile: tile)) {
                    print("bad math!")
                    return false
                }
            }
            
            if gameBoard!.numberOfBottomConnectedValuedTiles(tile: tile) == 2 {
                if !checkMath(threeTiles: gameBoard!.getBottomConnectedValuedTiles(tile: tile)) {
                    print("bad math")
                    return false
                }
            }
            
            if gameBoard!.numberOfBottomConnectedValuedTiles(tile: tile) != 2 && !gameBoard!.isConnectedToValuedTilesBottomTop(tile: tile) {
                print("Error--only connected to one tile on the bottom!")
                return false
            }
    
        }
        
        if gameBoard!.isConnectedToValuedTilesTop(tile: boardTile) {
            
            
            if gameBoard!.isConnectedToValuedTilesBottomTop(tile: tile) {
                if !checkMath(threeTiles: gameBoard!.getBottomTopConnectedValuedTiles(tile: tile)) {
                    print("bad math!")
                    return false
                }
            }
            
            if gameBoard!.numberOfTopConnectedValuedTiles(tile: tile) == 2 {
                if !checkMath(threeTiles: gameBoard!.getTopConnectedValuedTiles(tile: tile)) {
                    print("bad math")
                    return false
                }
            }
            
            if gameBoard!.numberOfTopConnectedValuedTiles(tile: tile) != 2 && !gameBoard!.isConnectedToValuedTilesBottomTop(tile: tile) {
                print("Error--only connected to one tile on the bottom!")
                return false
            }
            
        }
    
        if gameBoard!.isConnectedToValuedTilesLeft(tile: boardTile) {
            
            
            if gameBoard!.isConnectedToValuedTilesRightLeft(tile: tile) {
                if !checkMath(threeTiles: gameBoard!.getRightLeftConnectedValueTiles(tile: tile)){
                    print("bad math!")
                    return false
                }
            }
            
            if gameBoard!.numberOfLeftConnectedValuedTiles(tile: tile) == 2 {
                if !checkMath(threeTiles: gameBoard!.getLeftConnectedValuedTiles(tile: tile)) {
                    print("bad math")
                    return false
                }
            }
            
            if gameBoard!.numberOfLeftConnectedValuedTiles(tile: tile) != 2 &&
                !gameBoard!.isConnectedToValuedTilesRightLeft(tile: tile){
                print("Error--only connected to one tile on the left!")
                return false
            }
            
        }
        
        if gameBoard!.isConnectedToValuedTilesRight(tile: boardTile) {
            
            
            if gameBoard!.isConnectedToValuedTilesRightLeft(tile: tile) {
                if !checkMath(threeTiles: gameBoard!.getRightLeftConnectedValueTiles(tile: tile)) {
                    print("bad math!")
                    return false
                }
            }
            
            if gameBoard!.numberOfRightConnectedValuedTiles(tile: tile) == 2 {
                if !checkMath(threeTiles: gameBoard!.getRightConnectedValuedTiles(tile: tile)) {
                    print("bad math")
                    return false
                }
            }
            
            if gameBoard!.numberOfRightConnectedValuedTiles(tile: tile) != 2 && !gameBoard!.isConnectedToValuedTilesRightLeft(tile: tile) {
                print("Error--only connected to one tile on the right!")
                return false
            }
            
        }
        
        
        
        
        
        return true
    }
    
    func selectedTilesOnlyConnectedToThree() -> Bool {
        for tile in selectedPlayerTiles where tile.name != "DELETE"{
            
            
            if !tileIsOnlyConnectedToThree(tile: tile) {
                return false
            }
            
            
        }
        
        return true
    }

    
    func showSelectedTiles() {
        if selectedPlayerTiles.count == 0 {
            print("No selected player tiles!")
        }
        else {
            print("There are \(selectedPlayerTiles.count) selected player tiles")
        
        for tile in selectedPlayerTiles {
            
                print("tile value: \(tile.getTileLabelText())")
            }
        }
    }
    
    func showTilesUsedThisTurn() {
        if tilesUsedThisTurn.count == 0 {
            print("No tiles used this turn!")
        }
        else {
            print("There are \(tilesUsedThisTurn.count) tiles used this turn")
            
            for tile in tilesUsedThisTurn {
                
                print("tile value: \(tile.getTileLabelText())")
            }
        }
    }
    
    func checkMath(int1: Int, int2: Int, int3: Int) -> Bool {
        let n1 = Float(int1)
        let n2 = Float(int2)
        let n3 = Float(int3)
        
        return n1 == n2*n3 ||
            n1 == n2/n3    ||
            n1 == n2 + n3  ||
            n1 == n2 - n3  ||
            n3 == n2*n1    ||
            n3 == n2/n1    ||
            n3 == n2 + n1  ||
            n3 == n2 - n1
        
    }
    func checkMath(threeTiles: [Tile]) -> Bool {
        
        let int1 = threeTiles[0].getTileValue()!
        let int2 = threeTiles[1].getTileValue()!
        let int3 = threeTiles[2].getTileValue()!
        
        print("Checking math: \(int1) \(int2) \(int3)")
        let n1 = Float(int1)
        let n2 = Float(int2)
        let n3 = Float(int3)
        
        return n1 == n2*n3 ||
            n1 == n2/n3    ||
            n1 == n2 + n3  ||
            n1 == n2 - n3  ||
            n3 == n2*n1    ||
            n3 == n2/n1    ||
            n3 == n2 + n1  ||
            n3 == n2 - n1
        
    }
    enum playTileError: Error {
        
        case TilesNotOnBoard
        case TilesNotConnected
        case TilesNotConnectedInThrees
        case InvalidEquation
        case NotConnectedToBoardTile
    }

    
    func calculateScore()  {
        var nBonusTiles = 0
    
        for tile in selectedPlayerTiles {
            if tile.name != "DELETE" {
            let gameBoardTile = gameBoard!.getTile(atRow: tile.row, andCol: tile.col)
            if gameBoard!.bonusPointTiles.contains(gameBoardTile) {
                nBonusTiles += 1
            }
            }
        }
        
        var nonDeleteSelectedPlayerTiles = [Tile]()
        for tile in selectedPlayerTiles where tile.name != "DELETE" {
        
            nonDeleteSelectedPlayerTiles.append(tile)
        }
        
        let points = nBonusTiles*2 + nonDeleteSelectedPlayerTiles.count * nonDeleteSelectedPlayerTiles.count
        currentPlayer.score += points
        currentScoreLbl.text = "\(currentPlayer.userName!)'s score: \(currentPlayer.score)"
      scoreIncrement = points
    
        
    }
    
    




}






























