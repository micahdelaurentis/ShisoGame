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


class GameViewController: UIViewController {
    var hamburgerControl = Hamburger()
    var goToLogin = false
    var lastPresentedGame: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    
       let blackView = UIView(frame: self.view.frame)
      //  blackView.backgroundColor = .black
        
      //  self.view.addSubview(blackView)
    print("In game vc view did load....")
      perform(#selector(setUpHamburger), with: nil, afterDelay: 0.01)
        
       
        if FirebaseConstants.CurrentUserID  == nil || goToLogin == true {
            
     perform(#selector(presentLoginVC), with: nil, afterDelay: 0.01)
            
        }
        else {
          
          perform(#selector(presentDisplayVC), with: nil, afterDelay: 0.01)
            
        }
    }
    
    func presentGame(game: Game) {
       
        
        if let view =  self.view as? SKView {
            
           self.dismiss(animated: true, completion: nil)
           hamburgerControl.removeSlideOut()
            if let scene = GameplayScene(fileNamed: "GameplayScene") {
                scene.name = "Shiso GameScene"
                scene.game = game
    
                scene.size = view.bounds.size
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
                self.lastPresentedGame = game
            
            }
        }
    }
    
    
    @objc func presentDisplayVC() {
        print("In present display vc")
        hamburgerControl.removeSlideOut()
        let vc = GameDisplayTableVC()
        vc.modalPresentationStyle = .fullScreen
        vc.gameVC = self
        lastPresentedGame = nil 
     
        present(vc, animated: true, completion: nil)
    }
    
    
    @objc func presentLoginVC() {
        let vc = LoginVC()
        vc.modalPresentationStyle = .fullScreen 
        present(vc, animated: true, completion: nil)
    }
    func presentStartNewGameVC() {
        let vc = StartNewGameVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    func presentStatsVC() {
        let vc = StatisticsVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    func presentSettingsVC(){
        let vc = SettingsVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true,completion: nil)
    }
    
    @objc func setUpHamburger(){
      
       hamburgerControl.setUpNavBarWithHamburgerBtn(inVC: self, color:.black)
        
    }
    
    override var shouldAutorotate: Bool {
        return false
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


