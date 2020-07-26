//
//  BoxLoc.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 8/24/19.
//  Copyright © 2019 Micah DeLaurentis. All rights reserved.
//

import Foundation


class BoxLoc {
    var boxID: String = ""
    var row: Int = 0
    var col: Int  = 0
    var newBox: Bool = true
    var player1Viewed:Bool = false
    var player2Viewed:Bool = false
    
    
    
    init(row:Int, col:Int, newBox:Bool = true , player1Viewed:Bool = false, player2Viewed:Bool = false) {
        self.row = row
        self.col = col
        self.newBox = newBox
        self.boxID = randomString(length: 5)
        self.player1Viewed = player1Viewed
        self.player2Viewed = player2Viewed
    }
   

    init(fromDict dict: [String: Any]) {
        if let row = dict["boxRow"] as? Int {
            self.row = row
        }
        if let col = dict["boxCol"] as? Int {
            self.col = col
        }
        if let boxID = dict["boxID"] as? String {
            self.boxID = boxID
        }
        
        if let newBox = dict["newBox"] as? Bool {
            self.newBox = newBox
        }
        if let player1Viewed = dict["player1Viewed"] as? Bool {
            self.player1Viewed = player1Viewed
        }
        
        if let player2Viewed = dict["player2Viewed"] as? Bool {
            self.player2Viewed = player2Viewed
        }
        
    }
    
    
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func convertToDict() -> [String: Any] {
        var boxAsDict = [String: Any]()
        
        boxAsDict["boxRow"] = row
        boxAsDict["boxCol"] = col
        boxAsDict["newBox"] = newBox
        boxAsDict["boxID"] = boxID
        boxAsDict["player2Viewed"] = player2Viewed
        boxAsDict["player1Viewed"] = player1Viewed
        
        return boxAsDict
    }
    
    func hasTheSameCenter(asBox box2: BoxLoc) -> Bool {
        return row == box2.row && col == box2.col
        
    }
    
    func hasTheSameCenterAsAnyBox(inboxes boxes:[BoxLoc]) -> Bool {
        for box in boxes {
            if hasTheSameCenter(asBox: box){
                return true
            }
        }
        return false 
    }
    
}
