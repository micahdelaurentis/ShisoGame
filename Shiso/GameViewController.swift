//
//  GameViewController.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 5/29/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import UIKit
import SpriteKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class GameViewController: UIViewController, TransitionDelegate {

    var goToLogin = true 
 
    override func viewDidLoad() {
        super.viewDidLoad()        
        
   
        
        Fire.dataService.delegate = self
       
        
            
        if let view = self.view as! SKView? {
            if FirebaseConstants.CurrentUserID  == nil || goToLogin == true {
                if let scene = LoginScene(fileNamed: "LoginScene") {
                    scene.mainVC = self 
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view.presentScene(scene)
                    
                    
                }
            }
            else {
                
           if let scene = Shiso_MainMenuScene(fileNamed: "Shiso_MainMenuScene") {
                    scene.scaleMode = .aspectFill
                    scene.mainVC = self
                    view.presentScene(scene)
                }
                else {
                    print("Can't present shiso_mainmenuscene!!!!!!!!!")
                }
                
 
                /*
                Fire.dataService.loadGame(){
                    (loadedGame)
                    
                    in
                    
                if let scene = GameplayScene(fileNamed: "GameplayScene") {
                    scene.game = loadedGame
                    scene.scaleMode = .aspectFill
                    view.presentScene(scene)
                }
                else {
                    print("can't let scene be gameplay scene!!")
                    }
                }
 */
 
              
              
            }
            
            /*
            if Auth.auth().currentUser != nil {
                // Set the scale mode to scale to fit the window
                
                Fire.dataService.loadGame(){
                    
                    (game) in
                    
                    if let scene = GameplayScene(fileNamed: "GameplayScene") {
                        scene.scaleMode = .aspectFill
                        scene.game = game
                        // Present the scene
                        view.presentScene(scene)
                    }
                }
                
            }
        else {
           if let scene = LoginScene(fileNamed: "LoginScene") {
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            
            
            }
        }
      */
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    
    func showLoginAlert(message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showLoginError(message: String) {
     
        let alertController = UIAlertController(title: "Oops!", message: "\(message)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showLoginSuccess(message: String) {
        
        let alertController = UIAlertController(title: "Successful Login!", message: "\(message)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
