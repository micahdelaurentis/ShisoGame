//
//  TileRack.swift
//  Shiso

//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import SpriteKit

class TileRack {
    
    var playerTiles = [Int:Tile]()
    var playerTilesUnset: Bool {
        for i in 0 ... 7 {
            if playerTiles[i]?.tileLabel.text != nil {
                return false
            }
        }
        return true
    }
    let tileRack: SKSpriteNode = {
        let tileRack = SKSpriteNode()
        tileRack.name = "Tile Rack"
        tileRack.size = GameConstants.TileRackDisplaySize
        tileRack.zPosition = 2
        tileRack.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tileRack.color = UIColor.green
        
        
    return tileRack
    }()
    
    func setUpPlayerTileRack(player: Int)  {
  
        if playerTilesUnset == false {
            
            for i in 0 ..< 7 {
                if let tile = playerTiles[i] {
                    tileRack.addChild(tile)
                    tile.position = tile.startingPosition
                    tile.rackPosition = i
                }
            }
        }
            
        else {
            
            for i in 0..<7 {
        
            let tile = Tile()
            tile.initializeTile(tileValueText: nil, includeRandomTextValue: true, player: player)
            tile.rackPosition = i
            if tile.name == nil { // ie not wildcard or delete tile
                tile.name = GameConstants.TilePlayerTileName
            }
            
            playerTiles[i] = tile 
            
            //position tile view in tileRack 
            
            let separatorWidth: Int = 10
            
            tile.position.x =  tileRack.position.x - tileRack.size.width/2 + 20 + CGFloat((i+1)*separatorWidth) + CGFloat(i)*tile.size.width
            
            tile.startingPosition = CGPoint(x: tile.position.x, y: tile.position.y)
                
            tileRack.addChild(tile)
            }
        }
        
    }
    
    func removeAndReplaceTileFromRack(tile: Tile, player: Int){
        print("In removeAndReplaceTileFromRack...")
        let newTilePos = tile.startingPosition
        let newTileIndex = tile.rackPosition
        
        print("replacing tile with value: \(tile.getTileLabelText()) and position: \(tile.startingPosition) and rack position \(tile.rackPosition)")
        
        
        let newTile = Tile()
        newTile.initializeTile(tileValueText: nil , includeRandomTextValue: true, player: player)
     
        switch newTile.tileLabel.text! {
        case GameConstants.TileWildCardSymbol : newTile.name = GameConstants.TileWildcardTileName
        case GameConstants.TileDeleteTileSymbol  : newTile.name = GameConstants.TileDeleteTileName
        default:
            newTile.name = GameConstants.TilePlayerTileName
        }
        
        tileRack.removeChildren(in: [tile])
        newTile.position = newTilePos
        newTile.rackPosition = newTileIndex
        newTile.startingPosition = newTilePos
        playerTiles[newTileIndex] = newTile
        tileRack.addChild(newTile)
        print("tile replaced with new tile with value : \(newTile.getTileLabelText()) and position: \(newTile.startingPosition) and rack position \(newTile.rackPosition)")
        
    }
    
 
    
    
    func convertToDict() -> [String: Any] {
        print("converting tile rack to dict....")
     
        var dict: [String: Any] = [:]
        
        for i in playerTiles.keys {
            dict["Tile_\(i)"]  = playerTiles[i]?.convertToDict()
        }
        
        return dict
    }
    
    class func convertFromDictToTileRack(dict: [String: Any]) -> TileRack{
        var playerTiles = [Int: Tile]()
        let tileRack = TileRack()
        for i in 0 ... 7 {
            if let tileDict  = dict["Tile_\(i)"] as? [String: Any] {
                playerTiles[i] = Tile.initializeFromDict(dict: tileDict)
            }
        }
        
        tileRack.playerTiles = playerTiles
        return tileRack
    }
    
    func showTileRack() {
       print( "Showing tile rack...")
        for i in 0 ... 7 {
            if let tile = playerTiles[i] {
                tile.showTileValues()
            }
        }
    }
    
    class func convertTileRackFromStr(strVersion: String) -> TileRack {
        return TileRack()
    }

    
    
}
