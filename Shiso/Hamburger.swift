//
//  Hamburger.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 3/17/18.
//  Copyright © 2018 Micah DeLaurentis. All rights reserved.
//

import UIKit
import SpriteKit
class Hamburger: NSObject, UITableViewDataSource, UITableViewDelegate {

    var hamburgerContents = ["My Games", "Settings", "Statistics",  "Log Out"]
    var navBar: UINavigationBar!
    lazy var slideOutMenu: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    

    func hamburgerMenuButtonTapped() {
            toggleSlideOut()
    }
    
    
    var hamburgerMenuShowing: Bool = false
    
    weak var VC: UIViewController? {
        didSet{
            
            print("VC in hamburger set to: \(VC)")
      
        }
    }
    
    func showSlideOut() {
    if let window = UIApplication.shared.keyWindow {
            slideOutMenu.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 200)
            window.addSubview(slideOutMenu)
            
            let slideOutMenuHeight: CGFloat = 200
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                 self.slideOutMenu.frame = CGRect(x: 0, y: window.frame.height - slideOutMenuHeight, width: self.slideOutMenu.frame.width, height: self.slideOutMenu.frame.height)
            }, completion: nil)
            
            hamburgerMenuShowing = true
        
        }
    }
    
    func removeSlideOut() {
        guard hamburgerMenuShowing else { return }
        if let window = UIApplication.shared.keyWindow {
          
            //window.addSubview(slideOutMenu)
            
           
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.slideOutMenu.frame = CGRect(x: 0, y: window.frame.height, width: self.slideOutMenu.frame.width, height: self.slideOutMenu.frame.height)
            }, completion: nil)
            hamburgerMenuShowing = false
        }
    }
    
    func toggleSlideOut() {
        if !hamburgerMenuShowing {
            showSlideOut()
        }
        else {
            removeSlideOut()
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hamburgerContents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let txt =  hamburgerContents[indexPath.row]
        cell.textLabel?.text = txt
        cell.imageView?.image = UIImage(named: txt)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("IN SELECT ROW")
     let hc = hamburgerContents[indexPath.row]
        removeSlideOut()
       
     
        if let vc = VC as? GameViewController {
          
             print("PRESENTING VC: \(vc.presentingViewController) PRESENT-ED VC: \(vc.presentedViewController)")
          
            if hc == "My Games" {
             
             if let _ = vc.presentedViewController as? GameDisplayTableVC {
                    print("already presenting game display!!!!!")
                
                }
             else {
                //vc.dismiss(animated: false, completion: nil)
                if let v = vc.view as? SKView {
                    v.presentScene(nil)
                }
                vc.presentDisplayVC()
                }
            }
                
            else if hc == "Log Out" {
                if let v = vc.view as? SKView {
                    v.presentScene(nil)
                }
                Fire.dataService.logOutUser{
                    vc.presentedViewController?.dismiss(animated: true, completion: nil)
                   vc.presentLoginVC()
                }
                
            }
            else if hc == "Statistics" {
                print("vc = \(vc) presented: \(vc.presentedViewController) presenting: \(vc.presentingViewController)")
                if let v = vc.view as? SKView {
                    v.presentScene(nil)
                }
                vc.dismiss(animated: false, completion: nil)
                vc.presentStatsVC()
               // vc.dismiss(animated: false, completion: nil)
               // vc.presentStatsVC()
                

            }
            else {
               print("you selected something else")
            }
            
            
        }
        else {
            
            print("can't let vc = VC as gamevc. vc is \(VC)")
            
        }

    }
    
    func setUpNavBarWithHamburgerBtn(inVC vc: UIViewController) {
        
        print("setting up navbar with hamburger with vc:\(vc)")
          navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: vc.view.frame.size.width, height: 50))
       
        vc.view.addSubview(navBar)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            navBar.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
          navBar.topAnchor.constraint(equalTo: vc.view.topAnchor).isActive = true
        }
        navBar.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor).isActive = true
        navBar.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 50).isActive = true 
        
        let hamburgerImg = UIImage(named: "hamburger")
        let hamburgerMenuButton = UIBarButtonItem(image: hamburgerImg, style: .plain, target: self, action: nil)
        
        let navItem = UINavigationItem()
        navItem.leftBarButtonItem = hamburgerMenuButton
        navBar.setItems([navItem], animated: false)
        
        hamburgerMenuButton.action = #selector(hamburgerMenuButtonTapped)
        if let vc = vc as? GameDisplayTableVC {
            print("setting up hamburget in vc gamedisplayvc")
           self.VC = vc.gameVC
            
        }
        else { self.VC = vc}
        /*
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            print(" in vc: \(vc) and CAN set up VC as root vc!")
            VC = rootVC
        }
        else {
            print(" in vc: \(vc) and can't set up VC as root vc!")
        } */
    }
    
    
    
}
