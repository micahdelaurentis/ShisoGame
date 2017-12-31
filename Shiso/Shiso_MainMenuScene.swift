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
    var vc: UIViewController?
    var challengeBtn: UIButton!
    var opponentNameField: UITextField!
    
    override func didMove(to view: SKView) {
        
        
        challengeBtn = UIButton(type: UIButtonType.roundedRect)
        challengeBtn.layer.borderWidth = 1.5
        challengeBtn.layer.masksToBounds = true
        challengeBtn.layer.cornerRadius = 4.0
        challengeBtn.backgroundColor = UIColor.white
        challengeBtn.frame = CGRect(x: view.center.x - 100, y: view.center.y, width: 200, height: 50)
        challengeBtn.setTitle("Play a friend!", for: .normal)
        challengeBtn.addTarget(self, action: #selector(showChallenge), for: .touchUpInside)
        
        view.addSubview(challengeBtn)

        opponentNameField = UITextField(frame: CGRect(x: challengeBtn.frame.origin.x - 25, y: challengeBtn.frame.maxY + 5, width: 250, height: 30))
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
        
    }
    func showChallenge() {
       opponentNameField.isHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
       
       
    
        vc?.present(InvitesController(), animated: true, completion: nil)
        
        if let oppName = textField.text, oppName != "" {
            opponentNameField.text = ""
            createChallenge(opponentUserName: oppName)
        }
      return  true
    }
    func createChallenge(opponentUserName: String) {
        Fire.dataService.postChallenge(opponentUserName: opponentUserName)
    }
}
