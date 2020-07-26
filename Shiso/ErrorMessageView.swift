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
class ErrorMessageView: SKShapeNode {
    
   
    let OKLabel = SKLabelNode()
    let illegalMoveLabel = SKLabelNode()
    let illegalMoveMessage = SKLabelNode()
    
    
    var handler: (() -> ())?
    
    override init() {
 
        super.init()
        
        fillColor = .blue
        zPosition = 10
        isUserInteractionEnabled = true
    
    }
    
    func setUpErrorMessageView(handler: (()->())?){
        
        self.handler = handler
       
        OKLabel.text = "OK"
        OKLabel.fontSize = 20
        OKLabel.fontColor = .white
        
        OKLabel.fontName = "Arial-BoldMT"
        OKLabel.position.y = self.frame.minY + OKLabel.frame.size.height/2 + 15
        OKLabel.zPosition = 5
        
        addChild(OKLabel)
    
   
        illegalMoveLabel.text = "Math error!"
        illegalMoveLabel.fontColor = .black
        illegalMoveLabel.fontName = "Arial-BoldMT"
        illegalMoveLabel.fontSize = 25
        illegalMoveLabel.position = CGPoint(x: 0, y: self.frame.maxY - illegalMoveLabel.frame.size.height/2 - 20)
        addChild(illegalMoveLabel)
        
        
    }
   
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            if nodes(at: loc).contains(OKLabel) {
               
                self.removeFromParent()
            
                if handler != nil {
                    handler!()
                }
            }
            
          
            
        }
        
    }
 
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
