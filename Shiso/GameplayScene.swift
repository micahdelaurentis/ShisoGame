//
//  GameplayScene.swift
//  Shiso
//

//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import SpriteKit
import Foundation
import AVFoundation
import Firebase
class GameplayScene: SKScene {

    let audioPlayer = AVAudioPlayer()
      var turnIsOver: Bool = false
    var game = Game() {
        didSet{
            print("game set in GameplayScene!!! single player: \(game.singlePlayerMode) GameID: \(game.gameID) tiles left: \(game.tilesLeft)")
        }
    }
    var bonusTilesUsed = [Tile]()
   
    var timeLabel = SKLabelNode()
    
    var timeLeft: Int? {
        didSet {
          
            let mins = "\(timeLeft!/60)"
            let secsN = timeLeft! - 60*(timeLeft!/60)
            let secs = secsN < 10 ? "0\(secsN)" : "\(secsN)"
            
            timeLabel.text = "\(mins):\(secs)"
            if timeLeft!/60 == 0 {
            if 0 < secsN && secsN <= 30 {

                timeLabel.fontColor = .red
            }
            else if secsN == 0 {
                timeLabel.removeFromParent()

            }
            }
        }
    }

    var gameTimer: Timer?
    var selectedPlayerTilesTileData = [TileData]()
    var singlePlayerPauseButton = SKLabelNode()
    var resumeGameButton = SKLabelNode()
    
    var mainVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    
    var currentUserIsCurrentPlayer: Bool = false
    var player1: Player!
    var player2: Player!
    

    var nonDeleteSelectedPlayerTiles = [Tile]()
    var restartBtn = SKLabelNode(text: "restart")
    var saveBtn = SKSpriteNode(color: UIColor.black, size: CGSize(width: 50, height: 50))
    

    var playerPassedTurn: Bool = true
    
    let wildCardPickOptions = ["", "0", "1", "2", "3" ,"4" ,"5", "6","7","8","9", "10", "11","12","13","14","15","16",
                               "17","18","19","20","21","22","23","24"]
    
    
    var wildCardPicker = WildCardPickerView()
    
    var tileCount = 20
    
    let tileRefreshBtn = SKLabelNode()
    
   let tileBag = SKSpriteNode(imageNamed: "tileSack")
    var tilesLeft: Int = 0  {
        didSet {
           
           tilesLeft = max(0, tilesLeft) // won't create infinite loop
            if !game.singlePlayerMode { tilesLeftLbl.text = "\(tilesLeft) tiles remaining" }
        }
    }
    var tilesLeftLbl = SKLabelNode()
    
    var player1Score = 0
    var player2Score = 0
    
    var timer = Timer()
    var player1ScoreLbl = SKLabelNode()
    var player2ScoreLbl = SKLabelNode()
    var otherScoreLbl = SKLabelNode()
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
    
    var singlePlayerRefreshtiles: SKShapeNode!
    
    let exchangeExitBtn = SKSpriteNode(imageNamed: "exitButton")
    var disableGame = false
    
    var currentTileRack = SKSpriteNode() //not needed
    var currentTileRackDisplay = SKSpriteNode()
    var currentScoreLbl = SKLabelNode()
    
    var pauseView = SKSpriteNode()
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
    
    var bingoLabel = SKLabelNode(text: "Nice! +\(GameConstants.BingoPoints)!")
    
    var selectedGameBoardTiles = [Tile]() 
    var endOfGamePanel = SKSpriteNode()
    var singlePlayerEndOfGamePanel = SKSpriteNode()
    var yesBtn = SKLabelNode()
    var noBtn = SKLabelNode()
    var tileRefreshBtnTapped = false
  
    var recallTilesBtn: SKShapeNode!
    
    var backLblNode = SKLabelNode(text: "🔙")
  
    var eog = GameOverPanel()
    var lastTouchedWildCardTile: Tile?

    var initializeGameCount: Int!
   
    func presentGameOverPanel(){
        print("In presentGameOverPanel. game board display width: \(gameBoardDisplay.size.width)")
        let eogWidth = 0.6*gameBoardDisplay.size.width
        let eogHeight = 0.6*gameBoardDisplay.size.height
        eog = GameOverPanel(rect: CGRect(x: -eogWidth/2, y: -eogHeight/2, width: eogWidth , height: eogHeight), cornerRadius: 15)
       // eog.position.y = gameBoardDisplay.size.height/2 + eog.frame.size.height/2 + 5
        eog.setUpGameOverPanel(game: game)
        
       eog.position.x = self.frame.minX - eog.frame.size.width/2
       let slideInEOG = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 1.0)
        addChild(eog)
        eog.run(slideInEOG)
        
        guard self.scene?.children != nil else {
            return
            
        }
        

         disableGame = true
    }
    
    func initializeGame () {
        print("in initializeGame")
 
    
        
    gameBoard = game.board
    gameBoardDisplay = gameBoard.setUpBoard()
    gameBoardDisplay.name = GameConstants.GameBoardDisplayName
        
        if game.gameOver {
            print("in initialize game...game over, presenting game over panel")
            presentGameOverPanel()
            
            FirebaseConstants.CurrentUserPath!.child(FirebaseConstants.UserGames).child(game.gameID).removeValue()
            FirebaseConstants.GamesNode.child(game.gameID).removeValue()
        }
        
  
        
   //game.singlePlayerMode = true
        if game.singlePlayerMode {
            //timeLeft = 45
             timeLeft = game.timeSelection.rawValue*60
        }
    
        player1 = game.player1
        player2 = game.player2
        
    currentPlayer = player1.userID == game.currentPlayerID ? player1 : player2
    currentPlayerN = currentPlayer.player1 == true ? 1 : 2
        
     if !game.singlePlayerMode {
           tilesLeft = game.tilesLeft
            print("tiles Left = \(tilesLeft)")
        }
        else {
          tilesLeft = 1000
        }
        
        // setUpPlayerTiles()
       // currentUserTileRack = player1.userID == FirebaseConstants.CurrentUserID ? player1.tileRack : player2.tileRack
    
       // currentUserTileRack.setUpPlayerTileRack(player: currentPlayerN)
        
        
       // print("in initializeGame: setting player 1 score label for: \(player1.userName!) and player 2 to: \(player2.userName!)")
        player1ScoreLbl.text =  "\(player1.userName!): \(player1.score)"
        player2ScoreLbl.text = "\(player2.userName!): \(player2.score)"
        player1ScoreLbl.fontSize = 20
        player2ScoreLbl.fontSize = 20
        
        currentScoreLbl = currentPlayerN == 1 ? player1ScoreLbl : player2ScoreLbl
        otherScoreLbl = currentPlayerN == 1 ? player2ScoreLbl : player1ScoreLbl
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
    
    func setUpGame(){
        print("in set up Game")
        self.scene?.removeChildren(in: [currentPlayerTileRackDisplay, gameBoardDisplay])
        currentPlayerTileRackDisplay = SKSpriteNode()
        gameBoardDisplay = SKSpriteNode()
        
        gameBoard = game.board
        gameBoardDisplay = gameBoard.setUpBoard()
        gameBoardDisplay.name = GameConstants.GameBoardDisplayName
        
        if game.gameOver {
            presentGameOverPanel()
            
            FirebaseConstants.CurrentUserPath!.child(FirebaseConstants.UserGames).child(game.gameID).removeValue()
            FirebaseConstants.GamesNode.child(game.gameID).removeValue()
        }
        
        
        
        //game.singlePlayerMode = true
        if game.singlePlayerMode {
            //timeLeft = 45
            timeLeft = game.timeSelection.rawValue*60
        }
        if !game.singlePlayerMode {
            tilesLeft = game.tilesLeft
            print("tiles Left = \(tilesLeft)")
        }
        else {
            tilesLeft = 1000
        }
        
        player1 = game.player1
        player2 = game.player2
        
        currentPlayer = player1.userID == game.currentPlayerID ? player1 : player2
        currentPlayerN = currentPlayer.player1 == true ? 1 : 2
        
    
       
        
        // print("in initializeGame: setting player 1 score label for: \(player1.userName!) and player 2 to: \(player2.userName!)")
        player1ScoreLbl.text =  "\(player1.userName!): \(player1.score)"
        player2ScoreLbl.text = "\(player2.userName!): \(player2.score)"
  
        
        currentScoreLbl = currentPlayerN == 1 ? player1ScoreLbl : player2ScoreLbl
        otherScoreLbl = currentPlayerN == 1 ? player2ScoreLbl : player1ScoreLbl
        currentScoreLbl.fontColor = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
        otherScoreLbl.fontColor =  UIColor.white
        
        
        currentPlayerTileRack = currentPlayer.tileRack
        currentPlayerTileRack.setUpPlayerTileRack(player: currentPlayerN)
        currentPlayerTileRackDisplay = currentPlayerTileRack.tileRack
        currentPlayerTileRackDisplay.name = GameConstants.TileRackDisplayName
        
        
       
        
        gameBoardDisplay.position = GameConstants.BoardPosition
        addChild(gameBoardDisplay)
        
        currentPlayerTileRackDisplay.position.x = 0
        currentPlayerTileRackDisplay.position.y = -gameBoardDisplay.size.height/2 - currentPlayerTileRackDisplay.size.height/2 - 10
        addChild(currentPlayerTileRackDisplay)
        
        
    }
    
    func setUpGame1(){
        print("in set up Game: current User ID: \(FirebaseConstants.CurrentUserID)")
        self.scene?.removeChildren(in: [currentPlayerTileRackDisplay, gameBoardDisplay])
      
        print("In set up game....current turn passed  = \(game.currentTurnPassed). last turn passed: \(game.lastTurnPassed)")
        
        currentPlayerTileRackDisplay = SKSpriteNode()
   
        
        gameBoardDisplay = SKSpriteNode()
        
        gameBoard = game.board
        gameBoardDisplay = gameBoard.setUpBoard()
        gameBoardDisplay.name = GameConstants.GameBoardDisplayName
        
      
        if game.gameOver {
            print("in set up game...game over, presenting game over panel")
            presentGameOverPanel()
            
            FirebaseConstants.CurrentUserPath!.child(FirebaseConstants.UserGames).child(game.gameID).removeValue()
            FirebaseConstants.GamesNode.child(game.gameID).removeValue()
        }
        
       
        
        //game.singlePlayerMode = true
        if game.singlePlayerMode {
            //timeLeft = 45
            timeLeft = game.timeSelection.rawValue*60
        }
        if !game.singlePlayerMode {
            tilesLeft = game.tilesLeft
            print("tiles Left = \(tilesLeft)")
        }
        else {
            tilesLeft = 1000
        }
        
        player1 = game.player1
        player2 = game.player2
        
        
        
        currentPlayer = player1.userID == game.currentPlayerID ? player1 : player2
        currentPlayerN = currentPlayer.player1 == true ? 1 : 2
        
        let currentUserPlayer = game.player1.userID == FirebaseConstants.CurrentUserID ? player1 : player2
        guard currentUserPlayer != nil else {
            print("Current user player is nil. returning....")
            return
        }
        let currentUserPlayerN = currentUserPlayer!.player1 ? 1 : 2
        currentUserIsCurrentPlayer = currentUserPlayerN == currentPlayerN
        print("Current user is current player? --> \(currentUserIsCurrentPlayer)")
        if !currentUserIsCurrentPlayer {
            disableGame = true
            currentPlayerTileRack = currentUserPlayer!.tileRack
        }
        else {
            currentPlayerTileRack = currentPlayer.tileRack
        }
        
        
        // print("in initializeGame: setting player 1 score label for: \(player1.userName!) and player 2 to: \(player2.userName!)")
        player1ScoreLbl.text =  "\(player1.userName!): \(player1.score)"
        player2ScoreLbl.text = "\(player2.userName!): \(player2.score)"
        
        
        currentScoreLbl = currentPlayerN == 1 ? player1ScoreLbl : player2ScoreLbl
        otherScoreLbl = currentPlayerN == 1 ? player2ScoreLbl : player1ScoreLbl
        currentScoreLbl.fontColor = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
        otherScoreLbl.fontColor =  UIColor.white
     
        print("in set up game 1....player tile rack tile count: \(currentUserPlayer?.tileRack.playerTiles.count) and current turn passed: \(game.currentTurnPassed)")
   
      currentPlayerTileRack.setUpPlayerTileRack(player: currentUserPlayerN,
    createAllNewTiles: currentUserPlayer?.tileRack.playerTiles.count == 0 && game.currentTurnPassed == true)
      
        
        currentPlayerTileRackDisplay = currentPlayerTileRack.tileRack
        currentPlayerTileRackDisplay.name = GameConstants.TileRackDisplayName
  
        gameBoardDisplay.position = GameConstants.BoardPosition
        addChild(gameBoardDisplay)
        
        currentPlayerTileRackDisplay.position.x = 0
        currentPlayerTileRackDisplay.position.y = -gameBoardDisplay.size.height/2 - currentPlayerTileRackDisplay.size.height/2 - 10
        
        addChild(currentPlayerTileRackDisplay)
        
        if currentUserPlayer?.tileRack.playerTiles.count == 0 && game.currentTurnPassed == false {
            print("player used all tiles...ending turn. tiles left = \(tilesLeft)")
            turnIsOver = true
           
        }
      
        
        
    }
    
    func updateScoreLabel() {
        if game.singlePlayerMode {
            player1ScoreLbl.text = "Score: \(player1.score)"
        }
        else { currentScoreLbl.text = "\(currentPlayer.userName!): \(currentPlayer.score)"
            
        }
    }
    
    func showCurrentTileRack() {
        print("Showing currentUserTileRack...") 
        currentPlayerTileRack.showTileRack()
    }
    
    override func didMove(to view: SKView) {
        
        print("in didMove to view. Game ID: \(game.gameID)")
     
        self.setUpGame1()
      
         /*setUpNodeWithText(nodeLabel: "Node with Text!", lblFontColor: .red, lblFontSize: 40, nodeSize: CGSize(width:300,height:50), nodePos: CGPoint(x:0,y:0), nodeColor: .black)
       */
      
        playBtn_NEW = SKShapeNode(rect: CGRect(x: 0, y: 0, width: currentPlayerTileRackDisplay.size.width/3, height: 0.5*currentPlayerTileRackDisplay.size.height + 5), cornerRadius: 5)
        playBtn_NEW.fillColor =  UIColor(red: 85/255, green: 158/255, blue: 131/255, alpha: 1.0)
        let playBtnText = SKLabelNode(text: "Play+")
        playBtnText.fontColor = .white
        playBtnText.fontName = GameConstants.TileLabelFontName
        playBtnText.fontSize = 20

       playBtn_NEW.position = CGPoint(x: currentPlayerTileRackDisplay.frame.minX,
        y: currentPlayerTileRackDisplay.position.y - currentPlayerTileRackDisplay.size.height/2 - playBtn_NEW.frame.size.height/2 - 20)
        playBtnText.horizontalAlignmentMode = .center
        playBtnText.verticalAlignmentMode  = .center
        
        
        
       // playBtn_NEW.position = CGPoint(x: -350, y:  -self.size.height/2 + 150)
       playBtnText.position = CGPoint(x: playBtn_NEW.position.x + playBtn_NEW.frame.width/2, y: playBtn_NEW.position.y + playBtn_NEW.frame.height/2)
        
             playBtnText.position = CGPoint(x: playBtn_NEW.frame.midX, y: playBtn_NEW.frame.midY)
        
        addChild(playBtn_NEW)
        addChild(playBtnText)
        
        
        recallTilesBtn = SKShapeNode(rect: CGRect(x: 0, y:0, width: playBtn_NEW.frame.size.width, height: playBtn_NEW.frame.size.height - 3), cornerRadius: 5)
        recallTilesBtn.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        recallTilesBtn.position = CGPoint(x: currentPlayerTileRackDisplay.frame.maxX - recallTilesBtn.frame.size.width, y: playBtn_NEW.position.y)
        
        
        let recallTilesBtnText = SKLabelNode(text: "Recall")
        recallTilesBtnText.fontColor = UIColor(red: 67/255, green: 84/255, blue: 167/255, alpha: 1.0)
        recallTilesBtnText.fontName = GameConstants.TileLabelFontName
        recallTilesBtnText.fontSize = 20
        recallTilesBtnText.position = CGPoint(x: recallTilesBtn.position.x + recallTilesBtn.frame.width/2, y: recallTilesBtn.position.y + recallTilesBtn.frame.height/2)
        recallTilesBtnText.horizontalAlignmentMode = .center
        recallTilesBtnText.verticalAlignmentMode = .center
        recallTilesBtnText.zPosition = recallTilesBtn.zPosition + 1
        
        addChild(recallTilesBtn)
        addChild(recallTilesBtnText)
        
        
      //add score Labels
        
        player1ScoreLbl.position = CGPoint(x: game.singlePlayerMode ? 0 : gameBoardDisplay.frame.minX + player1ScoreLbl.frame.size.width/2 + 20, y: gameBoardDisplay.frame.maxY + player1ScoreLbl.frame.size.height/2 + 20)
        player1ScoreLbl.zPosition = 2
        player1ScoreLbl.fontSize = 25
        player1ScoreLbl.fontName = "Arial"
        
        addChild(player1ScoreLbl)
        
        
        player2ScoreLbl.position = CGPoint(x: gameBoardDisplay.frame.maxX - player1ScoreLbl.frame.size.width/2 - 20, y: player1ScoreLbl.position.y)
        player2ScoreLbl.zPosition = 2
        player2ScoreLbl.fontSize = 25
        player2ScoreLbl.fontName = "Arial"
        
        addChild(player2ScoreLbl)
        
    
     
            endTurnBtn = SKShapeNode(rect: CGRect(x: 0, y:0, width: playBtn_NEW.frame.size.width, height: playBtn_NEW.frame.size.height - 3), cornerRadius: 5)
            endTurnBtn.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
            endTurnBtn.position = CGPoint(x: playBtn_NEW.position.x , y: playBtn_NEW.position.y - playBtn_NEW.frame.height - 5)
            let endTurnText = SKLabelNode(text: "End Turn")
            endTurnText.fontColor = UIColor.red
            endTurnText.fontName = GameConstants.TileLabelFontName
            endTurnText.fontSize = 20
            endTurnText.position = CGPoint(x: endTurnBtn.position.x + endTurnBtn.frame.width/2, y: endTurnBtn.position.y + playBtn_NEW.frame.height/2)
            endTurnText.horizontalAlignmentMode = .center
            endTurnText.verticalAlignmentMode = .center
            endTurnText.zPosition = endTurnBtn.zPosition + 1
            // addChild(playBtn)
    
            addChild(endTurnBtn)
            addChild(endTurnText)
            
            exchangeBtn = SKShapeNode(rect:CGRect(x:0,y:0, width: playBtn_NEW.frame.size.width, height: playBtn_NEW.frame.size.height - 3), cornerRadius: 5)
            exchangeBtn.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
            exchangeBtn.position = CGPoint(x: recallTilesBtn.position.x, y: endTurnBtn.position.y)
            
            let exchangeBtnText = SKLabelNode(text: "Exchange")
            exchangeBtnText.fontColor = UIColor(red: 67/255, green: 84/255, blue: 167/255, alpha: 1.0)
            exchangeBtnText.fontName = GameConstants.TileLabelFontName
            exchangeBtnText.fontSize = 20
            exchangeBtnText.position = CGPoint(x: exchangeBtn.position.x + exchangeBtn.frame.width/2,y: exchangeBtn.position.y + exchangeBtn.frame.height/2)
            exchangeBtnText.horizontalAlignmentMode = .center
            exchangeBtnText.verticalAlignmentMode = .center
            exchangeBtnText.zPosition = exchangeBtn.zPosition + 1
            
            addChild(exchangeBtn)
            addChild(exchangeBtnText)
        
        
        
            
        
            //add separator bar between two score labels
            let labelSeparatorBar = SKSpriteNode(color: .black, size: CGSize(width: 5, height: 2*player1ScoreLbl.frame.size.height))
            labelSeparatorBar.position.y = player1ScoreLbl.position.y
            addChild(labelSeparatorBar)
            
            
            tilesLeftLbl.position.y = //tileBag.position.y - tileBag.size.height/2 - tilesLeftLbl.frame.size.height/2 - 5
                labelSeparatorBar.position.y + labelSeparatorBar.size.height/2 + 10
            tilesLeftLbl.fontSize = 16
            addChild(tilesLeftLbl)
            tilesLeftLbl.fontName = GameConstants.TileLabelFontName
        
        
        bingoLabel.fontName = "Arial-BoldMT"
        bingoLabel.fontSize = 50
        bingoLabel.fontColor = .yellow
        bingoLabel.zPosition = 2
        bingoLabel.isHidden = true
        addChild(bingoLabel)
     

     
        wildCardPicker.initializePicker(tileColor: .lightGray)
        
        addChild(wildCardPicker)
        
        wildCardPicker.zPosition = 50
        wildCardPicker.isHidden = true
        
        if game.singlePlayerMode {
            
            labelSeparatorBar.isHidden = true
            player2ScoreLbl.isHidden = true
            player1ScoreLbl.text = "Score: \(player1.score)"
           //exchangeBtnText.isHidden = true
            exchangeBtn.isHidden = true
            
            playBtn_NEW.position.y = currentPlayerTileRackDisplay.position.y - currentPlayerTileRackDisplay.size.height/2 - playBtn_NEW.frame.size.height/2 - 50
            playBtnText.position = CGPoint(x: playBtn_NEW.frame.midX, y: playBtn_NEW.frame.midY)
            
            
            
            singlePlayerRefreshtiles =  SKShapeNode(rect:CGRect(x:0,y:0, width: playBtn_NEW.frame.size.width, height: playBtn_NEW.frame.size.height - 3), cornerRadius: 5)
            singlePlayerRefreshtiles.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
            addChild(singlePlayerRefreshtiles)
            
            recallTilesBtn.position.x = playBtn_NEW.frame.maxX + 10
            
            recallTilesBtn.position.y = playBtn_NEW.position.y
            
           // singlePlayerRefreshtiles.setScale(0.7)
            singlePlayerRefreshtiles.position.x = recallTilesBtn.frame.maxX + 10
            singlePlayerRefreshtiles.position.y = playBtn_NEW.position.y
            exchangeBtnText.position.x = singlePlayerRefreshtiles.frame.midX
            exchangeBtnText.position.y = singlePlayerRefreshtiles.frame.midY
            
            
           // recallTilesBtn.setScale(0.7)
            recallTilesBtnText.position.x = recallTilesBtn.frame.midX
            recallTilesBtnText.position.y = recallTilesBtn.frame.midY
            
            
            //playBtn_NEW.setScale(1.5)
         //  playBtn_NEW.position.y = recallTilesBtn.position.y - playBtn_NEW.frame.size.height/2
           endTurnText.isHidden = true
            endTurnBtn.isHidden  = true

           // timeLabel.position = CGPoint(x: tilesLeftLbl.position.x, y: tilesLeftLbl.position.y - 10)
            timeLabel.position = CGPoint(x: 0, y: player1ScoreLbl.frame.maxY + timeLabel.frame.size.height/2 + 2)
            timeLabel.zPosition = 50
            timeLabel.fontName = "Arial-BoldMT"
            timeLabel.fontColor = .white
            timeLabel.fontSize = 20
            gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
           
            addChild(timeLabel)
            
            singlePlayerPauseButton.text = "PAUSE"
            singlePlayerPauseButton.fontName = "Arial-BoldMT"
            singlePlayerPauseButton.fontColor = .blue
            singlePlayerPauseButton.fontSize = 15
            singlePlayerPauseButton.position = CGPoint(x: view.frame.size.width/2 - singlePlayerPauseButton.frame.size.width, y:
                currentScoreLbl.position.y)
            addChild(singlePlayerPauseButton)
            
            resumeGameButton = SKLabelNode()
            resumeGameButton.text = "RESUME"
            resumeGameButton.fontColor = .white
            resumeGameButton.fontSize = 20
            resumeGameButton.fontName = "Arial-BoldMT"
      
            pauseView.isHidden = true
            pauseView.size = self.size
            pauseView.color = .black
            pauseView.zPosition = 100
            addChild(pauseView)
            pauseView.addChild(resumeGameButton)
            resumeGameButton.position = CGPoint(x: 0, y: 200)
            /*
            singlePlayerRefreshtiles.position.x = recallTilesBtnText.position.x
            singlePlayerRefreshtiles.position.y = recallTilesBtn.position.y - recallTilesBtn.frame.size.height/2 - singlePlayerRefreshtiles.frame.size.height - 30
            singlePlayerRefreshtiles.fontSize = 80
            addChild(singlePlayerRefreshtiles)
            */
            
            
         
        }
        
        }
    
       let newHighScoreLbl = SKLabelNode(text: "New High Score!!")

    func updateTimer(){
        guard disableGame == false else {return}
        timeLeft! -= 1
        
        if timeLeft == 0 {
            print("Time left 0")
            gameTimer?.invalidate()
           disableGame = true
            singlePlayerPauseButton.removeFromParent()
            presentGameOverPanel()
            if game.timeSelection != .untimed {
                Fire.dataService.updateHighScore(atPath: FirebaseConstants.CurrentUserPath!.child("Stats"), game: game){
                    (beatHighScore) in
                    
                    if beatHighScore != nil && beatHighScore! {
                     
                       self.newHighScoreLbl.fontSize = 70
                        self.newHighScoreLbl.fontColor = .red
                        self.newHighScoreLbl.fontName = "Avenir-Heavy"
                        self.newHighScoreLbl.zPosition = 100
                        self.addChild(self.newHighScoreLbl)
                        let fontColorTimer =  Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.updateFontColors), userInfo: nil, repeats: true)
                   
                      
                    }
                }
             
            }
        }
    }
  
    func updateFontColors() {
        newHighScoreLbl.fontColor = newHighScoreLbl.fontColor == .red ? .yellow : .red

    }
    
    override func willMove(from view: SKView) {
        print("in will move from view...about to saveGameData1.....")
        
        
        recall()
        if !game.gameOver && !game.singlePlayerMode {
            Fire.dataService.saveGameData1(game: game,completion: nil)
        
        }
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard disableGame == false else {return}
        
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
              /*  if (wildCardLoc.y - wildCardPicker.frame.height/2 > playBtn_NEW.frame.maxY) &&
                    (wildCardLoc.y + wildCardPicker.frame.height/2 < self.scene!.frame.maxY)
                    && (wildCardLoc.x  - wildCardPicker.frame.width/2 > self.scene!.frame.minX)
                    && (wildCardLoc.x + wildCardPicker.frame.width/2 < self.scene!.frame.maxX)
                    {
                    
                    wildCardPicker.position = wildCardLoc
                    
                } */
              
             
            
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
            
            tile.row = -1
            tile.col = -1
            
            
            if let holdVal = boardTile.holdingValue, let holdCol = boardTile.holdingColor , let holdPlayer = boardTile.holdingPlayer{
                boardTile.setTileValue(value: holdVal)
                print("holding player is: \(holdPlayer)")
                boardTile.color = holdPlayer == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                boardTile.player = holdPlayer
             /*   if boardTile.player == nil {
                    print("board tile player is nil....")
                    boardTile.player = holdCol == GameConstants.TilePlayer1TileColor ? 1 : 2
                } */
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     /*
        guard currentUserIsCurrentPlayer else {
            print("You are not the current player!!")
            return
        }
       */
      /*  guard disableGame == false else {
            
                print("Game disabled")
                return
            
        } */
        //MARK: PAUSE GAME
           for touch in touches {
                let location = touch.location(in: self)
                
              
                
                
                if nodes(at: location).contains(singlePlayerPauseButton) {
                    
                    
                    disableGame = true
                   
                    
                    if disableGame {
                        
                        pauseView.isHidden = false
                      
                    }
                
                
                   
                }
                if nodes(at: location).contains(resumeGameButton) {
                    print("hitting resume...")
                    pauseView.isHidden = true
                    disableGame = false
                }
       
                 guard disableGame == false else {return}
        
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
                    //MARK: double tile size
                    
                    if tile.size.width - GameConstants.TileSize.width < 1 {
                    tile.size.width = tile.size.width*2
                    tile.size.height = tile.size.height*2
                    tile.alpha = 0.8
                
                    }
                    else {
                        print("Tile size is NOT  \(GameConstants.TileSize), it's: \(tile.size)")
                    }
                    
                    }
                }
                else if nodes(at: location).contains(tile) && exchangeMode  {
                    
                    
                    if !(exchangeCandidates.contains(tile)) {
                        let tileY = convert(CGPoint(x:0, y: exchangeExitBtn.frame.minY - tile.size.height/2 - 1), to: tile).y
                        tile.position.y = tileY
                        tile.zPosition = exchangeBackground.zPosition + 1
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
                            
                            //MARK: double tile size
                        print("SECOND DOUBLING")
                            tile.size.height = tile.size.height*2
                            tile.size.width = tile.size.width*2
                            tile.alpha = 0.8
                        }
                    }
                    
                  
                    
                    if selectedPlayerTilesAtNode.count > 1 {
                        for tile in selectedPlayerTilesAtNode {
                            print("tile at node: \(tile.getTileTextRepresentation())")
                            if tile.tileType == TileType.eraser {
                                print("you have an eraser tile here of size: \(tile.size). normal size: \(GameConstants.TileSize)")
                                
                                tile.isHidden = false
                                tile.alpha = 1.0
                                tile.size.width = GameConstants.TileSize.width
                                tile.size.height = GameConstants.TileSize.height
                                print("after sale: you have an eraser tile here of size: \(tile.size). normal size: \(GameConstants.TileSize)")
                                
                                
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
                   // selectedPlayerTile?.alpha = 1.0
                    
                    
                    if let holdVal = touchedTile.holdingValue, let holdPlayer = touchedTile.holdingPlayer, let holdCol = touchedTile.holdingColor {
                        print("touched tile holding color: \(touchedTile.holdingColor)")
                        print("holding val is \(touchedTile.holdingValue)")
                        print("touched tile player: \(touchedTile.player)")
                        touchedTile.setTileValue(value: holdVal)
                        touchedTile.color = holdPlayer == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                        
                        touchedTile.player = holdPlayer
                        
                        touchedTile.holdingValue = nil
                        touchedTile.holdingColor = nil
                        touchedTile.holdingPlayer = nil  
                     
                    }
                    else {
                        
                       touchedTile.player = nil
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
        
            if wildCardPicker.isHidden && nodes(at: location).contains(playBtn_NEW)  && deactivateGameNodes == false {
                playBtnPushed = true
                //NOTE: FIX THIS CODE!!!! DON'T HAVE PLAY AND PLAY1
                if game.singlePlayerMode {
                    play()
                }
                else {
                 play1()
                }
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
           
                if game.singlePlayerMode && nodes(at: location).contains(singlePlayerRefreshtiles) {
                 recall()
                    wildCardPicker.isHidden = true
                    
                    for tile in currentPlayerTileRack.playerTiles.values {
                        currentPlayerTileRack.removeAndReplaceTileFromRack(tile: tile, player: 1)
                    }
                    func showPenalty() {
                     let penaltyLabel = SKLabelNode(text: "-4!")
                     penaltyLabel.position.y = player1ScoreLbl.position.y
                    penaltyLabel.position.x = player1ScoreLbl.position.x + player1ScoreLbl.frame.size.width + 1
                        penaltyLabel.fontColor = .red
                        penaltyLabel.fontSize = 80
                        penaltyLabel.fontName = "Arial-BoldMT"
                    addChild(penaltyLabel)
                    
                   let fadePenalty = SKAction.fadeAlpha(to: 0.0, duration: 1.2)
                    let sinkPenaltyLbl = SKAction.moveTo(y: penaltyLabel.position.y - 100, duration: 1.2)
                    penaltyLabel.run(sinkPenaltyLbl)
                        penaltyLabel.run(fadePenalty){
                            self.game.player1.score -= 4
                            self.updateScoreLabel()
                    }
                   
                 
                    }
                    
                    showPenalty()
                  
                }
                
                
        
                
            if nodes(at: location).contains(restartBtn) {
                if let view = self.view {
                    
                    if let scene = GameplayScene(fileNamed: "GameplayScene") {
                        scene.scaleMode = .aspectFill
                        view.presentScene(scene)
                    }
                    
                }
            }
             
            
                
                //MARK: EXCHANGE BUTTON PRESSED
                
                if wildCardPicker.isHidden && nodes(at: location).contains(exchangeBtn) && !exchangeMode {
                    var zPs = [CGFloat]()
                    for child in self.scene!.children {
                            zPs.append(child.zPosition)
                    }
                    
                     guard tilesLeft != 0 else {
                        let alert = UIAlertController(title:"No tiles left!", message: "Exchanges are not possible without any tiles left to exchange!", preferredStyle: UIAlertControllerStyle.alert)
                        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        alert.addAction(ok)
                        if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                            mainVC.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    guard game.currentTurnPassed else {
                        let alert = UIAlertController(title:"Sorry...", message: "You can't exchange tiles if you've already played this turn!", preferredStyle: UIAlertControllerStyle.alert)
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
                    
                    exchangeBackground = SKSpriteNode(color: .white, size: CGSize(width: currentPlayerTileRackDisplay.size.width, height: currentPlayerTileRackDisplay.size.height*3))
                   
                    exchangeBackground.zPosition = 51
                  
                   
                    
                    exchangeExitBtn.scale(to: CGSize(width: 30, height: 30))
                    exchangeExitBtn.position.x = exchangeBackground.frame.minX + exchangeExitBtn.size.width/2
                    
                    exchangeExitBtn.position.y = exchangeBackground.frame.maxY - exchangeExitBtn.size.height/2
                
                    exchangeExitBtn.zPosition = exchangeBackground.zPosition + 1
                    guard exchangeExitBtn.parent == nil else {
                        print("exchange button already has a parent: \(exchangeExitBtn.parent)")
                        return
                    }
                    addChild(exchangeExitBtn)
                    
                    exchangeLabel = SKLabelNode(text: "Select the tiles you'd like to exchange!")
                    exchangeLabel.fontColor = .black
                    exchangeLabel.fontName = GameConstants.TileLabelFontName
                    exchangeLabel.fontSize = 16
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
                    exchangeConfirmationLbl.fontSize = 16
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
                    
                    print("EXCHANGE CONFIRMATION LABEL HIT!")
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
                        
                        self.resetExchange()
                        
                        self.game.currentTurnPassed = false
                        self.turnDone()
                        
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
                else if nodes(at: location).contains(exchangeConfirmationLbl){
                    print("Something went wrong. Exchange candidates count: \(exchangeCandidates.count). < tilesLEft? \(tilesLeft) \(exchangeCandidates.count <= tilesLeft) and exchange mode? \(exchangeMode)")
                    
            }
            //RECALL TILES
                if wildCardPicker.isHidden && nodes(at: location).contains(recallTilesBtn), selectedPlayerTiles.count > 0 {
                  recall()
                    
                }
        
             
            
                //MARK: End Turn button hit
            if wildCardPicker.isHidden && nodes(at: location).contains(endTurnBtn) && deactivateGameNodes == false {
                
                if endGame {
                    displayEndOfGamePanel()
                    break
                }
               
                
                if  playBtnPushed || selectedPlayerTiles.count == 0 {
                    
                    let endTurnAlert = UIAlertController(title: nil, message: "End your turn?", preferredStyle: UIAlertControllerStyle.alert)
                    let endTurnConfirm = UIAlertAction(title: "End Turn", style: .default, handler: { (okAction) in
                        
                      
                       
                        
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
                
              
                if selectedTile.size != GameConstants.TileSize {
                    selectedTile.size = GameConstants.TileSize
                    selectedTile.alpha = 1.0
                }
                
                for node in nodes(at: location) {
                    if let targetTile = node as? Tile {
                
                        if targetTile.name == GameConstants.TileBoardTileName  && targetTile.tileIsEmpty && selectedTile.name != GameConstants.TileDeleteTileName {
                            print("selected tile is on board and about to set row/col as \(targetTile.row) and \(targetTile.col)")
                            /** play sound **/
                            
                            run(SKAction.playSoundFileNamed("clickSound.wav", waitForCompletion: false))
                           
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
                            disableGame = true
                            let fade = SKAction.fadeOut(withDuration: 0.5)
                            let playEraserSound1 = SKAction.playSoundFileNamed("EraserSound1.wav", waitForCompletion: false)
                            let fadeWithSound = SKAction.group([fade,playEraserSound1])
                            selectedTile.run(fadeWithSound){
                                self.disableGame = false
                            }
                            
                           //selectedTile.isHidden = true
                            if let tileValue = targetTile.getTileValue() {
                                targetTile.holdingValue = tileValue
                                targetTile.holdingColor = targetTile.color
                                targetTile.holdingPlayer = targetTile.player
                                print("set target tile holding val to: \(targetTile.holdingValue), holdin PLAYER to \(targetTile.holdingPlayer) ,and holding color to: \(targetTile.holdingColor)")
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
    func resetExchange() {
        print("removing a bunch of nodes from parents....")
        
        self.deactivateGameNodes = false
        self.exchangeMode  = false
        self.exchangeExitBtn.removeFromParent()
        self.exchangeBackground.removeFromParent()
        self.exchangeLabel.removeFromParent()
        self.exchangeBackground.removeFromParent()
        self.exchangeConfirmation.removeFromParent()
        self.exchangeConfirmationLbl.removeFromParent()
        self.exchangeCandidates.removeAll()
        
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
    
            print("BINGO!!")
        
          self.currentPlayer.score += GameConstants.BingoPoints
        
            bingoLabel.isHidden = false
            bingoLabel.zPosition = gameBoardDisplay.zPosition + 1000
            let moveBingoLabel: SKAction = SKAction.moveBy(x: 0, y: self.frame.height/2 - bingoLabel.frame.size.height, duration: 2.0)
            let fade = SKAction.fadeOut(withDuration: 2.0)
            let moveAndFadeBingo = SKAction.group([moveBingoLabel, fade])
        bingoLabel.run(moveAndFadeBingo){
            self.bingoLabel.position = CGPoint(x: 0, y: 0)
            self.bingoLabel.alpha = 1.0
            self.bingoLabel.isHidden = true
          
            self.updateScoreLabel()
        }
        /*
            bingoLabel.run(moveBingoLabel){
                self.updateScoreLabel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                {
                    self.switchPlayers()
                }
            }
 */
    
        
    }
    func turnDone() {
       
        print("In turnDone")
        if tilesUsedThisTurn.count == 7 && !game.singlePlayerMode {
            
         //   showBingo()
            print("BINGO BINGO BINGO BINGO")
            
        }
      
            switchPlayers()
        
        
    }
    
    func refreshTiles(completion: (() -> ())?) {
        print("Refresh tiles hit...")
        print("Selected player tiles: \(selectedPlayerTiles)")
        for tile in currentPlayerTileRack.playerTiles.values {
            if tileCount > 0 {
           currentPlayerTileRack.removeAndReplaceTileFromRack(tile: tile, player: currentPlayerN)
            tileCount -= 1
            }
            
            else {
                break
            }
        }
 
       completion?()
    }
    
    
    func switchPlayers() {
        print("in switch players")
     refillTileRack()
        //showCurrentTileRack()
 
    //bold other player's name and unbold current player
        
  
    
     
      print("after refill tile rack...")
        selectedPlayerTiles.removeAll()
        selectedPlayerTile = nil
        tilesUsedThisTurn.removeAll()
        playBtnPushed = false
        game.currentPlayerID = player1.userID == currentPlayer.userID ? player2.userID : player1.userID
        
        if (game.lastTurnPassed && game.currentTurnPassed) || (currentPlayerTileRack.playerTiles.count == 0 && tilesLeft == 0) {
            game.gameOver = true
            print("GAME OVER")
           // presentGameOverPanel()
            
            Fire.dataService.saveGameData1(game: game){
                (game)
                in
                print("in switch players, game over. presenting game over panel")
                self.presentGameOverPanel()
            }
            
            Fire.dataService.updateStatsAndRemoveGame(game: game)
            
            
        }
        else {
         
            game.gameOver = false
            game.tilesLeft = tilesLeft
            game.lastTurnPassed = game.currentTurnPassed
            game.currentTurnPassed = true
            game.lastUpdated =  Int(NSDate().timeIntervalSince1970)
            print("about to disable game")
          
            self.disableGame = true

        }
 
    Fire.dataService.saveGameData1(game: self.game, completion: nil)
       /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            print("about to save...current player (player \(self.currentPlayerN)) score: \(self.currentPlayer.score) player 1 score: \(self.player1.score) player2 score = \(self.player2.score)")
            Fire.dataService.saveGameData(game: self.game, completion: nil)
        }
        */
      
       

    }
    
    struct TileData {
        var row: Int
        var col: Int
        
        init(row: Int, col: Int) {
            self.row = row
            self.col = col
        }
    }
    
    func convertTileToTileData(tile: Tile) -> TileData {
            return TileData(row: tile.row, col: tile.col)
    }
    
    func convertTileDatatoTile(tileData: TileData) -> Tile {
        return gameBoard.getTile(atRow: tileData.row, andCol: tileData.col)
    }
    
    
    func play1() {
  
        print("IN PLAY 1")
        let copySelectedPlayerTiles  = selectedPlayerTiles
        
        
        for tile in selectedPlayerTiles where tile.tileType != TileType.eraser {
            nonDeleteSelectedPlayerTiles.append(tile)
        }
        
        let legalMove =  checkIfLegalMove()
        
        
        // if so, set values on board and remove tiles, if not alert user and return tiles
        // replace player tiles that were played
        
        for tile in selectedPlayerTiles {
            print("showing selected tiles before saving..tile value: \(tile.getTileTextRepresentation()) tile type: \(tile.tileType) tile row/col : \(tile.row),\(tile.col) starting pos: \(tile.startingPosition)")
        }
        
        if legalMove {
          
           game.currentTurnPassed = false 
            
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
            
            currentPlayerTileRack.removeTilesFromRack(tiles: selectedPlayerTiles)
        
            if !game.singlePlayerMode {
                /*** TRY: save game data and update automatically ****/
                
                for tile in nonDeleteSelectedPlayerTiles {
                    tile.showTileValues()
                    selectedPlayerTilesTileData.append(convertTileToTileData(tile: tile))
                }
                
                for tile in currentPlayerTileRack.playerTiles.values {
                    print("tile in player tile rack...rack pos: \(tile.rackPosition) value: \(tile.getTileTextRepresentation()) row/col: \(tile.row), \(tile.col)")
            
                }
                if currentPlayerN == 1 {
                    print("game.player1.tileRack == currentplayerTilerack? --> \(currentPlayerTileRack.playerTiles == game.player1.tileRack.playerTiles)")
                }
                else {
                    print("game.player2.tileRack == currentplayerTilerack? --> \(game.player2.tileRack.playerTiles == currentPlayerTileRack.playerTiles)")
                }
                var nTimesSaved = 0
                Fire.dataService.saveGameData1(game: game){
                    
                   (game)
                    
                    in
                    
                    print("in save game data1 closure in gameplayscene!!!!!!!!!!!!!!!!!")
                    
                    nTimesSaved += 1
                    print("GAME UPDATED. N: \(nTimesSaved)")
                   guard nTimesSaved == 1 else { return }
                    
                    self.game = game
                    self.setUpGame1()
                    
                    /*
                    self.gameBoard = game.board
                    self.gameBoardDisplay.removeFromParent()
                    self.gameBoardDisplay = SKSpriteNode()
                    self.gameBoardDisplay = self.gameBoard.setUpBoard()
                    self.addChild(self.gameBoardDisplay)
                    */
                    
                    for td in self.selectedPlayerTilesTileData {
                        let t = self.convertTileDatatoTile(tileData: td)
                    
                        self.selectedPlayerTiles.append(t)
                        t.showTileValues()
                
                    }
                    
                    for tile in self.currentPlayerTileRack.playerTiles.values {
                        print("showing tiles in currentPlayerTileRack after save Game data. tile val: \(tile.getTileTextRepresentation()) rack pos: \(tile.rackPosition)")
                    }
 

                    self.selectedPlayerTilesTileData.removeAll()
                    
                    
                    self.lightUpPlayedTiles {
                        
                        (tiles) in
                        for tile in tiles {
                            tile.color = self.currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                            print("in light up played tiles closure, self.currentPlayerN: \(self.currentPlayerN)")
                        }
                        print("tiles used this turn: \(self.tilesUsedThisTurn.count)")
                        if self.tilesUsedThisTurn.count == 7 && !self.game.singlePlayerMode {
                            self.showBingo()
                        }
                        
                        if self.turnIsOver {
                            print("turn is over, used all tiles....switching players")
                            self.switchPlayers()
                        }
                        
                    }
                }
            }
            

            
       
            
            
            
            // showCurrentTileRack()
            if game.singlePlayerMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.replaceTiles(tilesToReplace: copySelectedPlayerTiles)
                }
            }
            print("About to remove selected player tiles....")
            self.selectedPlayerTiles.removeAll()
            print("should be no selected tiles: \(self.selectedPlayerTiles)")
        }
            
        else {
            
            run(SKAction.playSoundFileNamed("IllegalPlay.wav", waitForCompletion: false))
            
            for tile in selectedPlayerTiles {
                
                //var deleteTileHere = false
                tile.isHidden = false
                tile.alpha = 1.0
                let row = tile.row
                let col = tile.col
                
                
                if tile.isTileOnBoard() {
                    
                    print("tile on board after illegal move: \(tile.getTileTextRepresentation()) row: \(tile.row) col:\(tile.col) starting position: \(tile.startingPosition)")
                    
                    let gameBoardTile = gameBoard?.getTile(atRow: row, andCol: col)
                    
    
                    if let holdVal = gameBoardTile!.holdingValue, let holdPlayer = gameBoardTile!.holdingPlayer /*,let holdCol = gameBoardTile!.holdingColor */{
                        
                        gameBoardTile!.setTileValue(value: holdVal)
                        gameBoardTile!.player = holdPlayer
                        if  gameBoardTile!.player == 1 {
                            print("tile is back to player 1 so setting player 1 color")
                            gameBoardTile!.color = GameConstants.TilePlayer1TileColor
                            
                        }
                        else if gameBoardTile!.player == 2 {
                            print("tile is back to player 2 so setting player 2 color")
                            gameBoardTile!.color = GameConstants.TilePlayer2TileColor
                            
                        }
                        else {
                            print("tile is neithe 1 nor 2 so setting it to green")
                            gameBoardTile!.color = .green
                        }
        
                     /*
                        gameBoardTile!.color = gameBoardTile!.player == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                        */
                        print("after illegal move set value back to: \(gameBoardTile!.getTileTextRepresentation()), set tile color back to \(gameBoardTile!.color) and player back to playerN: \(gameBoardTile!.player)")
                      /*  gameBoardTile!.holdingValue = nil
                        gameBoardTile!.holdingColor = nil
                        gameBoardTile!.holdingPlayer = nil
                      */
                        
                    }
                        
                    else {
                        print("after illegal move, game board tile has no holding value, player, or color...setting to nil")
                        gameBoardTile!.setTileValue(value: nil)
                        if bonusTilesUsed.contains(gameBoardTile!) {
                            gameBoardTile!.tileLabel.text = "+2"
                            gameBoardTile!.tileLabel.fontColor = .gray
                
                        }
                        gameBoardTile!.player = 0
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
    func play() {
        print("tiles Left: \(tilesLeft)")
        let copySelectedPlayerTiles  = selectedPlayerTiles
        for tile in selectedPlayerTiles where tile.tileType != TileType.eraser {
            nonDeleteSelectedPlayerTiles.append(tile)
        }
        
      let legalMove =  checkIfLegalMove()
        
      
        // if so, set values on board and remove tiles, if not alert user and return tiles
        // replace player tiles that were played
        
        if legalMove {
           
            
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
              
                if self.tilesUsedThisTurn.count == 7 && !self.game.singlePlayerMode {
                  // self.showBingo()
                }
                
   
            }
            
         
            
           // showCurrentTileRack()
            if game.singlePlayerMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.replaceTiles(tilesToReplace: copySelectedPlayerTiles)
                }
            }
            
            self.selectedPlayerTiles.removeAll()
        }
        
        else {
            
           for tile in selectedPlayerTiles {
                
                //var deleteTileHere = false
                tile.isHidden = false
                tile.alpha = 1.0
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

    func replaceTiles(tilesToReplace: [Tile]) {
        print("in replace tiles. selected tiles to replace: \(tilesToReplace)")
        for tile in tilesToReplace {
            currentPlayerTileRack.removeAndReplaceTileFromRack(tile: tile, player: currentPlayerN)
        }
    }
    
    func lightUpPlayedTiles(completion: ([Tile]) -> ()) {
    
        var color: SKColor = SKColor()
        
        color = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
        
        print("current player N: \(currentPlayerN)")
        
        let gameBoardTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
        
        let expandTile = SKAction.scale(by: 1.2, duration: 0.1)
        let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 0.0 , duration: 0.1)
        let changeBack = SKAction.colorize(with: color, colorBlendFactor: 0.0, duration: 0.1)
        let playValidMove =  SKAction.playSoundFileNamed("ValidMoveSound.wav", waitForCompletion: false)
        
        let shrinkTile = SKAction.scale(by: 1/1.2, duration: 0.6)
        let wait = SKAction.wait(forDuration: 0.1)
        let seq = SKAction.sequence([ wait, shrinkTile, changeBack])
       let changeToYellowAndPlaySound = SKAction.group([changeToYellow,playValidMove])
        calculateScore()
        //let points = scoreIncrement
        print("in light up tiles, after calculateScore(). points = \(scoreIncrement)")
       
        
        for  (i,tile) in gameBoardTiles.enumerated() {
           tile.run(expandTile)
            tile.zPosition = 4
           
            
            tile.run(changeToYellowAndPlaySound){
                tile.run(seq){
                    tile.zPosition = 2
                    if i == gameBoardTiles.count - 1 {
                        var loc = gameBoardTiles[i].position
                        loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                       // self.showPoints(atLocation: loc, points: points)
                       self.showPoints(atLocation: loc, points: self.scoreIncrement)
                       
                        self.selectedPlayerTiles.removeAll()
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
                    print("Tile val: \(tile.getTileValue()) row: \(tile.row) col: \(tile.col)")
                        
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
       
    
        pointDisplay.zPosition = 5
        let movePointDisplay = SKAction.moveTo(y: location.y + 300, duration: 2)
        let fadePointDisplay = SKAction.fadeOut(withDuration: 2)
        
        addChild(pointDisplay)
        
        pointDisplay.run(movePointDisplay)
        pointDisplay.run(fadePointDisplay){
        pointDisplay.removeFromParent()
            print("in showPoints(): current player score is: \(self.currentPlayer.score)")
            //self.currentPlayerScore += points
            self.updateScoreLabel()
            
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

        print("in refill tile rack. tiles left: \(tilesLeft)")
       /*
        for tile in tilesUsedThisTurn {
              currentPlayerTileRack.removeTileFromRack(tile: tile, player: currentPlayerN, replace: tilesLeft > 0)
            if !game.singlePlayerMode { tilesLeft -= 1 }

        }
 */
        currentPlayerTileRack.removeAndReplaceTileFromRack1(player: currentPlayerN, tilesLeft: tilesLeft){
            (nTilesUsed)
            in
            print("in closure for remove/replace. nTilesUsed: \(nTilesUsed)")
            if !self.game.singlePlayerMode {
            self.tilesLeft -= nTilesUsed
            }
        }
        
    selectedPlayerTiles.removeAll()
    tilesUsedThisTurn.removeAll()
    
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
        for tile in selectedPlayerTiles where /*tile.name != "DELETE"*/ tile.tileType != TileType.eraser {
            
            
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
        print("before adding points...current player score is: \(currentPlayer.score)")
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































