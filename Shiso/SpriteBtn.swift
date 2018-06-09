//
//  SpriteBtn.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 4/15/18.
//  Copyright © 2018 Micah DeLaurentis. All rights reserved.
//

import SpriteKit

class SpriteBtn: SKShapeNode {
 
    init(nodeLabel: String, lblFontColor: UIColor, lblFontSize: CGFloat,
    nodeSize: CGSize, nodePos: CGPoint, nodeColor: UIColor) {
     super.init()
        
        path = CGPath(roundedRect: CGRect(origin: nodePos, size: nodeSize), cornerWidth: 10, cornerHeight: 10, transform: nil)
        fillColor = nodeColor
        lineWidth = 2
        strokeColor = .black
        let lbl = SKLabelNode(text: nodeLabel)
        lbl.fontColor = lblFontColor
        lbl.fontSize = lblFontSize
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center 
        addChild(lbl)
        zPosition = 20
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
func createSpriteBtn( nodeLabel: String, lblFontColor: UIColor, lblFontSize: CGFloat,
                            nodeSize: CGSize, nodePos: CGPoint, nodeColor: UIColor)  -> SKShapeNode {
        
       let btn = SKShapeNode(rect: CGRect(x: 0, y: 0, width: nodeSize.width ,height: nodeSize.height), cornerRadius: 10.0)
        btn.position = nodePos
        btn.fillColor = nodeColor
        
        let lbl = SKLabelNode(text: nodeLabel)
        lbl.fontColor = lblFontColor
        lbl.fontName  = GameConstants.TileLabelFontName
        lbl.fontSize = lblFontSize
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center
        lbl.position = CGPoint(x: btn.position.x + btn.frame.width/2, y: btn.position.y + btn.frame.height/2)
        
        btn.addChild(lbl)
        return btn
    }
}
