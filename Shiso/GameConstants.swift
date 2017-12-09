//
//  GameConstants.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 10/7/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import SpriteKit

struct GameConstants {
  
    static let GameplaySceneName  = "GameplayScene"
    
    static let TileBoardTileName = "Board"
    static let TilePlayerTileName = "Player Tile"
    static let TileDeleteTileName = "DELETE"
    static let TileWildcardTileName = "WILDCARD"
    static let TileWildCardSymbol = "?"
    static let TileDeleteTileSymbol = "X"
    static let WildCardPickerExitBoxName = "EXIT WILDCARD PICKER VIEW"
    
    static let BingoPoints = 10
    
    static let TileSize = CGSize(width: 50, height: 50)
    static let TileZposition: CGFloat = 2
    static let TileAnchorPoint = CGPoint(x: 0.5, y: 0.5)
    static let WildCardPickerViewTileName = "WILDCARD PICKER TILE"
    static let TileLabelZposition: CGFloat = 4
    static let TileLabelPosition = CGPoint(x: 0, y: 0)
    static let TileLabelFontSize: CGFloat =  20
    static let TileLabelFontName = "Arial"
    static let TileLabelFontColor = SKColor.black
    static let WildCardCheckTileName = "WILDCARD CHECK TILE"
    static let WildCardXTileName = "WILD CARD X TILE"
    static let TileDefaultColor = SKColor.brown
    
    static let TilePlayer1TileColor = SKColor.blue
    static let TilePlayer2TileColor = SKColor.red
    static let TileBoardTileColor = SKColor.brown
    static let TileBonusTileColor = SKColor.green
    
    static let BoardSize = CGSize(width: 800, height: 800)
    static let BoardAnchorPoint = CGPoint(x: 0.5, y: 0.5)
    static let BoardSeparatorWidth: CGFloat = 10
    static let BoardPosition = CGPoint(x: 150, y: 0)
    static let GameBoardDisplayName = "GAMEBOARD DISPLAY"
    
    static let TileRackDisplayPosition = CGPoint(x: -50, y: -450)
    static let TileRackDisplayName = "TILERACK DISPLAY"
    static let TileRackDisplaySize = CGSize(width: 430, height: 60)  
   
}

