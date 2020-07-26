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
    
    var scoreForLabel:Int = 0
    var boxBonusViewedThisTurn: Bool = false
    var boxesViewedThisTurn = [BoxLoc]()
    var playsSeen = [String]()
    var legalPlaysThisTurn  = [[Tile]]()
    var badMathTiles = [Tile]()
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
    
    var tilesBombedThisTurn = [Tile]()
    var bombedValuedTilesToRestore = [Tile]()
    
    
    var justRemovedPlays = false
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
    var playSound = UserDefaults.standard.bool(forKey: GameConstants.soundsOnUserDefaultsBool)
    
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
            if !game.singlePlayerMode { tilesLeftLbl.text = "\(tilesLeft) tiles remaining (v.5)" }
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
    
    var anySelectedTilesOnBoard = false {
        didSet {
            if anySelectedTilesOnBoard == true {
                playBtn_NEW?.fillColor = GameConstants.PlayBtnColor
                playBtn_NEW?.alpha = 1.0
            }
           else  {
                playBtn_NEW?.fillColor = .red
                playBtn_NEW?.alpha = 0.2
            }
        }
    }
  
    
    
    var targetTileSelectedPlayerTiles: [Tile]{
        var t = [Tile]()
        for tile in selectedPlayerTiles {
            if tile.row != -1 && tile.col != -1
            {
                let candidate = gameBoard.getTile(atRow: tile.row, andCol: tile.col)
                t.append(candidate)
                
            }
            
        }
        
        return t
    }
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
                    
                    let alert = UIAlertController(title:"Not enough tiles left!", message: "The maximum number of tiles you can exchange this turn is: \(tilesLeft)", preferredStyle: UIAlertController.Style.alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
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
    
    var bingoLabel = SKLabelNode(text: "+\(GameConstants.BingoPoints)")
    
    var selectedGameBoardTiles = [Tile]() 
    var endOfGamePanel = SKSpriteNode()
    var singlePlayerEndOfGamePanel = SKSpriteNode()
    var yesBtn = SKLabelNode()
    var noBtn = SKLabelNode()
    var tileRefreshBtnTapped = false
  
    var recallTilesBtn: SKShapeNode!
    
    var backLblNode = SKLabelNode(text: "🔙")
  
    var eog = GameOverPanel()
    var errorMessageView = ErrorMessageView()
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
        let wait = SKAction.wait(forDuration: 1.5)
        let waitAndSlide = SKAction.sequence([wait, slideInEOG])
        eog.run(waitAndSlide)
        
        guard self.scene?.children != nil else {
            return
            
        }
        

        disableGame = true
        presentGameOverPanelComplete = true
    }
    
    func presentErrorMessageView(){
        
        let w = 0.6*gameBoardDisplay.size.width
        let h = 0.25*gameBoardDisplay.size.height
        
   
       // errorMessageView = ErrorMessageView(rect: CGRect(x: -w/2, y: -h/2, width: w, height: h), cornerRadius: 15)
        errorMessageView = ErrorMessageView(rect: CGRect(x: -w/2, y: gameBoardDisplay.position.y + gameBoardDisplay.size.height/2 , width: w, height: h), cornerRadius: 15)
       errorMessageView.setUpErrorMessageView{
            for tile in self.badMathTiles {
                tile.tileLabel.fontColor = .white 
            }
           // self.handleRestoringTilesAfterIllegalMove()
            self.recall()
            self.nonDeleteSelectedPlayerTiles.removeAll()
            self.removeSelectedPlayerTiles()
            self.bonusTilesUsed.removeAll()
            self.badMathTiles.removeAll()
        }

        
        addChild(errorMessageView)
        
    
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
    
    
    var nTimesLoadedGame = 0
    var nTimesRunWholeLoadGame = 0
    func setUpGame3(){
        
        
        print("in set up Game 3: current User ID: \(FirebaseConstants.CurrentUserID)")
        
        
       // self.scene?.removeChildren(in: [currentPlayerTileRackDisplay, gameBoardDisplay])
        
        
      //  currentPlayerTileRackDisplay = SKSpriteNode()
       // gameBoardDisplay = SKSpriteNode()
        
        Fire.dataService.loadGameWithObserver(gameID: game.gameID){
            (game)
            
            
            in
            
        
            print("In load game closure. last Turn passed: \(game.lastTurnPassed) game over: \(game.gameOver) current turn passed: \(game.currentTurnPassed)  end of turn:\(self.endOfTurn) switched Players: \(self.switchedPlayers) turnIsOver = \(self.turnIsOver) ignore game over:\(self.ignoreGameOver). resigned player: \(game.resignedPlayerNum)")
            
            
            print("showing game data in loadgame closure. game id:\(game.gameID) player1: \(game.player1.userName) player2: \(game.player2.userName) current player ID: \(game.currentPlayerID) current User: \(FirebaseConstants.CurrentUserID)")
            
   
            
            guard !self.ignoreGameOver else {
                print("in load game obs, ignore game over = true, returning")
                return
            }
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
          
            guard !(game.resignedPlayerNum != 0 && !self.setUpGame2CompletionShouldRun) else {
                print("game over, resigned")
                 self.presentGameOverPanel()
                return
            }
            guard !self.justRemovedPlays else {
                print("Just removed plays, not setting up load game")
                if game.gameOver {
                    if !self.presentGameOverPanelComplete {
                        self.presentGameOverPanel()
                    }
                }
                self.justRemovedPlays = false
                return
            }
            
          
   
            self.scene?.removeChildren(in: [self.currentPlayerTileRackDisplay, self.gameBoardDisplay])
            self.currentPlayerTileRackDisplay = SKSpriteNode()
            self.gameBoardDisplay = SKSpriteNode()
 
            self.selectedPlayerTiles = game.selectedPlayerTiles
            
            
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
            // SET UP SCORE LABELS
            // SET UP SCORE LABELS
            
            let scoreIncrementFromLastPlays = self.getScoreIncrementFromLastPlays()
            self.scoreForLabel = self.getPlayerToUseInLoadGameClosure().score - scoreIncrementFromLastPlays
            print("Score increment from last plays: \(scoreIncrementFromLastPlays)")
            print("score for label = \(self.scoreForLabel)")
            if self.currentUserPlayer.plays.count > 0 && !self.shouldNotRunAnimation() && !self.presentGameOverPanelComplete && self.game.lastPlayerToMove == 1  {
                print("last player to move was 1, adjusting player 1 score down by increment, so label will be: \(self.player1.score - scoreIncrementFromLastPlays) before adding increment.")
                
                
                self.player1ScoreLbl.text =  "\(self.player1.userName!): \(max(0,self.player1.score - scoreIncrementFromLastPlays))"
                self.player2ScoreLbl.text = "\(self.player2.userName!): \(self.player2.score)"
            }
        
            else if self.currentUserPlayer.plays.count > 0 && !self.shouldNotRunAnimation()  &&  !self.presentGameOverPanelComplete && self.game.lastPlayerToMove == 2  {
                
                print("last player to move was 2, adjusting player 2 score down by increment, so label will be: \(self.player2.score - scoreIncrementFromLastPlays) before adding increment.")
                
                
                 self.player2ScoreLbl.text =  "\(self.player2.userName!): \(max(0,self.player2.score - scoreIncrementFromLastPlays))"
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
            
           
            //MARK: light up tiles in load game
           
           
            self.lightUpPlaysInSequence(plays: self.currentUserPlayer.plays){
             
               self.justRemovedPlays = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ){
                    Fire.dataService.removePlays(game: game, player: self.currentUserPlayer){
                        print("remove plays done")
    
                    }
                    
                } 
              
            self.legalPlaysThisTurn.removeAll()
            self.removeSelectedPlayerTiles()
            self.removeNonDeleteSelectedPlayerTiles()
            
             
            }
            
       
            
            
          
            
            
            self.removeSelectedPlayerTiles()
            self.removeNonDeleteSelectedPlayerTiles()
            
            
        
            //if it's the first time after didMoveToView, need to set up all the player's other views
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
            print("player score after used in show bingo is: \(player.score)")
            scoreLabel = player.player1 ? player1ScoreLbl : player2ScoreLbl
            
            scoreLabel.text = "\(player.userName!): \(player.score)"
            
        }
    }
    
    func getScoreIncrementFromLastPlays() -> Int {
    var scoreIncrementFromLastPlays = 0
        
    for play in currentUserPlayer.plays {
        print("play = \(play.playID), points=\(play.points). adding \(play.points) to score increment which is before adding \(scoreIncrementFromLastPlays)" )
    scoreIncrementFromLastPlays += play.points
        print("after adding, it's \(scoreIncrementFromLastPlays)")
    }
        return scoreIncrementFromLastPlays + GameConstants.BoxBonus*getNBoxBonusesToShowThisTurn() + GameConstants.BingoPoints*(game.lastPlayerUsedAllTiles ? 1 : 0)
        
        }
        
    func getNBoxBonusesToShowThisTurn() -> Int{
    
    let newBoxes = self.game.boxLocs.filter{self.currentUserPlayer.player1 ? !$0.player1Viewed: !$0.player2Viewed}
    
        return newBoxes.filter{!$0.hasTheSameCenterAsAnyBox(inboxes: self.boxesViewedThisTurn)}.count
    }
    
    func updateScoreLabel(player: Player, byIncrement: Int) {
      print("in update score label...with increment \(byIncrement)")
        var scoreLabel = SKLabelNode()
        
        
        if game.singlePlayerMode {
            player1ScoreLbl.text = "Score: \(player1.score)"
        }
        else {
            scoreLabel = player.player1 ? player1ScoreLbl : player2ScoreLbl
            
            print("about to increment score label which is: \(self.scoreForLabel) by \(byIncrement) points")
            print("before comparing to actual score score for label is \(scoreForLabel)")
            scoreForLabel = min(scoreForLabel + byIncrement, player.score)
            print("after comparing to actual score score for label is \(scoreForLabel)")
            scoreLabel.text = "\(player.userName!): \(scoreForLabel)"
            //self.scoreForLabel += byIncrement
           
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
    self.playBtn_NEW.fillColor = .red
    playBtn_NEW.alpha = 0.2
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

    @objc func updateTimer(){
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
            
        else if !game.gameOver && !endOfTurn && boxBonusViewedThisTurn{
            print("Not end of turn and new box locs viewed, saving")
            updateBoxLocs {
                
                 Fire.dataService.saveGameData1(game: self.game, savePlays: self.currentPlayer.plays.count > 0 , completion: nil)
                
            }
            
          
            
        }
        
       else if (!endOfTurn && !disableGame && wildCardValueSet && !game.gameOver){
            print("Not end of turn. End of turn = \(endOfTurn) and wild card set, saving game data!")
            Fire.dataService.saveGameData1(game: game,completion: nil)
            }
     
  
            
        Fire.dataService.removeObserversFromGamesNode(game: game)
        }
        
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard disableGame == false else {
            print("Game disabled, returning from touches moved")
            return
            
        }
        
        
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
        anySelectedTilesOnBoard = false
        print("Selected player tiles count before revert bombs: \(selectedPlayerTiles.count)")
        let bTiles = selectedPlayerTiles.filter({$0.tileType == .bomb})
        for bTile in bTiles {
            revertGameBoardAfterBombTileMoved(bombTile: bTile, inTouchesMoved: false)
        }
        print("selected player tiles count after revert bombs: \(selectedPlayerTiles.count)")
        var boardTile = Tile()
        for tile in selectedPlayerTiles.filter({$0.tileType != .bomb}) {
            print("in recall. tile = \(tile.getTileTextRepresentation()) about to set row to -1 etc")
            tile.isHidden = false
            tile.alpha = 1.0
         
            let goHome = SKAction.move(to: tile.startingPosition, duration: 0.3)
           boardTile = gameBoard.getTile(atRow: tile.row, andCol: tile.col)
            print("board tile player: \(boardTile.player)")
            boardTile.showTile(msg: "showing board tile in recall..")
            boardTile.inSelectedPlayerTiles = false
         
            tile.row = -1
            tile.col = -1
           
          
            if !tilePlaysOverBombedAreaThisTurn(tile: tile) , tilePlaysOverDeleteTileInSelectedPlayerTiles(tile: tile) || tile.tileType == .eraser, let holdVal = boardTile.getHoldingValueToRestore(), let holdPlayer = boardTile.getHoldingPlayerToRestore(){
                print("tile doesn't play over bombed area in recall...")
                boardTile.setTileValue(value: holdVal)
                print("holding player is: \(holdPlayer)")
                print("holding value is: \(holdVal)")
                boardTile.color = holdPlayer == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                boardTile.player = holdPlayer
             /*   if boardTile.player == nil {
                    print("board tile player is nil....")
                    boardTile.player = holdCol == GameConstants.TilePlayer1TileColor ? 1 : 2
                } */
             
            }
            else {
                print("Not restoring tile values in recall...board tile holding val: \(boardTile.getHoldingValueToRestore())")
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
            
            print("after recall--> board tile player: \(boardTile.player)")

        }
        boardTile.removeHoldingValuesAfterRestoring()
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
                        let expandTile = SKAction.scale(by: 2, duration: 0.4)
                        let shrinkTile = SKAction.scale(by: 1/2, duration: 0.2)
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
                    print("touching tile in selected tiles of type: \(touchedTile.tileType)")
                  
                    
                    let row = touchedTile.row
                    let col = touchedTile.col
                   
                    var eraserTileAtNode: Tile?
                    var selectedPlayerTilesAtNode = [Tile]()
                    var valuedTileDeletedThisPlay = valuedTileWasDeletedThisPlay(tile: touchedTile)
                 
                    if selectedPlayerTiles.filter({$0.tileType == .bomb && $0.row == touchedTile.row  && $0.col == touchedTile.col}).count > 0 {
                        print("touches began: touching bomb tile")
                        revertGameBoardAfterBombTileMoved(bombTile: touchedTile)
                    }
                
                    else {
                        print("touches began, not touching bomb tile")
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
                                    print("you have an eraser tile here, in touches began")
                                    
                                    tile.isHidden = false
                                    tile.alpha = 1.0
                                    tile.size.width = GameConstants.TileSize.width
                                    tile.size.height = GameConstants.TileSize.height
                                    
                                    
                                    
                                    let returnHome = SKAction.move(to: tile.startingPosition, duration: 1.0)
                                    tile.run(returnHome)
                                    
                                    
                                    selectedPlayerTiles = selectedPlayerTiles.filter({$0 != tile})
                                    tilesUsedThisTurn = tilesUsedThisTurn.filter({$0 != tile})
                                    
                                }
                                else {
                                    selectedPlayerTile = tile
                                    
                                    
                                }
                            }
                            
                        }
                        else if selectedPlayerTilesAtNode.count > 0 {
                            selectedPlayerTile = selectedPlayerTilesAtNode[0]
                        }
                        
                        selectedPlayerTilesAtNode.removeAll()
                        
                        selectedPlayerTile?.isHidden = false
                        // selectedPlayerTile?.alpha = 1.0
                      
                        
                     
                        
                     
                        if  valuedTileDeletedThisPlay, let holdVal = touchedTile.getHoldingValueToRestore(), let holdPlayer = touchedTile.getHoldingPlayerToRestore()
                            
                        {
                            print("Tile was deleted this play...")
                            print("holding value to restore: \(holdVal)")
                            print("about to restore...")
                            touchedTile.setTileValue(value: holdVal)
                            touchedTile.color = holdPlayer == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                            
                            touchedTile.player = holdPlayer
                            
                            touchedTile.removeHoldingValuesAfterRestoring()
                           
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
                        let alert = UIAlertController(title:"No tiles left!", message: "Exchanges are not possible without any tiles left to exchange!", preferredStyle: UIAlertController.Style.alert)
                        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                        alert.addAction(ok)
                        if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                            mainVC.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    guard game.currentTurnPassed else {
                        let alert = UIAlertController(title:"Sorry...", message: "You can't exchange tiles if you've already played this turn!", preferredStyle: UIAlertController.Style.alert)
                        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                        alert.addAction(ok)
                        if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                            mainVC.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    guard game.numSequentialPlaysWithNoTilesUsed != 3 else {
                        let alert = UIAlertController(title:"Sorry...", message: "You must use a tile this turn or else the game with end. Exchange not available!", preferredStyle: UIAlertController.Style.alert)
                        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                        alert.addAction(ok)
                        if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                            mainVC.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    if game.numSequentialPlaysWithNoTilesUsed == 2 {
                        let alert = UIAlertController(title:"Warning!", message: "If you exchange tiles and your opponent ends their turn without playing a tile the game will end!", preferredStyle: UIAlertController.Style.alert)
                                             let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                                             alert.addAction(ok)
                                             if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                                                 mainVC.present(alert, animated: true, completion: nil)
                                             }
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
                    let exchangeAlertOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:
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
                        //NEW: changing exchange turn to equal a passed turn
                        self.game.currentTurnPassed = true
                        
                        
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
                    
                    let alertCon = UIAlertController(title: nil, message: "Exchange tiles and lose your turn?", preferredStyle: UIAlertController.Style.alert)
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
                
                var msg: String
                if game.numSequentialPlaysWithNoTilesUsed == 2 {
                    msg = "Warning: If you end your turn and your opponent ends their turn without playing a tile the game will end! Do you still want to end your turn?"
                }
               else if game.numSequentialPlaysWithNoTilesUsed == 3 {
                    msg = "Warning: ending your turn will mark 2 consecutive rounds of turns with no tiles played and end the game!. Do you still want to end your turn?"
                }
                else {
                    msg = "End your turn?"
                }
              
                    
                let endTurnAlert = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertController.Style.alert)
                    let endTurnConfirm = UIAlertAction(title: "End Turn", style: .default, handler: { (okAction) in
                        
                      
                       
                        self.endOfTurn = true
                        
                        if self.selectedPlayerTiles.count > 0 {
                            print("recalling selected player tiles after end of turn hit.")
                            self.gameBoard!.showTiles(tiles: self.selectedPlayerTiles, message: "selected tiles to remove before exiting game:")
                            self.recall()
                        }
                        self.tilesBombedThisTurn.removeAll()
                        self.switchPlayers()
                        
                    })
                let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
                    
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
                
                        if targetTile.name == GameConstants.TileBoardTileName  && targetTile.tileIsEmpty && selectedTile.tileType != .eraser
                        && selectedTile.tileType != .bomb {
                            print("selected tile is on board and about to set row/col as \(targetTile.row) and \(targetTile.col)")
                            /** play sound **/
                            
                        
                            if playSound { run(SKAction.playSoundFileNamed("clickSound.wav", waitForCompletion: false))
                            }
                           
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
                            
                            
                            
                            
                        else if targetTile.name == GameConstants.TileBoardTileName && targetTile.tileIsEmpty &&
                            selectedTile.tileType == .eraser {
                            print("moving tile \(selectedTile.tileType) back to rack, empty position on board")
                            returnTileToRack(tile: selectedTile)
                        }
                            
                        
                        else if targetTile.name == GameConstants.TileBoardTileName && !targetTile.tileIsEmpty && selectedTile.tileType == .eraser
                            && !targetTile.inSelectedPlayerTiles /*&& !gameBoard!.startingTiles.contains(targetTile)*/
                            && !targetTile.tileInStartingTiles()
                        
                        {
                            
                       
                            selectedTileOnBoard = true
                            selectedTile.row = targetTile.row
                            selectedTile.col  = targetTile.col
                            disableGame = true
                            let fade = SKAction.fadeOut(withDuration: 0.5)
                            let playEraserSound1 = SKAction.playSoundFileNamed("EraserSound1.wav", waitForCompletion: false)
                            
                            var fadeWithSound: SKAction
                            if playSound {
                                fadeWithSound = SKAction.group([fade,playEraserSound1])
                            }
                            else {
                                fadeWithSound = fade
                            }
                            selectedTile.run(fadeWithSound){
                                self.disableGame = false
                            }
                            
                            
                           //selectedTile.isHidden = true
                            if targetTile.getTileValue() != nil {
                                
                            targetTile.setHoldingValues()
                                
                                
                                print("set target tile holding val to: \(targetTile.holdingValue), holding PLAYER to \(targetTile.holdingPlayer) ,and holding color to: \(targetTile.holdingColor)")
                            }
                            targetTile.setTileValue(value: nil)
                            targetTile.color = GameConstants.TileBoardTileColor
                            targetTile.player = nil
                            targetTile.inSelectedPlayerTiles = true
                            targetTile.rackPosition = selectedTile.rackPosition
                        
                                                       
                        }
                        
                        
                        else if targetTile.name == GameConstants.TileBoardTileName &&
                            selectedTile.tileType == .bomb {
                           print("checking if bomb tile has anything to delete...")
                            if !gameBoard.boxTilesHaveNonStarterValuedTiles(withCenterTile: targetTile)
                              || bombAreaContainsAnySelectedPlayerTiles(bombTile: targetTile)
                               /* || gameBoard.getTile(atRow: targetTile.row, andCol: targetTile.col).starterTile */
                            {
                                
                                returnTileToRack(tile: selectedTile)
                            }
                            else {
                                selectedTileOnBoard = true
                                selectedTile.row = targetTile.row
                                selectedTile.col  = targetTile.col
                                disableGame = true
                                let fade = SKAction.fadeOut(withDuration: 0.5)
                                let changeToRed = SKAction.colorize(with: .red, colorBlendFactor: 0.0 , duration: 0.2)
                                let playBombSound = SKAction.playSoundFileNamed("bomb.mp3", waitForCompletion: false)
                                
                                var fadeWithSound: SKAction
                                if playSound {
                                    fadeWithSound = SKAction.group([fade,playBombSound])
                                }
                                else {
                                    fadeWithSound = fade
                                }
                                selectedTile.run(fadeWithSound){
                                    self.disableGame = false
                                   
                                }
                                
                                targetTile.inSelectedPlayerTiles = true
                                for t in gameBoard.getBoxofTiles(withCenterTile: targetTile) where !t.starterTile{
                                    if t.getTileValue() != nil {
                                     t.setHoldingValues()
                                     bombedValuedTilesToRestore.append(t)
                                    }
                                    if !(t.tileLabel.text  == GameConstants.TileBonusTileText) {
                                        t.setTileValue(value: nil)
                                    }
                                    t.color = GameConstants.TileBoardTileColor
                                    t.player = 0
                                    //t.inSelectedPlayerTiles = true
                                    tilesBombedThisTurn.append(t)
                                    
                                }
                                
                          
                            }
                            
                            
                            
                        }
                    }
                    
                }
                
                if !selectedTileOnBoard {
                    //showSelectedTiles()
                    returnTileToRack(tile: selectedTile)
                    print("there are: \(selectedPlayerTiles.count) selected player tiles....")
                    anySelectedTilesOnBoard = selectedPlayerTiles.count > 0
                }
                else {
                    anySelectedTilesOnBoard = true
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
    

    
        func bombAreaContainsAnySelectedPlayerTiles(bombTile: Tile) -> Bool {
    
            print("target tile select tiles count = \(targetTileSelectedPlayerTiles.count)")
            
         let selectedTilesBombed = gameBoard.getBoxofTiles(withCenterTile: bombTile).filter { targetTileSelectedPlayerTiles.contains($0)
          
            }
            
            print("Selected tiles bombed count = \(selectedTilesBombed.count)")
            for tile in selectedTilesBombed {
                print("selected tile bombed... row/col val = \(tile.row) \(tile.col) \(tile.getTileTextRepresentation())")
            }
            return selectedTilesBombed.count > 0

        
        }

    func bombAreaContainsTile(bombTile: Tile, tile: Tile) -> Bool {
        print("Checking if bomb area contains tile. bombTile row/col =  \(bombTile.row),\(bombTile.col) and tile row, col = \(tile.row), \(tile.col)")
        return  tile.row <= bombTile.row + 1 && tile.row >= bombTile.row - 1
        && tile.col <= bombTile.col + 1 && tile.col >= bombTile.col - 1
    }
    
 
    func tilePlaysOverBombedAreaInSamePlay(tile: Tile) -> Bool {
        guard selectedPlayerTiles.filter({$0.row == tile.row && $0.col == tile.col}).count > 0  else {
            print("tile not in selected player tiles in tilePlaysOverBombedAreaInSamePlay")
            return false
        }
        for bombTile in selectedPlayerTiles.filter({$0.tileType == .bomb}) {
            print("Checking if bombtile \(bombTile) contains touched tile \(tile)")
            if bombAreaContainsTile(bombTile: bombTile, tile: tile) {
                return true
            }
        }
        
        return false
    }
    
    func tilePlaysOverBombedAreaThisTurn(tile: Tile) -> Bool {
        return tilesBombedThisTurn.filter({ (t) -> Bool in
            t.row == tile.row && t.col == tile.col
        }).count > 0
    }

    func tilePlaysOverDeleteTileInSelectedPlayerTiles(tile: Tile) -> Bool {
        guard tile.tileType != .eraser else {
            return false
        }
        return selectedPlayerTiles.filter({ (t) -> Bool in
            t.row == tile.row && t.col == tile.col && t.tileType == .eraser
        }).count > 0
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            self.bingoLabel.isHidden = false
            self.bingoLabel.zPosition = self.gameBoardDisplay.zPosition + 1000
            let moveBingoLabel: SKAction = SKAction.moveBy(x: 0, y: self.frame.height/2 - self.bingoLabel.frame.size.height, duration: 2.0)
            let fade = SKAction.fadeOut(withDuration: 4.0)
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
    
    func updateBoxLocs(completion: (()->())?){
        for boxLoc in game.boxLocs {
            print("checking if game has any box locs in updateBoxLocs...")
            for bL in boxesViewedThisTurn {
              print("in update box locs..there were box(es) viewed this turn, so accounting for that!")
                if bL.boxID == boxLoc.boxID {
                    boxLoc.newBox = false
                    if currentUserPlayer.player1 {
                        boxLoc.player1Viewed = true
                    }
                    else {
                        boxLoc.player2Viewed = true
                    }
                    break
                }
            }
        }
        
        game.showBoxLocs()
        boxBonusViewedThisTurn = false
        if completion != nil {
            completion!()
        }
    }
    
    func switchPlayers() {
        
        if game.currentTurnPassed {
            game.numSequentialPlaysWithNoTilesUsed += 1
        }
        else {
            game.numSequentialPlaysWithNoTilesUsed = 0
        }
        
        print("in switch players, num turns with no tiles used: \(game.numSequentialPlaysWithNoTilesUsed)")
        
        let gameOver = /*(game.lastTurnPassed && game.currentTurnPassed && tilesLeft == 0) */
            game.numSequentialPlaysWithNoTilesUsed == 4
            || (currentPlayerTileRack.playerTiles.count == 0 && tilesLeft == 0)
        
        refillTileRack()
        
        switchedPlayers = true
       
        
        playBtnPushed = false
        if /*game.currentTurnPassed */ game.selectedPlayerTiles.count ==  0 {
           game.lastScoreIncrement = 0
        }
        game.currentPlayerID = player1.userID == currentPlayer.userID ? player2.userID : player1.userID
        
        
        //game.selectedPlayerTiles.removeAll()
        
        if gameOver || game.gameOver {
            game.gameOver = true
            game.currentTurnPassed = true
            print("GAME OVER from switch players")
            if (game.lastTurnPassed && game.currentTurnPassed) {
                print("Game over because player passed turn and previous player passed turn")
            }
         //   presentGameOverPanel()
            ignoreGameOver = false
            
           // Fire.dataService.updateStatsAndRemoveGame(game: game)
            
              Fire.dataService.saveGameData1(game: self.game, savePlays: currentPlayer.plays.count > 0 , completion: nil)
    }
     
        else {
            game.gameOver = false
            game.tilesLeft = tilesLeft
            game.lastTurnPassed = game.currentTurnPassed
            game.currentTurnPassed = true
            game.lastUpdated =  Int(NSDate().timeIntervalSince1970)
            print("about to disable game in switch players, game over false.")
            disableGame = true
            updateBoxLocs(completion: nil)
            Fire.dataService.saveGameData1(game: self.game, savePlays: currentPlayer.plays.count > 0 , completion: nil)
        }
 
        selectedPlayerTiles.removeAll()
        
        tilesUsedThisTurn.removeAll()
        selectedPlayerTile = nil
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
        
    
        for tile in selectedPlayerTiles where tile.tileType != .eraser && tile.tileType != .bomb {
            nonDeleteSelectedPlayerTiles.append(tile)
            print("In play1: selected tile that is not eraser--value= \(tile.getTileTextRepresentation()) row/col: \(tile.row), \(tile.col)")
        }
        
        
        
        let legalMove =  checkIfLegalMove()
        
        
        // if so, set values on board and remove tiles, if not alert user and return tiles
        // replace player tiles that were played
        

        if legalMove {
          
           game.currentTurnPassed = false
            game.numSequentialPlaysWithNoTilesUsed = 0
           bombedValuedTilesToRestore.removeAll()
            
            for tile in selectedPlayerTiles {
                
                let row = tile.row
                let col = tile.col
                let gameBoardTile = gameBoard!.getTile(atRow: row, andCol: col)
                
                
                gameBoardTile.inSelectedPlayerTiles = false
                anySelectedTilesOnBoard = false
                if  !gameBoardTile.starterTile && (tile.tileType == TileType.eraser || tile.tileType == .bomb) {
                    
                    print("changing tile to white after bomb: row=\(gameBoardTile.row), col=\(gameBoardTile.col)")
                        gameBoardTile.color = .white
                          tile.holdingValue = gameBoardTile.holdingValue
                    tile.holdingPlayer = gameBoardTile.holdingPlayer
                   
                }
                 
                
            }
            game.selectedPlayerTiles = selectedPlayerTiles
           
          
          
           
         //   showSelectedTiles()
            
            currentPlayerTileRack.removeTilesFromRack(tiles: selectedPlayerTiles)
        
            if !game.singlePlayerMode {
                calculateScore()
                var boxCount = 0
                var newBoxLocs = [BoxLoc]()
                let boxes =  gameBoard.getBoxLocsForTiles(tiles: nonDeleteSelectedPlayerTiles)
                if boxes.count > 0 {
                    print("Boxes found this turn: \(boxes.count)")
                    for box in boxes {
                        if game.boxLocIsNew(bL: box){
                            print("Got a new box at row:\(box.row), col:\(box.col)")
                            boxCount += 1
                            game.boxLocs.append(box)
                            newBoxLocs.append(box)
                            
                            currentPlayer.score += GameConstants.BoxBonus
                            game.lastScoreIncrement += GameConstants.BoxBonus
                            print("After new box bonus in play1() and having added box bonus to score, score is now: \(currentPlayer.score)")
                           
                        }
                        else {
                            print("already have a box at row:\(box.row), col:\(box.col). not adding")
                        }
                    }
                }
              
               currentPlayer.plays.removeAll()
                for (n,tile) in selectedPlayerTiles.enumerated() {
                    tile.tileOrderInPlay = n
                }
                let pts = game.lastScoreIncrement - boxCount*GameConstants.BoxBonus
                print("points for turn with \(boxCount) boxes: \(pts)")
                currentPlayer.plays.append(Play(playTiles: selectedPlayerTiles, points: pts, boxLocs: newBoxLocs))
                
                game.lastPlayerToMove = currentPlayerN
             
                if currentPlayer.tileRack.playerTiles.count == 0 && game.currentTurnPassed == false {
                    print("in play1: player used all tiles...switching players")
                    print("in play1, before switching players, incremented score. player score is now: \(currentPlayer.score)")
                    game.lastPlayerUsedAllTiles = true
                    wildCardValueSet = false
                    game.lastScoreIncrement += GameConstants.BingoPoints
                    currentPlayer.score += GameConstants.BingoPoints
                    switchPlayers()
                }
                else {
                    game.lastPlayerUsedAllTiles = false
                    Fire.dataService.saveGameData1(game: game,savePlays: true, completion: nil)
                }
            }
            
            if game.singlePlayerMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.replaceTiles(tilesToReplace: copySelectedPlayerTiles)
                }
                for tile in selectedPlayerTiles {
                    let gb =  gameBoard.getTile(atRow: tile.row, andCol: tile.col)
                    gb.removeHoldingValuesAfterRestoring()
                }
                legalPlaysThisTurn.removeAll()
            }
            
            removeSelectedPlayerTiles()
        }
            
        else {
            print(" NOT A LEGAL MOVE !!!!!")
            anySelectedTilesOnBoard = false
            legalPlaysThisTurn.removeAll()
            
            if playSound {run(SKAction.playSoundFileNamed("IllegalPlay.wav", waitForCompletion: false))}
            
            if badMathTiles.count > 0 {
            
                print("badmathtiles count = \(badMathTiles.count)")
                for tile in badMathTiles {
                    
                    print("tile value in bad tiles: \(tile.tileValue) row:\(tile.row), col:\(tile.col) tile type:\(tile.name)")
                    tile.tileLabel.fontColor = .red
                   
                }
    
             
             presentErrorMessageView()
                
            }
            else {
             // handleRestoringTilesAfterIllegalMove()
                recall()
                        nonDeleteSelectedPlayerTiles.removeAll()
                       removeSelectedPlayerTiles()
                        bonusTilesUsed.removeAll()
            }

        }

    }
    
    func handleRestoringTilesAfterIllegalMove(){
        
        for tile in selectedPlayerTiles {
            
            //var deleteTileHere = false
            tile.isHidden = false
            tile.alpha = 1.0
            let row = tile.row
            let col = tile.col
            
            
            if tile.isTileOnBoard() {
                
                print("tile on board after illegal move: \(tile.getTileTextRepresentation()) row: \(tile.row) col:\(tile.col) starting position: \(tile.startingPosition)")
                
                let gameBoardTile = gameBoard?.getTile(atRow: row, andCol: col)
                
                
                if !tilePlaysOverBombedAreaThisTurn(tile: tile), let holdVal = gameBoardTile!.holdingValue, let holdPlayer = gameBoardTile!.holdingPlayer /*,let holdCol = gameBoardTile!.holdingColor */{
                    
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
        for tile in selectedPlayerTiles where tile.tileType != TileType.eraser && tile.tileType != .bomb{
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
   
            }
            
       
          
            lightUpPlayedTiles {
                (tiles) in
                
                for tile in tiles {
                    tile.color = currentPlayerN == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                }
            
            }
            

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.replaceTiles(tilesToReplace: copySelectedPlayerTiles)
                }
              
              legalPlaysThisTurn.removeAll()
            
            
            self.selectedPlayerTiles.removeAll()
        }
        
        else {
                
                anySelectedTilesOnBoard = false
                
                if playSound {run(SKAction.playSoundFileNamed("IllegalPlay.wav", waitForCompletion: false))}
                
                if badMathTiles.count > 0 {
                
                    print("badmathtiles count = \(badMathTiles.count)")
                    for tile in badMathTiles {
                        
                        print("tile value in bad tiles: \(tile.tileValue) row:\(tile.row), col:\(tile.col) tile type:\(tile.name)")
                        tile.tileLabel.fontColor = .red
                       
                    }
        
                 
                 presentErrorMessageView()
                    
                }
                else {
                 // handleRestoringTilesAfterIllegalMove()
                    recall()
                            nonDeleteSelectedPlayerTiles.removeAll()
                           removeSelectedPlayerTiles()
                            bonusTilesUsed.removeAll()
                }

            }
        for tile in copySelectedPlayerTiles {
            if tile.tileType == .bomb || tile.tileType == .eraser {
                let gbT = gameBoard.getTile(atRow: tile.row, andCol: tile.col)
                   gbT.removeHoldingValuesAfterRestoring()
                   if tile.tileType == .bomb {
                   for bt in gameBoard.getBoxofTiles(withCenterTile: tile){
                                   bt.removeHoldingValuesAfterRestoring()
                     }
                    }
        }
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
        let playValidMove =  SKAction.playSoundFileNamed("success1.wav", waitForCompletion: false)
        let changeVolume = SKAction.changeVolume(to: 2, duration: 0.0)
        let changeToYellowAndPlaySound = SKAction.group([changeToYellow, playValidMove,changeVolume])
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

    func lightUpBoxTiles(tiles: [Tile], colorToUseInLightUp: UIColor = .yellow, pointsToShow: Int,completion: (()->())?){
        
       
        print("in light up box tiles...about to convert non delete selected tiles to board tiles")
        
        
        let expandTile = SKAction.scale(by: 1.2, duration: 0.1)
        let changeToColor = SKAction.colorize(with: colorToUseInLightUp, colorBlendFactor: 0.0 , duration: 0.3)
       
        let playBoxBonus =  SKAction.playSoundFileNamed("BoxBonus.mp3", waitForCompletion: false)
        
        var changeToColorAndPlaySound: SKAction
        if playSound {
            changeToColorAndPlaySound = SKAction.group([changeToColor, playBoxBonus])
            
        }
        else {
            changeToColorAndPlaySound = changeToColor
        }
        
        
         let shrinkTile = SKAction.scale(by: 1/1.2, duration: 0.6)
        let wait = SKAction.wait(forDuration: 0.3)
        //  let changeToYellowAndPlaySound = SKAction.group([changeToYellow,playValidMove])
    
       
        for  (i,tile) in tiles.enumerated() {
            var color: UIColor
           
            if tile.player == 1 {
                color =  GameConstants.TilePlayer1TileColor
            }
            else if tile.player == 2 {
                color =  GameConstants.TilePlayer2TileColor
            }
            
            else if tile.tileValue != nil {
                color = .lightGray
            }
            
            else {
                color = .white
            }
            
            let changeBack = SKAction.colorize(with: color, colorBlendFactor: 0.0, duration: 1.5)
            let seq = SKAction.sequence([ wait, shrinkTile, changeBack])
            tile.run(expandTile)
            tile.zPosition = 4
            
    
            tile.run(changeToColorAndPlaySound){
                //self.playValidMoveAudioNode.run(playValidMoveQuiet)
                
                tile.run(seq){
                    
                    tile.zPosition = 2
                    
                    if i == tiles.count - 1 {
                     //   var loc = tiles[i].position
                        
                        
                       // loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                        
                        // self.showPoints(atLocation: loc, points: points)
                      
                        self.showPoints(atLocation: CGPoint(x: 0, y: 0), points: pointsToShow, color:  .green)
                        
                        self.selectedPlayerTiles.removeAll()
                    }
                }
            }
            
            
        }
        if completion != nil {
        completion!()
        }
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
        let playValidMove =  SKAction.playSoundFileNamed("success1.wav", waitForCompletion: false)
        
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

    func lightUpPlays(plays: [Play], completion: (() -> ())?){
        
        print("in light up plays for \(String(describing: self.currentUserPlayer.userName)) with \(plays.count) plays.")
        
     
      
        guard plays.count > 0 else {
           
            print("No plays, returning from light up plays")
            return
        }
    
        
       
        var color: SKColor = SKColor()
        color = getPlayerToUseInLoadGameClosure().player1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
        
    
        // let gameBoardTiles = convertSelectedPlayerTilesIntoBoardTiles()
        // do eraser tiles first in sort, so that the rest of closure below runs
        
        
        let expandTile = SKAction.scale(by: 1.2, duration: 0.2)
        let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 0.0 , duration: 0.1)
        let changeBack = SKAction.colorize(with: color, colorBlendFactor: 0.0, duration: 0.1)
        let playValidMove = SKAction.playSoundFileNamed("success1.wav", waitForCompletion: false)
        
        let shrinkTile = SKAction.scale(by: 1/1.2, duration: 1.0)
        let wait = SKAction.wait(forDuration: 0.5)
        
        let seq = SKAction.sequence([ wait, shrinkTile, changeBack])
        var changeToYellowAndPlaySound: SKAction
        if playSound {
            changeToYellowAndPlaySound = SKAction.group([changeToYellow,playValidMove])
            
        }
        else {
            changeToYellowAndPlaySound = changeToYellow
        }
        
        let fadeToWhite = SKAction.colorize(with: GameConstants.TileBoardTileColor, colorBlendFactor: 0.0, duration: 0.3)
        
        
        var nBonusTilesUsed: Int = 0
        
        
        for play in plays.filter({!self.playsSeen.contains($0.playID)})  {
          
            
            
           
          
            var orderedTiles = orderTilesWithEraserTilesFirst(tiles: play.playTiles)
            for  (i,tile) in orderedTiles.enumerated() {
                
                
                let gameBoardTile = self.game.board.getTile(atRow: tile.row, andCol: tile.col)
                if tile.tileType == .eraser  {
                    print("eraser tile found, moving on. light up tiles 1")
                    
                    if game.lastPlayerToMove != (currentUserPlayer.player1 == true ? 1 : 2) {
                        
                        gameBoardTile.run(fadeToWhite)
                        if playSound  {
                            gameBoardTile.run(SKAction.playSoundFileNamed("EraserSound1.wav", waitForCompletion: false))
                        }
                        
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
                            
                            let points = play.points
                            
                            print("points to show is \(points)")
                            self.showPoints(atLocation: loc, points: points, color:  color)
                            
                            
                            
                        }
                    }
                }
                
                
            }
          
            playsSeen.append(play.playID)
            
            
         
        }
        if game.lastPlayerUsedAllTiles {
            print("after showing plays in light up plays, BINGO, so going to showBingo()")
            self.showBingo()
        }
        
    self.currentUserPlayer.plays.removeAll()
 
        if  completion != nil {
            completion!()
        }
    }
   
   
    
    func tileErasesTileInOtherPlay(tile: Tile, plays: [Play]) -> Bool {
        guard tile.tileType == .eraser || tile.tileType == .bomb else {
            return false
        }
        for play in plays {
            for playTile in play.playTiles {
                if playTile != tile && playTile.tileType != .eraser && playTile.tileType != .bomb && tile.row == playTile.row && tile.col == playTile.col {
                    return true
                }
            }
        }
        return false
    }

    
    func runBoxBonusAnimation(play: Play){
        print("in runBoxBonusAnimation")
        if play.boxLocs.count > 0 {
            print("play \(play.playID) has boxes")
                                        print("play \(play.playID) has box loc! current user is player \(self.currentUserPlayer.playerN) player 1 viewed: \(play.boxLocs[0].player1Viewed) player 2 viewed: \(play.boxLocs[0].player2Viewed)")
                                        let newBoxLocs = self.game.boxLocs.filter{self.currentUserPlayer.player1 ? !$0.player1Viewed : !$0.player2Viewed}
                                            
            print("new box locs after filtered to unviewed has \(newBoxLocs.count). about to set boxBonusViewedThisTurn to true")
                                        
                                    
                                        self.boxBonusViewedThisTurn = true
                                   
                                        for newBox in newBoxLocs where !self.boxesViewedThisTurn.contains(where: {$0.boxID == newBox.boxID}) && play.boxLocs.filter({$0.row == newBox.row && $0.col == newBox.col}).count == 1  {
        
                        
                           self.lightUpBoxTiles(tiles:self.getTilesInBox(withCenterLoc: newBox), colorToUseInLightUp: .green, pointsToShow: GameConstants.BoxBonus){
                               self.boxesViewedThisTurn.append(newBox)
                           
                           }
                       }
                                    }
    }
    
    func lightUpPlaysInSequence(plays: [Play], completion: (() -> ())?){
        
       
        print("in light up plays in seq for \(String(describing: self.currentUserPlayer.userName)) with \(plays.count) plays.")
        
        
        
        guard plays.filter({!self.playsSeen.contains($0.playID)}).count > 0 else {
            
            print("No plays to see, returning from light up plays")
            return
        }
        
        if currentUserIsCurrentPlayer {
            disableGame = true
        }
        
        
        
        var color: SKColor = SKColor()
        color = getPlayerToUseInLoadGameClosure().player1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
        //the color associated with the last player to move
        
        
        
        // let gameBoardTiles = convertSelectedPlayerTilesIntoBoardTiles()
        // do eraser tiles first in sort, so that the rest of closure below runs
        
        
        
        let expandTile = SKAction.scale(by: 1.2, duration: 0.2)
        let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 0.0 , duration: 0.1)
        let changeToRed = SKAction.colorize(with: .red, colorBlendFactor: 0.0 , duration: 0.2)
        let changeBack = SKAction.colorize(with: color, colorBlendFactor: 0.0, duration: 0.1)
        let playValidMove =  SKAction.playSoundFileNamed("success1.wav", waitForCompletion: false)
        
        let shrinkTile = SKAction.scale(by: 1/1.2, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.5)
        
       // let seq = SKAction.sequence([ wait, shrinkTile, changeBack])
        var changeToYellowAndPlaySound: SKAction
        if playSound {
            changeToYellowAndPlaySound = SKAction.group([expandTile, changeToYellow,playValidMove])
            
        }
        else {
             changeToYellowAndPlaySound = SKAction.group([expandTile, changeToYellow])
        }
        let fadeToWhite = SKAction.colorize(with: GameConstants.TileBoardTileColor, colorBlendFactor: 0.0, duration: 0.1)
        
       
        let lightUpTileSeq = SKAction.sequence([changeToYellowAndPlaySound, wait, shrinkTile ])
        
        var nBonusTilesUsed: Int = 0
        
        var allPlayTileActions = [SKAction]()
        allPlayTileActions.removeAll()
        
        let playsSortedByDate = plays.sorted { (play1, play2) -> Bool in
            play1.playCreatedDate < play2.playCreatedDate
        }
        if game.lastPlayerToMove != (currentUserPlayer.player1 == true ? 1 : 2) {
            revertBoardToStateBeforePlays(plays: plays, board: gameBoard)
        }
   
        //loop through plays in the order they were created, only viewing the ones not seen
        for play in playsSortedByDate.filter({!self.playsSeen.contains($0.playID)})  {
        
                      
            
            print("play created date: \(play.playCreatedDate)")
            var playTileActions = [SKAction]()
            var tileAction = SKAction()
           // var orderedTiles = orderTilesWithEraserTilesFirst(tiles: play.playTiles)
            
       
            
            let playTilesSorted = play.playTiles.sorted { (t1, t2) -> Bool in
                t1.tileOrderInPlay! < t2.tileOrderInPlay!
            }
            
            for  (i,tile) in playTilesSorted.enumerated()  {
               
                tile.showTile(msg: "showing tile in playtilesSorted...")
                
                let gameBoardTile = self.gameBoard.getTile(atRow: tile.row, andCol: tile.col)
                   let currentGameBoardTileValue = gameBoardTile.tileValue
                   let currentGameBoardTilePlayer = gameBoardTile.player
               
                //IF PLAYED TILE IS ERASER...
                
                if tile.tileType == .eraser {
                    print("eraser tile found, light up plays in sequence")
                
                   if game.lastPlayerToMove != (currentUserPlayer.player1 == true ? 1 : 2) {
//
//
//                    if let holdVal = tile.holdingValue, let holdingPlayer = tile.holdingPlayer {
//                        print("in light plays, eraser tile,setting gameboard tile to have holding val: \(holdVal) and color: \(holdingPlayer == 1 ? "blue" : "green" ) and original tile value is \(currentGameBoardTileValue)")
//
//
//                        gameBoardTile.tileLabel.text = "\(holdVal)"
//
//                       if !tileErasesTileInOtherPlay(tile: tile, plays: plays){
//
//                        gameBoardTile.color = holdingPlayer == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
//                        }
//                        else {
//                            gameBoardTile.color = GameConstants.TileBoardTileColor
//                        }
//
//
//                    }
//                    else {
//                    print("can't get hold val for eraser tile in light up plays")
//                    }
                    
                    
                    //tile action will be to show the erasing of the tile
                     tileAction = SKAction.run {
                        var eraserBit:SKAction
                        if self.playSound {
                            print("SOUND IS ON IN CLOSURE OF PLAY TILES IN SEQ")
                            eraserBit = SKAction.group([fadeToWhite,SKAction.playSoundFileNamed("EraserSound1.wav", waitForCompletion: false) ])
                            
                        }
                        else {
                            eraserBit = fadeToWhite
                        }
                    gameBoardTile.run(eraserBit){
                            print("setting tile to final value after erasing, which is currentGameBoardValue: \(currentGameBoardTileValue)")
                        //gameBoardTile.setTileValue(value: currentGameBoardTileValue)
                        
                        var overwritten = false
                        var overwrittenTileLblText = ""
                        for pT in playTilesSorted where pT.tileType != .eraser && pT.tileType != .bomb {
                            if pT.row == tile.row && pT.col == tile.col {
                                overwritten = true
                                overwrittenTileLblText = pT.tileLabel.text!
                                print("tile was overwritten by \(pT.tileLabel) at row, col: \(pT.row),\(pT.col)")
                                break
                            }
                        }
                         gameBoardTile.tileLabel.text = overwritten ? "\(overwrittenTileLblText)"
                            : ""
                     
                        gameBoardTile.resetHoldingValues()
                         
                        }
   
                        
                        if i == play.playTiles.count - 1 && play.points > 0 {
                            print("about to show points because we're on the last tile in the play")
                            var loc = gameBoardTile.position
                            loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                            // self.showPoints(atLocation: loc, points: points)
                            
                            let points = play.points
                            
                            self.showPoints(atLocation: loc, points: points, color:  color)
                         
                           
                            
                        } else if i == play.playTiles.count - 1 {
                            print("Not showing points because play.points = \(play.points)")
                        }
                        self.runBoxBonusAnimation(play: play)
                                              
                        }
                   
                       
                  
                        
                   }
                
                   else {
                       
                        tileAction  = SKAction.run{
                            if i == play.playTiles.count - 1 && play.points > 0 {
                                print("about to show points, on last tile in play")
                                var loc = gameBoardTile.position
                                
                                
                                
                                // loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                                if gameBoardTile.col == GameConstants.BoardNumCols {
                                    loc.x = gameBoardTile.position.x - gameBoardTile.size.width
                                }
                                else if gameBoardTile.col == 0 {
                                    loc.x = gameBoardTile.position.x + gameBoardTile.size.width
                                }
                               
                                let bonusPoints = play.getPointsFromBonusTiles()
                                let points = play.points - bonusPoints
                                
                                self.showPoints(atLocation: loc, points: points, color:  color)
                                if bonusPoints > 0 {
                                    var loc1 = CGPoint()
                                    
                                    if loc.x - 100 < self.gameBoardDisplay.frame.minX {
                                        loc1.x = loc.x + 100
                                    }
                                    else {
                                        loc1.x = loc.x - 100
                                    }
                                    loc1.y = loc.y
                                    
                                    self.showPoints(atLocation: loc1, points: bonusPoints, color: .gray)
                                }
                                
                                
                            }
                            
                           
                        }
                 self.runBoxBonusAnimation(play: play)
                    }
                   
                   
                    playTileActions.append(tileAction)
                   // continue
                }
                else if tile.tileType == .bomb {
                    print("bomb tile found, light up plays in sequence and index \(i) in plays")
                    //HANDLE BOMB ANIMATION FOR PLAYER THAT DID NOT MAKE THE PLAY
                    if game.lastPlayerToMove != (currentUserPlayer.player1 == true ? 1 : 2) {
           
                        tileAction = SKAction.run {
                            var bombBit:SKAction
                            if self.playSound {
                                print("SOUND IS ON IN CLOSURE OF PLAY TILES IN SEQ..")
                                bombBit = SKAction.group([changeToRed, fadeToWhite,SKAction.playSoundFileNamed("bomb.mp3", waitForCompletion: false) ])
                                
                            }
                            else {
                                bombBit = SKAction.group([changeToRed, fadeToWhite])
                            }
                            for (gNum,gTile) in self.gameBoard.getBoxofTiles(withCenterTile: tile).enumerated() where !gTile.starterTile {
                                
                                print("running bomb animation in lightUpPlaysInSequence for tile at row: \(gTile.row), col:\(gTile.col)")
                                    gTile.run(bombBit){
                                 
                                        
                                       var overwritten = false
                                        
                                        for t in playTilesSorted  where t.tileType != .bomb && t.tileType != .eraser {
                                            if t.row == gTile.row && t.col == gTile.col {
                                                print("tile at row, col \(t.row),\(t.col) w val \(t.tileValue) overwrites bombed area from bomb at \(tile.row)\(tile.col)" )
                                                overwritten = true
                                                break
                                            }
                                        }
//
//
                                        if !overwritten {
                                        print("bombed tile at row,col \(gTile.row),\(gTile.col) is NOT overwritten by other tile in play")
                                            if !(gTile.tileLabel.text == GameConstants.TileBonusTileText) {
                                                gTile.tileLabel.text = ""
                                            }
                                         gTile.color = GameConstants.TileBoardTileColor
                                        }
                                        else {
                                            print("tile at  row,col \(gTile.row),\(gTile.col) WAS bombed and later overwritten with value \(gTile.getTileTextRepresentation())")
                                        }
                                  
                                }
                                
                              
                                gTile.resetHoldingValues()
                            }
                            
                            
                            if i == play.playTiles.count - 1 && play.points > 0 {
                                print("about to show points because we're on the last tile in the play")
                                var loc = gameBoardTile.position
                                loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                                // self.showPoints(atLocation: loc, points: points)
                                
                                let points = play.points
                                
                                self.showPoints(atLocation: loc, points: points, color:  color)
                                
                                
                                
                                
                            } else if i == play.playTiles.count - 1 {
                                print("Not showing points because play.points = \(play.points)")
                            }
                           self.runBoxBonusAnimation(play: play)
                        }
                        
                        
                        
                        
                        
                    }
                        
                    else {
                        
                        tileAction  = SKAction.run{
                            if i == play.playTiles.count - 1 && play.points > 0 {
                                print("about to show points, on last tile in play")
                                var loc = gameBoardTile.position
                                
                                
                                
                                // loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                                if gameBoardTile.col == GameConstants.BoardNumCols {
                                    loc.x = gameBoardTile.position.x - gameBoardTile.size.width
                                }
                                else if gameBoardTile.col == 0 {
                                    loc.x = gameBoardTile.position.x + gameBoardTile.size.width
                                }
                                
                                let bonusPoints = play.getPointsFromBonusTiles()
                                let points = play.points - bonusPoints
                                
                                self.showPoints(atLocation: loc, points: points, color:  color)
                                if bonusPoints > 0 {
                                    var loc1 = CGPoint()
                                    /*
                                    if loc.x - 100 < self.gameBoardDisplay.frame.minX {
                                        loc1.x = loc.x + 100
                                    }
                                    else {
                                        loc1.x = loc.x - 100
                                    }
                                    loc1.y = loc.y
                                    */
                                    loc1.x = loc.x
                                    loc1.y = loc.y - 400
                                    self.showPoints(atLocation: loc1, points: bonusPoints, color: .gray)
                                }
                                
                                
                            }
                            self.runBoxBonusAnimation(play: play)
                        }
                        
                    }
                    
                   
                    
                    playTileActions.append(tileAction)
                    // continue
                }
                
                else {
                print("going past bomb/eraser bit in light up tiles. means we didn't just find eraser tile....")
//                gameBoardTile.run(expandTile)
//                gameBoardTile.zPosition = 4
//
            
                if game.lastPlayerToMove != (currentUserPlayer.player1 == true ? 1 : 2) {
                   // gameBoardTile.tileLabel.color = GameConstants.TileBoardTileColor
                  
            
                   // gameBoardTile.color = GameConstants.TileBoardTileColor
                   
                    
                    // gameBoardTile.setTileValue(value: tile.tileValue)
                //   gameBoardTile.tileLabel.text = "\(tile.tileValue!)"
                //    gameBoardTile.tileLabel.isHidden = true
                    
                }
                tileAction = SKAction.run{
                  //   gameBoardTile.tileLabel.isHidden = false
                   
                   gameBoardTile.tileLabel.text = "\(tile.tileValue!)"
                    print("setting tile to have tile value: \(tile.tileValue)")
                        gameBoardTile.run(lightUpTileSeq){
                            
                            var colorizeColor: UIColor
                            switch tile.player {
                            case 1 : colorizeColor = GameConstants.TilePlayer1TileColor
                            case 2: colorizeColor = GameConstants.TilePlayer2TileColor
                            default: colorizeColor = GameConstants.TileBoardTileColor
                            }
                            gameBoardTile.run(SKAction.colorize(with: colorizeColor, colorBlendFactor: 1.0, duration: 0.3))
                         
                            
                           
                            
                            if i == play.playTiles.count - 1 {
                                print("about to show points, on last tile in play")
                                var loc = gameBoardTile.position
                                
                                
                                
                               // loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                                if gameBoardTile.col == GameConstants.BoardNumCols {
                                    loc.x = gameBoardTile.position.x - gameBoardTile.size.width
                                }
                                else if gameBoardTile.col == 0 {
                                    loc.x = gameBoardTile.position.x + gameBoardTile.size.width
                                }
                                // self.showPoints(atLocation: loc, points: points)
                                
                                
//
//                                let newBoxLocs = self.game.boxLocs.filter{self.currentUserPlayer.player1 ? !$0.player1Viewed: !$0.player2Viewed}
//
//                                if newBoxLocs.count > 0 {
//                                let BLS =  self.gameBoard.getBoxLocsForTiles(tiles: play.playTiles)
//                                var excludeBoxes = [BoxLoc]()
//                                var nBoxes = 0
//                                for bL in BLS {
//                                    if bL.hasTheSameCenterAsAnyBox(inboxes: newBoxLocs)
//                                        && !bL.hasTheSameCenterAsAnyBox(inboxes: self.boxesViewedThisTurn)
//                                    && !bL.hasTheSameCenterAsAnyBox(inboxes: excludeBoxes){
//                                        nBoxes += 1
//                                        excludeBoxes.append(bL)
//                                    }
//
//                                }
//                                    points = play.points - 15*nBoxes
//                                }
//                                else {
//                                     points = play.points
//                                }

              /* try light up box tiles after play */
                                
                                if play.boxLocs.count > 0 {
                                    print("play \(play.playID) has box loc! current user is player \(self.currentUserPlayer.playerN) player 1 viewed: \(play.boxLocs[0].player1Viewed) player 2 viewed: \(play.boxLocs[0].player2Viewed)")
                                    let newBoxLocs = self.game.boxLocs.filter{self.currentUserPlayer.player1 ? !$0.player1Viewed : !$0.player2Viewed}
                                        
                                    print("new box locs after filtered to unviewed has \(newBoxLocs.count)")
                                    
                                    self.boxBonusViewedThisTurn = true
                               
                                    for newBox in newBoxLocs where !self.boxesViewedThisTurn.contains(where: {$0.boxID == newBox.boxID}) && play.boxLocs.filter({$0.row == newBox.row && $0.col == newBox.col}).count == 1  {
    
                    
                       self.lightUpBoxTiles(tiles:self.getTilesInBox(withCenterLoc: newBox), colorToUseInLightUp: .green, pointsToShow: GameConstants.BoxBonus){
                           self.boxesViewedThisTurn.append(newBox)
                       
                       }
                   }
                                }
                                
   
                            let bonusPoints = play.getPointsFromBonusTiles()
                            let points = play.points - bonusPoints
                              
                                self.showPoints(atLocation: loc, points: points, color:  color)
                                if bonusPoints > 0 {
                                    var loc1 = CGPoint()
                                    
                                    if loc.x - 100 < self.gameBoardDisplay.frame.minX {
                                        loc1.x = loc.x + 100
                                    }
                                    else {
                                        loc1.x = loc.x - 100
                                    }
                                    loc1.y = loc.y
                                    
                                    self.showPoints(atLocation: loc1, points: bonusPoints, color: .gray)
                                }
                                
                                
                            }
                            
                            
                       }
                    
                    
//                    if self.gameBoardTileIsBonusTile(tile: gameBoardTile){
//                        //currentPlayer.score += 2
//                        print("lightuptileseq closure, bonus tile!")
//                        nBonusTilesUsed += 1
//                        self.showPoints(atLocation: gameBoardTile.position, points: 2, color: .gray)
//
//
//                    }
                    
                }
                
                print("appending tile action for NON-eraser tile...")
                playTileActions.append(tileAction)
                
            }
            }
            print("after ordered tiles loop, appending all play tiled actions and appending to play seen")
            allPlayTileActions.append(SKAction.sequence([SKAction.group(playTileActions), SKAction.wait(forDuration: 2.0)]) )
            playsSeen.append(play.playID)
            
       
            
        }
    
        
        //allPlayTileActions.removeAll()
    
        self.run(SKAction.sequence(allPlayTileActions)){
        
            if self.game.lastPlayerUsedAllTiles {
                print("after showing plays in light up plays, BINGO, so going to showBingo()")
                self.showBingo()
            }
            /*
            let newBoxLocs = self.game.boxLocs.filter{self.currentUserPlayer.player1 ? !$0.player1Viewed : !$0.player2Viewed }
            if newBoxLocs.count > 0 {
                self.boxBonusViewedThisTurn = true
              
                for newBox in newBoxLocs where !self.boxesViewedThisTurn.contains(where: {$0.boxID == newBox.boxID}) {
                    self.lightUpBoxTiles(tiles:self.getTilesInBox(withCenterLoc: newBox), colorToUseInLightUp: .green, pointsToShow: GameConstants.BoxBonus){
                        self.boxesViewedThisTurn.append(newBox)
                    
                    }
                }
            
            } */
            
            
        
            if self.currentUserIsCurrentPlayer {
                self.disableGame = false
            }
            
            self.currentUserPlayer.plays.removeAll()
            
            if  completion != nil {
                
                completion!()
            }
        }
      
//        self.currentUserPlayer.plays.removeAll()
//
//        if  completion != nil {
//
//            completion!()
//        }
    }
    
    
    func lightUpPlaysInSequence1(plays: [Play], completion: (() -> ())?){
        
     
        guard plays.filter({!self.playsSeen.contains($0.playID)}).count > 0 else {
            
            print("No plays to see, returning from light up plays")
            return
        }
        
        if currentUserIsCurrentPlayer {
            disableGame = true
        }
        
        
        
        var color: SKColor = SKColor()
        color = getPlayerToUseInLoadGameClosure().player1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
        //the color associated with the last player to move
        
        
        
        // let gameBoardTiles = convertSelectedPlayerTilesIntoBoardTiles()
        // do eraser tiles first in sort, so that the rest of closure below runs
        
        
        let expandTile = SKAction.scale(by: 1.2, duration: 0.2)
        let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 0.0 , duration: 0.1)
        let changeBack = SKAction.colorize(with: color, colorBlendFactor: 0.0, duration: 0.1)
        let playValidMove =  SKAction.playSoundFileNamed("success1.wav", waitForCompletion: false)
        
        let shrinkTile = SKAction.scale(by: 1/1.2, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.5)
        
        // let seq = SKAction.sequence([ wait, shrinkTile, changeBack])
        var changeToYellowAndPlaySound: SKAction
        if playSound {
            changeToYellowAndPlaySound = SKAction.group([expandTile, changeToYellow,playValidMove])
            
        }
        else {
            changeToYellowAndPlaySound = SKAction.group([expandTile, changeToYellow])
        }
        let changeToRed = SKAction.colorize(with: .red, colorBlendFactor: 0.0, duration: 0.3)
        let fadeToWhite = SKAction.colorize(with: GameConstants.TileBoardTileColor, colorBlendFactor: 0.0, duration: 0.3)
        
        let lightUpTileSeq = SKAction.sequence([changeToYellowAndPlaySound, wait, shrinkTile ])
        
        var nBonusTilesUsed: Int = 0
        
        var allPlayTileActions = [SKAction]()
        allPlayTileActions.removeAll()
        
        let playsSortedByDate = plays.sorted { (play1, play2) -> Bool in
            play1.playCreatedDate < play2.playCreatedDate
        }
        if game.lastPlayerToMove != (currentUserPlayer.player1 == true ? 1 : 2) {
            revertBoardToStateBeforePlays(plays: plays, board: gameBoard)
        }
        
        //loop through plays in the order they were created, only viewing the ones not seen
        for play in playsSortedByDate.filter({!self.playsSeen.contains($0.playID)})  {
            
            print("play created date: \(play.playCreatedDate)")
            var playTileActions = [SKAction]()
            var tileAction = SKAction()
            // var orderedTiles = orderTilesWithEraserTilesFirst(tiles: play.playTiles)
            
            
            
            let playTilesSorted = play.playTiles.sorted { (t1, t2) -> Bool in
                t1.tileOrderInPlay! < t2.tileOrderInPlay!
            }
            
            for  (i,tile) in playTilesSorted.enumerated()  {
                
                tile.showTile(msg: "showing tile in playtilesSorted...")
                
                let gameBoardTile = self.gameBoard.getTile(atRow: tile.row, andCol: tile.col)
                let currentGameBoardTileValue = gameBoardTile.tileValue
                let currentGameBoardTilePlayer = gameBoardTile.player
                
                //IF PLAYED TILE IS ERASER...
                
                if tile.tileType == .eraser {
                    print("eraser tile found, light up plays in sequence")
                    if game.lastPlayerToMove != (currentUserPlayer.player1 == true ? 1 : 2) {
                    
                        //tile action will be to show the erasing of the tile
                        tileAction = SKAction.run {
                            var eraserBit:SKAction
                            
                            if self.playSound {
                                 eraserBit = SKAction.group([fadeToWhite,SKAction.playSoundFileNamed("EraserSound1.wav", waitForCompletion: false) ])
                                
                            }
                            else {
                                eraserBit = fadeToWhite
                            }
                            gameBoardTile.run(eraserBit){
                            
                                gameBoardTile.resetHoldingValues()
                                gameBoardTile.tileLabel.text = ""
                            }
                            
                            if i == play.playTiles.count - 1 && play.points > 0 {
                                print("about to show points because we're on the last tile in the play")
                                var loc = gameBoardTile.position
                                loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                                // self.showPoints(atLocation: loc, points: points)
                                
                                let points = play.points
                                
                                self.showPoints(atLocation: loc, points: points, color:  color)
      
                            }
                            
                        }
                        
                    }
                        
                    else {
                        
                        tileAction  = SKAction.run{
                            if i == play.playTiles.count - 1 && play.points > 0 {
                                print("about to show points, on last tile in play")
                                var loc = gameBoardTile.position
                                
                                
                                
                                // loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                                if gameBoardTile.col == GameConstants.BoardNumCols {
                                    loc.x = gameBoardTile.position.x - gameBoardTile.size.width
                                }
                                else if gameBoardTile.col == 0 {
                                    loc.x = gameBoardTile.position.x + gameBoardTile.size.width
                                }
                                
                                let bonusPoints = play.getPointsFromBonusTiles()
                                let points = play.points - bonusPoints
                                
                                self.showPoints(atLocation: loc, points: points, color:  color)
                                if bonusPoints > 0 {
                                    var loc1 = CGPoint()
                                    
                                    if loc.x - 100 < self.gameBoardDisplay.frame.minX {
                                        loc1.x = loc.x + 100
                                    }
                                    else {
                                        loc1.x = loc.x - 100
                                    }
                                    loc1.y = loc.y
                                    
                                    self.showPoints(atLocation: loc1, points: bonusPoints, color: .gray)
                                }
                                
                                
                            }
                        }
                        
                    }
    
                    playTileActions.append(tileAction)
                    // continue
                }
                else if tile.tileType == .bomb {
                    print("bomb tile found, light up plays in sequence and index \(i) in plays")
                    //HANDLE BOMB ANIMATION FOR PLAYER THAT DID NOT MAKE THE PLAY
                    if game.lastPlayerToMove != (currentUserPlayer.player1 == true ? 1 : 2) {
                        
                        tileAction = SKAction.run {
                            var bombBit:SKAction
                            if self.playSound {
                                print("SOUND IS ON IN CLOSURE OF PLAY TILES IN SEQ")
                                bombBit = SKAction.group([fadeToWhite,SKAction.playSoundFileNamed("bomb.mp3", waitForCompletion: false) ])
                                
                            }
                            else {
                                bombBit = fadeToWhite
                            }
                            for (gNum,gTile) in self.gameBoard.getBoxofTiles(withCenterTile: tile).enumerated() where !gTile.starterTile {
                                if gNum == 0 {
                                    gTile.run(bombBit)
                                    
                                }
                                else {
                                    gTile.run(fadeToWhite)
                                }
                                gTile.resetHoldingValues()
                                 gTile.tileLabel.text = ""
                            }
                            
                            
                            if i == play.playTiles.count - 1 && play.points > 0 {
                              
                                var loc = gameBoardTile.position
                                loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                                // self.showPoints(atLocation: loc, points: points)
                                
                                let points = play.points
                                
                                self.showPoints(atLocation: loc, points: points, color:  color)
                                
                                
                            }
                        }
                        
                    }
                        
                    else {
                        
                        tileAction  = SKAction.run{
                            if i == play.playTiles.count - 1 && play.points > 0 {
                                print("about to show points, on last tile in play")
                                var loc = gameBoardTile.position
                                
                                
                                
                                // loc.x = min(self.gameBoardDisplay.frame.maxX - 15, loc.x)
                                if gameBoardTile.col == GameConstants.BoardNumCols {
                                    loc.x = gameBoardTile.position.x - gameBoardTile.size.width
                                }
                                else if gameBoardTile.col == 0 {
                                    loc.x = gameBoardTile.position.x + gameBoardTile.size.width
                                }
                                
                                let bonusPoints = play.getPointsFromBonusTiles()
                                let points = play.points - bonusPoints
                                
                                self.showPoints(atLocation: loc, points: points, color:  color)
                                if bonusPoints > 0 {
                                    var loc1 = CGPoint()
                                    
                                    if loc.x - 100 < self.gameBoardDisplay.frame.minX {
                                        loc1.x = loc.x + 100
                                    }
                                    else {
                                        loc1.x = loc.x - 100
                                    }
                                    loc1.y = loc.y
                                    
                                    self.showPoints(atLocation: loc1, points: bonusPoints, color: .gray)
                                }
                                
                                
                            }
                        }
                        
                    }
                    
                    playTileActions.append(tileAction)
                    // continue
                }
                    
                else {
                
                
                    tileAction = SKAction.run{
                        
                        gameBoardTile.tileLabel.text = "\(tile.tileValue!)"
                      
                        gameBoardTile.run(lightUpTileSeq){
                            
                            var colorizeColor: UIColor
                            switch tile.player {
                            case 1 : colorizeColor = GameConstants.TilePlayer1TileColor
                            case 2: colorizeColor = GameConstants.TilePlayer2TileColor
                            default: colorizeColor = GameConstants.TileBoardTileColor
                            }
                            gameBoardTile.run(SKAction.colorize(with: colorizeColor, colorBlendFactor: 1.0, duration: 0.3))
                            
                
                            if i == play.playTiles.count - 1 {
                                var loc = gameBoardTile.position
                               
                                if gameBoardTile.col == GameConstants.BoardNumCols {
                                    loc.x = gameBoardTile.position.x - gameBoardTile.size.width
                                }
                                else if gameBoardTile.col == 0 {
                                    loc.x = gameBoardTile.position.x + gameBoardTile.size.width
                                }
                                
                                let bonusPoints = play.getPointsFromBonusTiles()
                                let points = play.points - bonusPoints
                                
                                self.showPoints(atLocation: loc, points: points, color:  color)
                                if bonusPoints > 0 {
                                    var loc1 = CGPoint()
                                    
                                    if loc.x - 100 < self.gameBoardDisplay.frame.minX {
                                        loc1.x = loc.x + 100
                                    }
                                    else {
                                        loc1.x = loc.x - 100
                                    }
                                    loc1.y = loc.y
                                    
                                    self.showPoints(atLocation: loc1, points: bonusPoints, color: .gray)
                                }
                                
                                
                            }
                            
                            
                        }
                     
                    }
                    playTileActions.append(tileAction)
                    
                }
            }
             allPlayTileActions.append(SKAction.sequence([SKAction.group(playTileActions), SKAction.wait(forDuration: 2.5)]) )
            playsSeen.append(play.playID)
            
            
        }
        
        
        //allPlayTileActions.removeAll()
        
        self.run(SKAction.sequence(allPlayTileActions)){
            
            
            if self.game.lastPlayerUsedAllTiles {
                print("after showing plays in light up plays, BINGO, so going to showBingo()")
                self.showBingo()
            }
            
            let newBoxLocs = self.game.boxLocs.filter{self.currentUserPlayer.player1 ? !$0.player1Viewed : !$0.player2Viewed }
            if newBoxLocs.count > 0 {
                self.boxBonusViewedThisTurn = true
                
                for newBox in newBoxLocs where !self.boxesViewedThisTurn.contains(where: {$0.boxID == newBox.boxID}) {
                    self.lightUpBoxTiles(tiles:self.getTilesInBox(withCenterLoc: newBox), colorToUseInLightUp: .green, pointsToShow: GameConstants.BoxBonus){
                        self.boxesViewedThisTurn.append(newBox)
                        
                    }
                }
                
            }
            
            if self.currentUserIsCurrentPlayer {
                self.disableGame = false
            }
            
            self.currentUserPlayer.plays.removeAll()
            
            if  completion != nil {
                
                completion!()
            }
        }
        
        //        self.currentUserPlayer.plays.removeAll()
        //
        //        if  completion != nil {
        //
        //            completion!()
        //        }
    }
    
    
    func getTilesInBox(withCenterLoc centerBoxLoc: BoxLoc) -> [Tile]{
    
        var boxTiles = [Tile]()
        
        for r in centerBoxLoc.row - 1 ... centerBoxLoc.row + 1 {
            for c in centerBoxLoc.col - 1 ... centerBoxLoc.col + 1 {
                boxTiles.append(gameBoard!.getTile(atRow: r, andCol: c))
            }
        }
        
        
        return boxTiles
        
    }
    

    func lightUpTilesInBoxBonus(tiles: [Tile]){
        
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
                if tile.tileType != TileType.eraser && tile.tileType != .bomb {
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
    
    
    func orderTilesWithEraserTilesFirst(tiles: [Tile]) -> [Tile] {
        
        var tilesOrdered = [Tile]()
        let eraserTiles = tiles.filter{$0.tileType == .eraser}
        
        
        for tile in eraserTiles {
            
            tilesOrdered.append(tile)
            
        }
        
        // showSelectedTiles()
        
        
        for tile in tiles where tile.tileType != .eraser {
            tilesOrdered.append(tile)
        }
       
        return tilesOrdered
    }
    
    
    func showPoints(atLocation location: CGPoint,points: Int, message: String = "", color: UIColor?) {
        
        
        let pointDisplay = SKLabelNode(text: "\(message) + \(points)!")
      
        pointDisplay.fontName = "AvenirNext-Bold"
        pointDisplay.fontSize = 50
        
        if let displayColor = color {
            pointDisplay.fontColor = displayColor
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
        
        print("in showPoints(): current player score is: \(self.currentPlayer.score), showing \(points) points")
           
         //   self.updateScoreLabel(player: self.getPlayerToUseInLoadGameClosure() )
            
            self.updateScoreLabel(player: self.getPlayerToUseInLoadGameClosure(), byIncrement: points)
        }
    }
    
  
    
    func checkIfLegalMove() -> Bool  {
     
        
        
        if !checkIfLegalTilePath() {
            
            
            let alert = UIAlertController(title:"Illegal tile path", message: "You can build off any tile in a row or column that a tile placed during the current play is touching", preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(ok)
            if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                mainVC.present(alert, animated: true, completion: nil)
            }
            
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
            
            
            let alert = UIAlertController(title:"Oops!", message: "You must connect to at least one tile not played during the current play!", preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(ok)
            if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                mainVC.present(alert, animated: true, completion: nil)
            }
            
            return false
        }
        
        if !selectedTilesOnlyConnectedToThree() {
            
//            let alert = UIAlertController(title:"Illegal play", message: "You can only build in a row or column that has at least 2 other tiles in it!", preferredStyle: UIAlertController.Style.alert)
//            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
//            alert.addAction(ok)
//            if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
//                mainVC.present(alert, animated: true, completion: nil)
//            }
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
                seedTiles.append(connectedTile)
               /* if connectedTile.player != currentPlayerN {
                    seedTiles.append(connectedTile)
                }
                 */
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
        print("nonDeleteSelectedPlayerTiles count = \(nonDeleteSelectedPlayerTiles.count)")
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
            tile.size = GameConstants.TileSize
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
        currentPlayerTileRack.removeAndReplaceTileFromRack1(player: currentPlayerN, tilesLeft: tilesLeft, game: game){
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
        
        if gameBoard!.isConnectedToValuedTilesBottom(tile: boardTile){
            
            
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
        for tile in selectedPlayerTiles where /*tile.name != "DELETE"*/ tile.tileType != TileType.eraser
        && tile.tileType != .bomb{
            
            
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
        
        if n1 == n2*n3 ||
            n1 == n2/n3    ||
            n1 == n2 + n3  ||
            n1 == n2 - n3  ||
            n3 == n2*n1    ||
            n3 == n2/n1    ||
            n3 == n2 + n1  ||
            n3 == n2 - n1 {
        
            print("about to check if we already counted  \(int1) at (\(threeTiles[0].row), \(threeTiles[0].col)) \(int2) at (\(threeTiles[1].row), \(threeTiles[1].col)) and \(int3) at (\(threeTiles[2].row), \(threeTiles[2].col))")
         /*   for playSet in legalPlaysThisTurn {
                var match = 0
                for tile in playSet {
                    for tile3 in threeTiles{
                       
                        if tile.row == tile3.row && tile.col == tile3.col && tile.tileValue == tile3.tileValue {
                            match += 1
                            break
                        }
                    }
                
                }
             
                if match == 3 {
                     print("Already have 3 tiles, not adding:  \(int1) \(int2) \(int3)")
                    return true
                    
                    
                }
                
            
            
            
            }
            */
            for playSet in legalPlaysThisTurn {
                print("comparing three tiles to \(playSet[0].tileValue) at (\(playSet[0].row),\(playSet[0].col)), \(playSet[1].tileValue) at (\(playSet[1].row),\(playSet[1].col)), \(playSet[2].tileValue) at (\(playSet[2].row),\(playSet[2].col))")
                if threeTiles[0].hasSamePositionAndValuesAsTile(inTileArray: playSet)
                    && threeTiles[1].hasSamePositionAndValuesAsTile(inTileArray: playSet)
                    &&  threeTiles[2].hasSamePositionAndValuesAsTile(inTileArray: playSet){
                print("not adding 3 tiles \(int1),\(int2),\(int3)...as these were already counted")
                return true
                }
            }
            print("adding 3 tiles to legal plays this turn:  \(int1) \(int2) \(int3)")
           print("legal plays this turn has \(legalPlaysThisTurn.count) plays in it")
            legalPlaysThisTurn.append(threeTiles)
            return true
        }
        
        for tile in threeTiles {
            badMathTiles.append(gameBoard!.getTile(atRow: tile.row, andCol: tile.col))
        }
       
        
        return false
        
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
                print("in calc score: bonus tiles used += 1!")
                nBonusTilesUsed += 1
            }
        }
        let points = nonDeleteSelectedPlayerTiles.count*legalPlaysThisTurn.count + 2*nBonusTilesUsed
        print("In calc score. Number of Legal Equations = \(legalPlaysThisTurn.count)")
        print("In calc score--number of tiles used: \(nonDeleteSelectedPlayerTiles.count)")
    
        
       currentPlayer.score += points
        
        print("In calculateScore(), extra points: \(points); points for \(currentPlayer.userName) is now: \(currentPlayer.score)")
       // currentScoreLbl.text = "\(currentPlayer.userName!)'s score: \(currentPlayer.score)"
      game.lastScoreIncrement = points
    
        
    }
    

    func revertBoardToStateBeforePlays(plays: [Play], board: Board) {
        var mem = [Tile]()
        for play in plays.sorted(by: { (p1, p2) -> Bool in
            p1.playCreatedDate < p2.playCreatedDate
        }) {
            
            for pTile in play.playTiles.sorted(by: { (t1, t2) -> Bool in
                t1.tileOrderInPlay! < t2.tileOrderInPlay!
            }) {
                pTile.showTile(msg: "showing tiles in play order in revert...")
                
                
                if mem.filter({ (t) -> Bool in
                    t.row == pTile.row && t.col == pTile.col
                }).count == 0 || pTile.tileType == .bomb {
                    pTile.showTile(msg: "adding to mem because no tile encountered yet")
                    mem.append(pTile)
     
                   let bTile = board.getTile(atRow: pTile.row, andCol: pTile.col)
                    if let holdVal = pTile.holdingValue, let holdPlayer = pTile.holdingPlayer {
                        pTile.showTile(msg: "pTile not bomb, but has holding value, so restoring in revert.")
                        bTile.tileLabel.text = "\(holdVal)"
                        bTile.color = holdPlayer == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                    }
                    else if !bTile.starterTile {
                        if bTile.tileLabel.text != GameConstants.TileBonusTileText {
                           bTile.tileLabel.text = ""
                        }
                        bTile.color = GameConstants.TileBoardTileColor
                    }
                    
                    
                    if pTile.tileType == .bomb {
                        for bombTile in board.getBoxofTiles(withCenterTile: pTile) where !bombTile.starterTile{
                            if mem.filter({ (memT) -> Bool in
                                memT.row == bombTile.row && memT.col == bombTile.col
                            }).count == 0 {
                                mem.append(bombTile)
                                let bombBTile = board.getTile(atRow: bombTile.row, andCol: bombTile.col)
                                if let holdVal = bombTile.holdingValue, let holdPlayer = bombTile.holdingPlayer {
                                    print("checking bombed tiles in revert: row/col \(bombTile.row), \(bombTile.col) has holding value: \(holdVal)")
                                    bombBTile.tileLabel.text = "\(holdVal)"
                                    bombBTile.color = holdPlayer == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                                }
                                else {
                                       print("checking bombed tiles in revert: row/col \(bombTile.row), \(bombTile.col) does NOT have holding value. tile text = \(bombTile.tileLabel.text)")
                                    if bombTile.tileLabel.text != GameConstants.TileBonusTileText {
                                        bombTile.tileLabel.text = ""
                                        print("Setting bomb tile text to nil, not bonus text")
                                    }
                                    bombBTile.color = GameConstants.TileBoardTileColor
                                }
                                
                            }
                        }
                    }
                    
            
                    
                }
                else {
                    pTile.showTile(msg: "not adding to mem...,already have a tile at this place.")
                }
            }
        }
        
        gameBoard.showBoard(msg: "After reverting board")
        
        
    }
    
    func revertBoxFromBomb(bombTile: Tile) {
        print("reverting box from bomb!")
        for bTile in gameBoard.getBoxofTiles(withCenterTile: bombTile) where !bTile.starterTile {
            if let holdVal = bTile.holdingValue, let holdPlayer = bTile.holdingPlayer {
                bTile.setTileValue(value: holdVal)
                
                bTile.color = holdPlayer == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                bTile.player = holdPlayer
                bTile.holdingValue = nil
                bTile.holdingPlayer = nil
                
            }
            else {
                bTile.setTileValue(value: nil)
                bTile.color  = GameConstants.TileBoardTileColor
            }
        }
            
            
    }
    func revertGameBoardAfterBombTileMoved(bombTile: Tile, inTouchesMoved: Bool = true ){
    
        print("REVERTING AFTER BOMB TILE")
//        let returnHome = SKAction.move(to: tile.startingPosition, duration: 1.0)
//        tile.run(returnHome)
        for bTile in gameBoard.getBoxofTiles(withCenterTile: bombTile)  {
            
            
            if bTile.tileIndexInValuedBombedTilesToRestore(bombedTilesToRestore: bombedValuedTilesToRestore) > -1 {
                print("tile at row, col: \(bTile.row),\(bTile.col) is a valued bombed tile to restore.")
            if let holdVal = bTile.getHoldingValueToRestore(),
                let holdPlayer = bTile.getHoldingPlayerToRestore(){
              
                bTile.setTileValue(value: holdVal)
                
                bTile.color = holdPlayer == 1 ? GameConstants.TilePlayer1TileColor : GameConstants.TilePlayer2TileColor
                bTile.player = holdPlayer
                bTile.removeHoldingValuesAfterRestoring()
                }
               
                bombedValuedTilesToRestore.remove(at: bTile.tileIndexInValuedBombedTilesToRestore(bombedTilesToRestore: bombedValuedTilesToRestore))
            }
            else if !bTile.starterTile{
                bTile.setTileValue(value: nil)
                bTile.color  = GameConstants.TileBoardTileColor
                bTile.player = nil
            }
            
            if bTile.inSelectedPlayerTiles {
                print("bTile in selected player tiles is row,col: \(bTile.row) \(bTile.col) value: \(bTile.getTileTextRepresentation())")
                let selectedTiles = selectedPlayerTiles.filter(){$0.row == bTile.row && $0.col == bTile.col}
                for sT in selectedTiles {
                    print("showing sT in selected player tiles that play over bombed area: \(sT.row) \(sT.col) value: \(sT.getTileTextRepresentation()), assoc. board tile holding player: \(bTile.holdingPlayer ?? -99), hold val: \(bTile.holdingValue ?? -99), board tile player: \(bTile.player)")
                    
                }
                
                if selectedTiles.count > 0 {
                    for sTile in selectedTiles {
                        print("sTile corresp. to bTile is row,col: \(sTile.row) \(sTile.col) value: \(sTile.getTileTextRepresentation())")
                     
                        sTile.isHidden = false
                       
                        if sTile.tileType == .bomb && inTouchesMoved {
                        sTile.size.width = 2*GameConstants.TileSize.width
                        sTile.size.height = 2*GameConstants.TileSize.height
                        sTile.alpha = 0.8
                        selectedPlayerTile = sTile
                            
                        }
                        else {
                            sTile.size.width = GameConstants.TileSize.width
                            sTile.size.height = GameConstants.TileSize.height
                            sTile.alpha = 1.0
                            sTile.inSelectedPlayerTiles = false
                         
                            let returnHome = SKAction.move(to: sTile.startingPosition, duration: 1.0)
                            sTile.run(returnHome)
                            selectedPlayerTiles = selectedPlayerTiles.filter({$0 != sTile})
                            tilesUsedThisTurn = tilesUsedThisTurn.filter({$0 != sTile})
                        }
                        sTile.row = -1
                        sTile.col = -1
                        
                    }
                    
                }
               bTile.inSelectedPlayerTiles = false
               
            }
            
        }
        
        
    }
    
    func valuedTileWasDeletedOrBombedThisPlay(tile: Tile) -> Bool {
        return tile.tileIndexInValuedBombedTilesToRestore(bombedTilesToRestore: bombedValuedTilesToRestore) > -1
            || selectedPlayerTiles.filter({ (t) -> Bool in
                t.tileType == .eraser && t.row == tile.row && t.col == tile.col
            }).count > 0
    
    }
    
    func valuedTileWasBombedThisPlay(tile: Tile) -> Bool {
        return tile.tileIndexInValuedBombedTilesToRestore(bombedTilesToRestore: bombedValuedTilesToRestore) > -1

    }

    func valuedTileWasDeletedThisPlay(tile: Tile) -> Bool {
          return selectedPlayerTiles.filter({ (t) -> Bool in
              t.tileType == .eraser && t.row == tile.row && t.col == tile.col
          }).count > 0

      }

    
  
    func tileIsPlayedOverByOtherTileInPlay(tile: Tile, bombTile: Tile, play: Play) -> Bool {
        
        guard bombTile.tileType == .bomb && play.playTiles.contains(bombTile) else {
            print("bombtile is not a bomb tile or play doesn't contain it")
            return false
        }
        guard  (bombTile.row - 1) <= tile.row && tile.row <= (bombTile.row + 1)
            && (bombTile.col - 1) <= tile.col && tile.col <= (bombTile.col + 1) else {
                print("bombTile doens't bomb out tile at row,col \(tile.row), \(tile.col) in tileIsPlayedOverByOtherTileInPlay")
                return false
        }
        for (n,playTile) in play.playTiles.enumerated() where n > play.playTiles.index(of: bombTile)!{
            print("n = \(n), playTile val = \(playTile.tileLabel.text) row,col = \(playTile.row),\(playTile.col).  checking if playTile has the same row,col as bombed out tile at row, col: \(tile.row),\(tile.col)")
            if playTile.row == tile.row && playTile.col == tile.col {
                return true
            }
        }
        return false
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































