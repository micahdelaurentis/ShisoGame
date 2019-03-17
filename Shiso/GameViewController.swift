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
    override func viewDidLoad() {
        super.viewDidLoad()
    
      perform(#selector(setUpHamburger), with: nil, afterDelay: 0.01)
        
       
        if FirebaseConstants.CurrentUserID  == nil || goToLogin == true {
            
     perform(#selector(presentLoginVC), with: nil, afterDelay: 0.01)
            
        }
        else {
          
          perform(#selector(presentDisplayVC), with: nil, afterDelay: 0.01)
            
        }
    
    }
    
    func presentDisplayVC() {
        hamburgerControl.removeSlideOut()
        let vc = GameDisplayTableVC()
        vc.gameVC = self 
     
        present(vc, animated: true, completion: nil)
    }
    
    func presentLoginVC() {
        let vc = LoginVC()   
        present(vc, animated: true, completion: nil)
    }
    func presentStartNewGameVC() {
        let vc = StartNewGameVC()
        present(vc, animated: true, completion: nil)
    }
    func presentStatsVC() {
        let vc = StatisticsVC()
        present(vc, animated: true, completion: nil)
    }
 
    func setUpHamburger(){
        hamburgerControl.setUpNavBarWithHamburgerBtn(inVC: self)

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


