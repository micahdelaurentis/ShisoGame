//
//  Board.swift
//  Shiso
//

//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import SpriteKit
import UIKit

class Board {
   
    var startingTiles = [Tile]()
    var bonusPointTiles = [Tile]()
    var grid = [[Tile]]() 
   
    
    var intersectingBlocks = [[Tile]]()
    var alreadyCountedTargetTiles = [Tile]()
    
    func setUpBoard() -> SKSpriteNode {
        let gridEmpty = grid.isEmpty
        print("In set up board. grid empty: \(gridEmpty)")
 
        print(" grid empty: \(gridEmpty), n tiles in grid: \(grid.count)")
    
        let board = SKSpriteNode()
        board.color = .black
        let boardDimension = GameConstants.TileSize.width * CGFloat(GameConstants.BoardNumCols + 1)
           + GameConstants.BoardSeparatorWidth * CGFloat(GameConstants.BoardNumCols + 2 )
       
        board.size = CGSize(width: boardDimension, height: boardDimension)
        
        board.anchorPoint = GameConstants.BoardAnchorPoint
        
        let separatorWidth = GameConstants.BoardSeparatorWidth
        
        
        var row = [Tile]()
        var rand = 0
        
        for j in 0...GameConstants.BoardNumRows {
           rand = Int(arc4random_uniform(UInt32(8)))
            for i in 0 ... GameConstants.BoardNumCols {
               
                
                let tile = gridEmpty ? Tile() : grid[j][i]
             
                if gridEmpty {
                
                if j==2 && i==2 || j==2 && i == (GameConstants.BoardNumRows - 2) || j==((GameConstants.BoardNumRows - 2)) && i==2
                    || (j==(GameConstants.BoardNumRows - 2) && i==(GameConstants.BoardNumRows - 2)) {
                   
                    tile.initializeTile(tileValueText: nil, includeRandomTextValue: true)
                    tile.color = GameConstants.TileStartingTilesColor 
                   //print("In board, creating tiles, tile name: \(tile.name)")
                    while tile.tileType == TileType.eraser || tile.tileType == TileType.wildcard  || tile.tileType == TileType.bomb {
                        
                         tile.setTileValue(value: Int(arc4random_uniform(25)))
                         tile.texture = nil
                         tile.tileType = TileType.regular
                    }
                    startingTiles.append(tile)
                }
                else if j == 0 && i == 0 || j == 0 && i == 9 ||
                    j == 9 && i == 9
                    || j == 9 && i == 0
                    || i == 3 && j == 3 || i == 3 && j == 8
                    || i == 6 && j == 1 || i == 6 && j == 6
                    
                {
                    tile.initializeTile(tileValueText: "+2")
                    tile.tileLabel.fontColor = .gray
                    bonusPointTiles.append(tile)
                }
               else {
                    tile.initializeTile(tileValueText: nil)
                  
                    }
                    
                tile.anchorPoint = GameConstants.TileAnchorPoint
                tile.zPosition = GameConstants.TileZposition
                tile.name = GameConstants.TileBoardTileName
                tile.row = j
                tile.col = i
                  
                    tile.position.x = CGFloat(i + 1)*separatorWidth - board.size.width/2 + tile.size.width/2 + CGFloat(i)*tile.size.width
                    tile.position.y = board.size.height/2 -  CGFloat(j + 1)*separatorWidth - tile.size.height/2 - CGFloat(j)*tile.size.height
                    
              //  tile.position = CGPoint(x:CGFloat(i + 1)*separatorWidth - (board.size.width)/2 + tile.size.width*CGFloat(i), y:
              //      board.size.height/2 - CGFloat(j + 1)*separatorWidth - tile.size.height - tile.size.height*CGFloat(j))
                tile.currentPosition = tile.position 
                row.append(tile)
                
                if i == GameConstants.BoardNumRows {
                    grid.append(row)
                    row.removeAll()
                }
        
            }
            
                else {
                 //  tile.position = tile.currentPosition
                tile.position.x = CGFloat(tile.col + 1)*separatorWidth - board.size.width/2 + tile.size.width/2 +  CGFloat(tile.col)*tile.size.width
                    
                tile.position.y = board.size.height/2 -  CGFloat(tile.row + 1)*separatorWidth - tile.size.height/2 - CGFloat(tile.row)*tile.size.height
                }
           // print("about to add tile to board")
             //   tile.showTileValues()
            
                board.addChild(tile)
            
            }
        
        }
        
        
        
        
     
        return board 
    }
    

    func convertBoardToView(tilew: Int, tileh: Int, separatorWidthInt:Int = 1 ) -> UIView {
       
        let boardWidth = tilew*(GameConstants.BoardNumRows + 1) + separatorWidthInt*(GameConstants.BoardNumRows + 2)
        let boardHeight = tileh*(GameConstants.BoardNumCols + 1) + separatorWidthInt*(GameConstants.BoardNumCols + 2)
        let boardView = UIView(frame: CGRect(x: 0, y: 0, width: boardWidth, height: boardHeight))
        boardView.backgroundColor = .black
       
        if grid.isEmpty {
            print("Grid empty...creating board")
            let _ = setUpBoard()
            print("Board set up...grid empty is now: \(grid.isEmpty)")
        }
        
        for row in 0 ... GameConstants.BoardNumRows {
            for col in 0 ... GameConstants.BoardNumCols {
              
                let tile = getTile(atRow: row, andCol: col)
                    let tileUIBtn = UIButton()
                    tileUIBtn.frame.size = CGSize(width: tilew, height: tileh)
                    let txt = tile.getTileLabelText()
                
                    tileUIBtn.setTitle("\(txt)", for: .normal)
                    tileUIBtn.setTitleColor(.black, for: .normal)
                    tileUIBtn.titleLabel?.font = UIFont(name: GameConstants.TileLabelFontName, size: 13)
                    
                
                    tileUIBtn.backgroundColor = tile.color
                    tileUIBtn.layer.borderColor = UIColor.black.cgColor
                    tileUIBtn.layer.borderWidth = 0.5
                
                   tileUIBtn.frame.origin.x = CGFloat((col + 1)*separatorWidthInt + col*tilew)
                   tileUIBtn.frame.origin.y = CGFloat((row + 1)*separatorWidthInt + row*tileh)
                   
                   boardView.addSubview(tileUIBtn)

                }
            }
        
        
     
        
        
        return boardView
    }
    
 
    
    
    
    
    
    
    func getTileLabelText(row: Int, col: Int) -> String? {
        return grid[row][col].tileLabel.text
    }
    
    
    
    func getTileValue(row: Int, col: Int) -> Int? {
        return grid[row][col].tileValue
    }
    
    func getTile(atRow row: Int, andCol col: Int) -> Tile {
    
        return grid[row][col]
    }
    
    func isTileValueEmpty(atRow row: Int, andCol col: Int) -> Bool {
        
        return getTile(atRow: row, andCol: col).tileIsEmpty
    }
    
    func setTileValue(row: Int, col: Int, value: Int?) {
         grid[row][col].tileValue = value
    }
    
    func setTileInGrid(row: Int , col: Int, tile: Tile) {
     
            grid[row][col] = tile
      
    }
    
    func appendTileRowInGrid(tileRow: [Tile]) {
        grid.append(tileRow)
    }
    
    

    func tileLabelTextIsEmpty(row: Int, col: Int) -> Bool {
        return getTileLabelText(row: row, col: col) == ""
    }
    
    func tileValueIsEmpty(row: Int, col: Int) -> Bool {
        return getTileValue(row: row, col: col) == nil
    }
    
    func getBoxLocsForTiles(tiles: [Tile]) -> [BoxLoc] {
      var  boxLocs = [BoxLoc]()
        for r in 0...GameConstants.BoardNumRows - 2 {
            for c in 0...GameConstants.BoardNumCols - 2 {
                var boxTileCount = 0
                for i in r...r + 2 {
                    for j in c ... c + 2 {
                        if !getTile(atRow: i, andCol: j).tileIsEmpty {
                            boxTileCount += 1
                        }
                    }
                }
                if boxTileCount == 9 {
                    print("in board get box locs for nondelete tiles: box found with middle tile row: \(r+1) col: \(c+1)")
                    for tile in tiles {
                        if r <= tile.row && tile.row <= r + 2 && c <= tile.col && tile.col <= c + 2 {
                            boxLocs.append(BoxLoc(row: r + 1, col: c + 1, newBox: true))
                            print("in board, box DOES contain nondelete selected tile with value: \(String(describing: tile.tileValue)), at row/col: \(tile.row), \(tile.col) --> adding box with center: row: \(r+1) col: \(c+1)")
                            break
                        }
                        else {
                            print("in board, box doesn't contain any nondelete tiles, not adding row: \(r+1) col: \(c+1)")
                        }
                    }
                 //   boxLocs.append(BoxLoc(row: r + 1, col: c + 1))
                }
                
            }
        }
        
        return boxLocs
    }
    
    
    func getBoxofTiles(withCenterTile tile: Tile) -> [Tile] {
        var box = [Tile]()
        
        let row = tile.row
        let col = tile.col
        
        for c in max(0, col - 1) ... min(GameConstants.BoardNumCols, col + 1) {
            for r in max(0, row - 1) ... min(GameConstants.BoardNumRows, row + 1){
           box.append(getTile(atRow: r, andCol: c))
    
            }
        }
        
        return box
    }
    
    
    
    
    func tileIsWithinBombBounds(tile: Tile, bombTile: Tile) -> Bool {
        guard bombTile.tileType == .bomb else {
            return false
        }
        
        return bombTile.row - 1 <= tile.row  && tile.row <= bombTile.row + 1
            && bombTile.col - 1 <= tile.col && tile.col <= bombTile.col + 1
        
    }
   
    func tileIsPlayTileWithinBombBounds(tile: Tile, bombTile: Tile, plays: [Play]) -> Bool {
        var tileInPlays = false
        for play in plays{
            for playTile in play.playTiles {
                if tile.tileType != .bomb && tile.tileType != .eraser && tile.row == playTile.row && tile.col == playTile.col {
                    tileInPlays = true
                    break
                }
            }
        }
        
        return tileInPlays && tileIsWithinBombBounds(tile: tile, bombTile: bombTile)
    }
    
    
    
    
    func boxTilesHaveNonStarterValuedTiles(withCenterTile tile: Tile) -> Bool {
        
        for sTile in getBoxofTiles(withCenterTile: tile) where !sTile.starterTile {
            showTile(tile: sTile, message: "in box of tiles surrounding t")
            if !sTile.tileIsEmpty {
                print("non-empty tile found...returning True")
                return true
            }
        }
        print("no non-empty tile found, returnign false")
        return false
    }
    
   
    
    
    func tilesHaveAnyValuesAsideFromStarterTiles(tiles: [Tile]) -> Bool {
        
        for tile in tiles where !tile.starterTile {
            if !tile.tileIsEmpty {
                return true
            }
        }
        return false
        
    }
    
   
    
    
    func getTiles(atRow row: Int) -> [Tile] {
        
        var tiles = [Tile]()
        
        for tile in grid[row] {
            tiles.append(tile)
            }
        
        return tiles
    }
    
    
    
    func getTiles(atCol col: Int) -> [Tile] {
        
        var tiles = [Tile]()
        
        
        for i in 0 ... GameConstants.BoardNumCols {
            
            tiles.append(grid[i][col])
        }
        
        return tiles
    }
    
    
    func getTiles(fromTileArray tiles: [Tile]) -> [Tile] {
        var gameBoardTiles = [Tile]()
        for tile in tiles {
            gameBoardTiles.append(getTile(atRow: tile.row, andCol: tile.col))
        }
        return gameBoardTiles
    }
    
    func getTilesAtCol(col: Int, minRow: Int = 0, maxRow:Int = GameConstants.BoardNumRows) -> [Tile] {
        
        var tiles = [Tile]()
        
        for row in minRow ... maxRow {
            
            tiles.append(grid[row][col])
            
        }
        
        return tiles
    }
    
    func getTilesAtRow(row: Int, minCol: Int = 0, maxCol:Int = GameConstants.BoardNumCols) -> [Tile] {
        
        var tiles = [Tile]()
        
        for col in minCol ... maxCol {
            
            tiles.append(grid[row][col])
            
        }
        
        return tiles
    }
    
    
    func tileIsConnectedToBoardTileWithValue(tile: Tile) -> Bool {
        
        let row = tile.row
        let col = tile.col
        var otherTile = Tile()
        
        if row > 0 {
             otherTile = getTile(atRow: row - 1, andCol: col)
           
            if otherTile.inSelectedPlayerTiles == false && otherTile.tileIsEmpty == false {
                return true
            }
        }
        
        if row < GameConstants.BoardNumRows {
        otherTile = getTile(atRow: row + 1, andCol: col)
        if otherTile.inSelectedPlayerTiles == false && otherTile.tileIsEmpty == false {
            return true
        }
        }
        
        if col > 0 {
            
        otherTile = getTile(atRow: row, andCol: col - 1)
        
            if otherTile.inSelectedPlayerTiles == false && otherTile.tileIsEmpty == false {
            return true
            }
        }
        
        if col < GameConstants.BoardNumCols {
            
            otherTile = getTile(atRow: row, andCol: col + 1)
        if otherTile.inSelectedPlayerTiles == false && otherTile.tileIsEmpty == false {
            return true
        }
        }
        
    
        return false
    }
    
    
    func anyTilesTouchingOriginalBoardTilesWithValue(tiles: [Tile]) -> Bool {
        for tile in tiles {
            if tileIsConnectedToBoardTileWithValue(tile: tile) {
                return true
            }
        }
        return false
    }
    /*
    func getAllSetsOfThreeTilesConnectedToTile(tile: Tile) -> [[Tile]] {
        
        
        var allSetsOfThreeTiles = [[Tile]]()
        let row = tile.row
        let col = tile.col
        let boardTile = getTile(atRow: row, andCol: col)
        
        
        if col - 1 > 0 && !tileValueIsEmpty(row: row, col: col - 1) {
            if col - 2 > 0 && !tileValueIsEmpty(row: row, col: col - 2) {
                
                allSetsOfThreeTiles.append([getTile(atRow: row, andCol: col-2), getTile(atRow: row, andCol: col-1),
                                            boardTile])
            }
            
            else if col + 1 < 7 && !tileValueIsEmpty(row: row, col: col + ){
               
            }
        }
        
        
        
        
        return allSetsOfThreeTiles
    }
    */
    
    func getLeftConnectedValuedTiles(tile: Tile) -> [Tile] {
    var leftSet = [Tile]()
    let row = tile.row
    let col = tile.col
    var left1Tile: Tile?
    var left2Tile: Tile?
    
        if col - 2 >= 0 {
            if !tileValueIsEmpty(row: row , col: col - 2) {
                 left2Tile = getTile(atRow: row, andCol: col - 2)
                
            }
        }
        if col - 1 >= 0 {
            if !tileValueIsEmpty(row: row , col: col - 1) {
                 left1Tile = getTile(atRow: row, andCol: col - 1)
              
            }
        }
        
        
        if left1Tile != nil {
            
            if left2Tile != nil {
                leftSet.append(left2Tile!)
                leftSet.append(left1Tile!)
                leftSet.append(tile)
            }
            
            else {
                leftSet.append(left1Tile!)
                leftSet.append(tile)
            }
        }
        
        return leftSet
}
    
    func isConnectedToValuedTilesLeft(tile: Tile) -> Bool {
        return getLeftConnectedValuedTiles(tile: tile).count > 0
    }
    
    
    
    
    func getRightConnectedValuedTiles(tile: Tile) -> [Tile] {
        var rightSet = [Tile]()
        
        
        let row = tile.row
        let col = tile.col
        
        //print("in get right connected tiles...checking on tile: \(tile.getTileTextRepresentation())")
    
        var right2Tile: Tile?
        var right1Tile: Tile?
        

        if col + 1 <= GameConstants.BoardNumCols {
            if !tileValueIsEmpty(row: row , col: col + 1) {
                right1Tile = getTile(atRow: row, andCol: col + 1)
            }
        }
        
        if col + 2 <= GameConstants.BoardNumCols {
            if !tileValueIsEmpty(row: row , col: col + 2) {
                right2Tile = getTile(atRow: row, andCol: col + 2)
            }
        }
        
        if right1Tile != nil {
            rightSet.append(tile)
            rightSet.append(right1Tile!)
            
            if right2Tile != nil {
                rightSet.append(right2Tile!)
            }
        }
        
        
  
        return rightSet
    }
    
    func isConnectedToValuedTilesRight(tile: Tile) -> Bool {
        return getRightConnectedValuedTiles(tile: tile).count > 0
    }

    func getRightLeftConnectedValueTiles(tile: Tile) -> [Tile] {
        var set = [Tile]()
        
       let row = tile.row
       let col = tile.col
        
        if isConnectedToValuedTilesLeft(tile: tile) {
            set.append(getTile(atRow: row, andCol: col - 1))
        }
        set.append(tile)
        if isConnectedToValuedTilesRight(tile: tile) {
            set.append(getTile(atRow: row, andCol: col + 1))
        }
    return set
    }
    
    func isConnectedToValuedTilesRightLeft(tile: Tile) -> Bool {
        return isConnectedToValuedTilesRight(tile: tile) && isConnectedToValuedTilesLeft(tile: tile)
    }
    
    
    func getTopConnectedValuedTiles(tile: Tile) -> [Tile] {
        var topSet = [Tile]()
        let row = tile.row
        let col = tile.col
        var top2Tile: Tile?
        var top1Tile: Tile?
        
        if row - 2 >= 0 {
            if !tileValueIsEmpty(row: row - 2, col: col) {
                top2Tile = getTile(atRow: row - 2, andCol: col)
            }
        }
        if row - 1 >= 0 {
            if !tileValueIsEmpty(row: row - 1 , col: col) {
                top1Tile = getTile(atRow: row - 1, andCol: col)
            }
        }
        if top1Tile != nil {
            topSet.append(tile)
            topSet.append(top1Tile!)
            if top2Tile != nil {
                topSet.append(top2Tile!)
            }
        }
        
        
        return topSet
    }
    
    func isConnectedToValuedTilesTop(tile: Tile) -> Bool {
        return getTopConnectedValuedTiles(tile: tile).count > 0
    }
    
    
    
    func getBottomConnectedValuedTiles(tile: Tile) -> [Tile] {
        var bottomSet = [Tile]()
                
        let row = tile.row
        let col = tile.col
        
        var bottom1Tile: Tile?
        var bottom2Tile: Tile?
        
        if row + 1 <= GameConstants.BoardNumRows {
            if !tileValueIsEmpty(row: row + 1 , col: col) {
                bottom1Tile = getTile(atRow: row + 1, andCol: col)
            }
        }
        
        if row + 2 <= GameConstants.BoardNumRows {
            if !tileValueIsEmpty(row: row + 2, col: col) {
                bottom2Tile = getTile(atRow: row + 2, andCol: col)
            }
        }
        
        if bottom1Tile != nil {
            bottomSet.append(tile)
            bottomSet.append(bottom1Tile!)
            
            if bottom2Tile != nil {
                bottomSet.append(bottom2Tile!)
            }
        }
        
        return bottomSet
    }
    
    func isConnectedToValuedTilesBottom(tile: Tile) -> Bool {
        return getBottomConnectedValuedTiles(tile: tile).count > 0
    }
    

    
    func getBottomTopConnectedValuedTiles(tile: Tile) -> [Tile] {
        var set = [Tile]()
        
        let row = tile.row
        let col = tile.col
        
        if isConnectedToValuedTilesTop(tile: tile) {
            set.append(getTile(atRow: row - 1, andCol: col))
        }
        set.append(tile)
        if isConnectedToValuedTilesBottom(tile: tile) {
            set.append(getTile(atRow: row + 1, andCol: col))
        }
        return set
    }
    
    func isConnectedToValuedTilesBottomTop(tile: Tile) -> Bool {
        return isConnectedToValuedTilesBottom(tile: tile) && isConnectedToValuedTilesTop(tile: tile)
    }
    
    func numberOfLeftConnectedValuedTiles(tile: Tile) -> Int {
        if isConnectedToValuedTilesLeft(tile: tile) {
            return max(0,getLeftConnectedValuedTiles(tile: tile).count - 1)
        }
        else {
            return 0
        }
    }
    
    func numberOfRightConnectedValuedTiles(tile: Tile) -> Int {
        if isConnectedToValuedTilesRight(tile: tile) {
            return max(0, getRightConnectedValuedTiles(tile: tile).count - 1)
            
        }
        else {
            return 0
        }
    }
    
    
    func numberOfTopConnectedValuedTiles(tile: Tile) -> Int {
        if isConnectedToValuedTilesTop(tile: tile) {
            return max(0, getTopConnectedValuedTiles(tile: tile).count - 1)
        }
        else {
            return 0
        }
    }
    
    func numberOfBottomConnectedValuedTiles(tile: Tile) -> Int {
        if isConnectedToValuedTilesBottom(tile: tile) {
            return max(0, getBottomConnectedValuedTiles(tile: tile).count - 1)
                       }
        else {
            return 0
        }
    }
    

    func tileIsLeftOrRightConnectedToTargetTile(tile: Tile, targetTiles: [Tile]) -> Bool {
       showTile(tile: tile, message: "Checking right/left connected in hug function")
        var leftTile: Tile?
        var rightTile: Tile?
        if isConnectedToValuedTilesLeft(tile: tile) {
            leftTile = getLeftConnectedValuedTiles(tile: tile).reversed()[1]
            if let leftTile = leftTile {
                showTile(tile: leftTile, message: "left Connected Tile")
                if targetTiles.contains(leftTile){
                    return true
                }
            }
        }
        if isConnectedToValuedTilesRight(tile: tile) {
            rightTile = getRightConnectedValuedTiles(tile: tile)[1]
            
            if let rightTile = rightTile {
                showTile(tile: rightTile, message: "right Connected Tile")
                if targetTiles.contains(rightTile){
                    return true
                }
            }
        }
        
//        if let left = leftTile {
//
//            if targetTiles.contains(left) {
//                return true
//            }
//        }
//        else if let right = rightTile {
//            if targetTiles.contains(right) {
//                return true
//            }
//        }
        
        return false
        
    }
    
    
    
    func tileIsTopOrBottomConnectedToTargetTile(tile: Tile, targetTiles: [Tile]) -> Bool {
        showTile(tile: tile, message: "checking if top/bottom connected in hug function")
        var topTile: Tile?
        var bottomTile: Tile?
        if isConnectedToValuedTilesTop(tile: tile) {
            topTile = getTopConnectedValuedTiles(tile: tile).reversed()[1]
            if let topTile = topTile {
                showTile(tile: topTile, message: "top tile")
                if targetTiles.contains(topTile) {
                    return true
                }
            }
        }
        if isConnectedToValuedTilesBottom(tile: tile) {
            bottomTile = getBottomConnectedValuedTiles(tile: tile)[1]
            if let bottomTile = bottomTile {
                showTile(tile: bottomTile, message: "bottom tile")
                if targetTiles.contains(bottomTile) {
                    return true
                }
            }
       
        }
        
  /*      if let top = topTile {
            print("tile is connected to top tile")
            if targetTiles.contains(top) {
                return true
            }
        }
        else if let bottom = bottomTile {
            print("tile is connected to bottom tile")
       
            if targetTiles.contains(bottom) {
                return true
            }
        }
     
        */
        print("target tiles doesn't contain top or bottom tile in hug function. returning false")
        return false
        
    }

    
    func getIntersectingGameBoardTilesFromTileArrays(tileArray1: [Tile], tileArray2: [Tile]) -> [Tile] {
        
        var intersectingTiles = [Tile]()
        for tile in tileArray1 {
            if tileArray2.contains(tile) {
                intersectingTiles.append(tile)
                
            }
        }
        return intersectingTiles
    }
    
    func TileArraysIntersect(tileArray1: [Tile], tileArray2: [Tile]) -> Bool {
        return getIntersectingGameBoardTilesFromTileArrays(tileArray1: tileArray1, tileArray2: tileArray2).count != 0
    }
    
    
    
    
    func getMinimallySpanningRowTileBlockContainingTile(tile: Tile) -> [Tile] {
      
        print("in get min spanning row tiles containing \(tile.row), \(tile.col)")
        var tiles = [Tile]()
        
        let row = tile.row
        let col = tile.col
        let boardTile = getTile(atRow: row, andCol: col)
        
      
        if col - 1 >= 0 {
            for lCol in (0 ... col-1).reversed() {
               
                
                        let lTile = getTile(atRow: row, andCol: lCol)
                        if !lTile.tileIsEmpty {
                        tiles.append(lTile)
                        }
                            
                else {
                    break
                    }
                
            }
        
            if tiles.count > 0 {
                tiles = tiles.reversed()
            }
            
        }
        
        
        tiles.append(boardTile)
        
        if col + 1 <= GameConstants.BoardNumCols {
            for rCol in (col + 1)...GameConstants.BoardNumCols {
               
              
                    let rTile = getTile(atRow: row, andCol: rCol)
                    if !rTile.tileIsEmpty {
                        tiles.append(rTile)
                    }
                        
                    else {
                        break
                    }
                
            }
        }
    
      
        showTiles(tiles: tiles, message: "tiles in min spanning row")
    
        return tiles
    }
    func showTile(tile: Tile, message: String? = nil) {
        let message  = message ?? ""
        print("\(message)...tile empty: \(tile.tileIsEmpty), row, col = \(tile.row), \(tile.col) value: \(tile.tileLabel.text ?? "") ")
    }
    func showTiles(tiles: [Tile], message: String?) {
        for tile in tiles {
            showTile(tile: tile, message: message)
        }
    }
    
    
    
    func getMinimallySpanningColTileBlockContainingTile(tile: Tile) -> [Tile] {
        var tiles = [Tile]()
        
        
        let row = tile.row
        let col = tile.col
        let boardTile = getTile(atRow: row, andCol: col)
        
        if row - 1 >= 0 {
        for aRow in (0...row-1).reversed() {
            
           
          
                let aTile = getTile(atRow: aRow, andCol: col)
                if !aTile.tileIsEmpty {
                    tiles.append(aTile)
                }
                else {
                    break
                }
            
            
            if tiles.count > 0 {
               tiles =  tiles.reversed()
            }
            
        }
        }
        tiles.append(boardTile)
        
        if row + 1 <= GameConstants.BoardNumRows {
            for bRow in (row + 1)...GameConstants.BoardNumRows {
               let bTile = getTile(atRow: bRow, andCol: col)
                if !bTile.tileIsEmpty {
                    tiles.append(bTile)
                }
                else {
                    break
                }
            }
            
        }
        
        
        showTiles(tiles: tiles, message: "min spanning col tiles")
        return tiles
    }
    
    func tileIsPartOfColBlock(tile: Tile) -> Bool {
        return getMinimallySpanningColTileBlockContainingTile(tile: tile).count > 1
    }
  
    
    func tileIsPartOfRowBlock(tile: Tile) -> Bool {
        return getMinimallySpanningRowTileBlockContainingTile(tile: tile).count > 1
    }

    

    func getTilesInIntersectingBlocks( seedTiles: [Tile]?, targetTiles: [Tile])  {
        
        print("In get tiles in intersecting blocks")
        guard targetTiles.count > 0 else {return }
        
        
        
        var searchFunc: (Tile) -> [Tile]
        var hugFunc: (Tile,[Tile]) -> Bool
        var startTiles: [Tile]!
        
        if seedTiles == nil {
            let startTile = targetTiles[0]
            print("start tile is at row,col: \(targetTiles[0].row), \(targetTiles[0].col)")
            
            if tileIsPartOfRowBlock(tile: startTile) {
                print("start tile is part of row block")
                startTiles = getMinimallySpanningRowTileBlockContainingTile(tile: startTile)
                searchFunc = getMinimallySpanningColTileBlockContainingTile
                //hugFunc = tileIsTopOrBottomConnectedToTargetTile
                hugFunc = tileMinSpanColSetContainsTargetTile
            }
                
            else {
                print("start tile is part of col block")
                startTiles = getMinimallySpanningColTileBlockContainingTile(tile: startTile)
                searchFunc = getMinimallySpanningRowTileBlockContainingTile
                //hugFunc = tileIsLeftOrRightConnectedToTargetTile
                 hugFunc = tileMinSpanRowSetContainsTargetTile
            }
            
        
        }
        
        else {
            guard seedTiles!.count > 1 else {return }
            
            startTiles = seedTiles!
            
            
            for tile in startTiles {
                print("start Tile \(tile.getTileValue()!)")
            }
            
            
            let startTile0 = startTiles[0]
            let startTile1 = startTiles[1]
            
            if startTile0.row == startTile1.row {
                searchFunc = getMinimallySpanningColTileBlockContainingTile
               // hugFunc = tileIsTopOrBottomConnectedToTargetTile
                hugFunc = tileMinSpanColSetContainsTargetTile
            }
            
            else {
                searchFunc = getMinimallySpanningRowTileBlockContainingTile
              //  hugFunc = tileIsLeftOrRightConnectedToTargetTile
                
                hugFunc = tileMinSpanRowSetContainsTargetTile
            }
            
        }
                // NOTE: target tiles will be the nonDeleteSelectedPlayerTiles
        // startTiles is the min spanning block containing at least one target tile
       
        
       
        
        for tile in startTiles {
            print("looping thru start tiles, at row,col: \(tile.row), \(tile.col)")
            if targetTiles.contains(tile) && !alreadyCountedTargetTiles.contains(tile){
                print("Target tiles contains row,col: \(tile.row), \(tile.col)")
                alreadyCountedTargetTiles.append(tile)
                
                if hugFunc(tile, targetTiles) {
                    
                    let tileSet =  searchFunc(tile)
                    for newTile in tileSet where newTile != tile  {
                        if targetTiles.contains(newTile) && !alreadyCountedTargetTiles.contains(newTile) {
                            
                            getTilesInIntersectingBlocks(seedTiles: tileSet, targetTiles: targetTiles)
                        }
                    }
                }
                
            }
            else {
                print("target tiles doesn't contain \(tile.getTileValue())")
            }
            
        }
        
    }
    
    
    func checkThatAlreadyCountedTargetTilesContainsAllTargetTiles(targetTiles: [Tile]) -> Bool {
    
        for tile in targetTiles {
            if !alreadyCountedTargetTiles.contains(tile) {
                return false
            }
        }
        
        return true
    }
    
   
    func checkIfLegalTilePath(targetTiles: [Tile]) -> Bool {
        print("In board check if legal path")
        alreadyCountedTargetTiles.removeAll()
        intersectingBlocks.removeAll()
        guard targetTiles.count > 0 else {
            print("no target tiles in check if legal tile path, returning false")
            return false }
        
        if targetTiles.count == 1 {
            return true
        }
        
        for t in targetTiles {
            showTile(tile: t, message: "check if legal tile path target tiles...")
        }
        getTilesInIntersectingBlocks(seedTiles: nil, targetTiles: targetTiles)
        
        return checkThatAlreadyCountedTargetTilesContainsAllTargetTiles(targetTiles: targetTiles)
        
        
        
        }
    
    /* check if tile's minimum spanning column set contains a tile in target tiles other than itself */
    func tileMinSpanColSetContainsTargetTile(tile: Tile, targetTiles: [Tile]) -> Bool {
      
        return getMinimallySpanningColTileBlockContainingTile(tile: tile).filter({ (e) -> Bool in
            e != tile && targetTiles.contains(e)
        }).count > 0
       
    }
    func tileMinSpanRowSetContainsTargetTile(tile: Tile, targetTiles: [Tile]) -> Bool {
        print("in tile min span row set contains target tile. tile: \(tile.row),\(tile.col)")
        return getMinimallySpanningRowTileBlockContainingTile(tile: tile).filter({ (e) -> Bool in
            e != tile && targetTiles.contains(e)
        }).count > 0
        
    }
    
    func convertToDict() -> [String:Any] {
        print("In Board.convertToDict...")
        var boardDict:[String: Any] = [:]
        for i in 0 ... GameConstants.BoardNumRows {
            for j in 0 ... GameConstants.BoardNumCols {
                let tile = getTile(atRow: i, andCol: j)
                
                    boardDict["Row\(i)_Col\(j)"] = tile.convertToDict()
            }
        }
        
        return boardDict
    }
    
    func showBoard(msg: String = "") {
        print ("Showing board...\(msg)")
        if grid.count - 1 > -1 {
        for i in 0 ... grid.count - 1{
            for j in 0 ... grid[0].count - 1 {
                print("Tile at row,col: (\(i),\(j))label text = \(String(describing: getTile(atRow: i, andCol: j).tileLabel.text))")
                
            }
        }
        }
    }
    
    func percentOfBoardOccupied() -> Float {
        print("in percent of board occupied")
        var numValuedTiles: Float = 0
        for i in 0 ... GameConstants.BoardNumRows {
                   for j in 0 ... GameConstants.BoardNumCols {
                    numValuedTiles +=  getTile(atRow: i, andCol: j).tileIsEmpty ? 0 : 1
                       
                         
                   }
               }
    
    
        let ans: Float =  numValuedTiles/Float(100)
    
        print("percent of board occupied  = \(ans) -- \(numValuedTiles) out of 100")
        return ans
        
    }
    
    
    
}//end of class
