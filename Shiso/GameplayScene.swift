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
            print("game set in GameplayScene!!! GameID: \(game.gameID)")
        }
    }
    var bonusTilesUsed = [Tile]()
   
    var timeLabel = SKLabelNode()
    var timeLeft: Int? {
        didSet {
            timeLabel.text = "Time left: \(timeLeft!)"
        }
    }
    var gameTimer: Timer?
    
    
    var mainVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    
    var currentUserIsCurrentPlayer: Bool {
        return game.currentPlayerID == FirebaseConstants.CurrentUserID
    }
    var player1: Player!
    var player2: Player!
    

    var nonDeleteSelectedPlayerTiles = [Tile]()
    var restartBtn = SKLabelNode(text: "restart")
    var saveBtn = SKSpriteNode(color: UIColor.black, size: CGSize(width: 50, height: 50))
    

    var playerPassedTurn: Bool = false
    
    let wildCardPickOptions = ["", "0", "1", "2", "3" ,"4" ,"5", "6","7","8","9", "10", "11","12","13","14","15","16",
                               "17","18","19","20","21","22","23","24"]
    
    
    var wildCardPicker = WildCardPickerView()
    
    var tileCount = 20
    
    let tileRefreshBtn = SKLabelNode()
    
   let tileBag = SKSpriteNode(imageNamed: "tileSack")
    var tilesLeft: Int = 0  {
        didSet {
            print("There are now \(tilesLeft) tiles left")
           tilesLeft = max(0, tilesLeft) // won't create infinite loop
            tilesLeftLbl.text = "\(tilesLeft) tiles remaining"
        }
    }
    var tilesLeftLbl = SKLabelNode(text: "1 tiles remaining")
    
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
    
    var exchangeConfirmationLbl = SKLabelNode()

    var exchangeCandidates =  [Tile](){
        didSet{
            if exchangeCandidates.count == 0 || exchangeCandidates.count > tilesLeft
    
            {
                if exchangeCandidates.count > tilesLeft {
                    
                    let alert = UIAlertController(title:"Not enough tiles left!", message: "The maximum number of tiles you can exchange this turn is: \(tilesLeft)", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(ok)
                    if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                        mainVC.present(alert, animated: true, completion: nil)
                    }
                }
                exchangeConfirmationLbl.fontColor = .gray
                exchangeConfirmationLbl.fontName = GameConstants.TileLabelFontName
            }
            else {
                exchangeConfirmationLbl.fontColor = .black
                 exchangeConfirmationLbl.fontName = "ArialRoundedMTBold"

            }
        }
    }
    var exchangeMode = false
    var exchangeConfirmation = SKShapeNode()
    var exchangeBackground = SKSpriteNode()
    var exchangeLabel = SKLabelNode()
    let exchangeExitBtn = SKSpriteNode(imageNamed: "exitButton")
    var disableGame = false
    
    var currentTileRack = SKSpriteNode() //not needed
    var currentTileRackDisplay = SKSpriteNode()
    var currentScoreLbl = SKLabelNode()
    

    var currentPlayer: Player!
    var currentPlayerN = Int()
 
    var currentPlayerScore = Int(){
        didSet {
            print("player \(currentPlayerN) score: \(currentPlayerScore)")
            let currentPlayerScoreLbl = currentPlayerN == 1 ? player1ScoreLbl : player2ScoreLbl
      
        }
    }
    
    
    var gameBoard: Board!
    var gameBoardDisplay = SKSpriteNode()
    
    var playBtn = Tile()
    var playBtn_NEW: SKShapeNode!
    var endTurnBtn: SKShapeNode!
    var exchangeBtn: SKShapeNode!
    
    var bingoLabel = SKLabelNode(text: "Nice One! +10")
    
    var selectedGameBoardTiles = [Tile]() 
    var endOfGamePanel = SKSpriteNode()
    var yesBtn = SKLabelNode()
    var noBtn = SKLabelNode()
    var tileRefreshBtnTapped = false
  
    var recallTilesBtn: SKShapeNode!
    
    var backLblNode = SKLabelNode(text: "🔙")
  
    var eog = GameOverPanel()
    var lastTouchedWildCardTile: Tile?

    var initializeGameCount: Int!
   
    func presentGameOverPanel(){
        let eogWidth = 580
        let eogHeight = 330
        eog = GameOverPanel(rect: CGRect(x: -eogWidth/2, y: -eogHeight/2, width: eogWidth , height: eogHeight), cornerRadius: 15)
        eog.position.y = gameBoardDisplay.size.height/2 + eog.frame.size.height/2 + 5
        eog.setUpGameOverPanel(game: game)
  
       
        addChild(eog)
        
        
        
        guard self.scene?.children != nil else {
            return
            
        }
        

         disableGame = true
    }
    
    func initializeGame () {

       // let test = SpriteBtn(nodeLabel: "TEST !!!", lblFontColor: .blue, lblFontSize: 40, nodeSize: CGSize(width:300, height:50), nodePos: CGPoint(x:0,y:0), nodeColor: .blue)
       // addChild(test)

     
    
    gameBoard = game.board
    gameBoardDisplay = gameBoard.setUpBoard()
    
     
        if game.gameOver {
            presentGameOverPanel()
            
            FirebaseConstants.CurrentUserPath!.child(FirebaseConstants.UserGames).child(game.gameID).removeValue()
            FirebaseConstants.GamesNode.child(game.gameID).removeValue()
            
        }
        
    gameBoardDisplay.name = GameConstants.GameBoardDisplayName
        
        
  //  game.singlePlayerMode = true
        if game.singlePlayerMode {
            timeLeft = 10
        }
    
        player1 = game.player1
        player2 = game.player2
    //  print("player 1 is: \(player1.userName) player 2 is: \(player2.userName)")
    currentPlayer = player1.userID == game.currentPlayerID ? player1 : player2
    currentPlayerN = currentPlayer.player1 == true ? 1 : 2
   
    tilesLeft = game.tilesLeft
        // setUpPlayerTiles()
       // currentUserTileRack = player1.userID == FirebaseConstants.CurrentUserID ? player1.tileRack : player2.tileRack
    
       // currentUserTileRack.setUpPlayerTileRack(player: currentPlayerN)
        
        
       // print("in initializeGame: setting player 1 score label for: \(player1.userName!) and player 2 to: \(player2.userName!)")
        player1ScoreLbl.text = "\(player1.userName!): \(player1.score)"
        player2ScoreLbl.text = "\(player2.userName!): \(player2.score)"
        player1ScoreLbl.fontSize = 40
        player2ScoreLbl.fontSize = 40
        
        
       
        
        currentScoreLbl = currentPlayerN == 1 ? player1ScoreLbl : player2ScoreLbl
        let otherScoreLbl = currentPlayerN == 1 ? player2ScoreLbl : player1ScoreLbl
        currentScoreLbl.fontColor = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
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
        
    currentPlayerTileRackDisplay.position.x = 0
    currentPlayerTileRackDisplay.position.y = -gameBoardDisplay.size.height/2 - currentPlayerTileRackDisplay.size.height/2 - 10
    addChild(currentPlayerTileRackDisplay)
   
        
        
    }
    
    func updateScoreLabel() {
     
        currentScoreLbl.text = "\(currentPlayer.userName!): \(currentPlayer.score)"
        
    }
    
    func showCurrentTileRack() {
        print("Showing currentUserTileRack...") 
        currentPlayerTileRack.showTileRack()
    }
    
    override func didMove(to view: SKView) {
        
       self.initializeGame()
    
    
        
        if game.singlePlayerMode {
            addChild(timeLabel)
            timeLabel.zPosition = 50
            timeLabel.color = .black
            timeLabel.fontSize = 50
            gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            
            
        }
    
    restartBtn.fontSize = 40
    restartBtn.zPosition = 3
    restartBtn.position = CGPoint(x: -200, y: 400)
  //  addChild(restartBtn)
        
        
        playBtn.initializeTile(width: 200, height: 100, tileValueText: nil)
        playBtn.tileLabel.text = "PLAY +"
        playBtn.name = "Play"

        playBtn.position = CGPoint(x: -20, y: -250)
        playBtn.color = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        
        /*setUpNodeWithText(nodeLabel: "Node with Text!", lblFontColor: .red, lblFontSize: 40, nodeSize: CGSize(width:300,height:50), nodePos: CGPoint(x:0,y:0), nodeColor: .black)
       */
        
        playBtn_NEW = SKShapeNode(rect: CGRect(x: 0, y:0, width: 300, height: 70), cornerRadius: 10)
        playBtn_NEW.fillColor =  UIColor(red: 85/255, green: 158/255, blue: 131/255, alpha: 1.0)
        let playBtnText = SKLabelNode(text: "Play +")
        playBtnText.fontColor = .white
        playBtnText.fontName = GameConstants.TileLabelFontName
        playBtnText.fontSize = 45

       playBtnText.horizontalAlignmentMode = .center
       playBtnText.verticalAlignmentMode  = .center
      
        
        playBtn_NEW.position = CGPoint(x: -350, y:  -self.size.height/2 + 150)
        playBtnText.position = CGPoint(x: playBtn_NEW.position.x + playBtn_NEW.frame.width/2, y: playBtn_NEW.position.y + playBtn_NEW.frame.height/2)
       
        endTurnBtn = SKShapeNode(rect: CGRect(x: 0, y:0, width: 300, height: 70), cornerRadius: 10)
        endTurnBtn.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        endTurnBtn.position = CGPoint(x: playBtn_NEW.position.x , y: playBtn_NEW.position.y - playBtn_NEW.frame.height - 10)
        let endTurnText = SKLabelNode(text: "End Turn")
        endTurnText.fontColor = UIColor.red
        endTurnText.fontName = GameConstants.TileLabelFontName
        endTurnText.fontSize = 35
        endTurnText.position = CGPoint(x: endTurnBtn.position.x + endTurnBtn.frame.width/2, y: endTurnBtn.position.y + playBtn_NEW.frame.height/2)
        endTurnText.horizontalAlignmentMode = .center
        endTurnText.verticalAlignmentMode = .center
        endTurnText.zPosition = endTurnBtn.zPosition + 1
       // addChild(playBtn)
        addChild(playBtn_NEW)
        addChild(playBtnText)
        
        addChild(endTurnBtn)
        addChild(endTurnText)
        
        
        
        recallTilesBtn = SKShapeNode(rect: CGRect(x: 0, y:0, width: playBtn_NEW.frame.size.width, height: playBtn_NEW.frame.size.height), cornerRadius: 10)
        recallTilesBtn.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        recallTilesBtn.position = CGPoint(x: gameBoardDisplay.frame.size.width/2 - recallTilesBtn.frame.size.width, y: playBtn_NEW.position.y)
        recallTilesBtn.position.y = playBtn_NEW.position.y
        
        let recallTilesBtnText = SKLabelNode(text: "Recall")
        recallTilesBtnText.fontColor = UIColor(red: 67/255, green: 84/255, blue: 167/255, alpha: 1.0)
        recallTilesBtnText.fontName = GameConstants.TileLabelFontName
        recallTilesBtnText.fontSize = 35
        recallTilesBtnText.position = CGPoint(x: recallTilesBtn.position.x + recallTilesBtn.frame.width/2, y: recallTilesBtn.position.y + recallTilesBtn.frame.height/2)
        recallTilesBtnText.horizontalAlignmentMode = .center
        recallTilesBtnText.verticalAlignmentMode = .center
        recallTilesBtnText.zPosition = recallTilesBtn.zPosition + 1
        
        addChild(recallTilesBtn)
        addChild(recallTilesBtnText)
        
        
        exchangeBtn = SKShapeNode(rect:CGRect(x:0,y:0, width: playBtn_NEW.frame.size.width, height: playBtn_NEW.frame.size.height), cornerRadius: 10)
        exchangeBtn.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        exchangeBtn.position = CGPoint(x: recallTilesBtn.position.x, y: endTurnBtn.position.y)
        
        let exchangeBtnText = SKLabelNode(text: "Exchange")
        exchangeBtnText.fontColor = UIColor(red: 67/255, green: 84/255, blue: 167/255, alpha: 1.0)
        exchangeBtnText.fontName = GameConstants.TileLabelFontName
        exchangeBtnText.fontSize = 30
        exchangeBtnText.position = CGPoint(x: exchangeBtn.position.x + exchangeBtn.frame.width/2,y: exchangeBtn.position.y + exchangeBtn.frame.height/2)
        exchangeBtnText.horizontalAlignmentMode = .center
        exchangeBtnText.verticalAlignmentMode = .center
        exchangeBtnText.zPosition = exchangeBtn.zPosition + 1
        
        addChild(exchangeBtn)
        addChild(exchangeBtnText)
        
        
        
        
        
        
       
      //add score Labels
        player1ScoreLbl.position = CGPoint(x: -200, y: 600)
        player1ScoreLbl.zPosition = 2
        
        player1ScoreLbl.fontSize = 50
        player1ScoreLbl.fontName = "Arial"
        
        addChild(player1ScoreLbl)
        
       
        player2ScoreLbl.position = CGPoint(x: 200, y: 600)
        player2ScoreLbl.zPosition = 2
        player2ScoreLbl.fontSize = 50
        player2ScoreLbl.fontName = "Arial"
        
        addChild(player2ScoreLbl)
        
        
        //add separator bar between two score labels
        let labelSeparatorBar = SKSpriteNode(color: .black, size: CGSize(width: 5, height: 2*player1ScoreLbl.frame.size.height))
        labelSeparatorBar.position.y = player1ScoreLbl.position.y
        addChild(labelSeparatorBar)
        
       tileBag.position.y = labelSeparatorBar.position.y - labelSeparatorBar.size.height/2 - tileBag.size.height/2 - 20
       // addChild(tileBag)
        
        tilesLeftLbl.position.y = //tileBag.position.y - tileBag.size.height/2 - tilesLeftLbl.frame.size.height/2 - 5
        labelSeparatorBar.position.y - labelSeparatorBar.size.height/2 - tileBag.size.height/2 - 20
        addChild(tilesLeftLbl)
        tilesLeftLbl.fontName = GameConstants.TileLabelFontName
       
        
        bingoLabel.position = CGPoint(x: 0, y: 400)
        bingoLabel.fontName = "Arial"
        bingoLabel.fontSize = 50
        bingoLabel.zPosition = 2
        addChild(bingoLabel)
        bingoLabel.isHidden = true
        

        
        
        
        
     
        wildCardPicker.initializePicker(tileColor: .lightGray)
        
        addChild(wildCardPicker)
        
        wildCardPicker.zPosition = 50
        wildCardPicker.isHidden = true
        
        }
    
    
    func updateTimer(){
        timeLeft? -= 1
        print("time left: \(timeLeft)")
        if timeLeft == 0 {
            gameTimer?.invalidate()
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard disableGame == false else {return}
      //  guard currentUserIsCurrentPlayer else {return}
        
        for touch in touches {
            
            let location = touch.location(in: currentPlayerTileRackDisplay)
            
            if let selectedTile = selectedPlayerTile, selectedPlayerTile?.tileLabel.text != "?",
             deactivateGameNodes == false ,
                selectedPlayerTiles.contains(selectedTile) {
                
                selectedTile.position = location
               
            }
            
            
            if !wildCardPicker.isHidden {
                let wildCardLoc = touch.location(in: self)
                wildCardPicker.position = wildCardLoc
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
          guard disableGame == false else {return}
            for touch in touches {
            
                let location = touch.location(in: self)
            
            
       
        
            for tile in currentPlayerTileRack.playerTiles.values  {
                if nodes(at: location).contains(tile), deactivateGameNodes == false {
                  
                    playBtnPushed = false
                    selectedPlayerTile = tile
                    selectedPlayerTile?.tileLabel.fontColor = .white
                    if selectedPlayerTile?.tileLabel.text == GameConstants.TileWildCardSymbol{
                    
                        wildCardPicker.isHidden = false
                        deactivateGameNodes = true
                        
                    }
                    
                   
                    
                    
           
                
                  if !selectedPlayerTiles.contains(tile)  && tile.tileLabel.text != GameConstants.TileWildCardSymbol {
                        selectedPlayerTiles.append(tile)
                        tilesUsedThisTurn.append(tile)
                    
                    }
                }
                else if nodes(at: location).contains(tile) && exchangeMode  {
                    
                    
                    if !(exchangeCandidates.contains(tile)) {
                        tile.position.y -= 150
                        exchangeCandidates.append(tile)
                    }
                    else {
                       exchangeCandidates =  exchangeCandidates.filter{$0 != tile}
                       tile.position = tile.startingPosition
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
                            self.selectedPlayerTile?.tileLabel.fontColor = .white
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
                
                if let touchedTile = node as? Tile, touchedTile.name == GameConstants.TileBoardTileName,
                    touchedTile.inSelectedPlayerTiles, deactivateGameNodes == false  {
                   
                    let row = touchedTile.row
                    let col = touchedTile.col
                   
                    var eraserTileAtNode: Tile?
                    var selectedPlayerTilesAtNode = [Tile]()
                    for tile in selectedPlayerTiles {
                        if tile.row == row && tile.col == col {
                            //selectedPlayerTile = tile
                            selectedPlayerTilesAtNode.append(tile)
                            
                        }
                    }
                    
                    print("there are \(selectedPlayerTilesAtNode.count) tiles at this node")
                
                    
                    if selectedPlayerTilesAtNode.count > 1 {
                        for tile in selectedPlayerTilesAtNode {
                            print("tile at node: \(tile.getTileTextRepresentation())")
                            if tile.tileType == TileType.eraser {
                                print("you have an eraser tile here")
                                tile.isHidden = false
                                tile.alpha = 1.0
                                
                                let returnHome = SKAction.move(to: tile.startingPosition, duration: 1.0)
                                tile.run(returnHome)
                                selectedPlayerTiles = selectedPlayerTiles.filter({$0 != tile})
                                tilesUsedThisTurn = tilesUsedThisTurn.filter({$0 != tile})
                                showSelectedTiles()
                            }
                            else {
                                selectedPlayerTile = tile
                            }
                        }
                        
                    }
                    else {
                        selectedPlayerTile = selectedPlayerTilesAtNode[0]
                    }
                    
                    selectedPlayerTilesAtNode.removeAll()
                 
                    
                    selectedPlayerTile?.isHidden = false
                    selectedPlayerTile?.alpha = 1.0
                    
                    
                    if let holdVal = touchedTile.holdingValue, let holdCol = touchedTile.holdingColor {
                        print("touched tile holding color: \(touchedTile.holdingColor)")
                        print("holding val is \(touchedTile.holdingValue)")
                        print("touched tile player: \(touchedTile.player)")
                        touchedTile.setTileValue(value: holdVal)
                        touchedTile.color = holdCol
                        touchedTile.player = holdCol == GameConstants.TilePlayer1TileColor ? 1 : 2
                        touchedTile.holdingValue = nil
                        touchedTile.holdingColor = nil
                     
                    }
                    else {
                       touchedTile.setTileValue(value: nil)
                        let gameBoardTile = gameBoard.getTile(atRow: row, andCol: col)
                        if bonusTilesUsed.contains(gameBoardTile) {
                            touchedTile.tileLabel.text = "+2"
                            touchedTile.tileLabel.fontColor = .gray
                            for (i,bonusTile) in bonusTilesUsed.enumerated() {
                                if bonusTile == gameBoardTile {
                                    bonusTilesUsed.remove(at: i)
                                    break
                                }
                            }
                            
                        }
                       touchedTile.color = GameConstants.TileDefaultColor
                    }
                
                    
                    touchedTile.inSelectedPlayerTiles = false
                    
                  
                }
            }
        
            if nodes(at: location).contains(playBtn_NEW)  && deactivateGameNodes == false {
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
             
                func recall() {
                    for tile in selectedPlayerTiles {
                        tile.isHidden = false
                        tile.alpha = 1.0
                        let goHome = SKAction.move(to: tile.startingPosition, duration: 0.3)
                        let boardTile = gameBoard.getTile(atRow: tile.row, andCol: tile.col)
                        boardTile.inSelectedPlayerTiles = false
                        
                        
                        
                        if let holdVal = boardTile.holdingValue, let holdCol = boardTile.holdingColor {
                            boardTile.setTileValue(value: holdVal)
                            boardTile.color = holdCol
                            if boardTile.player == nil {
                                boardTile.player = holdCol == GameConstants.TilePlayer1TileColor ? 1 : 2
                            }
                        }
                        else {
                            boardTile.player = nil
                            boardTile.setTileValue(value: nil)
                            boardTile.color = GameConstants.TileBoardTileColor
                            
                        }
                        
                        if bonusTilesUsed.contains(boardTile) {
                            print("Bonus tiles contains tile!")
                            boardTile.tileLabel.text = "+2"
                            boardTile.tileLabel.fontColor = .gray
                        }
                        
                        tile.run(goHome)
                        for (ind, turnTile) in tilesUsedThisTurn.enumerated() {
                            if turnTile == tile {
                                tilesUsedThisTurn.remove(at: ind)
                                break
                            }
                        }
                    }
                    selectedPlayerTiles.removeAll()
                    bonusTilesUsed.removeAll()
                    
                }
                
                //MARK: EXCHANGE BUTTON PRESSED
                
                if nodes(at: location).contains(exchangeBtn) {
                    
                     guard tilesLeft != 0 else {
                        let alert = UIAlertController(title:"No tiles left!", message: "Exchanges are not possible without any tiles left to exchange!", preferredStyle: UIAlertControllerStyle.alert)
                        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        alert.addAction(ok)
                        if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                            mainVC.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    
                    exchangeMode = true
                    deactivateGameNodes = true
                    
                    recall()
                    
                    exchangeBackground = SKSpriteNode(color: .white, size: CGSize(width: gameBoardDisplay.size.width, height: currentPlayerTileRackDisplay.size.height*3))
                    exchangeBackground.position.x  = currentPlayerTileRackDisplay.position.x
                    exchangeBackground.position.y = currentPlayerTileRackDisplay.position.y - exchangeBackground.size.height/2 - currentPlayerTileRackDisplay.size.height/2 - 20
                    exchangeBackground.zPosition = 2
                    
                  
                   
                    
                    exchangeExitBtn.scale(to: CGSize(width: 40, height: 40))
                    exchangeExitBtn.position.x = currentPlayerTileRackDisplay.position.x - currentPlayerTileRackDisplay.size.width/2  + exchangeExitBtn.size.width/2 + 5
                    
                    exchangeExitBtn.position.y = currentPlayerTileRackDisplay.position.y - currentPlayerTileRackDisplay.size.height/2 -
                        exchangeExitBtn.size.height/2 - 22
                
                    exchangeExitBtn.zPosition = exchangeBackground.zPosition + 1
                   
                    addChild(exchangeExitBtn)
                    
                    exchangeLabel = SKLabelNode(text: "Select the tiles you'd like to exchange!")
                    exchangeLabel.fontColor = .black
                    exchangeLabel.fontName = GameConstants.TileLabelFontName
                    exchangeLabel.fontSize = 30
                    exchangeLabel.zPosition = exchangeBackground.zPosition + 1
                    exchangeLabel.position.y = exchangeExitBtn.position.y
                    exchangeLabel.verticalAlignmentMode = .center
                    
                    exchangeLabel.position.x = exchangeExitBtn.position.x + exchangeLabel.frame.size.width/2 + exchangeExitBtn.size.width/2 + 5
                    
                    addChild(exchangeLabel)
                    
                    
                   let exchangeConfirmationWidth = currentPlayerTileRackDisplay.size.width/3 + 2
                    exchangeConfirmation = SKShapeNode(rect: CGRect(x: -exchangeConfirmationWidth/2, y: exchangeLabel.position.y -
                        currentPlayerTileRackDisplay.size.height*2.5, width: exchangeConfirmationWidth, height:currentPlayerTileRackDisplay.size.height), cornerRadius: 10)
                    exchangeConfirmation.fillColor = .lightGray
                    exchangeConfirmation.zPosition = exchangeBackground.zPosition + 1
                    
                     exchangeConfirmationLbl = SKLabelNode(text: "Exchange")
                    exchangeConfirmationLbl.fontColor = .gray
                    exchangeConfirmationLbl.fontName = GameConstants.TileLabelFontName
                    exchangeConfirmationLbl.fontSize = 40
                    exchangeConfirmationLbl.position.y =  exchangeLabel.position.y -
                        currentPlayerTileRackDisplay.size.height*2.5 + exchangeConfirmationLbl.frame.size.height
                   
                    exchangeConfirmationLbl.verticalAlignmentMode = .center
                    exchangeConfirmationLbl.horizontalAlignmentMode = .center
                    
                    
                    exchangeConfirmationLbl.zPosition = exchangeConfirmation.zPosition + 1
                    
                    addChild(exchangeConfirmationLbl)
                    addChild(exchangeConfirmation)
                    
                addChild(exchangeBackground)
              }
            
            
                if nodes(at: location).contains(exchangeExitBtn){
                    
                    deactivateGameNodes = false
                    exchangeMode  = false
                    for tile in currentPlayerTileRack.playerTiles.values {
                        tile.position = tile.startingPosition
                    }
                    exchangeExitBtn.removeFromParent()
                    exchangeBackground.removeFromParent()
                    exchangeLabel.removeFromParent()
                    exchangeBackground.removeFromParent()
                    exchangeConfirmation.removeFromParent()
                    exchangeConfirmationLbl.removeFromParent()
                    
                    exchangeCandidates.removeAll()
                }
                
                if nodes(at: location).contains(exchangeConfirmationLbl)
                    && 0 < exchangeCandidates.count && exchangeCandidates.count <= tilesLeft && exchangeMode {
                    //MARK: expand on exchange
                    
                    let exchangeAlertOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:
                    { action in
                    
                        self.currentPlayerTileRack.swapOutExchangedTiles(tiles: self.exchangeCandidates, playerN: self.currentPlayerN)
                       
                        for tile in self.exchangeCandidates {
                            print("tile in exchange candidates, val: \(tile.getTileTextRepresentation()) and rack position: \(tile.rackPosition)")
                            let newTile = self.currentPlayerTileRack.playerTiles[tile.rackPosition]
                            guard newTile != nil else {
                                print("new Tile is nil, returning")
                                return
                            }
                            
                                let color = self.currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                            
                                let expandTile = SKAction.scale(by: 1.5, duration: 0.1)
                                let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 0.0 , duration: 0.1)
                                let changeBack = SKAction.colorize(with: color, colorBlendFactor: 0.0, duration: 0.1)
                                
                                let shrinkTile = SKAction.scale(by: 1/1.5, duration: 0.6)
                                let wait = SKAction.wait(forDuration: 1.0)
                                let seq = SKAction.sequence([ wait, shrinkTile, changeBack])
                                newTile!.run(expandTile)
                                newTile!.run(changeToYellow){
                                    newTile!.run(seq)
                                
                            }
                     
                        }
                        
                        self.deactivateGameNodes = false
                        self.exchangeMode  = false
                        self.exchangeExitBtn.removeFromParent()
                        self.exchangeBackground.removeFromParent()
                        self.exchangeLabel.removeFromParent()
                        self.exchangeBackground.removeFromParent()
                        self.exchangeConfirmation.removeFromParent()
                        self.exchangeConfirmationLbl.removeFromParent()
                        self.exchangeCandidates.removeAll()
                        
                        
                    })
                    let exchangeAlertCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                        
                    cancelAction in
                        
                        for tile in self.exchangeCandidates {
                            tile.position = tile.startingPosition
                        
                        }
                       self.exchangeCandidates.removeAll()
                    })
                    
                    let alertCon = UIAlertController(title: nil, message: "Exchange tiles and lose your turn?", preferredStyle: UIAlertControllerStyle.alert)
                    alertCon.addAction(exchangeAlertOK)
                    alertCon.addAction(exchangeAlertCancel)
                    
                    
                    if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                        mainVC.present(alertCon, animated: true, completion: nil)
                    }
                
                    
                   
                }
                
            //RECALL TILES
                if nodes(at: location).contains(recallTilesBtn), selectedPlayerTiles.count > 0 {
                  recall()
                    
                }
        
             
            
                //MARK: End Turn button hit
            if nodes(at: location).contains(endTurnBtn) && deactivateGameNodes == false {
                
                if endGame {
                    displayEndOfGamePanel()
                    break
                }
               
                
                if  playBtnPushed || selectedPlayerTiles.count == 0 {
                    
                    let endTurnAlert = UIAlertController(title: nil, message: "End your turn?", preferredStyle: UIAlertControllerStyle.alert)
                    let endTurnConfirm = UIAlertAction(title: "End Turn", style: .default, handler: { (okAction) in
                        self.playerPassedTurn = self.tilesUsedThisTurn.count == 0
                        print("passed turn? -> \(self.playerPassedTurn)")
                        
                        
                        self.turnDone()
                    })
                    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                    
                    endTurnAlert.addAction(endTurnConfirm)
                    endTurnAlert.addAction(cancel)
                    
                    if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                        mainVC.present(endTurnAlert, animated: true, completion: nil)
                    }
                
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
          guard disableGame == false else {return}
        for touch in touches {
            
            let location = touch.location(in: self)
            
           
            
            var selectedTileOnBoard = false
            if let selectedTile = selectedPlayerTile, nodes(at: location).contains(selectedTile), deactivateGameNodes == false {
                
                
                for node in nodes(at: location) {
                    if let targetTile = node as? Tile {
                
                        if targetTile.name == GameConstants.TileBoardTileName  && targetTile.tileIsEmpty && selectedTile.name != GameConstants.TileDeleteTileName {
                            print("selected tile is on board and about to set row/col as \(targetTile.row) and \(targetTile.col)")
                            selectedTileOnBoard = true
                            selectedTile.row = targetTile.row
                            selectedTile.col  = targetTile.col
                           // print("selected tile value: \(selectedTile.getTileValue()) and rack position \(selectedTile.rackPosition)")
                           
                            
                            selectedTile.isHidden = true
                      
                            
                            if targetTile.tileLabel.text == "+2" {
                                bonusTilesUsed.append(targetTile)
                                print("in touchesEnded: bonus Tile touched!!!")
                            }
                            
                            
                            targetTile.color = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor :GameConstants.TilePlayer2TileColor
                            
                            if let tileValue = selectedTile.getTileValue() {
            
                              targetTile.setTileValue(value: tileValue)
                               
                                targetTile.tileLabel.fontColor = .white
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
                            && !targetTile.tileInStartingTiles()
                        
                        {
                            
                       
                            selectedTileOnBoard = true
                            selectedTile.row = targetTile.row
                            selectedTile.col  = targetTile.col
                            let fade = SKAction.fadeOut(withDuration: 0.5)
                            selectedTile.run(fade)
                           //selectedTile.isHidden = true
                            if let tileValue = targetTile.getTileValue() {
                                targetTile.holdingValue = tileValue
                                targetTile.holdingColor = targetTile.color
                                print("set target tile holding val to: \(targetTile.holdingValue) and holding color to: \(targetTile.holdingColor)")
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
        
            bingoLabel.isHidden = false
            let moveBingoLabel: SKAction = SKAction.moveBy(x: 0, y: 270, duration: 2)
            let fade = SKAction.fadeOut(withDuration: 2)
            bingoLabel.run(fade)
            bingoLabel.run(moveBingoLabel){
                self.updateScoreLabel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                {
                    self.switchPlayers()
                }
            }
            bingoLabel.position = CGPoint(x: 0, y: 400)
            bingoLabel.alpha = 1.0
            
            
        
    }
    func turnDone() {
        
        print("In turnDone")
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
       
        if (game.lastTurnPassed && playerPassedTurn) || (currentPlayerTileRack.playerTiles.count == 0 && tilesLeft == 0) {
            game.gameOver = true
            presentGameOverPanel()
            
            
            Fire.dataService.updateStatsAndRemoveGame(game: game)
            
            
        }
        else {
            game.gameOver = false
            game.tilesLeft = tilesLeft
            game.lastTurnPassed = playerPassedTurn
            game.lastUpdated =  Int(NSDate().timeIntervalSince1970)
        
       

        }
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            print("about to save...current player (player \(self.currentPlayerN)) score: \(self.currentPlayer.score) player 1 score: \(self.player1.score) player2 score = \(self.player2.score)")
            Fire.dataService.saveGameData(game: self.game, completion: nil)
        }
        
      
       

    }
    

    
    
    func play() {
        
        for tile in selectedPlayerTiles where tile.tileType != TileType.eraser {
            nonDeleteSelectedPlayerTiles.append(tile)
        }
        
      let legalMove =  checkIfLegalMove()
        
      
        // if so, set values on board and remove tiles, if not alert user and return tiles
        // replace player tiles that were played
        
        if legalMove {
            print("Good!")
          
            //tilesLeft -= selectedPlayerTiles.count
            
            for tile in selectedPlayerTiles {
                
                let row = tile.row
                let col = tile.col
                let gameBoardTile = gameBoard!.getTile(atRow: row, andCol: col)
                gameBoardTile.inSelectedPlayerTiles = false
                
                if tile.tileType == TileType.eraser {
                   gameBoardTile.color = .white
                    gameBoardTile.holdingValue = nil
                }
                
            }
          
            lightUpPlayedTiles {
                (tiles) in

                for tile in tiles {
                    tile.color = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                }
              
                self.selectedPlayerTiles.removeAll()
                
                if self.tilesUsedThisTurn.count == 8 {
                   self.showBingo()
                }
                
            
            }
           // showCurrentTileRack()
        }
        
        else {
            for tile in selectedPlayerTiles {
                
                //var deleteTileHere = false
                tile.isHidden = false
                let row = tile.row
                let col = tile.col
                
                
                if tile.isTileOnBoard() {
                    
                    
                    
                    let gameBoardTile = gameBoard?.getTile(atRow: row, andCol: col)
                    
                    gameBoardTile?.player = 0
                    
                    if let holdVal = gameBoardTile!.holdingValue, let holdCol = gameBoardTile!.holdingColor {
         
                        gameBoardTile!.setTileValue(value: holdVal)
                        gameBoardTile!.color = holdCol
                    }
                    
                    else {
                        gameBoardTile!.setTileValue(value: nil)
                        if bonusTilesUsed.contains(gameBoardTile!) {
                            gameBoardTile!.tileLabel.text = "+2"
                            gameBoardTile!.tileLabel.fontColor = .gray
                        }
                        gameBoardTile!.color = GameConstants.TileDefaultColor
                    }
     
                    
                    
                    gameBoardTile!.inSelectedPlayerTiles = false
                }
            }
            
           
            resetSelectedPlayerTiles()
           
        }
        
        
         nonDeleteSelectedPlayerTiles.removeAll()
         bonusTilesUsed.removeAll()
    }

    
    
    func lightUpPlayedTiles(completion: ([Tile]) -> ()) {
    
        var color: SKColor = SKColor()
        
        color = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
        
        
        
        let gameBoardTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
        
        let expandTile = SKAction.scale(by: 1.2, duration: 0.1)
        let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 0.0 , duration: 0.1)
        let changeBack = SKAction.colorize(with: color, colorBlendFactor: 0.0, duration: 0.1)

        let shrinkTile = SKAction.scale(by: 1/1.2, duration: 0.6)
        let wait = SKAction.wait(forDuration: 0.1)
        let seq = SKAction.sequence([ wait, shrinkTile, changeBack])
        
        calculateScore()
        //let points = scoreIncrement
        print("in light up tiles, after calculateScore(). points = \(scoreIncrement)")
        
        for  (i,tile) in gameBoardTiles.enumerated() {
           tile.run(expandTile)
            tile.zPosition = 4
            tile.run(changeToYellow){
                tile.run(seq){
                    tile.zPosition = 2
                    if i == gameBoardTiles.count - 1 {
                        var loc = gameBoardTiles[i].position
                        loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                       // self.showPoints(atLocation: loc, points: points)
                       self.showPoints(atLocation: loc, points: self.scoreIncrement)
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
                print("in convertnonDelete... tile value is \(tile.getTileValue()) at row \(tile.row) and col \(tile.col)")
                if tile.tileType != TileType.eraser {
                    print("Tile val: \(tile.getTileValue()!) row: \(tile.row) col: \(tile.col)")
                        
                gameBoardTiles.append(gameBoard!.getTile(atRow: tile.row, andCol: tile.col))
                }
            }
        }
        return gameBoardTiles
    }
    
    func showPoints(atLocation location: CGPoint,points: Int) {
  
        let pointDisplay = SKLabelNode(text: "+ \(points)!")
      
        pointDisplay.fontName = "AvenirNext-Bold"
        pointDisplay.fontSize = 50
        pointDisplay.fontColor = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
        pointDisplay.position = CGPoint(x: location.x , y: location.y)
       
    
        pointDisplay.zPosition = 2
        let movePointDisplay = SKAction.moveTo(y: location.y + 300, duration: 2)
        let fadePointDisplay = SKAction.fadeOut(withDuration: 2)
        
        addChild(pointDisplay)
        
        pointDisplay.run(movePointDisplay)
        pointDisplay.run(fadePointDisplay){
        pointDisplay.removeFromParent()
            print("in showPoints(): current player score is: \(self.currentPlayer.score)")
            //self.currentPlayerScore += points
            self.updateScoreLabel()
           // self.currentScoreLbl.text = "\(self.currentPlayer.userName!): \(self.currentPlayer.score)"
            print("changed score label, player points is: \(self.currentPlayer.score)")
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
    
    func nonPlayerTileConnectedToTargetTile() -> Tile? {
     
        let tTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
        for tile in tTiles {
            let connectedTiles = gameBoard.getBottomTopConnectedValuedTiles(tile: tile) + gameBoard.getRightLeftConnectedValueTiles(tile: tile)
            for connectedTile in connectedTiles {
                if connectedTile.player != currentPlayerN {
                   return connectedTile
                }
            }
        }
        return nil
    }

    func checkIfLegalTilePath() -> Bool {
        
        let nonPlayerSeedTile = nonPlayerTileConnectedToTargetTile()
        var targetTiles = [Tile]()
        if let base = nonPlayerSeedTile {
            print("Tile is connected to non-current-player tile: \(base.getTileTextRepresentation())")
            targetTiles =  convertNonDeleteSelectedPlayerTilesIntoBoardTiles() + [base]
            
        }
        else {
            print("No tile connected to non-current-player tile")
         targetTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
            
        }
        
        
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
    
/*        for tile in tilesUsedThisTurn {
           
             currentPlayerTileRack.removeAndReplaceTileFromRack(tile: tile, player:currentPlayerN)
             print("Finished remove and replace tile from rack")
            
            
            
        }
        
    */
        
        for tile in tilesUsedThisTurn {
            print("tiles left: \(tilesLeft)")
            currentPlayerTileRack.removeTileFromRack(tile: tile, player: currentPlayerN, replace: tilesLeft > 0)
            tilesLeft -= 1
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
                print("connected right/left? --> \(gameBoard!.isConnectedToValuedTilesRightLeft(tile: tile))")
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
 
        var nonDeleteSelectedPlayerTiles = [Tile]()
        for tile in selectedPlayerTiles where tile.tileType !=  TileType.eraser {
           nonDeleteSelectedPlayerTiles.append(tile)
        }
        print("in calculate score: bonus tiles used = \(bonusTilesUsed.count)")
        for btile in bonusTilesUsed {
            print("bonus tile at row: \(btile.row) and col: \(btile.col)")
        }
        let points = 2*bonusTilesUsed.count + nonDeleteSelectedPlayerTiles.count * nonDeleteSelectedPlayerTiles.count
        
        currentPlayer.score += points
        
        print("In calculateScore(), extra points: \(points); points for current player is now: \(currentPlayer.score)")
       // currentScoreLbl.text = "\(currentPlayer.userName!)'s score: \(currentPlayer.score)"
      scoreIncrement = points
    
        
    }
    


    func setUpNodeWithText( nodeLabel: String, lblFontColor: UIColor, lblFontSize: CGFloat,
                            nodeSize: CGSize, nodePos: CGPoint, nodeColor: UIColor)  {
        
        let sh = SKShapeNode(rect: CGRect(x: 0, y: 0, width: nodeSize.width ,height: nodeSize.height), cornerRadius: 10.0)
        sh.position = nodePos
        sh.fillColor = nodeColor
        
        let lbl = SKLabelNode(text: nodeLabel)
        lbl.fontColor = lblFontColor
        lbl.fontName  = GameConstants.TileLabelFontName
        lbl.fontSize = lblFontSize
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center
        lbl.position = CGPoint(x: sh.position.x + sh.frame.width/2, y: sh.position.y + sh.frame.height/2)
        
        addChild(sh)
        addChild(lbl)
    }




}































