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
    static let TileRackSeparatorWidth:CGFloat = 5
    static let TileBoardTileName = "Board"
    static let TilePlayerTileName = "Player Tile"
    static let TileDeleteTileName = "DELETE"
    static let TileWildcardTileName = "WILDCARD"
    static let TileWildCardSymbol = "?"
    static let TileDeleteTileSymbol =  "X"
    static let WildCardPickerExitBoxName = "EXIT WILDCARD PICKER VIEW"
    
    static let BingoPoints = 10
    
  //  static let TileSize = CGSize(width: 70, height: 70)
  
    static let TileZposition: CGFloat = 2
    static let TileAnchorPoint = CGPoint(x: 0.5, y: 0.5)
    static let WildCardPickerViewTileName = "WILDCARD PICKER TILE"
    static let TileLabelZposition: CGFloat = 4
    static let TileLabelPosition = CGPoint(x: 0, y: 0)
    static let TileLabelFontSize: CGFloat =  40
    static let TileLabelFontName = "Arial"
    static let TileLabelFontColor = UIColor.white 
    static let WildCardCheckTileName = "WILDCARD CHECK TILE"
    static let WildCardXTileName = "WILD CARD X TILE"
    static let TileDefaultColor = UIColor(red: 243/255, green: 243/255, blue: 240/255, alpha: 1.0)
    static let TileStartingTilesColor =  UIColor(red: 158/255, green: 156/255, blue: 156/255, alpha: 1.0)
    
    static let TilePlayer1TileColor = UIColor(red: 3/255, green: 146/255, blue: 207/255, alpha: 1.0)
    static let TilePlayer2TileColor = UIColor(red: 102/255, green: 101/255, blue: 71/255, alpha: 1.0)
    static let TileBoardTileColor = UIColor(red: 243/255, green: 243/255, blue: 240/255, alpha: 1.0)
    
    //static let BoardSize = CGSize(width: 800, height: 800)
    static let BoardSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    static let BoardAnchorPoint = CGPoint(x: 0.5  , y: 0.5)
    static let BoardSeparatorWidth: CGFloat = 2
    static let BoardPosition = CGPoint(x: 0, y: 0)
    static let GameBoardDisplayName = "GAMEBOARD DISPLAY"
    static let BoardNumRows: Int = 9
    static let BoardNumCols: Int = 9
    

    static let TileSize: CGSize = {

      let screenWidth = UIScreen.main.bounds.size.width
      let screenHeight = UIScreen.main.bounds.size.height
      let totalSepWidth: CGFloat = 22 //CGFloat((GameConstants.BoardNumCols + 2))*GameConstants.BoardSeparatorWidth
        let actualCols: CGFloat = 10 //CGFloat(GameConstants.BoardNumCols + 1)
      let tileWidth = (screenWidth - totalSepWidth)/actualCols
        return CGSize(width: tileWidth , height: tileWidth )
       // return CGSize(width: 70, height: 70)
    }()
    static let TileRackDisplayPosition = CGPoint(x: -50, y: -450)
    static let TileRackDisplayName = "TILERACK DISPLAY"
    static let TileRackDisplaySize = CGSize(width: 430, height: 60)  
   
    static let InviteID = "inviteID"
    static let Invite_ReceiverID = "receiverID"
    static let Invite_receiverName = "receiverUserName"
    static let Invite_senderID = "senderID"
    static let Invite_senderName = "senderUserName"
    static let Invite_status = "status"
    static let Invite_timestamp = "timestamp"
    static let Invite_statusPending = "?"
    static let Invite_status_accepted = "ACCEPTED"
    static let Invite_status_declined = "DECLINED"
    
    static let FontArialBoldMT = "Arial-BoldMT"
    static let ExchangeExitBtnName = "Exchange Exit Button"
    
    
}

