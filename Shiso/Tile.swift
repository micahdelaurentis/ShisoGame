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
    case bomb
}
class Tile: SKSpriteNode {
   
    var holdingValue: Int?
    var holdingColor: UIColor?
    var holdingPlayer: Int?
    
    var holdingValue_temp: Int?
    var holdingPlayer_temp: Int?
    
    var valueWhenDeletedThisPlay: Int?
    var playerWhenDeletedThisPlay: Int?
    
    var tileLabel = SKLabelNode()
    var player: Int!
    var tileIsEmpty: Bool {
      return getTileValue() == nil 

    }
    var row = -1
    var col = -1
    var tileOrderInPlay: Int?
    
    var tileValue: Int?
    var inSelectedPlayerTiles = false
    
    var rackPosition = Int()
    var startingPosition = CGPoint()
    var currentPosition = CGPoint() 
    var bonusTile = false 
    var starterTile: Bool {
        return (row == 2 && col == 2) ||
        (row == 2 && col == 7) ||
        (row == 7 && col == 2) ||
        (row == 7 && col == 7)
    }
  
    
    var tileType: TileType!
    
    

    func initializeTile(width: CGFloat = GameConstants.TileSize.width, height: CGFloat = GameConstants.TileSize.height, tileValueText: String?, includeRandomTextValue: Bool = false, player: Int = 0, randMax: Int = 100) {
        
        
       
        
        
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
        
   /*   if includeRandomTextValue {
        
            
                 if Double(arc4random_uniform(100)) <= 30 {
                
                if Double(arc4random_uniform(100)) <=  0 {
                tileLabel.text = GameConstants.TileWildCardSymbol
                self.name = GameConstants.TileWildcardTileName
                tileType = TileType.wildcard
                }
                
                else {
                    texture = player == 1 ? SKTexture(imageNamed: "player1BlueEraser") : SKTexture(imageNamed: "player2GreenEraser")
                    self.name = GameConstants.TileDeleteTileName
                    tileType = TileType.eraser
                    }
                
            }
            
            else {
                  setTileValue(value: 0)
                //setTileValue(value: Int(arc4random_uniform(25)))
                tileType = TileType.regular
                self.name = GameConstants.TilePlayerTileName
            }
            
        } */
            
      if includeRandomTextValue {
     
        switch Int.random(in: 1...randMax) {
            case 1..<2: setAllTileAttributes(tName: GameConstants.TileBombTileName, tType: .bomb, value: nil)
            case 2...3: setAllTileAttributes(tName: GameConstants.TileDeleteTileName, tType: .eraser, value: nil)
            case 4..<10: setAllTileAttributes(tName: GameConstants.TileWildcardTileName, tType: .wildcard, value: nil)
        
            case 10..<18: setAllTileAttributes(value: 0)
            case 18..<25: setAllTileAttributes(value: 1)
            case 25..<31: setAllTileAttributes(value: 2)
            case 31..<36: setAllTileAttributes(value: 3)
            case 36..<41: setAllTileAttributes(value: 4)
            case 41..<46: setAllTileAttributes(value: 5)
            case 46..<50: setAllTileAttributes(value: 6)
            case 50..<53: setAllTileAttributes(value: 7)
            case 53..<57: setAllTileAttributes(value: 8)
            case 57..<61: setAllTileAttributes(value: 9)
            case 61..<65: setAllTileAttributes(value: 10)
            case 65..<68: setAllTileAttributes(value: 11)
            case 68..<72: setAllTileAttributes(value: 12)
            case 72..<74: setAllTileAttributes(value: 13)
            case 74..<77: setAllTileAttributes(value: 14)
            case 77..<80: setAllTileAttributes(value: 15)
            case 80..<83: setAllTileAttributes(value: 16)
            case 83..<84: setAllTileAttributes(value: 17)
            case 84..<87: setAllTileAttributes(value: 18)
            case 87..<88: setAllTileAttributes(value: 19)
            case 88..<91: setAllTileAttributes(value: 20)
            case 91..<93: setAllTileAttributes(value: 21)
            case 93..<95: setAllTileAttributes(value: 22)
            case 95..<96: setAllTileAttributes(value: 23)
            case 96..<99: setAllTileAttributes(value: 24)
            case 99...randMax: setAllTileAttributes(tName: GameConstants.TileBombTileName, tType: .bomb, value: nil)
            default:  return
            
            }
        }
        
            
            
        //If includeRandomTextValue is false
            else if tileValueText != nil {
                switch tileValueText! {
                case "+2", "X" , "?", "B" : self.tileLabel.text = tileValueText
                default:
                    if let tileValInt = Int(tileValueText!) {
                        self.setTileValue(value: tileValInt)
                    }
                }
                
        }
   
        
        self.tileLabel.zPosition = GameConstants.TileLabelZposition
        self.tileLabel.position = GameConstants.TileLabelPosition
        self.tileLabel.fontSize = 20 //GameConstants.TileLabelFontSize
        self.tileLabel.fontName = GameConstants.TileLabelFontName
        self.tileLabel.fontColor = GameConstants.TileLabelFontColor
    }
    
    
    func getTileLabelText() -> String {
     
         return self.tileLabel.text ?? "" 
    }
    
    func getTileTextRepresentation() -> String {
        if tileLabel.text != nil {
            return tileLabel.text!
        }
        else if tileType == TileType.eraser {
            return GameConstants.TileDeleteTileSymbol
        }
        else { return "" }
    }
    
    func getTileValue() -> Int? {
        return self.tileValue
    }
    
    func setHoldingValues() {
        if let tv = tileValue  {
            if holdingValue == nil {
                holdingValue = tv
                holdingPlayer = player!
            }
            else {
                holdingValue_temp = tv
                holdingPlayer_temp = player!
            }
        }
    }
    func setValuesDeletedThisTurn(){
        playerWhenDeletedThisPlay = player
        valueWhenDeletedThisPlay = tileValue
    }
    
    
    func getHoldingValueToRestore() -> Int? {
        if holdingValue_temp != nil {
            return holdingValue_temp!
        }
        else if holdingValue != nil {
            return holdingValue
        }
        return nil 
    }
    
    
    func getHoldingPlayerToRestore() -> Int! {
        if holdingPlayer_temp != nil {
            return holdingPlayer_temp!
        }
        else if holdingPlayer != nil {
            return holdingPlayer
        }
        
        return nil 
   
    }
    
    func removeHoldingValuesAfterRestoring(){
        if holdingValue_temp != nil {
            holdingValue_temp = nil
            holdingPlayer_temp = nil
        }
        else {
            holdingValue = nil
            holdingPlayer = nil
        }
    }
    
    
    
    func setTileValue(value: Int?) {
        self.tileValue = value
        setTileLabelText()
    }
    func setAllTileAttributes(tName:String = GameConstants.TilePlayerTileName,
                              tType:TileType = TileType.regular, value: Int?
                             ){
        self.name = tName
        self.tileType = tType
        if let v = value {
            self.setTileValue(value: v)
        }
        if tType == .eraser {
          texture = player == 1 ? SKTexture(imageNamed: "player1BlueEraser") : SKTexture(imageNamed: "player2GreenEraser")
        }
        else if tType == .wildcard {
            tileLabel.text = GameConstants.TileWildCardSymbol
        }
        else if tType == .bomb {
            tileLabel.text = "💣"
        }
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
    func tileIndexInValuedBombedTilesToRestore(bombedTilesToRestore: [Tile]) -> Int {
        for (n,t) in bombedTilesToRestore.enumerated() {
            if row == t.row && col == t.col {
                return n
            }
        }
        return -1
    }
    
    
    func isTileOnBoard() -> Bool {
        return row != -1 
    }
    
    func resetHoldingValues() {
      
        print("resetting holding values to nil for tile at row, col: \(row),\(col)")
        holdingValue = nil
        holdingPlayer = nil
        holdingColor = nil
        
        holdingPlayer_temp = nil
        holdingValue_temp = nil
    }
    
    func convertToDict()-> [String: Any] {
       // print("in convertToDict in Tile...color = \(self.color)")
        var dict: [String: Any] = [:]
        
        if tileType == TileType.eraser {
            dict[FirebaseConstants.TileValue] = "X"
            
        }
        else if tileType == TileType.bomb {
            dict[FirebaseConstants.TileValue] = "B"
        }
        else {
          dict[FirebaseConstants.TileValue] = getTileLabelText()
        }
        
        if let holdVal = holdingValue {
            
               dict[FirebaseConstants.TileHoldingValue] = holdVal
        }
        
        if let ordInPlay = tileOrderInPlay {
            dict[FirebaseConstants.TileOrderInPlay] = ordInPlay
        }
        if let holdPlayer = holdingPlayer {
            dict[FirebaseConstants.TileHoldingPlayer] = holdPlayer
        }
     
        dict[FirebaseConstants.TileRow] = row
        dict[FirebaseConstants.TileCol] = col
        
        dict[FirebaseConstants.TileBonusTile] = bonusTile
        dict[FirebaseConstants.TilePlayer] = self.player
       
        dict[FirebaseConstants.TileRackPosition] = rackPosition
        dict[FirebaseConstants.TileCurrentPositionX] = currentPosition.x
        dict[FirebaseConstants.TileCurrentPositionY] = currentPosition.y
        dict[FirebaseConstants.TileStartingPositionX] = startingPosition.x
        dict[FirebaseConstants.TileStartingPositionY] = startingPosition.y
        dict[FirebaseConstants.TileTypeName] = name
        
        return dict
    }
    
   class func convertTilesToDict(tiles: [Tile]) -> [String: Any] {
        var tileDict = [String: Any]()
        for (n, tile) in tiles.enumerated(){
            
            tileDict["STile_\(n)"] = tile.convertToDict()
        }
        
        return tileDict
    }

    class func initializeTileArrayFromTileDicts(tileDicts: [[String:Any]]) -> [Tile] {
        var tileArray = [Tile]()
        
        for tileDict in tileDicts {
           tileArray.append(initializeFromDict(dict: tileDict))
        }
        
        return tileArray
        
    }
   class func initializeFromDict(dict: [String:Any]) -> Tile {
    
        let tile = Tile()
        tile.initializeTile(tileValueText: nil)
        
        if let dictTileValue = dict[FirebaseConstants.TileValue] as? String {
          //  print("tile value  = \(dictTileValue)")
            if dictTileValue == GameConstants.TileDeleteTileSymbol, let player = dict[FirebaseConstants.TilePlayer] as? Int {
                tile.tileLabel.text = ""
                tile.texture = player == 1 ? SKTexture(imageNamed: "player1BlueEraser") : SKTexture(imageNamed: "player2GreenEraser")
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
            else if dictTileValue == "B" {
                tile.tileLabel.text = "💣"
                tile.tileType = TileType.bomb
                
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
    
    if let ordInPlay = dict[FirebaseConstants.TileOrderInPlay] as? Int {
        tile.tileOrderInPlay = ordInPlay
    }
    
 
    if let holdVal = dict[FirebaseConstants.TileHoldingValue] as? Int {
        tile.holdingValue = holdVal
    }
    if let holdPlayer = dict[FirebaseConstants.TileHoldingPlayer] as? Int {
        tile.holdingPlayer = holdPlayer
    }
    
    if let tileIsBonusTile = dict[FirebaseConstants.TileBonusTile] as? Bool {
        tile.bonusTile = tileIsBonusTile
    }
    
    if let rackPos = dict[FirebaseConstants.TileRackPosition] as? Int {
        tile.rackPosition = rackPos
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
        
        tile.color = GameConstants.TileStartingTilesColor
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
      
        if self.parent != nil { print("Showing tile values for tile. Value: \(String(describing: self.tileLabel.text)) row: \(self.row) col: \(self.col) player: \(player)  parent: \(self.parent)")
        }
        }
  
    func showTile(msg:String = ""){
        print("\(msg). tile row, col: \(row), \(col), value: \(tileValue), labeltext: \(tileLabel.text), player: \(player),holding val: \(holdingValue), holding player: \(holdingPlayer) order in play: \(tileOrderInPlay)")
    }
    func tileInStartingTiles() -> Bool {
       return  row == 2 &&  col == 2 ||
            row == 2 &&  col == GameConstants.BoardNumCols - 2 ||
            row == GameConstants.BoardNumRows - 2 &&  col == 2 ||
            row == GameConstants.BoardNumRows - 2 &&  col == GameConstants.BoardNumCols - 2
    }
    
    func setPositionInTileRack() {
    let tileRackDisplayWidth = GameConstants.TileRackSeparatorWidth*8 + GameConstants.TileSize.width*7
      let tileOffset = tileRackDisplayWidth/2
      self.position.x =  size.width/2 - tileOffset + GameConstants.TileRackSeparatorWidth*CGFloat(rackPosition + 1) + size.width*CGFloat(rackPosition)
     
    }
    
    func  hasSamePositionsAndValues(asOtherTile t2: Tile) -> Bool {
        return row == t2.row &&  col == t2.col &&  tileValue == t2.tileValue
            
    }

    func hasSamePositionAndValuesAsTile(inTileArray tA: [Tile]) -> Bool {
        for tile in tA {
            if hasSamePositionsAndValues(asOtherTile: tile) {
                return true
            }
        }
        return false 
    }
    
    
    
  
    
}
