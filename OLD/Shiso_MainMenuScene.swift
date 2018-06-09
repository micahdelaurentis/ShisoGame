//
//  Shiso_MainMenuScene.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 12/15/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import SpriteKit

class Shiso_MainMenuScene: SKScene , UITextFieldDelegate {
    var mainVC: UIViewController?
    var challengeBtn: UIButton!
    var opponentNameField: UITextField!
    var goToGamesLabel = SKLabelNode(text: "Go To Games!")
    var logOutLabel = SKLabelNode(text: "Log out")
    var challengeNode = SKLabelNode(text: "Play a friend")
    
    override func didMove(to view: SKView) {
        
        print("mainVC nil: \(mainVC == nil). Assigning mainVC in didMove to view in Shiso_MainMenuScene...")
        if mainVC == nil {
            mainVC = UIApplication.shared.keyWindow?.rootViewController
            
           
        }
        
         print("\(mainVC is GameViewController)--main VC = rootwindowVC?")
        
      /*
        challengeBtn = UIButton(type: UIButtonType.roundedRect)
        challengeBtn.layer.borderWidth = 1.5
        challengeBtn.layer.masksToBounds = true
        challengeBtn.layer.cornerRadius = 4.0
        challengeBtn.backgroundColor = UIColor.white
        challengeBtn.frame = CGRect(x: view.center.x - 100, y: view.center.y, width: 200, height: 50)
        challengeBtn.setTitle("Play a friend!", for: .normal)
        challengeBtn.addTarget(self, action: #selector(showChallenge), for: .touchUpInside)
        
        view.addSubview(challengeBtn) */
 
        challengeNode.position = CGPoint(x: 0, y: 0)
        challengeNode.fontSize = 40
        challengeNode.fontName = GameConstants.TileLabelFontName
        addChild(challengeNode)
        
        opponentNameField = UITextField(frame: CGRect(x: view.frame.midX - 125, y: view.frame.midY + 40, width: 250, height: 30))
        opponentNameField.placeholder = "Enter Opponent's username"
        opponentNameField.backgroundColor = .white
        opponentNameField.layer.borderColor = UIColor.black.cgColor
        opponentNameField.layer.borderWidth = 1.0
        opponentNameField.layer.cornerRadius = 3.0
        opponentNameField.layer.masksToBounds = true 
        opponentNameField.leftViewMode = .always
        opponentNameField.leftView = UIView(frame: CGRect(origin: opponentNameField.frame.origin, size: CGSize(width: 15, height: opponentNameField.frame.height )))
        opponentNameField.isHidden = true
        opponentNameField.autocapitalizationType = .none
        opponentNameField.autocorrectionType = .no
       opponentNameField.delegate = self
        
        view.addSubview(opponentNameField)
 
        goToGamesLabel.fontName = GameConstants.TileLabelFontName
        goToGamesLabel.fontSize = 50
        goToGamesLabel.fontColor = UIColor.white
       
        
        let labelContainerColor = UIColor(red: 3/255, green: 146/255, blue: 207/255, alpha: 1.0)
        let labelContainer = SKSpriteNode(color: labelContainerColor, size: CGSize(width: goToGamesLabel.frame.size.width + 3, height: goToGamesLabel.frame.size.height  + 3))
        labelContainer.position = CGPoint(x: 0, y: UIScreen.main.bounds.size.height/3)
        addChild(labelContainer)
        goToGamesLabel.position.y = -goToGamesLabel.frame.height/2
        labelContainer.addChild(goToGamesLabel)
 
        logOutLabel.fontColor = .black
        logOutLabel.fontName = GameConstants.TileLabelFontName
        logOutLabel.fontSize = 30
        
        let logOutLabelContainer = SKSpriteNode(color: .white, size: CGSize(width: logOutLabel.frame.size.width + 3, height: logOutLabel.frame.size.height + 3))
        
        logOutLabelContainer.addChild(logOutLabel)
        logOutLabel.position.y = -logOutLabel.frame.height/2 + 2
        
        logOutLabelContainer.position = CGPoint(x: -frame.width/2 + logOutLabelContainer.frame.width/2 + 10,
        y: frame.height/2 - logOutLabelContainer.frame.height/2 - 10 )
        addChild(logOutLabelContainer)
    }
    
 
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isHidden = true 
        resignFirstResponder()
       
       
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            mainVC = rootVC
        }
        mainVC?.present(InvitesController(), animated: true, completion: nil)
        
        if let oppName = textField.text, oppName != "" {
            opponentNameField.text = ""
            createChallenge(opponentUserName: oppName)
            print("creating challenge against\(oppName)!")
        }
      return  true
    }
    func createChallenge(opponentUserName: String) {
        Fire.dataService.postChallenge(opponentUserName: opponentUserName, completion: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if nodes(at: location).contains(challengeNode) {
                opponentNameField.isHidden  = false
            }
            if nodes(at: location).contains(goToGamesLabel) {
                let gameVC = GameDisplayTableVC()
                if mainVC == nil {
                    print("go to games tapped in main menu: Main VC is nil: reassigning it now...")
                    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                        mainVC = rootVC
                    }
                    else {
                        print("No root view controller and can't find one. in main menu scene trying to present game display.")
                    }
                }
                if mainVC != nil {
                
                    mainVC!.present(gameVC, animated: true, completion: nil)
                   
                }
              
                
            }
            
            else if nodes(at: location).contains(logOutLabel) {
                Fire.dataService.logOutUser {
                    print("In logOutClosure!")
                    if let logScene = LoginScene(fileNamed: "LoginScene") {
                        print("Got logScene!")
                        if let view = self.view {
                            print("View about to present loginScene")
                            self.opponentNameField.removeFromSuperview()
                            
                            logScene.scaleMode = .aspectFit
                            view.presentScene(logScene)
                        }
                        else {
                            print("can't get view!!")
                        }
                    }
                    else {
                        print("can't get login scene!!")
                    }
                }
            }
        }
    }
    
    
}
