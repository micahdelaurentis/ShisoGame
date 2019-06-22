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
            print("game set in GameplayScene! current player ID: \(game.currentPlayerID)")
        }
    }
    var lastTurnPassed = false //just flags once whether the last turn passed based on game.lastTurnPassed to not run animation on first loop
    var wildCardValueSet = false
    var bonusTilesUsed = [Tile]()
    var doNotRunLoadGameClosure = false
    var timeLabel = SKLabelNode()
    var nTimesSaved: Int = 0
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

    var lastSelectedTilesInLightUpTiles = [Tile]()
    var bingo = 0
    var gameTimer: Timer?
    var selectedPlayerTilesTileData = [TileData]()
    var singlePlayerPauseButton = SKLabelNode()
    var resumeGameButton = SKLabelNode()
    
    var mainVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    
    var currentUserPlayer: Player!
    var currentUserPlayerTileRackIsEmpty = false
    var currentUserIsCurrentPlayer: Bool = false
    var player1: Player!
    var player2: Player!
    var player1Name = ""
    var player2Name = ""
    let playValidMoveAudioNode = SKAudioNode(fileNamed: "PlayValidMove.wav")
    var nonDeleteSelectedPlayerTiles = [Tile]()
    var restartBtn = SKLabelNode(text: "restart")
    var saveBtn = SKSpriteNode(color: UIColor.black, size: CGSize(width: 50, height: 50))
    

    var playerPassedTurn: Bool = true
    
    let wildCardPickOptions = ["", "0", "1", "2", "3" ,"4" ,"5", "6","7","8","9", "10", "11","12","13","14","15","16",
                               "17","18","19","20","21","22","23","24"]
    
    var presentGameOverPanelComplete = false
    var wildCardPicker = WildCardPickerView()
    
    var tileCount = 20
    
    let tileRefreshBtn = SKLabelNode()
    
   let tileBag = SKSpriteNode(imageNamed: "tileSack")
    var tilesLeft: Int = 0  {
        didSet {
           
           tilesLeft = max(0, tilesLeft) // won't create infinite loop
            if !game.singlePlayerMode { tilesLeftLbl.text = "\(tilesLeft) tiles remaining (v.4)" }
        }
    }
    var tilesLeftLbl = SKLabelNode()
    
    var player1Score = 0
    var player2Score = 0
    var ignoreGameOver = false
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
    var playsThisTurn = [[Tile]]()
    
    
    var playBtnPushed = false
    var endGame = false
    
    var switchedPlayers = false
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
    
    var bingoLabel = SKLabelNode(text: "+\(GameConstants.BingoPoints)!!!")
    
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
        presentGameOverPanelComplete = true
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
        currentPlayerTileRack.setUpPlayerTileRack(player: 1,createAllNewTiles: true)
        currentPlayerTileRackDisplay = currentPlayerTileRack.tileRack
        currentPlayerTileRackDisplay.name = GameConstants.TileRackDisplayName
        
        
       
        
        gameBoardDisplay.position = GameConstants.BoardPosition
        addChild(gameBoardDisplay)
        
        currentPlayerTileRackDisplay.position.x = 0
        currentPlayerTileRackDisplay.position.y = -gameBoardDisplay.size.height/2 - currentPlayerTileRackDisplay.size.height/2 - 10
        addChild(currentPlayerTileRackDisplay)
        guard view != nil else {
            print("No view, returning!")
            return
        }
        setUpInitialView(view: view!)
        
        
    }
    
    var setUpGame2CompletionShouldRun = true
    var endOfTurn = false {
        didSet{
            print("END OF TURN SET!!!!!!!!!!!!!")
        }
    }
    
    
  
    func alreadySeenAnimationForTiles(tile: [Tile]) -> Bool {
        
        
        
        return false
    }
    
    
    
    func setUpGame3(){
        
        
        print("in set up Game 3: current User ID: \(FirebaseConstants.CurrentUserID)")
        
        
        self.scene?.removeChildren(in: [currentPlayerTileRackDisplay, gameBoardDisplay])
        
        
        currentPlayerTileRackDisplay = SKSpriteNode()
        gameBoardDisplay = SKSpriteNode()
        
        Fire.dataService.loadGameWithObserver(gameID: game.gameID){
            (game)
            
            in
            
         
           
    
            print("In load game closure. last Turn passed: \(game.lastTurnPassed) game over: \(game.gameOver) current turn passed: \(game.currentTurnPassed)  end of turn:\(self.endOfTurn) switched Players: \(self.switchedPlayers) turnIsOver = \(self.turnIsOver) ignore game over:\(self.ignoreGameOver)")
            print("showing game data in loadgame closure. game id:\(game.gameID) player1: \(game.player1.userName) player2: \(game.player2.userName) current player ID: \(game.currentPlayerID) current User: \(FirebaseConstants.CurrentUserID)")
            
        
            guard !self.endOfTurn else {
                self.endOfTurn = false
                self.switchedPlayers = false
                if self.game.gameOver {
                    self.presentGameOverPanel()
                    print("presenting game over panel from load game in self end of turn statement at top")
                }
                
                self.currentScoreLbl.fontColor = .white
                self.otherScoreLbl.fontColor = self.currentPlayerN == 1 ? GameConstants.TilePlayer2TileColor : GameConstants.TilePlayer1TileColor
         
                
                return
            }
       
            guard !(game.gameOver && game.lastTurnPassed && !self.setUpGame2CompletionShouldRun) else {
                if !self.presentGameOverPanelComplete {
                    self.presentGameOverPanel()
                }
                print("presenting game over panel because game is over from two passed turns in a row")
                return
                
            
            }
          
         
            print("removing current player tile rack display and gameboard...")
          
            self.scene?.removeChildren(in: [self.currentPlayerTileRackDisplay, self.gameBoardDisplay])
            self.currentPlayerTileRackDisplay = SKSpriteNode()
            self.gameBoardDisplay = SKSpriteNode()
            
            
            
            self.selectedPlayerTiles = game.selectedPlayerTiles
            
            
            for tile in self.selectedPlayerTiles {
                print("showing selected player tiles in load game with obs.")
                print("tile val: \(tile.getTileTextRepresentation())")
            }
            
            self.nonDeleteSelectedPlayerTiles = game.selectedPlayerTiles.filter{$0.tileType != TileType.eraser}
            
            
            
           
            
            self.game = game
            
            self.gameBoard = game.board
            self.gameBoardDisplay = self.gameBoard.setUpBoard()
            self.gameBoardDisplay.name = GameConstants.GameBoardDisplayName
            
            self.tilesLeft = game.tilesLeft
            self.lastTurnPassed = game.lastTurnPassed
                
            self.player1 = game.player1
            self.player2 = game.player2
            
            if self.player1.userName != "" {
                self.player1Name = self.player1.userName
            }
            if self.player2.userName != "" {
                self.player2Name = self.player1.userName
            }
         //Determine who the current player is
            self.currentPlayer = self.player1.userID == game.currentPlayerID ? self.player1 : self.player2
            self.currentPlayerN = self.currentPlayer.player1 == true ? 1 : 2
            
            print("the current player is \(self.currentPlayer.userName)")
            
            self.currentUserPlayer = self.player1.userID == FirebaseConstants.CurrentUserID ? self.player1 : self.player2
            
            let currentUserPlayerN = self.currentUserPlayer!.player1 ? 1 : 2
            
            print("the current user is \(self.currentUserPlayer!.userName)")
            
            self.currentUserIsCurrentPlayer = currentUserPlayerN == self.currentPlayerN
            print("Current user is current player? --> \(self.currentUserIsCurrentPlayer)")
            print("the last player to move was Player \(self.game.lastPlayerToMove)")
            //if the current user is not the current player, i.e. it's not their turn
            if !self.currentUserIsCurrentPlayer {
                self.disableGame = true
                self.currentPlayerTileRack = self.currentUserPlayer!.tileRack
            }
            else {
                self.currentPlayerTileRack = self.currentPlayer.tileRack
                self.disableGame = false
              }
            

            self.currentUserPlayerTileRackIsEmpty = self.currentUserPlayer!.tileRack.playerTiles.count == 0
            print("Current user player tile rack empty? --> \(self.currentUserPlayerTileRackIsEmpty)")
           
            if !self.game.gameOver {
            self.currentPlayerTileRack.setUpPlayerTileRack(player: currentUserPlayerN,
                                                           createAllNewTiles: self.currentUserPlayerTileRackIsEmpty
                                                            && game.currentTurnPassed == true)
            }
            else {
            self.currentPlayerTileRack.setUpPlayerTileRack(player: currentUserPlayerN,
                                                           createAllNewTiles: false)
                
            }
        
           
            if self.game.lastPlayerToMove == 0 {
                self.game.lastPlayerToMove = self.currentPlayerN
            }
            
            
            // SET UP SCORE LABELS
       
            
        
            if !self.shouldNotRunAnimation() && !self.presentGameOverPanelComplete && self.game.lastPlayerToMove == 1 && self.player1.score != 0 {
                
                
                self.player1ScoreLbl.text =  "\(self.player1.userName!): \(self.player1.score - self.game.lastScoreIncrement)"
                self.player2ScoreLbl.text = "\(self.player2.userName!): \(self.player2.score)"
            }
        
            else if !self.shouldNotRunAnimation()  &&  !self.presentGameOverPanelComplete && self.game.lastPlayerToMove == 2 && self.player2.score != 0  {
                 self.player2ScoreLbl.text =  "\(self.player2.userName!): \(self.player2.score - self.game.lastScoreIncrement)"
                 self.player1ScoreLbl.text = "\(self.player1.userName!): \(self.player1.score)"
            }
            
          
            else {
                //print("GAME OVER PANEL COMPLETE")
                
                self.player1ScoreLbl.text =  "\(self.player1.userName!): \(self.player1.score )"
                self.player2ScoreLbl.text = "\(self.player2.userName!): \(self.player2.score)"
                
            }
            
           /*
            else {
                print("not game over panel complete and last player to move 1,2")
                self.player1ScoreLbl.text =  "\(self.player1Name): \(self.player1.score )"
                self.player2ScoreLbl.text = "\(self.player2Name): \(self.player2.score)"
                
            } */
            
          
            
            
            /*
            self.player1ScoreLbl.text =  "\(self.player1.userName!): \(self.player1.score)"
            self.player2ScoreLbl.text = "\(self.player2.userName!): \(self.player2.score)"
            */
            
            
            //Set text and font colors of score labels based on whose turn it is
            self.currentScoreLbl = self.currentPlayerN == 1 ? self.player1ScoreLbl : self.player2ScoreLbl
            self.otherScoreLbl = self.currentPlayerN == 1 ? self.player2ScoreLbl : self.player1ScoreLbl
            
            self.currentScoreLbl.fontColor = self.currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
            self.otherScoreLbl.fontColor =  UIColor.white
            
            
            self.currentPlayerTileRackDisplay = self.currentPlayerTileRack.tileRack
            self.currentPlayerTileRackDisplay.name = GameConstants.TileRackDisplayName
            
            self.gameBoardDisplay.position = GameConstants.BoardPosition
            
            self.addChild(self.gameBoardDisplay)
            
            
            self.currentPlayerTileRackDisplay.position.y = -self.gameBoardDisplay.size.height/2 - self.currentPlayerTileRackDisplay.size.height/2 - 10
            
            
            
            
            self.addChild(self.currentPlayerTileRackDisplay)
            
            self.bingo = self.game.lastPlayerUsedAllTiles == true ? 1 : 0
            
            
            print("should not run light up played tiles: \(self.shouldNotRunAnimation())")
            
           
       
         
                self.lightUpPlayedTiles1{
/*
            for tile in self.selectedPlayerTiles where tile.tileType == TileType.eraser {
                self.gameBoard.getTile(atRow: tile.row, andCol: tile.col).color = GameConstants.TileBoardTileColor
            }
 */
            
            
                    
            print("in light up layed tiles CLOSURE")
                self.lastSelectedTilesInLightUpTiles = self.game.selectedPlayerTiles
            
                   // var color: UIColor
                    //let playerToUse = self.getPlayerToUseInLoadGameClosure()
                    //color = playerToUse.player1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                    
                    //print("in light up played tiles closure. non delete selected tiles count: \(self.nonDeleteSelectedPlayerTiles.count)")
                  /*  for tile in tiles {
                        if tile.tileValue != nil {
                            tile.color = color
                        }
                    }*/
                    if self.bingo == 1 && !self.game.singlePlayerMode {
                        self.showBingo()
                       //self.bingo = 0
                        
                }
                    
                   
                    
                    if self.game.gameOver {
                        print("Showing game over panel in light up played tiles closure")
                        self.presentGameOverPanel()
                        self.ignoreGameOver = true
                    }
                    
                  /*  if self.switchedPlayers {
                        print("in light up tiles closure. switched players true...if not game over, switching to false")
                        if !self.game.gameOver {
                           self.switchedPlayers = false
                            print("game not over, so switched player set back to false")
                            
                        }
                        else {
                            self.presentGameOverPanel()
                        }
                    } */
            
            self.removeSelectedPlayerTiles()
            self.removeNonDeleteSelectedPlayerTiles()
            
            print("after light up tiles 1 closure, should be no selected tiles: count = \(self.selectedPlayerTiles.count)")
                }
            
            
          
            
            
            self.removeSelectedPlayerTiles()
            self.removeNonDeleteSelectedPlayerTiles()
            
            
        
            //if it's the first time after didMoveToView, need to set up all the player's other view
            if self.setUpGame2CompletionShouldRun {
                print("About to run setUpInitialView...")
                self.setUpInitialView(view: self.view!)
            }
            else {
                print("NOT supposed to run set up initial view")
            }
            
            
 
        }
        
    }
    
    
    func shouldNotRunAnimation() -> Bool {
        
        if game.lastTurnPassed && game.currentTurnPassed {
            print("will not run animation. last turn passed and current turn passed")
            return true
        }
        guard game.selectedPlayerTiles.count > 0 && lastSelectedTilesInLightUpTiles.count > 0 else {
            print("game selected player tiles count is 0 or last selected tiles in light up is 0, returning")
            return false
        }
   
       var nMatchedTiles = 0
        for tileS in game.selectedPlayerTiles {
            for tileL in lastSelectedTilesInLightUpTiles {
                if tileS.row == tileL.row && tileS.col == tileL.col && tileS.getTileTextRepresentation() == tileL.getTileTextRepresentation() {
                    nMatchedTiles += 1
                }
            }
        }
       print("matched \(nMatchedTiles). total count is \(game.selectedPlayerTiles.count).")
        return nMatchedTiles == game.selectedPlayerTiles.count
    }
    
    func updateScoreLabel() {
        if game.singlePlayerMode {
            player1ScoreLbl.text = "Score: \(player1.score)"
        }
        else { currentScoreLbl.text = "\(currentPlayer.userName!): \(currentPlayer.score)"
            
        }
    }
    
    func updateScoreLabel(player: Player) {
        var scoreLabel = SKLabelNode()
        
        
        if game.singlePlayerMode {
            player1ScoreLbl.text = "Score: \(player1.score)"
        }
        else {
            scoreLabel = player.player1 ? player1ScoreLbl : player2ScoreLbl
            
            scoreLabel.text = "\(player.userName!): \(player.score)"
            
        }
    }
    
    func showCurrentTileRack() {
        print("Showing currentUserTileRack...") 
        currentPlayerTileRack.showTileRack()
    }
   func setUpInitialView(view: SKView){
    /*setUpNodeWithText(nodeLabel: "Node with Text!", lblFontColor: .red, lblFontSize: 40, nodeSize: CGSize(width:300,height:50), nodePos: CGPoint(x:0,y:0), nodeColor: .black)
     */
    
    self.playBtn_NEW = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.currentPlayerTileRackDisplay.size.width/3, height: 0.5*self.currentPlayerTileRackDisplay.size.height + 5), cornerRadius: 5)
    self.playBtn_NEW.fillColor =  UIColor(red: 85/255, green: 158/255, blue: 131/255, alpha: 1.0)
    let playBtnText = SKLabelNode(text: "Play+")
    playBtnText.fontColor = .white
    playBtnText.fontName = GameConstants.TileLabelFontName
    playBtnText.fontSize = 20
    
    self.playBtn_NEW.position = CGPoint(x: self.currentPlayerTileRackDisplay.frame.minX,
    y: self.currentPlayerTileRackDisplay.position.y - self.currentPlayerTileRackDisplay.size.height/2 - self.playBtn_NEW.frame.size.height/2 - 20)
    playBtnText.horizontalAlignmentMode = .center
    playBtnText.verticalAlignmentMode  = .center
    
    
    
    // playBtn_NEW.position = CGPoint(x: -350, y:  -self.size.height/2 + 150)
    playBtnText.position = CGPoint(x: self.playBtn_NEW.position.x + self.playBtn_NEW.frame.width/2, y: self.playBtn_NEW.position.y + self.playBtn_NEW.frame.height/2)
    
    playBtnText.position = CGPoint(x: self.playBtn_NEW.frame.midX, y: self.playBtn_NEW.frame.midY)
    
    
    
    print("about to add play btn new")
    
    self.addChild(self.playBtn_NEW)
    self.addChild(playBtnText)
    
    
    self.recallTilesBtn = SKShapeNode(rect: CGRect(x: 0, y:0, width: self.playBtn_NEW.frame.size.width, height: self.playBtn_NEW.frame.size.height - 3), cornerRadius: 5)
    self.recallTilesBtn.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
    self.recallTilesBtn.position = CGPoint(x: self.currentPlayerTileRackDisplay.frame.maxX - self.recallTilesBtn.frame.size.width, y: self.playBtn_NEW.position.y)
    
    
    let recallTilesBtnText = SKLabelNode(text: "Recall")
    recallTilesBtnText.fontColor = UIColor(red: 67/255, green: 84/255, blue: 167/255, alpha: 1.0)
    recallTilesBtnText.fontName = GameConstants.TileLabelFontName
    recallTilesBtnText.fontSize = 20
    recallTilesBtnText.position = CGPoint(x: self.recallTilesBtn.position.x + self.recallTilesBtn.frame.width/2, y: self.recallTilesBtn.position.y + self.recallTilesBtn.frame.height/2)
    recallTilesBtnText.horizontalAlignmentMode = .center
    recallTilesBtnText.verticalAlignmentMode = .center
    recallTilesBtnText.zPosition = self.recallTilesBtn.zPosition + 1
    
    self.addChild(self.recallTilesBtn)
    self.addChild(recallTilesBtnText)
    
    
    //add score Labels
    
    self.player1ScoreLbl.position = CGPoint(x: self.game.singlePlayerMode ? 0 : self.gameBoardDisplay.frame.minX + self.player1ScoreLbl.frame.size.width/2 + 20, y: self.gameBoardDisplay.frame.maxY + self.player1ScoreLbl.frame.size.height/2 + 20)
    self.player1ScoreLbl.zPosition = 2
    self.player1ScoreLbl.fontSize = 25
    self.player1ScoreLbl.fontName = "Arial"
    
    self.addChild(self.player1ScoreLbl)
    
    
    self.player2ScoreLbl.position = CGPoint(x: self.gameBoardDisplay.frame.maxX - self.player1ScoreLbl.frame.size.width/2 - 20, y: self.player1ScoreLbl.position.y)
    self.player2ScoreLbl.zPosition = 2
    self.player2ScoreLbl.fontSize = 25
    self.player2ScoreLbl.fontName = "Arial"
    
    self.addChild(self.player2ScoreLbl)
    
    
    
    self.endTurnBtn = SKShapeNode(rect: CGRect(x: 0, y:0, width: self.playBtn_NEW.frame.size.width, height: self.playBtn_NEW.frame.size.height - 3), cornerRadius: 5)
    self.endTurnBtn.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
    self.endTurnBtn.position = CGPoint(x: self.playBtn_NEW.position.x , y: self.playBtn_NEW.position.y - self.playBtn_NEW.frame.height - 5)
    let endTurnText = SKLabelNode(text: "End Turn")
    endTurnText.fontColor = UIColor.red
    endTurnText.fontName = GameConstants.TileLabelFontName
    endTurnText.fontSize = 20
    endTurnText.position = CGPoint(x: self.endTurnBtn.position.x + self.endTurnBtn.frame.width/2, y: self.endTurnBtn.position.y + self.playBtn_NEW.frame.height/2)
    endTurnText.horizontalAlignmentMode = .center
    endTurnText.verticalAlignmentMode = .center
    endTurnText.zPosition = self.endTurnBtn.zPosition + 1
    // addChild(playBtn)
    
    self.addChild(self.endTurnBtn)
    self.addChild(endTurnText)
    
    self.exchangeBtn = SKShapeNode(rect:CGRect(x:0,y:0, width: self.playBtn_NEW.frame.size.width, height: self.playBtn_NEW.frame.size.height - 3), cornerRadius: 5)
    self.exchangeBtn.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
    self.exchangeBtn.position = CGPoint(x: self.recallTilesBtn.position.x, y: self.endTurnBtn.position.y)
    
    let exchangeBtnText = SKLabelNode(text: "Exchange")
    exchangeBtnText.fontColor = UIColor(red: 67/255, green: 84/255, blue: 167/255, alpha: 1.0)
    exchangeBtnText.fontName = GameConstants.TileLabelFontName
    exchangeBtnText.fontSize = 20
    exchangeBtnText.position = CGPoint(x: self.exchangeBtn.position.x + self.exchangeBtn.frame.width/2,y: self.exchangeBtn.position.y + self.exchangeBtn.frame.height/2)
    exchangeBtnText.horizontalAlignmentMode = .center
    exchangeBtnText.verticalAlignmentMode = .center
    exchangeBtnText.zPosition = self.exchangeBtn.zPosition + 1
    
    self.addChild(self.exchangeBtn)
    self.addChild(exchangeBtnText)
    
    
    
    
    
    //add separator bar between two score labels
    let labelSeparatorBar = SKSpriteNode(color: .black, size: CGSize(width: 5, height: 2*self.player1ScoreLbl.frame.size.height))
    labelSeparatorBar.position.y = self.player1ScoreLbl.position.y
    self.addChild(labelSeparatorBar)
    
    
    self.tilesLeftLbl.position.y = //tileBag.position.y - tileBag.size.height/2 - tilesLeftLbl.frame.size.height/2 - 5
    labelSeparatorBar.position.y + labelSeparatorBar.size.height/2 + 10
    self.tilesLeftLbl.fontSize = 16
    self.addChild(self.tilesLeftLbl)
    self.tilesLeftLbl.fontName = GameConstants.TileLabelFontName
    
    
    self.bingoLabel.fontName = "Arial-BoldMT"
    self.bingoLabel.fontSize = 50
    self.bingoLabel.fontColor = .yellow
    self.bingoLabel.zPosition = 2
    self.bingoLabel.isHidden = true
    self.addChild(self.bingoLabel)
    
    
    
    self.wildCardPicker.initializePicker(tileColor: .lightGray)
    
    self.addChild(self.wildCardPicker)
    
    self.wildCardPicker.zPosition = 50
    self.wildCardPicker.isHidden = true
    
    if self.game.singlePlayerMode {
    
    labelSeparatorBar.isHidden = true
    self.player2ScoreLbl.isHidden = true
    self.player1ScoreLbl.text = "Score: \(self.player1.score)"
    //exchangeBtnText.isHidden = true
    self.exchangeBtn.isHidden = true
    
    self.playBtn_NEW.position.y = self.currentPlayerTileRackDisplay.position.y - self.currentPlayerTileRackDisplay.size.height/2 - self.playBtn_NEW.frame.size.height/2 - 50
    playBtnText.position = CGPoint(x: self.playBtn_NEW.frame.midX, y: self.playBtn_NEW.frame.midY)
    
    
    
    self.singlePlayerRefreshtiles =  SKShapeNode(rect:CGRect(x:0,y:0, width: self.playBtn_NEW.frame.size.width, height: self.playBtn_NEW.frame.size.height - 3), cornerRadius: 5)
    self.singlePlayerRefreshtiles.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
    self.addChild(self.singlePlayerRefreshtiles)
    
    self.recallTilesBtn.position.x = self.playBtn_NEW.frame.maxX + 10
    
    self.recallTilesBtn.position.y = self.playBtn_NEW.position.y
    
    // singlePlayerRefreshtiles.setScale(0.7)
    self.singlePlayerRefreshtiles.position.x = self.recallTilesBtn.frame.maxX + 10
    self.singlePlayerRefreshtiles.position.y = self.playBtn_NEW.position.y
    exchangeBtnText.position.x = self.singlePlayerRefreshtiles.frame.midX
    exchangeBtnText.position.y = self.singlePlayerRefreshtiles.frame.midY
    
    
    // recallTilesBtn.setScale(0.7)
    recallTilesBtnText.position.x = self.recallTilesBtn.frame.midX
    recallTilesBtnText.position.y = self.recallTilesBtn.frame.midY
    
    
    //playBtn_NEW.setScale(1.5)
    //  playBtn_NEW.position.y = recallTilesBtn.position.y - playBtn_NEW.frame.size.height/2
    endTurnText.isHidden = true
    self.endTurnBtn.isHidden  = true
    
    // timeLabel.position = CGPoint(x: tilesLeftLbl.position.x, y: tilesLeftLbl.position.y - 10)
    self.timeLabel.position = CGPoint(x: 0, y: self.player1ScoreLbl.frame.maxY + self.timeLabel.frame.size.height/2 + 2)
    self.timeLabel.zPosition = 50
    self.timeLabel.fontName = "Arial-BoldMT"
    self.timeLabel.fontColor = .white
    self.timeLabel.fontSize = 20
    self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    
    self.addChild(self.timeLabel)
    
    self.singlePlayerPauseButton.text = "PAUSE"
    self.singlePlayerPauseButton.fontName = "Arial-BoldMT"
    self.singlePlayerPauseButton.fontColor = .blue
    self.singlePlayerPauseButton.fontSize = 15
    self.singlePlayerPauseButton.position = CGPoint(x:  view.frame.size.width/2 - self.singlePlayerPauseButton.frame.size.width, y:
    self.currentScoreLbl.position.y)
    self.addChild(self.singlePlayerPauseButton)
    
    self.resumeGameButton = SKLabelNode()
    self.resumeGameButton.text = "RESUME"
    self.resumeGameButton.fontColor = .white
    self.resumeGameButton.fontSize = 20
    self.resumeGameButton.fontName = "Arial-BoldMT"
    
    self.pauseView.isHidden = true
    self.pauseView.size = self.size
    self.pauseView.color = .black
    self.pauseView.zPosition = 100
    self.addChild(self.pauseView)
    self.pauseView.addChild(self.resumeGameButton)
    self.resumeGameButton.position = CGPoint(x: 0, y: 200)
    /*
     singlePlayerRefreshtiles.position.x = recallTilesBtnText.position.x
     singlePlayerRefreshtiles.position.y = recallTilesBtn.position.y - recallTilesBtn.frame.size.height/2 - singlePlayerRefreshtiles.frame.size.height - 30
     singlePlayerRefreshtiles.fontSize = 80
     addChild(singlePlayerRefreshtiles)
     */
    
    
    
    }
    if self.game.gameOver && !self.ignoreGameOver {
        print("GAME OVER....about to show game over panel. in observe closure")
        self.presentGameOverPanel()
        
        FirebaseConstants.CurrentUserPath!.child(FirebaseConstants.UserGames).child(game.gameID).removeValue()
        FirebaseConstants.GamesNode.child(game.gameID).removeValue()
    }
    self.setUpGame2CompletionShouldRun = false
    

    }
    override func didMove(to view: SKView) {
        print("IN DID MOVE TO VIEW!!!!")
        var playerToSaveTileRack = Player()
        if game.singlePlayerMode {
            setUpGame()
        }
        else {
        
            if game.player1.tileRack.playerTiles.count == 0 {
                print("player 1 tiles empty in did move to view. create tiles and save")
                game.player1.tileRack.setUpPlayerTileRack(player: 1, createAllNewTiles: true)
                Fire.dataService.saveTileRack(gameID: game.gameID, playerUserID: game.player1.userID, tileRack: game.player1.tileRack)
                
            }
            if game.player2.tileRack.playerTiles.count == 0 {
                print("player 2 tiles empty in did move to view. create tiles and save")
                game.player2.tileRack.setUpPlayerTileRack(player: 2, createAllNewTiles: true)
                Fire.dataService.saveTileRack(gameID: game.gameID, playerUserID: game.player2.userID, tileRack: game.player2.tileRack)
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                self.setUpGame3()
            }
         }
        
        
        }
    
    let newHighScoreLbl = SKLabelNode(text: "NEW HIGH SCORE!")

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
                     
                       self.newHighScoreLbl.fontSize = 30
                        self.newHighScoreLbl.fontColor = GameConstants.TilePlayer1TileColor
                        self.newHighScoreLbl.fontName = "Avenir-Heavy"
                        self.newHighScoreLbl.zPosition = 100
                        self.newHighScoreLbl.position.y = self.player1ScoreLbl.position.y
                        self.player1ScoreLbl.removeFromParent()
                        self.addChild(self.newHighScoreLbl)
                        
                        self.newHighScoreLbl.alpha = 0
                        
                        let fadeIn = SKAction.fadeIn(withDuration: 2.0)
                        let wait = SKAction.wait(forDuration: 3.0)
                       let fadeOut = SKAction.fadeOut(withDuration: 5.0)
                        let seq = SKAction.sequence([fadeIn, wait, fadeOut])
                        
                        self.newHighScoreLbl.run(seq)

                    }
                }
             
            }
        }
    }
  
    func updateFontColors() {
        newHighScoreLbl.fontColor = newHighScoreLbl.fontColor == .red ? .yellow : .red

    }
    
    override func willMove(from view: SKView) {
    
        print("in will move from view...")
        if !game.singlePlayerMode {
        recall()
        if (currentUserPlayerTileRackIsEmpty && !endOfTurn && !game.gameOver)   {
            print("Saving tile rack for the first time from will move from view")
            Fire.dataService.saveGameData1(game: game,completion: nil)
        
        }
        
        else if (!endOfTurn && wildCardValueSet && !game.gameOver){
            print("Not end of turn and wild card set!")
            Fire.dataService.saveGameData1(game: game,completion: nil)
            
            }
     
        
        Fire.dataService.removeObserversFromGamesNode(game: game)
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
            
            /*
            if !wildCardPicker.isHidden {
                
                
                let wildCardLoc = touch.location(in: self)
                wildCardPicker.position = wildCardLoc
                if (wildCardLoc.y - wildCardPicker.frame.height/2 > playBtn_NEW.frame.maxY) &&
                    (wildCardLoc.y + wildCardPicker.frame.height/2 < self.scene!.frame.maxY)
                    && (wildCardLoc.x  - wildCardPicker.frame.width/2 > self.scene!.frame.minX)
                    && (wildCardLoc.x + wildCardPicker.frame.width/2 < self.scene!.frame.maxX)
                    {
                    
                    wildCardPicker.position = wildCardLoc
                    
                }
              
             
            
            } */

        }
    }
    func recall() {
        for tile in selectedPlayerTiles {
            print("in recall. tile = \(tile.getTileTextRepresentation()) about to set row to -1 etc")
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
            
            if tile.bonusTile {
                print("Tile is bonus tile")
                boardTile.tileLabel.text = "+2"
                boardTile.tileLabel.fontColor = .gray
                tile.bonusTile = false
                
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
       guard (disableGame == false && presentGameOverPanelComplete == false) || game.singlePlayerMode else {
            
                print("Game disabled or game is over")
                return
            
        }
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
                        print("setting wildcard value!")
                        
                        
                        
                       selectedPlayerTile?.setTileValue(value: lastTouchedWildCardTile!.getTileValue())
                      
                        
                        //MARK: Set wildcard value
                        wildCardValueSet = true
                        
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
                    print("touching tile in selected tiles")
                  
                    
                    let row = touchedTile.row
                    let col = touchedTile.col
                   
                    var eraserTileAtNode: Tile?
                    var selectedPlayerTilesAtNode = [Tile]()
                    for tile in selectedPlayerTiles {
                        if tile.row == row && tile.col == col {
                            //selectedPlayerTile = tile
                            selectedPlayerTilesAtNode.append(tile)
                            
                            //MARK: double tile size
                     
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
                        if let selectedPlayerTile = selectedPlayerTile {
                        if selectedPlayerTile.bonusTile {
                            print("gameBoard tile is bonus tile")
                            gameBoardTile.tileLabel.text = "+2"
                            gameBoardTile.tileLabel.fontColor = .gray
                            selectedPlayerTile.bonusTile = false
                            for (i,bonusTile) in bonusTilesUsed.enumerated() {
                                if bonusTile == gameBoardTile {
                                    print("Found bonus tile to remove")
                                    bonusTilesUsed.remove(at: i)
                                    break
                                }
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
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                        
                         self.switchPlayers()
                        }
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
                
                
                
                
                    
                    let endTurnAlert = UIAlertController(title: nil, message: "End your turn?", preferredStyle: UIAlertControllerStyle.alert)
                    let endTurnConfirm = UIAlertAction(title: "End Turn", style: .default, handler: { (okAction) in
                        
                      
                       
                        self.endOfTurn = true
                        if self.selectedPlayerTiles.count > 0 {
                            print("recalling selected player tiles after end of turn hit.")
                            self.gameBoard!.showTiles(tiles: self.selectedPlayerTiles, message: "selected tiles to remove before exiting game:")
                            self.recall()
                        }
                        self.switchPlayers()
                        
                    })
                    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                    
                    endTurnAlert.addAction(endTurnConfirm)
                    endTurnAlert.addAction(cancel)
                    
                    if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                        mainVC.present(endTurnAlert, animated: true, completion: nil)
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
                      
                            
                            if targetTile.tileLabel.text == GameConstants.TileBonusTileText {
                                print("landed on bonus tile")
                                selectedTile.bonusTile = true
                                
                            }
                            else {
                                print("not land on bonus tile.")
                                selectedTile.bonusTile = false
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
    
    func tilePlayedIsBonusTile(tile: Tile) -> Bool {
        
        
        return true
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
    
            print("in show bingo! bingoLabel position = \(bingoLabel.position)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            self.bingoLabel.isHidden = false
            self.bingoLabel.zPosition = self.gameBoardDisplay.zPosition + 1000
            let moveBingoLabel: SKAction = SKAction.moveBy(x: 0, y: self.frame.height/2 - self.bingoLabel.frame.size.height, duration: 2.0)
            let fade = SKAction.fadeOut(withDuration: 2.0)
            let moveAndFadeBingo = SKAction.group([moveBingoLabel, fade])
            self.bingoLabel.run(moveAndFadeBingo){
                self.bingoLabel.position = CGPoint(x: 0, y: 0)
                self.bingoLabel.alpha = 1.0
                self.bingoLabel.isHidden = true
                
                self.updateScoreLabel(player: self.getPlayerToUseInLoadGameClosure())
                
                print("Just finished running bingo label in showBingo")
            }
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
        let gameOver = (game.lastTurnPassed && game.currentTurnPassed) || (currentPlayerTileRack.playerTiles.count == 0 && tilesLeft == 0)
        
        refillTileRack()
        
        switchedPlayers = true
      
        //showCurrentTileRack()
        selectedPlayerTiles.removeAll()
        
        tilesUsedThisTurn.removeAll()
        selectedPlayerTile = nil
        
        playBtnPushed = false
        if game.currentTurnPassed {
           game.lastScoreIncrement = 0
        }
        game.currentPlayerID = player1.userID == currentPlayer.userID ? player2.userID : player1.userID
        
        
        //game.selectedPlayerTiles.removeAll()
        
        if gameOver {
            game.gameOver = true
            game.currentTurnPassed = true
            print("GAME OVER from switch players")
            if (game.lastTurnPassed && game.currentTurnPassed) {
                print("Game over because player passed turn and previous player passed turn")
            }
         //   presentGameOverPanel()
            ignoreGameOver = false
            
           // Fire.dataService.updateStatsAndRemoveGame(game: game)
            
            Fire.dataService.saveGameData1(game: game, completion: nil)
    }
     
        else {
            game.gameOver = false
            game.tilesLeft = tilesLeft
            game.lastTurnPassed = game.currentTurnPassed
            game.currentTurnPassed = true
            game.lastUpdated =  Int(NSDate().timeIntervalSince1970)
            print("about to disable game")
            disableGame = true
            Fire.dataService.saveGameData1(game: self.game, completion: nil)
        }
 
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
    

    func removeSelectedPlayerTiles(){
        print("REMOVING SELECTED PLAYER TILES")
        selectedPlayerTiles.removeAll()
    }
    
    func removeNonDeleteSelectedPlayerTiles(){
        print("REMOVING NON DELETE SELECTED PLAYER TILES")
        nonDeleteSelectedPlayerTiles.removeAll()
    }
    
    func play1() {
  
        print("IN PLAY 1: n selected tiles = \(selectedPlayerTiles.count)")
        
       
        guard selectedPlayerTiles.count > 0 else {
            print("NO TILES SELECTED IN PLAY1. RETURNING")
            return
        }
        let copySelectedPlayerTiles  = selectedPlayerTiles
        
        
        
        
        for tile in selectedPlayerTiles where tile.tileType != TileType.eraser {
            nonDeleteSelectedPlayerTiles.append(tile)
            print("In play1: selected tile that is not eraser--value= \(tile.getTileTextRepresentation()) row/col: \(tile.row), \(tile.col)")
        }
        
        
        
        let legalMove =  checkIfLegalMove()
        
        
        // if so, set values on board and remove tiles, if not alert user and return tiles
        // replace player tiles that were played
        

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
            game.selectedPlayerTiles = selectedPlayerTiles
            
            playsThisTurn.append(selectedPlayerTiles)
            
         //   showSelectedTiles()
            
            currentPlayerTileRack.removeTilesFromRack(tiles: selectedPlayerTiles)
        
            if !game.singlePlayerMode {
                calculateScore()
               game.lastPlayerToMove = currentPlayerN
               
                if currentPlayer.tileRack.playerTiles.count == 0 && game.currentTurnPassed == false {
                    print("in play1: player used all tiles...switching players")
                    print("in play1, before switching players, incremented score. player score is now: \(currentPlayer.score)")
                    game.lastPlayerUsedAllTiles = true
                    wildCardValueSet = false
                    game.lastScoreIncrement += 10
                    currentPlayer.score += 10
                    switchPlayers()
                }
                else {
                    game.lastPlayerUsedAllTiles = false
                    Fire.dataService.saveGameData1(game: game,completion: nil)
                }
            }
            

            
       
            
            
            
            // showCurrentTileRack()
            if game.singlePlayerMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.replaceTiles(tilesToReplace: copySelectedPlayerTiles)
                }
            }
            
            removeSelectedPlayerTiles()
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
                        print("tile bonus tile: \(tile.bonusTile)")
                        if tile.bonusTile {
                            gameBoardTile!.tileLabel.text = "+2"
                            gameBoardTile!.tileLabel.fontColor = .gray
                            tile.bonusTile = false
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
       removeSelectedPlayerTiles()
        bonusTilesUsed.removeAll()
        
    }
    fileprivate func extractedFunc() {
        lightUpPlayedTiles {
            (tiles) in
            
            for tile in tiles {
                tile.color = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
            }
            
            if self.tilesUsedThisTurn.count == 7 && !self.game.singlePlayerMode {
                // self.showBingo()
            }
            
            
        }
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
    func gameBoardTileIsBonusTile(tile: Tile) -> Bool {
        for sTile in nonDeleteSelectedPlayerTiles where sTile.bonusTile {
            print("bonus tiles currently: \(sTile.getTileTextRepresentation())")
            if sTile.row == tile.row && sTile.col == tile.col {
                return true
            }
        }
        return false
    }
    
    func getPlayerToUseInLoadGameClosure() -> Player  {
    
        var playerToUse: Player
        playerToUse = game.lastPlayerToMove == 1 ? player1 : player2
       /* if !switchedPlayers && !game.currentTurnPassed {
            playerToUse = currentPlayer
        }
        else {
            playerToUse = currentPlayerN == 1 ? player2 : player1
        }
        
        print("switched:\(switchedPlayers) current turn passed: \(game.currentTurnPassed) --> PLAYER TO USE: \(playerToUse.userName)")
 */
        return playerToUse
    }
    
   
    func lightUpPlayedTiles(completion: ([Tile]) -> ()) {
    
        guard !shouldNotRunAnimation() else{
            print("should not run animation...reeturning from light up ")
            self.selectedPlayerTiles.removeAll()
            return
        }
      
        var color: SKColor = SKColor()
        color = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
      
        
        print("in light up played tiles...about to convert non delete selected tiles to board tiles")
        
        let gameBoardTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
        
        let expandTile = SKAction.scale(by: 1.2, duration: 0.1)
        let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 0.0 , duration: 0.1)
        let changeBack = SKAction.colorize(with: color, colorBlendFactor: 0.0, duration: 0.1)
        let playValidMove =  SKAction.playSoundFileNamed("ValidMoveSound.wav", waitForCompletion: false)
        let changeVolume = SKAction.changeVolume(to: 2, duration: 0.0)
        let changeToYellowAndPlaySound = SKAction.group([changeToYellow, playValidMove,changeVolume])
        let playValidMoveQuiet = SKAction.group([playValidMove, changeVolume])
        let shrinkTile = SKAction.scale(by: 1/1.2, duration: 0.6)
        let wait = SKAction.wait(forDuration: 0.1)
        let seq = SKAction.sequence([ wait, shrinkTile, changeBack])
     //  let changeToYellowAndPlaySound = SKAction.group([changeToYellow,playValidMove])
        var hasBingo = bingo
        var nBonusTilesUsed: Int = 0
       
        print("in light up tiles, after calculateScore(). points = \(self.game.lastScoreIncrement)")
        
        calculateScore()
         for  (i,tile) in gameBoardTiles.enumerated() {
            
            print("running light up tiles for tile \(i): \(tile.getTileTextRepresentation())")
            tile.run(expandTile)
            tile.zPosition = 4
          
            if gameBoardTileIsBonusTile(tile: tile){
                //currentPlayer.score += 2
                nBonusTilesUsed += 1
                showPoints(atLocation: tile.position, points: 2, color: .gray)
            }
           
            print("in light up played tiles, bingo?: \(hasBingo), N bonus tiles: \(nBonusTilesUsed) last score increment: \(self.game.lastScoreIncrement)")
            tile.run(changeToYellowAndPlaySound){
                //self.playValidMoveAudioNode.run(playValidMoveQuiet)
                
                tile.run(seq){
                
                    tile.zPosition = 2
                  
                    if i == gameBoardTiles.count - 1 {
                        var loc = gameBoardTiles[i].position
                        loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                       // self.showPoints(atLocation: loc, points: points)
                        
                        let points = self.game.lastScoreIncrement - 2*nBonusTilesUsed - 10*hasBingo
                        
                        print("points to show is \(points)")
                       self.showPoints(atLocation: loc, points: points, color:  color)
                       
                        self.selectedPlayerTiles.removeAll()
                    }
                }
            }
        
          
        }
        
        completion(gameBoardTiles)
    }

    
    func lightUpPlayedTiles1(completion: (() -> ())?) {
        
        guard !shouldNotRunAnimation() else{
            print("should not run animation...returning from light up ")
            self.selectedPlayerTiles.removeAll()
            return
        }
        
        var color: SKColor = SKColor()
        color = getPlayerToUseInLoadGameClosure().player1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
        
        
        print("in light up played tiles...about to convert selected tiles to board tiles")
        
       // let gameBoardTiles = convertSelectedPlayerTilesIntoBoardTiles()
        // do eraser tiles first in sort, so that the rest of closure below runs
        
      
        let expandTile = SKAction.scale(by: 1.2, duration: 0.2)
        let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 0.0 , duration: 0.1)
        let changeBack = SKAction.colorize(with: color, colorBlendFactor: 0.0, duration: 0.1)
        let playValidMove =  SKAction.playSoundFileNamed("ValidMoveSound.wav", waitForCompletion: false)
        
        let shrinkTile = SKAction.scale(by: 1/1.2, duration: 1.0)
        let wait = SKAction.wait(forDuration: 0.5)
        let seq = SKAction.sequence([ wait, shrinkTile, changeBack])
        let changeToYellowAndPlaySound = SKAction.group([changeToYellow,playValidMove])
        let fadeToWhite = SKAction.colorize(with: GameConstants.TileBoardTileColor, colorBlendFactor: 0.0, duration: 0.3)
        let lowerVolume = SKAction.changeVolume(to: 10, duration: 1.0)
        let playValidMoveQuiet = SKAction.group([playValidMove,lowerVolume])
        var hasBingo = self.bingo
        var nBonusTilesUsed: Int = 0
        
        print("in light up tiles, after calculateScore(). points = \(self.game.lastScoreIncrement)")
        
        var orderedTiles = orderSelectedPlayerTilesWithEraserTilesFirst()
        for  (i,tile) in orderedTiles.enumerated() {
            
            print("running light up tiles for tile \(i): \(tile.getTileTextRepresentation()) , at row/col: \(tile.row), \(tile.col) of type: \(tile.tileType)")
            
            let gameBoardTile = gameBoard.getTile(atRow: tile.row, andCol: tile.col)
            if tile.tileType == .eraser  {
                print("eraser tile found, moving on. light up tiles 1")
                
                if game.lastPlayerToMove != (currentUserPlayer.player1 == true ? 1 : 2) {
               
                 gameBoardTile.run(fadeToWhite)
                 gameBoardTile.run(SKAction.playSoundFileNamed("EraserSound1.wav", waitForCompletion: false))
                    
                  
                }
                continue
            }
            
            
            print("going past eraser bit in light up tiles. means we didn't just find eraser tile....")
            gameBoardTile.run(expandTile)
            gameBoardTile.zPosition = 4
            
            if gameBoardTileIsBonusTile(tile: gameBoardTile){
                //currentPlayer.score += 2
                nBonusTilesUsed += 1
                showPoints(atLocation: gameBoardTile.position, points: 2, color: .gray)
            }
            
            print("in light up played tiles, bingo?: \(hasBingo), N bonus tiles: \(nBonusTilesUsed) last score increment: \(self.game.lastScoreIncrement)")
            gameBoardTile.run (changeToYellowAndPlaySound){
//                self.playValidMoveAudioNode.run(playValidMoveQuiet, completion: {
//                    print("VALID MOVE QUIET WAS PLAYED")
//                })
                gameBoardTile.run(seq){
                    
                    gameBoardTile.zPosition = 2
                    
                    if i == orderedTiles.count - 1 {
                        var loc = gameBoardTile.position
                        loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                        // self.showPoints(atLocation: loc, points: points)
                        
                        let points = self.game.lastScoreIncrement - 2*nBonusTilesUsed - 10*hasBingo
                        
                        print("points to show is \(points)")
                        self.showPoints(atLocation: loc, points: points, color:  color)
                        
                       
                    }
                }
            }
            
            
        }
        
        if  completion != nil {
            completion!()
        }
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
        
           // showSelectedTiles()
            for tile in selectedPlayerTiles {
                print("in convertnonDelete... tile value is \(tile.getTileValue()) at row \(tile.row) and col \(tile.col)")
                if tile.tileType != TileType.eraser {
                    print("Tile val: \(tile.getTileValue()) row: \(tile.row) col: \(tile.col)")
                    if let gameBoard = gameBoard {
                gameBoardTiles.append(gameBoard.getTile(atRow: tile.row, andCol: tile.col))
                    }
                }
            }
        }
        return gameBoardTiles
    }
    
    
    func convertSelectedPlayerTilesIntoBoardTiles() -> [Tile] {
        
       
       let eraserTiles = selectedPlayerTiles.filter{$0.tileType == .eraser}
        
    
        var  gameBoardTiles = [Tile]()
        
        
        for tile in eraserTiles {
            print("in convert selected tiles..showing eraser tiles. eraser tile val: \(tile.getTileTextRepresentation()) at row/col: \(tile.row), \(tile.col) tile type: \(tile.tileType)")
            if let gameBoard = gameBoard {
                
                // let gbTile = gameBoard.getTile(atRow: tile.row, andCol: tile.col)
                
                //  print("in convert selected tiles to board.. game board tile value is \(gbTile.getTileValue()) at row \(gbTile.row) and col \(gbTile.col) and tile type is \(gbTile.tileType)")
                gameBoardTiles.append(gameBoard.getTile(atRow: tile.row, andCol: tile.col))
                
            }
        }
        

            // showSelectedTiles()
            
            
            for tile in selectedPlayerTiles where tile.tileType != .eraser {
                
                print("in convert selected tiles to board.. tile value is \(tile.getTileValue()) at row \(tile.row) and col \(tile.col) and tile type is \(tile.tileType)")
              if let gameBoard = gameBoard {
                        
                       // let gbTile = gameBoard.getTile(atRow: tile.row, andCol: tile.col)
                        
                           //  print("in convert selected tiles to board.. game board tile value is \(gbTile.getTileValue()) at row \(gbTile.row) and col \(gbTile.col) and tile type is \(gbTile.tileType)")
                        gameBoardTiles.append(gameBoard.getTile(atRow: tile.row, andCol: tile.col))
                        
                    }
                }
            
        
        print("After creating gameboard tiles...there are \(gameBoardTiles.count) tiles. showing all gameboard tiles...")
        for tile in gameBoardTiles {
            print("tile val: \(tile.getTileTextRepresentation()) row, col: \(tile.row), \(tile.col)")
        }
        
        return gameBoardTiles
    }
    
    
    
    func orderSelectedPlayerTilesWithEraserTilesFirst() -> [Tile] {
        
        var selectedTilesOrdered = [Tile]()
        let eraserTiles = selectedPlayerTiles.filter{$0.tileType == .eraser}
        

        for tile in eraserTiles {
         
                selectedTilesOrdered.append(tile)
   
        }
        
        // showSelectedTiles()
        
        
        for tile in selectedPlayerTiles where tile.tileType != .eraser {
                selectedTilesOrdered.append(tile)
        }
        
        
        print("After creating selected tiles ordered, there are \(selectedTilesOrdered.count) tiles. showing all...")
        for tile in selectedTilesOrdered {
            print("tile val: \(tile.getTileTextRepresentation()) row, col: \(tile.row), \(tile.col), type: \(tile.tileType)")
        }
        
        return selectedTilesOrdered
    }
    
    func showPoints(atLocation location: CGPoint,points: Int, color: UIColor?) {
  
      print("about to show \(points) in show points")
        let pointDisplay = SKLabelNode(text: "+ \(points)!")
      
        pointDisplay.fontName = "AvenirNext-Bold"
        pointDisplay.fontSize = 50
        
        if let displayColor = color {
            pointDisplay.fontColor = color
        }
        else {
            pointDisplay.fontColor = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
        }
        
            pointDisplay.position = CGPoint(x: location.x , y: location.y)
       
    
        pointDisplay.zPosition = 5
        let movePointDisplay = SKAction.moveTo(y: location.y + 300, duration: 2)
        let fadePointDisplay = SKAction.fadeOut(withDuration: 2)
        
        addChild(pointDisplay)
        
        pointDisplay.run(movePointDisplay)
        pointDisplay.run(fadePointDisplay){
        pointDisplay.removeFromParent()
            print("in showPoints(): current player score is: \(self.currentPlayer.score)")
           
            self.updateScoreLabel(player: self.getPlayerToUseInLoadGameClosure() )
            
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

    func nonPlayerSeedTilesConnectedToTargetTile() -> [Tile] {
        var seedTiles = [Tile]()
        let tTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
        for tile in tTiles {
            let connectedTiles = gameBoard.getBottomTopConnectedValuedTiles(tile: tile) + gameBoard.getRightLeftConnectedValueTiles(tile: tile)
            for connectedTile in connectedTiles {
                if connectedTile.player != currentPlayerN {
                    seedTiles.append(connectedTile)
                }
            }
        }
        return seedTiles
    }
    
    func checkIfLegalTilePath() -> Bool {
      
       // let nonPlayerSeedTile = nonPlayerTileConnectedToTargetTile()
        var targetTiles = [Tile]()
       /* if let base = nonPlayerSeedTile {
            print("Tile is connected to non-current-player tile: \(base.getTileTextRepresentation())")
            targetTiles =  convertNonDeleteSelectedPlayerTilesIntoBoardTiles() + [base]
            
        }
        else {
            print("No tile connected to non-current-player tile")
         targetTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
            
        } */
        
        targetTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles() + nonPlayerSeedTilesConnectedToTargetTile()
        
        
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
     
      gameBoard!.showTiles(tiles: nonDeleteSelectedPlayerTiles, message: "non Delete selected Player tiles in tile connected to board tile:")
       gameBoard!.showTiles(tiles: selectedPlayerTiles, message: "Selected Player tiles in tile connected to board tile:")
        
        if nonDeleteSelectedPlayerTiles.count  == 0 && selectedPlayerTiles.count > 0 {
        //    print("in tiles connected to board tiles with values---non delete selected tiles count = 0 and selected player tiles > 0, returning true")
            return true
        }
        else {
            return gameBoard!.anyTilesTouchingOriginalBoardTilesWithValue(tiles: convertNonDeleteSelectedPlayerTilesIntoBoardTiles())
        
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
        
      let nonDeleteSelectedPlayerTiles = convertNonDeleteSelectedPlayerTilesIntoBoardTiles()
        var nBonusTilesUsed: Int = 0
        for t  in nonDeleteSelectedPlayerTiles {
            if gameBoardTileIsBonusTile(tile: t) {
                nBonusTilesUsed += 1
            }
        }
        let points =  nonDeleteSelectedPlayerTiles.count * nonDeleteSelectedPlayerTiles.count + 2*nBonusTilesUsed
        print("In calc score. \(nBonusTilesUsed) bonus tiles were played. and \(nonDeleteSelectedPlayerTiles.count) non delete tiles used")
        
    
        
       currentPlayer.score += points
        
        print("In calculateScore(), extra points: \(points); points for \(currentPlayer.userName) is now: \(currentPlayer.score)")
       // currentScoreLbl.text = "\(currentPlayer.userName!)'s score: \(currentPlayer.score)"
      game.lastScoreIncrement = points
    
        
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































