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
    let separator: CGFloat = 5
    var vc: UIViewController?
    
    override init() {
        super.init()
        
        fillColor = .lightGray
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
   
    let gameOverLbl = SKLabelNode(text: "Game Over")

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
         
     
//        let p1UserName = NSAttributedString(string: game.player1.userName!, attributes: [NSAttributedString.Key.foregroundColor : player1TextColor])
//        let p2UserName = NSAttributedString(string: game.player2.userName!, attributes: [NSAttributedString.Key.foregroundColor : player2TextColor])
//
//
            
        //finalScoreLabel.text = "\(p1UserName): \(game.player1.score) | \(p2UserName): \(game.player2.score)"
        
        let winLbl = SKLabelNode()
        if (game.player1.score >= game.player2.score &&  game.resignedPlayerNum != 1)
        || game.resignedPlayerNum == 2 {
            winLbl.text = "\(game.player1.userName!): \(game.player1.score)"
        }
        else if (game.player1.score <= game.player2.score && game.resignedPlayerNum != 2) || game.resignedPlayerNum == 1 {
            winLbl.text = "\(game.player2.userName!): \(game.player2.score)"
        }
        winLbl.fontSize = 20
        winLbl.fontColor =  game.player1.score == game.player2.score && !(game.resignedPlayerNum != 0) ? .white: UIColor(red: 38/255, green: 127/255, blue: 14/255, alpha: 1.0)
        winLbl.fontName = "Arial-BoldMT"
        addChild(winLbl)
        
       /* let  winlblx: CGFloat = -self.frame.width/2 + winLbl.frame.width/2 + 5
        winLbl.position = CGPoint(x: winlblx, y: 0)
 */
        
        
        let loseLbl = SKLabelNode()
        if (game.player1.score >= game.player2.score && game.resignedPlayerNum != 1) || game.resignedPlayerNum == 2 {
                  loseLbl.text = "\(game.player2.userName!): \(game.player2.score)"
              }
        else if (game.player1.score < game.player2.score && game.resignedPlayerNum != 2) || game.resignedPlayerNum == 1 {
                  loseLbl.text = "\(game.player1.userName!): \(game.player1.score)"
              }
              loseLbl.fontSize = 20
              loseLbl.fontColor = .white
              loseLbl.fontName = "Arial-BoldMT"
              
        addChild(loseLbl)
        loseLbl.position = CGPoint(x: 0, y: winLbl.frame.minY - loseLbl.frame.height/2 - 10)
            
      
    
        let gameOverLbl = SKLabelNode(text: "Game Over!")

        gameOverLbl.fontColor = .black // UIColor(red: 16/255, green: 96/255, blue: 205/255, alpha: 1.0)
          gameOverLbl.fontSize = 35
          gameOverLbl.fontName = "Arial-BoldMT"
          gameOverLbl.position.y = frame.size.height/2  - gameOverLbl.frame.size.height - 10
          addChild(gameOverLbl)
              
        if game.resignedPlayerNum != 0 {
            let resignedLbl = SKLabelNode(text: "\(game.resignedPlayerNum == 1 ? game.player1.userName! : game.player2.userName!) resigned!")
            resignedLbl.position = CGPoint(x: 0, y: gameOverLbl.frame.minY - resignedLbl.frame.height/2 - 5)
            resignedLbl.fontSize = 17
            resignedLbl.fontName = "Arial-ItalicMT"
            resignedLbl.fontColor = .black
            addChild(resignedLbl)
        }
        gameResultLabel.fontName =  "Arial-BoldMT"
        gameResultLabel.fontColor = .blue
        gameResultLabel.fontSize = 30
        gameResultLabel.position = CGPoint(x: 0, y: self.frame.height/2 - gameResultLabel.frame.size.height/2 - 30)
        addChild(gameResultLabel)
        
        finalScoreLabel.fontSize = 15
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
        
        let exitShape = SKSpriteNode(color: .red, size: CGSize(width: exitLabel.frame.size.width + 10, height: exitLabel.frame.size.height + 10))
        exitShape.position.y = exitLabel.frame.midY
        exitShape.position.x = exitLabel.position.x
        
        addChild(exitShape)
        

        rematchLabel.text = game.singlePlayerMode == false ? "Rematch" : "Play Again"
        rematchLabel.fontSize = 16
        rematchLabel.zPosition = 5
        rematchLabel.fontColor = .black
        rematchLabel.fontName = "Arial-BoldMT"
        rematchLabel.position = CGPoint(x: self.frame.size.width/2 - rematchLabel.frame.size.width/2 - 15, y: exitLabel.position.y)
        addChild(rematchLabel)
        
        let rematchShape = SKSpriteNode(color: UIColor(red: 229/255, green: 198/255,blue: 5/255, alpha: 1.0), size: CGSize(width: rematchLabel.frame.size.width + 10, height: rematchLabel.frame.size.height + 10))
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
                 Fire.dataService.updateStatsAndRemoveGame(game: game)
            }
            
           else if nodes(at: loc).contains(rematchLabel){
                    handleRematch()
                    self.removeFromParent()
                    Fire.dataService.updateStatsAndRemoveGame(game: game)
            }
            
            else if nodes(at: loc).contains(playAgainLabel){
               self.removeFromParent()
                if let mainVC = UIApplication.shared.keyWindow?.rootViewController as? GameViewController {
                    print("got mainvc in play again label pushed")
                    if let mainV = mainVC.view as? SKView {
                        print("can let main vc be skview in play again label pushed")
                        if let gScene = GameplayScene(fileNamed: "GameplayScene") {
                            print("got gameplayscene object in play again label pushed")
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
