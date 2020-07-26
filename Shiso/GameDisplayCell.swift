//
//  InviteCell.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 12/31/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import UIKit




//NOT BEING USED//NOT BEING USED
//NOT BEING USED//NOT BEING USED
//NOT BEING USED//NOT BEING USED






class GameDisplayCell: UITableViewCell {
    
    var gameView = UIView()
  
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        gameView.frame = CGRect(x: 2 , y: 2, width: 30, height: 30)
        gameView.layer.borderWidth = 1.0
        gameView.layer.borderColor = UIColor.red.cgColor
        
        addSubview(gameView)
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
}

