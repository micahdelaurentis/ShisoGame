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
    var vc: UIViewController?
    
    override init() {
        super.init()
        
        fillColor = .white
        zPosition = 10
        isUserInteractionEnabled = true
    
    }
  
        func setUpGameOverPanel(game: Game) {
        self.game = game
            
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
        gameResultLabel.fontSize = 50
        gameResultLabel.position = CGPoint(x: 0, y: self.frame.height/2 - gameResultLabel.frame.size.height/2 - 30)
        addChild(gameResultLabel)
        
        finalScoreLabel.fontSize = 35
        finalScoreLabel.fontColor = .black
        finalScoreLabel.fontName = "Arial-BoldMT"
        finalScoreLabel.position = CGPoint(x:0, y:0)
        addChild(finalScoreLabel)
        
        
        exitLabel.text = "Exit"
        exitLabel.fontSize = 45
        exitLabel.fontColor = .blue
        exitLabel.fontName = "Arial-BoldMT"
        exitLabel.position = CGPoint(x: -self.frame.size.width/2 + exitLabel.frame.size.width/2 + 100, y: -self.frame.size.height/2 + 20)
        addChild(exitLabel)
        
        rematchLabel.text = "Rematch"
        rematchLabel.fontSize = 45
        rematchLabel.fontColor = .blue
        rematchLabel.fontName = "Arial-BoldMT"
        rematchLabel.position = CGPoint(x: self.frame.size.width/2 - rematchLabel.frame.size.width/2 - 75, y: exitLabel.position.y)
        addChild(rematchLabel)
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
            
            if nodes(at: loc).contains(rematchLabel){
                    handleRematch(game: game)
                    self.removeFromParent()
            }
        }
        
    }
 
    
 
    
    func handleRematch(game: Game) {
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
