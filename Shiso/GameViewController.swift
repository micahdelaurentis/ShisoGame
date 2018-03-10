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

    var goToLogin = false
 
    override func viewDidLoad() {
        super.viewDidLoad()
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.backgroundColor = .green
        view.addSubview(newView)
      
        if FirebaseConstants.CurrentUserID  == nil || goToLogin == true {
            perform(#selector(presentLoginVC), with: nil, afterDelay: 0.01)
        }
        else {
            perform(#selector(presentDisplayVC), with: nil, afterDelay: 0.01)
            
        }
    
    }
    
    func presentDisplayVC() {
        let vc = GameDisplayTableVC()
        
        present(vc, animated: true, completion: nil)
    }
    func presentLoginVC() {
        let vc = LoginVC()   
        present(vc, animated: true, completion: nil)
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
