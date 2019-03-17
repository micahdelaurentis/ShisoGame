//
//  wildCardPickerView.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 11/18/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import SpriteKit

class WildCardPickerView: SKSpriteNode {
    
    
    var wildCardCheck = SKLabelNode(text: "✓")
    var wildCardX = SKLabelNode(text: "☓")
    let separatorWidth = GameConstants.BoardSeparatorWidth
    
    func initializePicker(tileColor: UIColor) {
    
        self.color = .darkGray
        
        self.size = CGSize(width: 6*GameConstants.BoardSeparatorWidth + 5*GameConstants.TileSize.width, height: 6*GameConstants.BoardSeparatorWidth + 5*GameConstants.TileSize.height + 150)
      
        
        
        
        let selectATileLbl = SKLabelNode(text: "Select a tile!")
        addChild(selectATileLbl)
        selectATileLbl.position = CGPoint(x: 0 , y: self.size.height/2 - selectATileLbl.frame.height/2 + separatorWidth - 85)
        selectATileLbl.fontSize = 30
        selectATileLbl.fontName = GameConstants.TileLabelFontName
        
        
        let exitBox = SKLabelNode(text: "⌧")
        addChild(exitBox)
        exitBox.fontName = GameConstants.TileLabelFontName
        exitBox.fontSize = 25
        exitBox.position = CGPoint(x: -self.size.width/2 +  exitBox.frame.width/2 + separatorWidth, y: self.size.height/2 - exitBox.frame.height - separatorWidth)
       
        exitBox.name = GameConstants.WildCardPickerExitBoxName
        var text = 0
        for i in 0 ... 4 {
            for j in 0 ... 4 {
               
                let tile = Tile()
                tile.initializeTile(tileValueText: "\(text)")
                tile.name = GameConstants.WildCardPickerViewTileName 
                tile.color = tileColor
                tile.tileLabel.fontColor =  .white
                 self.addChild(tile)
                tile.position = CGPoint(x:CGFloat(j + 1)*separatorWidth - (self.size.width)/2 + tile.size.width*CGFloat(j) + tile.size.width/2,
                     y: self.size.height/2 - CGFloat(i + 1)*separatorWidth - tile.size.height/2 - tile.size.height*CGFloat(i) - 100)
                    
                
    
                text += 1
                
                
                
            }
        }
        wildCardCheck.fontColor = .green
        wildCardCheck.fontName = GameConstants.TileLabelFontName
        wildCardCheck.fontSize = 50
        wildCardCheck.color = .green
        wildCardCheck.name = GameConstants.WildCardCheckTileName
        wildCardCheck.isHidden = true
        
     /*   wildCardCheck.position = CGPoint(x: 4*separatorWidth - (self.size.width)/2 + 3*GameConstants.TileSize.width  + GameConstants.TileSize.width/2, y:
            self.size.height/2 - CGFloat(6)*separatorWidth - GameConstants.TileSize.height/2 - GameConstants.TileSize.height*CGFloat(5) - 100 - 2*separatorWidth) */
        
        wildCardCheck.position.x = self.frame.maxX - wildCardCheck.frame.size.width/2 - 10
        
        wildCardCheck.position.y = self.frame.minY //+ wildCardCheck.frame.size.height/2 + 5
       
        addChild(wildCardCheck)
        
        wildCardX.fontColor = .orange
        wildCardX.color = .orange
        wildCardX.name = GameConstants.WildCardXTileName
        wildCardX.fontName = GameConstants.TileLabelFontName
        wildCardX.fontSize = 50
        
     /*   wildCardX.position = CGPoint(x: 2*separatorWidth - (self.size.width)/2 + GameConstants.TileSize.width  + GameConstants.TileSize.width/2, y:
            self.size.height/2 - CGFloat(6)*separatorWidth - GameConstants.TileSize.height/2 - GameConstants.TileSize.height*CGFloat(5) - 100 - 2*separatorWidth) */
        
        wildCardX.position.x = -wildCardCheck.position.x
        wildCardX.position.y = wildCardCheck.position.y
            
        addChild(wildCardX)
       
        wildCardCheck.isHidden = true
        wildCardX.isHidden = true 
       
        self.setScale(1.3)
    }
    
    func showConfirmBtns() {
        wildCardX.isHidden = false
        wildCardCheck.isHidden = false
    }
    func hideConfirmBtns() {
        wildCardX.isHidden = true
        wildCardCheck.isHidden = true 
    }
    
}
