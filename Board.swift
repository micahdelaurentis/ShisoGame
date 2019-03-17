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
                    while tile.tileType == TileType.eraser || tile.tileType == TileType.wildcard {
                        
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
       
        var leftTile: Tile?
        var rightTile: Tile?
        if isConnectedToValuedTilesLeft(tile: tile) {
            leftTile = getLeftConnectedValuedTiles(tile: tile).reversed()[1]
        }
        if isConnectedToValuedTilesRight(tile: tile) {
            rightTile = getRightConnectedValuedTiles(tile: tile)[1]
        }
        
        if let left = leftTile {
            if targetTiles.contains(left) {
                return true
            }
        }
        else if let right = rightTile {
            if targetTiles.contains(right) {
                return true
            }
        }
        
        return false
        
    }
    
    
    
    func tileIsTopOrBottomConnectedToTargetTile(tile: Tile, targetTiles: [Tile]) -> Bool {
        
        var topTile: Tile?
        var bottomTile: Tile?
        if isConnectedToValuedTilesTop(tile: tile) {
            topTile = getTopConnectedValuedTiles(tile: tile).reversed()[1]
        }
        if isConnectedToValuedTilesBottom(tile: tile) {
            bottomTile = getBottomConnectedValuedTiles(tile: tile)[1]
        }
        
        if let top = topTile {
            if targetTiles.contains(top) {
                return true
            }
        }
        else if let bottom = bottomTile {
            if targetTiles.contains(bottom) {
                return true
            }
        }
        
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
    
     
        
    
        return tiles
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
        
        for tile in tiles {
            print("min spanning col tiles: \(tile.getTileValue()!) row: \(tile.row) col: \(tile.col)")
        }
        return tiles
    }
    
    func tileIsPartOfColBlock(tile: Tile) -> Bool {
        return getMinimallySpanningColTileBlockContainingTile(tile: tile).count > 1
    }
  
    
    func tileIsPartOfRowBlock(tile: Tile) -> Bool {
        return getMinimallySpanningRowTileBlockContainingTile(tile: tile).count > 1
    }

    

    func getTilesInIntersectingBlocks( seedTiles: [Tile]?, targetTiles: [Tile])  {
        
        guard targetTiles.count > 0 else {return }
        
        
        
        var searchFunc: (Tile) -> [Tile]
        var hugFunc: (Tile,[Tile]) -> Bool
        var startTiles: [Tile]!
        
        if seedTiles == nil {
            let startTile = targetTiles[0]
            
            if tileIsPartOfRowBlock(tile: startTile) {
                startTiles = getMinimallySpanningRowTileBlockContainingTile(tile: startTile)
                searchFunc = getMinimallySpanningColTileBlockContainingTile
                hugFunc = tileIsTopOrBottomConnectedToTargetTile
            }
                
            else {
                startTiles = getMinimallySpanningColTileBlockContainingTile(tile: startTile)
                searchFunc = getMinimallySpanningRowTileBlockContainingTile
                hugFunc = tileIsLeftOrRightConnectedToTargetTile
                
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
                hugFunc = tileIsTopOrBottomConnectedToTargetTile

            }
            
            else {
                searchFunc = getMinimallySpanningRowTileBlockContainingTile
                hugFunc = tileIsLeftOrRightConnectedToTargetTile

            }
            
        }
                // NOTE: target tiles will be the nonDeleteSelectedPlayerTiles
        // startTiles is the min spanning block containing at least one target tile
       
        
       
        
        for tile in startTiles {
            if targetTiles.contains(tile) && !alreadyCountedTargetTiles.contains(tile){
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
        alreadyCountedTargetTiles.removeAll()
        intersectingBlocks.removeAll()
        guard targetTiles.count > 0 else { return false }
        
        if targetTiles.count == 1 {
            return true
        }
        
        getTilesInIntersectingBlocks(seedTiles: nil, targetTiles: targetTiles)
        
        return checkThatAlreadyCountedTargetTilesContainsAllTargetTiles(targetTiles: targetTiles)
        
        
        
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
    
    func showBoard() {
        print ("Showing board...")
        if grid.count - 1 > -1 {
        for i in 0 ... grid.count - 1{
            for j in 0 ... grid[0].count - 1 {
                   print("value row \(i) col \(j): \(String(describing: getTileValue(row: i, col: j))) ")
                
            }
        }
        }
    }
    
    
    
    
    
}//end of class
