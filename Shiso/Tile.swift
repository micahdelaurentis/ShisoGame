//
//  Tile.swift
//  Shiso
//

//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import SpriteKit
enum TileType {
    case regular
    case eraser
    case wildcard
}
class Tile: SKSpriteNode {
   
    var holdingValue: Int?
    var holdingColor: UIColor?
    var tileLabel = SKLabelNode()
    var player: Int!
    var tileIsEmpty: Bool {
      return getTileValue() == nil 

    }
    var row = -1
    var col = -1
    var tileValue: Int?
    var inSelectedPlayerTiles = false
    
    var rackPosition = Int()
    var startingPosition = CGPoint()
    var currentPosition = CGPoint() 
    
  
    
    var tileType: TileType!
    
    
    
    func initializeTile(width: CGFloat = GameConstants.TileSize.width, height: CGFloat = GameConstants.TileSize.height, tileValueText: String?, includeRandomTextValue: Bool = false, player: Int = 0) {
        
        self.size = CGSize(width: width, height: height)
        self.zPosition = GameConstants.TileZposition
       
        self.anchorPoint = GameConstants.TileAnchorPoint 
        
        self.player = player
        
        switch player {
        case 1: self.color = GameConstants.TilePlayer1TileColor
        case 2: self.color = GameConstants.TilePlayer2TileColor
        default: self.color = GameConstants.TileDefaultColor
        }
        
        
        
        
        self.addChild(tileLabel)
        tileLabel.horizontalAlignmentMode = .center
        tileLabel.verticalAlignmentMode = .center
        
        if includeRandomTextValue {
                 if Double(arc4random_uniform(100)) <=  40 {
                
                if Double(arc4random_uniform(100)) <=  50 {
                tileLabel.text = GameConstants.TileWildCardSymbol
                self.name = GameConstants.TileWildcardTileName
                tileType = TileType.wildcard
                }
                
                else {
                    texture = SKTexture(image: #imageLiteral(resourceName: "ShisoEraserIcon"))
                    self.name = GameConstants.TileDeleteTileName
                    tileType = TileType.eraser
                }
                
            }
            
            else {
                    
                setTileValue(value: Int(arc4random_uniform(25)))
                tileType = TileType.regular
                self.name = GameConstants.TilePlayerTileName
            }
            
        }
        //If includeRandomTextValue is false
            else if tileValueText != nil {
                switch tileValueText! {
                case "+2", "X" , "?" : self.tileLabel.text = tileValueText
                default:
                    if let tileValInt = Int(tileValueText!) {
                        self.setTileValue(value: tileValInt)
                    }
                }
                
        }
   
        
        self.tileLabel.zPosition = GameConstants.TileLabelZposition
        self.tileLabel.position = GameConstants.TileLabelPosition
        self.tileLabel.fontSize = GameConstants.TileLabelFontSize
        self.tileLabel.fontName = GameConstants.TileLabelFontName
        self.tileLabel.fontColor = GameConstants.TileLabelFontColor
    }
    
    
    func getTileLabelText() -> String {
     
         return self.tileLabel.text ?? "" 
    }
    
    func getTileValue() -> Int? {
        return self.tileValue
    }
    
    func setTileValue(value: Int?) {
        self.tileValue = value
        setTileLabelText()
    }
    
    
    func setTileLabelText() {
        if let value = self.tileValue  {
            if value != -1 {
               self.tileLabel.text = "\(value)"
            }
        }
        else {
               self.tileLabel.text = ""
        }
    }
    
    
    func isTileOnBoard() -> Bool {
        return row != -1 
    }
    
    func convertToDict()-> [String: Any] {
       // print("in convertToDict in Tile...color = \(self.color)")
        var dict: [String: Any] = [:]
        
        if tileType == TileType.eraser {
            dict[FirebaseConstants.TileValue] = "X"
        }
        else {
          dict[FirebaseConstants.TileValue] = getTileLabelText()
        }
        
        
        dict[FirebaseConstants.TileRow] = row
        dict[FirebaseConstants.TileCol] = col
        

        dict[FirebaseConstants.TilePlayer] = self.player
       
        dict[FirebaseConstants.TileRackPosition] = rackPosition
        dict[FirebaseConstants.TileCurrentPositionX] = currentPosition.x
        dict[FirebaseConstants.TileCurrentPositionY] = currentPosition.y
        dict[FirebaseConstants.TileStartingPositionX] = startingPosition.x
        dict[FirebaseConstants.TileStartingPositionY] = startingPosition.y
        dict[FirebaseConstants.TileTypeName] = name
        
        return dict
    }    
   class func initializeFromDict(dict: [String:Any]) -> Tile {
    
        let tile = Tile()
        tile.initializeTile(tileValueText: nil)
    
        if let dictTileValue = dict[FirebaseConstants.TileValue] as? String {
          //  print("tile value  = \(dictTileValue)")
            if dictTileValue == GameConstants.TileDeleteTileSymbol  {
                tile.tileLabel.text = ""
                tile.texture = SKTexture(image: #imageLiteral(resourceName: "ShisoEraserIcon"))
                tile.tileType = .eraser
            }
            else if dictTileValue == GameConstants.TileWildCardSymbol {
                tile.tileLabel.text = dictTileValue
                tile.tileType = TileType.wildcard
            }
             
            else if dictTileValue == "+2" {
                tile.tileLabel.text = "+2"
                tile.tileType = TileType.regular
                tile.tileLabel.fontColor = .gray 
            }
            else {
                if let numVal = Int(dictTileValue) {
                    tile.setTileValue(value: numVal)
                    tile.tileType = TileType.regular
                }
            }
        }
    
 
    if let tileTypeName = dict[FirebaseConstants.TileTypeName] as? String {
        tile.name = tileTypeName
    }
    if let tileRow = dict[FirebaseConstants.TileRow] as? Int {
        tile.row = tileRow
    }
    if let tileCol = dict[FirebaseConstants.TileCol] as? Int {
        tile.col = tileCol
    }
    
    if let player = dict[FirebaseConstants.TilePlayer] as? Int {
        
        tile.player = player
        
        if player == 1 {
            tile.color = GameConstants.TilePlayer1TileColor
        }
        else if player == 2 {
            tile.color = GameConstants.TilePlayer2TileColor
        }
       else if tile.row == 2 && tile.col == 2 ||
        tile.row == 2 && tile.col == GameConstants.BoardNumCols - 2 ||
        tile.row == GameConstants.BoardNumRows - 2 && tile.col == 2 ||
            tile.row == GameConstants.BoardNumRows - 2 && tile.col == GameConstants.BoardNumCols - 2 {
        
        tile.color = GameConstants.TileStartingSquaresColor
        }
        else {
            tile.color = GameConstants.TileDefaultColor
        }
    }
  
        if let currPosX = dict[FirebaseConstants.TileCurrentPositionX] as? CGFloat,
            let currPosY = dict[FirebaseConstants.TileCurrentPositionY] as? CGFloat {
            tile.currentPosition = CGPoint(x: currPosX, y: currPosY)
            tile.position = tile.currentPosition
        }
        
        if let startPosX = dict[FirebaseConstants.TileStartingPositionX] as? CGFloat,
            let startPosY = dict[FirebaseConstants.TileStartingPositionY] as? CGFloat {
            tile.startingPosition = CGPoint(x: startPosX, y: startPosY)
        }
        
    
    
        
        //don't store info in unplayed turn. like holding value, inselected tiles, just reset to rack and don't save
        return tile
       
    }
    
    func showTileValues() {
      
        if self.parent != nil { print("Showing tile values for tile. Value: \(String(describing: self.tileLabel.text)) row: \(self.row) col: \(self.col) player: \(player) parent: \(self.parent)")
        }
        }
  
    
}
