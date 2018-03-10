//
//  GameDisplayTableVC.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 1/6/18.
//  Copyright © 2018 Micah DeLaurentis. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import Firebase

class GameDisplayTableVC: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
   
    var cellHeight: CGFloat = 0
    var tableView: UITableView!
    var games: [Game]?
    var tileh: Int = 20
    var tilew: Int = 20
    var mainVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    
    var backBtn: UIButton = {
        let bb = UIButton()
        bb.frame = CGRect(origin: CGPoint(x: 10, y: 30), size: CGSize(width: 70, height: 30))
        bb.backgroundColor = .yellow
        bb.setTitle("🔙", for: .normal)
        
        return bb
    }()
    
    let custGreenColor = UIColor(red: 85/255, green: 158/255, blue: 131/255, alpha: 1.0)
    lazy var newGameBtn: UIButton = {
        let ng = UIButton()
        ng.frame.size.width = 200
        ng.frame.size.height = 50
        ng.frame.origin.x = self.view.center.x - ng.frame.size.width/2
        ng.frame.origin.y = 75
        
        
        ng.backgroundColor = self.custGreenColor
        ng.setTitle("New Game", for: .normal)
        ng.layer.cornerRadius = 5
        ng.layer.masksToBounds = true
        
        return ng
    }()
    
    let notificationCircle: UIView = {
        let nc = UIView()
        nc.backgroundColor = .red
        nc.frame.size = CGSize(width: 8, height: 8)
        nc.layer.cornerRadius = nc.frame.size.width/2
        return nc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("IN GAMES DISPLAY VC: VIEW DID LOAD....")
        print("Showing games: \(games)")
     tableView = UITableView(frame: CGRect(x: view.frame.midX - 150, y: view.frame.midY - 150, width: 300, height: 300), style: UITableViewStyle.plain)
     
     tableView.dataSource = self
     tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "displayCell")
     view.addSubview(tableView)
     view.addSubview(backBtn)
     view.addSubview(newGameBtn)
        Fire.dataService.checkForChallengesReceived { (challengesReceived) in
            
            if challengesReceived == true {
                print("You have challenges!")
                self.notificationCircle.isHidden = false
            }
            else {
                print("you don't have any new challenges!")
                self.notificationCircle.isHidden = true
            }
        }
   
    view.addSubview(notificationCircle)
    let shisoPicImgView = UIImageView()
    shisoPicImgView.image = UIImage(named: "ShisoLeaf")
    shisoPicImgView.frame.size = CGSize(width: 30, height: 30)
    shisoPicImgView.frame.origin.x = view.frame.maxX - shisoPicImgView.frame.width - 5
    shisoPicImgView.frame.origin.y = 20
    shisoPicImgView.addSubview(notificationCircle)
    notificationCircle.frame.origin.x = shisoPicImgView.frame.size.width - notificationCircle.frame.size.width
    shisoPicImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shisoPicImgViewPressed)))
    shisoPicImgView.isUserInteractionEnabled = true
    view.addSubview(shisoPicImgView)
    
    
        
        
    tableView.separatorColor = .black 

    backBtn.addTarget(self, action: #selector(backBtnPushed), for: .touchUpInside)
    newGameBtn.addTarget((self), action: #selector(newGameBtnPushed), for: .touchUpInside)

    Fire.dataService.loadGames() {
            (loadedGames)
            in
            guard loadedGames.count != 0 else {
                print("no games loaded!")
                return
            }
            self.games = loadedGames
        
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        
        if self.games != nil {
            print("Games not nil in displayVC...")
            for (index,game) in self.games!.enumerated() {
                print("Game \(index): \(game.gameID)")
            }
        }
        else {
            print("games == NIL in displayVC!")
        }
        }
    }
    func shisoPicImgViewPressed() {
        present(InvitesController(), animated: true, completion: nil)
    }
    
    func backBtnPushed() {
        Fire.dataService.logOutUser{
            print("User successfully logged out! current user ID...should be nil==\(Auth.auth().currentUser?.uid)")
        self.present(LoginVC(), animated: true, completion: nil)
        }
    }
    
    
    
    func newGameBtnPushed() {
        present(StartNewGameVC(), animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     //let gameDisplayCell = tableView.dequeueReusableCell(withIdentifier: "gameDisplayCell", for: indexPath) as! GameDisplayCell
        
        let gameDisplayCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "displayCell")
        if let game = games?[indexPath.row] {
         print("game with index: \(indexPath.row) in tableView cellforrow at has id: \(game.gameID). Grid empty: \(game.board.grid.isEmpty)")
        let gameBoardDisplay = game.board.convertBoardToView(tilew: tilew , tileh: tileh)
        
            if game.currentPlayerID == FirebaseConstants.CurrentUserID {
                    gameBoardDisplay.layer.borderColor = custGreenColor.cgColor
                    gameBoardDisplay.layer.borderWidth = 3.0
            }
            
            
        //gameDisplayCell.backgroundColor = .white
        gameDisplayCell.contentView.addSubview(gameBoardDisplay)
        gameDisplayCell.backgroundColor = .black
            
            let gameLbl = UILabel(frame: CGRect(x: gameBoardDisplay.frame.size.width + 2, y: 0, width: 100, height: 100))
            gameLbl.text = "\(game.player1.userName!.capitalized)\n vs. \n\(game.player2.userName!.capitalized)"
            gameDisplayCell.contentView.addSubview(gameLbl)
            gameLbl.numberOfLines = 0
            gameLbl.textColor = .yellow 
           
     //  gameDisplayCell.separatorInset = UIEdgeInsets(top: 0, left: tableView.frame.size.width, bottom: 0, right: 0)
        return gameDisplayCell
        }
        else {
            print("no games yet!!!")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let separatorWidthInt = 1
       return CGFloat(tilew*(GameConstants.BoardNumRows + 1) + separatorWidthInt*(GameConstants.BoardNumRows + 2)) + 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let games = games {
            print("In didSelectRowAt function...")
            for game in games {
                print("gameID: \(game.gameID)")
            }
            let game = games[indexPath.row]
            print("you selected the game with ID: \(game.gameID)")
            if mainVC != nil {
                if let view =  mainVC!.view as? SKView {
                    if let scene = GameplayScene(fileNamed: "GameplayScene") {
                        
                        print("Again--you selected the game with ID: \(game.gameID)")
                        scene.game = game
                        scene.scaleMode = .aspectFit
                        view.presentScene(scene)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                }
            }
          
        }
    }
    
    func getCellSize(fromTileHeight tileh: Int, andTileWidth tilew: Int, separatorWidthInt: Int = 1) -> CGSize {
        return CGSize(width: tilew*(GameConstants.BoardNumRows + 1) + separatorWidthInt*(GameConstants.BoardNumRows + 2)
            , height: tileh*(GameConstants.BoardNumCols + 1) + separatorWidthInt*(GameConstants.BoardNumCols + 2))
    }
    


    func presentInvitesVC() {
        present(InvitesController(), animated: true, completion: nil)
    }

}
