//
//  StartNewGameVC.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 2/19/18.
//  Copyright © 2018 Micah DeLaurentis. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class StartNewGameVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
  
    var contacts = [String]()
    var mainVC: UIViewController?
    let contactCellID = "contactCellID"
    var backBtn: UIButton = {
        let bb = UIButton()
        bb.frame = CGRect(origin: CGPoint(x: 10, y: 30), size: CGSize(width: 70, height: 30))
        bb.backgroundColor =  .white
        bb.layer.cornerRadius = 3
        bb.setTitle("🔙", for: .normal)
        
        return bb
    }()
  

    var findOpponentBtn: UIButton!
    var timeBtn_2Min: UIButton!
    var timeBtn_5Min: UIButton!
    var timeBtn_10Min: UIButton!
    var timeBtn_untimed: UIButton!
    
    var singlePlayerModeBtn: UIButton!
    var playAFriendlbl: UILabel!
    var exitOutOfSinglePlayerModeBtn: UIButton!
    
    var userNameToChallenge: UITextField!
    var submitUserNameChallengeBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        print("IN STARTNEWGAMEVC VIEW DID LOAD.")
        
        mainVC = UIApplication.shared.keyWindow?.rootViewController
       // print("main VC in new games vc: \(mainVC)")
        tableView = UITableView(frame: CGRect(x: view.frame.midX - 150, y: view.frame.midY + 90, width: 300, height: 100), style: UITableViewStyle.plain)
        tableView.delegate  = self
        tableView.dataSource = self
        
        
        view.addSubview(tableView)
        tableView.isHidden = true
        
        view.addSubview(backBtn)
        
        findOpponentBtn = UIButton()
        findOpponentBtn.setTitle("Find me an opponent", for: .normal)
        
        findOpponentBtn.setTitleColor(.white, for: .normal)
        
        findOpponentBtn.layer.cornerRadius = 10
        findOpponentBtn.backgroundColor =  UIColor(red: 85/255, green: 158/255, blue: 131/255, alpha: 1.0)
        view.addSubview(findOpponentBtn)
        findOpponentBtn.translatesAutoresizingMaskIntoConstraints = false
        findOpponentBtn.topAnchor.constraint(equalTo: backBtn.bottomAnchor, constant: 50).isActive = true
        findOpponentBtn.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        findOpponentBtn.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        findOpponentBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
       findOpponentBtn.addTarget(self, action: #selector(findOpponentBtnPressed), for: .touchUpInside)
        
        
        
        singlePlayerModeBtn = UIButton()
        singlePlayerModeBtn.setTitle("Single Player Mode", for: .normal)
        singlePlayerModeBtn.setTitleColor(.white, for: .normal)
        singlePlayerModeBtn.layer.cornerRadius = findOpponentBtn.layer.cornerRadius
        singlePlayerModeBtn.backgroundColor = findOpponentBtn.backgroundColor
        singlePlayerModeBtn.translatesAutoresizingMaskIntoConstraints = false
      
        view.addSubview(singlePlayerModeBtn)
        singlePlayerModeBtn.topAnchor.constraint(equalTo: findOpponentBtn.bottomAnchor, constant: 50).isActive = true
        singlePlayerModeBtn.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        singlePlayerModeBtn.widthAnchor.constraint(equalTo: findOpponentBtn.widthAnchor).isActive = true
        singlePlayerModeBtn.heightAnchor.constraint(equalTo: findOpponentBtn.heightAnchor).isActive = true
        
        singlePlayerModeBtn.addTarget(self, action: #selector(singlePlayerModeBtnPressed), for: .touchUpInside)
      
        //Add time option buttons to appear where single player mode button is
      
        timeBtn_2Min = UIButton()
        timeBtn_2Min.setTitle("2 min.", for: .normal)
        timeBtn_2Min.setTitleColor(.white, for: .normal)
        timeBtn_2Min.backgroundColor = .gray
        timeBtn_2Min.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeBtn_2Min)
        timeBtn_2Min.leftAnchor.constraint(equalTo: singlePlayerModeBtn.leftAnchor).isActive = true
        timeBtn_2Min.widthAnchor.constraint(equalToConstant: 75).isActive = true
        timeBtn_2Min.centerYAnchor.constraint(equalTo: singlePlayerModeBtn.centerYAnchor).isActive = true
        timeBtn_2Min.isHidden = true
        timeBtn_2Min.addTarget(self, action: #selector(timeBtn_2min_Pressed), for: .touchUpInside)
 
        timeBtn_5Min = UIButton()
        timeBtn_5Min.setTitle("5 min.", for: .normal)
        timeBtn_5Min.setTitleColor(.white, for: .normal)
        timeBtn_5Min.backgroundColor = .gray
        timeBtn_5Min.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeBtn_5Min)
        timeBtn_5Min.leftAnchor.constraint(equalTo: timeBtn_2Min.rightAnchor,constant: 10).isActive = true
        timeBtn_5Min.widthAnchor.constraint(equalToConstant: 75).isActive = true
        timeBtn_5Min.centerYAnchor.constraint(equalTo: singlePlayerModeBtn.centerYAnchor).isActive = true
        timeBtn_5Min.isHidden = true
        timeBtn_5Min.addTarget(self, action: #selector(timeBtn_5min_Pressed), for: .touchUpInside)
        
        
        
        exitOutOfSinglePlayerModeBtn = UIButton()
     
        exitOutOfSinglePlayerModeBtn.setImage(UIImage(named: "goBackIconBlue"), for: .normal)
        exitOutOfSinglePlayerModeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitOutOfSinglePlayerModeBtn)
        exitOutOfSinglePlayerModeBtn.leftAnchor.constraint(equalTo: findOpponentBtn.leftAnchor).isActive = true
        exitOutOfSinglePlayerModeBtn.topAnchor.constraint(equalTo: findOpponentBtn.bottomAnchor, constant: 40).isActive = true
        exitOutOfSinglePlayerModeBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        exitOutOfSinglePlayerModeBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        exitOutOfSinglePlayerModeBtn.isHidden = true
        exitOutOfSinglePlayerModeBtn.addTarget(self, action: #selector(exitOutOfSinglePlayerModeBtnPressed), for: .touchUpInside)
        
      
        userNameToChallenge = UITextField()
     
        view.addSubview(userNameToChallenge)
    
        userNameToChallenge.attributedPlaceholder = NSAttributedString(string: "Enter username to challenge....", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
        userNameToChallenge.layer.cornerRadius = 5
        userNameToChallenge.backgroundColor = .white
        userNameToChallenge.translatesAutoresizingMaskIntoConstraints = false
        userNameToChallenge.topAnchor.constraint(equalTo: singlePlayerModeBtn.bottomAnchor, constant: 20).isActive = true
        userNameToChallenge.centerXAnchor.constraint(equalTo: singlePlayerModeBtn.centerXAnchor).isActive = true
        userNameToChallenge.widthAnchor.constraint(equalTo: singlePlayerModeBtn.widthAnchor, constant: 0).isActive = true
        userNameToChallenge.heightAnchor.constraint(equalTo: singlePlayerModeBtn.heightAnchor, constant: 0).isActive = true
        userNameToChallenge.addTarget(self, action: #selector(textEditingChanged), for: UIControlEvents.editingChanged)
        userNameToChallenge.autocorrectionType = UITextAutocorrectionType.no
        userNameToChallenge.autocapitalizationType = UITextAutocapitalizationType.none
        
        submitUserNameChallengeBtn = UIButton()
        submitUserNameChallengeBtn.setTitle("Submit Challenge!", for: .normal)
      
        submitUserNameChallengeBtn.setTitleColor(.black, for: .normal)
      
        submitUserNameChallengeBtn.isHidden = true
        
        submitUserNameChallengeBtn.layer.cornerRadius = 3
        submitUserNameChallengeBtn.backgroundColor = .white
        submitUserNameChallengeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(submitUserNameChallengeBtn)
        submitUserNameChallengeBtn.topAnchor.constraint(equalTo: userNameToChallenge.bottomAnchor, constant: 10).isActive = true
        submitUserNameChallengeBtn.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        submitUserNameChallengeBtn.addTarget(self, action: #selector(submitUserNameChallengeBtnPressed), for: .touchUpInside)
        submitUserNameChallengeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        submitUserNameChallengeBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 2, 2, 5)
        
        playAFriendlbl = UILabel()
        playAFriendlbl.text = "Play a friend:"
        playAFriendlbl.font = UIFont(name: GameConstants.TileLabelFontName, size: 25)
        playAFriendlbl.backgroundColor = .black
        playAFriendlbl.textColor = .white
        view.addSubview(playAFriendlbl)
        playAFriendlbl.isHidden = true
        playAFriendlbl.translatesAutoresizingMaskIntoConstraints = false
        playAFriendlbl.bottomAnchor.constraint(equalTo: tableView.topAnchor).isActive  = true
        playAFriendlbl.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive  = true
        

        backBtn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
        Fire.dataService.loadContacts { (contacts) in
          
            if contacts.count > 0 {
                self.tableView.isHidden  = false
                self.playAFriendlbl.isHidden = false
            }
            self.contacts = contacts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
          
        }
        
        
        tableView.backgroundColor = .white
    }
    func submitUserNameChallengeBtnPressed() {
        guard userNameToChallenge.text != "" else {
            print("NO USER NAME!! returning")
            return
        }
        
        challengeUser(contactName: userNameToChallenge.text!)
        userNameToChallenge.text = ""
    }
    
    
    func backBtnPressed() {
        print("Back btn pressed in start new game VC")
        print("Presenting vc: \(presentingViewController) presentedVc: \(presentedViewController)")
        if let mainVC =  UIApplication.shared.keyWindow?.rootViewController as? GameViewController {
            print("can let root vc be game vc")
            
           dismiss(animated: true, completion: nil)
            if let mainV = mainVC.view as? SKView {
                mainV.presentScene(nil)
            }
            if presentingViewController is LoginVC {
                print("YES< LOGIN PRESENTING!!")
            presentingViewController?.dismiss(animated: true){
             mainVC.presentDisplayVC()
            }
            }
            else {
                print("LOGIN VC NOT PRESENTING")
                 mainVC.presentDisplayVC()
            }
         
            
        }
        
        
    }
    
    func textEditingChanged(textField: UITextField) {
        if textField.text != "" {
           submitUserNameChallengeBtn.isHidden = false
        }
        else {
            submitUserNameChallengeBtn.isHidden = true
        }
    }
    

    
    func findOpponentBtnPressed() {
    
        Fire.dataService.createOpenInvite()
        let confirmationAction = UIAlertController(title: "The search is on!", message: "Once we find you an opponent your game will appear in your games menu. Check back soon!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        confirmationAction.addAction(ok)
        self.present(confirmationAction, animated: true, completion: nil)
  
    }
    
    func singlePlayerModeBtnPressed(){
         timeBtn_2Min.isHidden = false
        timeBtn_5Min.isHidden = false
       // timeBtn_10Min.isHidden = false
        
        singlePlayerModeBtn.isHidden = true
        exitOutOfSinglePlayerModeBtn.isHidden = false
    }
    func exitOutOfSinglePlayerModeBtnPressed(){
        timeBtn_2Min.isHidden = true
        timeBtn_5Min.isHidden = true
     //   timeBtn_10Min.isHidden = true
        
        exitOutOfSinglePlayerModeBtn.isHidden = true
        singlePlayerModeBtn.isHidden = false
    }
    func timeBtn_2min_Pressed() {
       timeBtn_Pressed(timeSelection: .twoMinute)
    }
    func timeBtn_5min_Pressed() {
        timeBtn_Pressed(timeSelection: .fiveMinute)
    }
    func timeBtn_10min_Pressed() {
        timeBtn_Pressed(timeSelection: .tenMinute)
    }
    func timeBtn_untimed_Pressed() {
        timeBtn_Pressed(timeSelection: .untimed)
    }
    
    
    func timeBtn_Pressed(timeSelection: TimeSelection) {
        
         if let gameVC = mainVC as? GameViewController, let gameView = gameVC.view as? SKView {
            if let scene = GameplayScene(fileNamed: "GameplayScene") {
                print("success: about to set up game in skview in gameVC")
                let game = Game()
                game.timeSelection = timeSelection
                scene.game = game 
                 
            
                Fire.dataService.getCurrentUserName{
                  (userName) in
                    
                    guard userName != nil else { print("no user name!")
                        return }
                    print("User name: \(userName)")
                        let p1 = Player(score: 0, userID: FirebaseConstants.CurrentUserID!, player1: true, userName: userName!, imageURL: nil, tileRack: TileRack())
                        game.singlePlayerMode = true
                        game.player1 = p1
                        game.currentPlayerID = p1.userID
                        scene.name = "Shiso GameScene"
                        scene.scaleMode = .aspectFit
                        
                      scene.size = gameView.bounds.size
                        gameVC.dismiss(animated: true, completion: nil)
                    print("gameVC presenting: \(gameVC.presentingViewController)")
                        print("about to present game view 2 mins from new game vc")
                    
                        gameView.presentScene(scene)
                        
                        
                    }
                
                    
                }
                
                
            }

        }
    
    
    deinit {
        print("Start new game VC deinitialized!")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: contactCellID)
     
            let contact = contacts[indexPath.row]
            contactCell.textLabel?.text = contact
          /* let inviteBtn = UIButton(type: .system)
            inviteBtn.setTitle("Invite!", for: .normal)
            inviteBtn.frame.size = CGSize(width: 100, height: 30)
            inviteBtn.frame.origin.x = contactCell.frame.origin.x + contactCell.frame.size.width - inviteBtn.frame.size.width - 5
            contactCell.addSubview(inviteBtn) */
      
        return contactCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactName = contacts[indexPath.row]
       challengeUser(contactName: contactName)
    }
    
    
    func challengeUser(contactName: String) {
        let msg = "Send \(contactName) an Invitation?"
        
        let alert = UIAlertController(title: "Challenge", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action) in
            
            Fire.dataService.postChallenge(opponentUserName: contactName, completion: {
                (success)
                
                in
                
                guard success else {
                    let failureNotification = UIAlertController(title: "Oops!", message: "We can't find a user named '\(contactName)'. Please check your spelling and try again. Case matters!", preferredStyle: UIAlertControllerStyle.alert)
                    failureNotification.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(failureNotification, animated: false, completion: nil)
                    return
                }
                let confirmationAction = UIAlertController(title: "Invitation successfully sent to \(contactName)!", message: nil, preferredStyle: .alert)
                self.present(confirmationAction, animated: true, completion: {(action)
                    in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                        confirmationAction.dismiss(animated: true, completion: nil)
                    })
                    
                    /* UIView.animate(withDuration: 3.0, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                     confirmationAction.view.alpha = 0
                     confirmationAction.view.backgroundColor = .green
                     }, completion: {(done) in confirmationAction.dismiss(animated: true, completion: nil)})
                     */
                    
                })
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    }


