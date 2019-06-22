//
//  TileRack.swift
//  Shiso

//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import SpriteKit

class TileRack {
    let separatorWidth: CGFloat = 5
    var playerTiles = [Int:Tile]()
     var playerTilesUnset: Bool {
        for i in 0 ... 7 {
            if playerTiles[i]?.tileLabel.text != nil {
                return false
            }
        }
        return true
    }
 
    var tileRack = SKSpriteNode()
    
    
  /*  var tileRack: SKSpriteNode = {
        
        let tileRack = SKSpriteNode()
        tileRack.name = "Tile Rack"
        tileRack.size.width = 7*GameConstants.TileSize.width + 8*5 //1 + num tiles = 7 times the separator width = 10
        tileRack.size.height = GameConstants.TileSize.height + 2*5 //separator width above and below
        
        tileRack.zPosition = 2
        tileRack.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tileRack.color = UIColor.black
        
        
    return tileRack
    }()
 
 */
    func createTileRack() {
        tileRack.removeAllChildren()
        tileRack.name = "Tile Rack"
        tileRack.size.width = 7*GameConstants.TileSize.width + 8*5 //1 + num tiles = 7 times the separator width = 10
        tileRack.size.height = GameConstants.TileSize.height + 2*5 //separator width above and below
        
        tileRack.zPosition = 2
        tileRack.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tileRack.color = UIColor.black
    }
    func setUpPlayerTileRack(player: Int, createAllNewTiles: Bool =  false)  {
        
        createTileRack()
        if !createAllNewTiles {
            print("do not create all new tiles. tile rack already has stuff in it? child count--> \(tileRack.children.count)")
       
        
            for i in 0 ..< 7 {
                if let tile = playerTiles[i] {
                    
                    tileRack.addChild(tile)
                    //tile.position = tile.startingPosition
                   
                   tile.rackPosition = i
                    /*let rackPos = CGFloat(i)
                    tile.position.x = tile.size.width/2 - tileRack.size.width/2 + separatorWidth*(rackPos + 1) + tile.size.width*rackPos
                    */
                    tile.setPositionInTileRack()
                    tile.startingPosition = tile.position
                }
            }
        }
            
        else {
            print("create all new set of tiles...")
            for i in 0..<7 {
        
            let tile = Tile()
            tile.initializeTile(tileValueText: nil, includeRandomTextValue: true, player: player)
            tile.rackPosition = i
            if tile.name == nil { // ie not wildcard or delete tile
                tile.name = GameConstants.TilePlayerTileName
            }
            
            playerTiles[i] = tile 
            
            //position tile view in tileRack 
            
          //  let separatorWidth: Int = 5
            
          /*  tile.position.x =  tileRack.position.x - tileRack.size.width/2 + tile.size.width/2 + CGFloat((i+1)*separatorWidth) + CGFloat(i)*tile.size.width
            */
            tile.setPositionInTileRack()
            tile.startingPosition = CGPoint(x: tile.position.x, y: tile.position.y)
                print("Adding tile to tile rack....")
            tileRack.addChild(tile)
            }
        }
        
    }

   
    func removeAndReplaceTileFromRack(tile: Tile, player: Int,  completion: ((Tile) -> ())? = nil){
      print("In removeAndReplaceTileFromRack...")
        let newTilePos = tile.startingPosition
        let newTileIndex = tile.rackPosition
        
       // print("replacing tile with value: \(tile.getTileLabelText()) and position: \(tile.startingPosition) and rack position \(tile.rackPosition)")
        
        
        let newTile = Tile()
        newTile.initializeTile(tileValueText: nil , includeRandomTextValue: true, player: player)
        
     
        
        tileRack.removeChildren(in: [tile])
        newTile.position = newTilePos
        newTile.rackPosition = newTileIndex
        newTile.startingPosition = newTilePos
        playerTiles[newTileIndex] = newTile
        tileRack.addChild(newTile)
     //   print("tile replaced with new tile with value : \(newTile.getTileLabelText()) and position: \(newTile.startingPosition) and rack position \(newTile.rackPosition)")
        
        if completion != nil {
            completion!(newTile)
        }
    }
    func removeAndReplaceTileFromRack1(player: Int,  tilesLeft: Int, completion: ((Int) -> ())? = nil){
        print("In removeAndReplaceTileFromRack version 2. tilerack children count:\(tileRack.children.count) tile rack count: \(playerTiles.count)")
      var numTiles = 0
    var nTilesLeft = tilesLeft
        print("n tiles left: \(nTilesLeft)")
        // print("replacing tile with value: \(tile.getTileLabelText()) and position: \(tile.startingPosition) and rack position \(tile.rackPosition)")
    
        for i in 0..<7 {

            if !(playerTiles[i]?.row == -1 && playerTiles[i]?.col == -1)  {
              //  print("player tile is on the board because row and col not = -1. tile val: \(playerTiles[i]?.getTileTextRepresentation()) row: \(playerTiles[i]?.row) \(playerTiles[i]?.col)")
                if let tile = playerTiles[i] {
                   // print("tile doesn't have row -1 and is going to be removed from rack:...")
                    tile.showTileValues()
                    tileRack.removeChildren(in: [tile])
                }
              
                if nTilesLeft > 0 {
                
                    let newTile = Tile()
                    newTile.rackPosition = i
                    newTile.initializeTile(tileValueText: nil , includeRandomTextValue: true, player: player)

                    playerTiles[i] = newTile
                  //  print("create new tile for player: val \(newTile.getTileTextRepresentation()) at location \(i)")
                  
                    
                    tileRack.addChild(newTile)
                    newTile.setPositionInTileRack()
                    
                    numTiles += 1
                  //  print("after created tile...num Tiles created: \(numTiles)")
                    nTilesLeft -= 1
                  //  print("after created tile...num tiles Left: \(nTilesLeft)")
                    
                }
                
            }
            else {
                   //  print("player tile is NOT on the board because row and col IS -1. So won't be replaced.tile val: \(playerTiles[i]?.getTileTextRepresentation()) row: \(playerTiles[i]?.row) \(playerTiles[i]?.col)")
            }

        }
     
        
        
        /*tileRack.removeChildren(in: [tile])
        newTile.position = newTilePos
        newTile.rackPosition = newTileIndex
        newTile.startingPosition = newTilePos
        playerTiles[newTileIndex] = newTile
        tileRack.addChild(newTile) */
        //   print("tile replaced with new tile with value : \(newTile.getTileLabelText()) and position: \(newTile.startingPosition) and rack position \(newTile.rackPosition)")
        
        if completion != nil {
            completion!(numTiles)
        }
    }
    
    func removeTilesFromRack(tiles: [Tile]){
        print("in removeTilesFromRack: removing tiles...\(tiles)")
        tileRack.removeChildren(in: tiles)
        for tile in tiles {
            print("removing tile from rack: value: \(tile.getTileTextRepresentation()) rack pos: \(tile.rackPosition) row/col: \(tile.row)/\(tile.col)")
            playerTiles.removeValue(forKey: tile.rackPosition)
        }
    

    }
    func swapOutExchangedTiles(tiles: [Tile], playerN: Int) {
        var tileText = [String]()
        
        for tile in tiles {
            tileText.append(tile.getTileTextRepresentation())
        }/*
        for txt in tileText {
            print("old tile value: \(txt)")
        }*/
        for tile in tiles {
        var newTile = Tile()
            newTile.initializeTile(tileValueText: nil, includeRandomTextValue: true, player: playerN)
           // print("new tile text to try: \(newTile.getTileTextRepresentation())")
            var textToTry = newTile.getTileTextRepresentation()
            while tileText.contains(textToTry) {
             //   print("we have to replace \(textToTry) that because it's not new!")
               newTile = Tile()
                newTile.initializeTile(tileValueText: nil, includeRandomTextValue: true, player: playerN)
                textToTry = newTile.getTileTextRepresentation()
               // print("trying new value: \(textToTry)")
            }
            
            //print("final replacement of old value: \(tile.getTileTextRepresentation()) is: \(newTile.getTileTextRepresentation())")
           
            let newTilePos = tile.startingPosition
            let newTileIndex = tile.rackPosition
            tileRack.removeChildren(in: [tile])
            newTile.position = newTilePos
            newTile.rackPosition = newTileIndex
            newTile.startingPosition = newTilePos
            playerTiles[newTileIndex] = newTile
            tileRack.addChild(newTile)
        }
    }
    
    func removeTileFromRack(tile: Tile, player: Int, replace: Bool = true){
        print("replace = \(replace).")
        
        let newTilePos = tile.startingPosition
        let newTileIndex = tile.rackPosition
        tileRack.removeChildren(in: [tile])
        
        if replace {
            
            let newTile = Tile()
            newTile.initializeTile(tileValueText: nil , includeRandomTextValue: true, player: player)
            
            
            
            newTile.position = newTilePos
            newTile.rackPosition = newTileIndex
            newTile.startingPosition = newTilePos
            playerTiles[newTileIndex] = newTile
            tileRack.addChild(newTile)
            print("tile replaced with new tile with value : \(newTile.getTileLabelText()) and position: \(newTile.startingPosition) and rack position \(newTile.rackPosition)")
        }
   
        else {
        playerTiles[newTileIndex] = nil
        }
      
  
    }
    
 
    
    
    func convertToDict() -> [String: Any] {
        print("converting tile rack to dict....")
     
        var dict: [String: Any] = [:]
        
        for i in playerTiles.keys /*where playerTiles[i] != nil */ {
    
        print("looking at tile \(i) in tile rack in converting tile rack to dict...")
            dict["Tile_\(i)"]  = playerTiles[i]?.convertToDict()
            print("tile \(i) in rack has value: \(playerTiles[i]?.getTileTextRepresentation())")
        }
        
        print("dict: \(dict)")
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
