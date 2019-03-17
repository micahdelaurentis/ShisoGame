//
//  GameOverPanel.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 6/23/18.
//  Copyright © 2018 Micah DeLaurentis. All rights reserved.
//

import Foundation
import SpriteKit
import Firebase
class GameOverPanel: SKShapeNode {

    var game: Game!
    let rematchLabel = SKLabelNode()
    let exitLabel = SKLabelNode()
    let gameResultLabel = SKLabelNode()
    let finalScoreLabel = SKLabelNode()
    
    let backToMenuLabel = SKLabelNode()
    let playAgainLabel = SKLabelNode()
    let finalSinglePlayerMessage = SKLabelNode()
    
    var vc: UIViewController?
    
    override init() {
        super.init()
        
        fillColor = .blue
        zPosition = 10
        isUserInteractionEnabled = true
    
    }
  
func setUpGameOverPanel(game: Game) {
        self.game = game
            
    if !game.singlePlayerMode {
      addTwoPlayerLabels()
    }
    else {
        addSinglePlayerLabels()
    }
    }
    func addSinglePlayerLabels() {
   //  finalSinglePlayerMessage.position =   CGPoint(x: 0, y: self.frame.height/2 - finalSinglePlayerMessage.frame.size.height/2 - 45)
   
    let gameOverLbl = SKLabelNode(text: "Game Over!")

    gameOverLbl.fontColor = .black
    gameOverLbl.fontSize = 25
    gameOverLbl.fontName = "Arial-BoldMT"
    gameOverLbl.position.y = frame.size.height/2  - gameOverLbl.frame.size.height - 10
    addChild(gameOverLbl)
        
    finalSinglePlayerMessage.text = "Final Score: \(game.player1.score)"
    finalSinglePlayerMessage.fontName = "Arial-BoldMT"
    finalSinglePlayerMessage.fontSize = 30
    finalSinglePlayerMessage.fontColor = .black
    finalScoreLabel.verticalAlignmentMode = .center
    finalScoreLabel.horizontalAlignmentMode = .center
    finalScoreLabel.position.y = -finalScoreLabel.frame.size.height/2
    addChild(finalSinglePlayerMessage)
        
     
        backToMenuLabel.text = "Back"
        backToMenuLabel.fontName = "Arial-BoldMT"
        backToMenuLabel.fontSize = 20
        backToMenuLabel.fontColor = .black
        backToMenuLabel.position = CGPoint(x: self.frame.minX + backToMenuLabel.frame.size.width/2 + 10, y: -self.frame.size.height/2 + 10)
        addChild(backToMenuLabel)
       
        playAgainLabel.text = "Play Again"
        playAgainLabel.fontSize = 20
        playAgainLabel.fontColor = .black
        playAgainLabel.fontName = "Arial-BoldMT"
        playAgainLabel.position = CGPoint(x: self.frame.size.width/2 - playAgainLabel.frame.size.width/2 - 10, y: -self.frame.size.height/2 + 10)
        addChild(playAgainLabel)
        
       
        
    }
    func addTwoPlayerLabels() {
        
        var result: String
        if game.player1.score == game.player2.score  {
            result = "Tied"
        }
        else {
            
            result = Auth.auth().currentUser?.uid == (game.player1.score > game.player2.score ? game.player1.userID: game.player2.userID) ? "Win" : "Lose"
        }
        gameResultLabel.text = "You \(result)!"
        
        finalScoreLabel.text = "\(game.player1.userName!): \(game.player1.score) | \(game.player2.userName!): \(game.player2.score)"
        
        gameResultLabel.fontName =  "Arial-BoldMT"
        gameResultLabel.fontColor = .black
        gameResultLabel.fontSize = 30
        gameResultLabel.position = CGPoint(x: 0, y: self.frame.height/2 - gameResultLabel.frame.size.height/2 - 30)
        addChild(gameResultLabel)
        
        finalScoreLabel.fontSize = 20
        finalScoreLabel.fontColor = .black
        finalScoreLabel.fontName = "Arial-BoldMT"
        finalScoreLabel.position = CGPoint(x:0, y:0)
        addChild(finalScoreLabel)
        
       
 
        
     
     
        
        exitLabel.text = "Exit"
        exitLabel.fontSize = 16
        exitLabel.fontColor = .white

        exitLabel.fontName = "Arial-BoldMT"
        exitLabel.position.x = self.frame.minX + exitLabel.frame.size.width/2 + 15
        exitLabel.position.y = self.frame.minY + exitLabel.frame.size.height/2 + 15
        exitLabel.zPosition = 5

        addChild(exitLabel)
        
        let exitShape = SKSpriteNode(color: .lightGray, size: CGSize(width: exitLabel.frame.size.width + 10, height: exitLabel.frame.size.height + 10))
        exitShape.position.y = exitLabel.frame.midY
        exitShape.position.x = exitLabel.position.x
        
        addChild(exitShape)
        

        rematchLabel.text = game.singlePlayerMode == false ? "Rematch" : "Play Again"
        rematchLabel.fontSize = 16
        rematchLabel.zPosition = 5
        rematchLabel.fontColor = .white
        rematchLabel.fontName = "Arial-BoldMT"
        rematchLabel.position = CGPoint(x: self.frame.size.width/2 - rematchLabel.frame.size.width/2 - 15, y: exitLabel.position.y)
        addChild(rematchLabel)
        
        let rematchShape = SKSpriteNode(color: .lightGray, size: CGSize(width: rematchLabel.frame.size.width + 10, height: rematchLabel.frame.size.height + 10))
        rematchShape.position.y = rematchLabel.frame.midY
        rematchShape.position.x = rematchLabel.position.x
        
        addChild(rematchShape)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            if nodes(at: loc).contains(exitLabel) {
              /*  if let vc = vc as? GameViewController {
                    vc.presentDisplayVC()
                }
                 */
                self.removeFromParent()
                
            }
            
           else if nodes(at: loc).contains(rematchLabel){
                    handleRematch()
                    self.removeFromParent()
            }
            
            else if nodes(at: loc).contains(playAgainLabel){
               self.removeFromParent()
                if let mainVC = UIApplication.shared.keyWindow?.rootViewController as? GameViewController {
                    if let mainV = mainVC.view as? SKView {
                        if let gScene = GameplayScene(fileNamed: "GameplayScene") {
                            game.player1.score = 0
                            game.player1.tileRack = TileRack()
                            game.board = Board()
                            gScene.game = game
                            gScene.scaleMode = .aspectFit
                            gScene.size = UIScreen.main.bounds.size 
                            mainVC.dismiss(animated: true, completion: nil)
                            mainV.presentScene(gScene)
                        }
                        
                    }
                }
            }
            else if nodes(at: loc).contains(backToMenuLabel) {
                if let mainVC = UIApplication.shared.keyWindow?.rootViewController as? GameViewController {
                    mainVC.present(StartNewGameVC(), animated: true, completion: nil)
                }

            }
            
        }
        
    }
 
    
 
    
    func handleRematch() {
        print("Rematch requested")
        if let opponentUserName = game.player1.userID == FirebaseConstants.CurrentUserID ? game.player2.userName : game.player1.userName
        {
            Fire.dataService.postChallenge(opponentUserName: opponentUserName, completion: nil)
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
