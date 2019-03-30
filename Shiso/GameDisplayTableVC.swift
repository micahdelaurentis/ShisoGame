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
    var gameVC: GameViewController! {
        didSet {
            print("set gamevc in displayvc to : \(gameVC)")
        }
    }
    var newGameSet: Bool = false
    var cellHeight: CGFloat = 0
    var tableView: UITableView!
    var games: [Game]? {
        didSet {
            if self.games!.count == 1 {
                numberOfGamesLbl.text = "You have 1 active game!"
            }
            else {
                numberOfGamesLbl.text = "You have \(self.games!.count) active games!"
            }
        }
    }
    var tileh: Int = 20
    var tilew: Int = 20
    let VCName = "Games List"
    var hamburgerControl = Hamburger()
   
    
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
    var numberOfGamesLbl = UILabel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        print("In view did load for game display VC. main vc \(UIApplication.shared.keyWindow?.rootViewController)")
         let singleGameViewHeight = CGFloat(tileh*(GameConstants.BoardNumCols + 1) + (GameConstants.BoardNumCols + 2))
   
        
    
    hamburgerControl.setUpNavBarWithHamburgerBtn(inVC: self)
    
    tableView =  UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0 ), style: UITableViewStyle.plain)
    tableView.isScrollEnabled = true
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "displayCell")
     view.addSubview(tableView)
     
   // view.addSubview(backBtn)
    view.addSubview(newGameBtn)
    
     //   numberOfGamesLbl.frame = CGRect(x: 0, y: newGameBtn.frame.maxY, width: view.frame.size.width, height: 75)
        view.addSubview(numberOfGamesLbl)
        numberOfGamesLbl.font = UIFont(name: GameConstants.TileLabelFontName, size: 20)
        numberOfGamesLbl.textColor = .white
        
        numberOfGamesLbl.translatesAutoresizingMaskIntoConstraints = false
        numberOfGamesLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        numberOfGamesLbl.topAnchor.constraint(equalTo: newGameBtn.bottomAnchor, constant: 10).isActive = true
        numberOfGamesLbl.heightAnchor.constraint(equalTo: newGameBtn.heightAnchor).isActive = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: numberOfGamesLbl.bottomAnchor, constant: 10).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 30).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 3*singleGameViewHeight).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true 
        
     
   
    view.addSubview(notificationCircle)
    let shisoPicImgView = UIImageView()
    shisoPicImgView.image = UIImage(named: "ShisoLeaf")
    shisoPicImgView.frame.size = CGSize(width: 30, height: 30)
    shisoPicImgView.frame.origin.x = view.frame.maxX - shisoPicImgView.frame.width - 5
    shisoPicImgView.frame.origin.y = 50
    shisoPicImgView.addSubview(notificationCircle)
    notificationCircle.frame.origin.x = shisoPicImgView.frame.size.width - notificationCircle.frame.size.width
    shisoPicImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shisoPicImgViewPressed)))
    shisoPicImgView.isUserInteractionEnabled = true
    view.addSubview(shisoPicImgView)
    
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

    tableView.backgroundColor = .black
    tableView.separatorColor = .black
    
    //backBtn.addTarget(self, action: #selector(backBtnPushed), for: .touchUpInside)
    newGameBtn.addTarget((self), action: #selector(newGameBtnPushed), for: .touchUpInside)

        loadGamesAndUpdateDisplay()
        
        if let games = games {
            print("in viewdidload for games display there are \(games.count) games")
            for game in games {
                print("in game display, looping thru games. game ID: \(game.gameID)")
            }
        }
        
     
    }
    override func viewDidAppear(_ animated: Bool) {
        print("in game display view did appear: presenting vc: \(presentingViewController)")
    }
    override func viewWillAppear(_ animated: Bool) {
        print("In game display vc view will appear")
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
        
        if newGameSet {
            print("GAME DISPLAY VC: NEW GAME JUST SET")
            loadGamesAndUpdateDisplay()
            self.newGameSet = false
        }
        else {
            print("game display vc view will appear: no new games loaded, so no refresh!")
        }
    }

    func shisoPicImgViewPressed() {
        hamburgerControl.removeSlideOut()
        present(InvitesController(), animated: true, completion: nil)
    }
    
    func getVCName() -> String {
        return "games list"
    }
    func loadGamesAndUpdateDisplay(completion: ((CGFloat) -> ())? = nil) {
        Fire.dataService.loadGames() {
            (loadedGames)
            in
           
            guard loadedGames.count != 0 else {
                return
            }
            self.games = loadedGames
            //self.games?.sort(by: {(game1, game2) in game1.lastUpdated > game2.lastUpdated})
            var currentPlayerGames = self.games!.filter{(game) in game.currentPlayerID == FirebaseConstants.CurrentUserID!}
            var opponentGames = self.games!.filter{(game) in game.currentPlayerID != FirebaseConstants.CurrentUserID!}
            
            currentPlayerGames.sort(by: {(game1, game2) in game1.lastUpdated > game2.lastUpdated})
            opponentGames.sort(by: { (game1, game2) in game1.lastUpdated > game2.lastUpdated})
          
            self.games = currentPlayerGames + opponentGames
        
          
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            if completion != nil {
                completion!(CGFloat(loadedGames.count))
            }
        }
        
    }
    
    func backBtnPushed() {
    hamburgerControl.removeSlideOut()
       
        Fire.dataService.logOutUser{
          
          if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
               self.dismiss(animated: true, completion: nil)
                mainVC.present(LoginVC(), animated: true, completion: nil)
                
            }
            else{
                print("can't let main vc present loginvc from display vc")
            }
            /*
            
            
            
            print("User successfully logged out! current user ID...should be nil==\(Auth.auth().currentUser?.uid)")
            
            if self.presentingViewController is LoginVC {
                print("presenting is loginvc...about to dismiss display vc")
                self.dismiss(animated: true, completion: nil)
            }
            else {
            print("presenting vc is: \(self.presentingViewController)")
            let loginVC = LoginVC()
            self.present(loginVC, animated: true, completion: nil)
            }
 */
        }
    }
    
 
    func newGameBtnPushed() {
        hamburgerControl.removeSlideOut()
        present(StartNewGameVC(), animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     //let gameDisplayCell = tableView.dequeueReusableCell(withIdentifier: "gameDisplayCell", for: indexPath) as! GameDisplayCell
        
        let gameDisplayCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "displayCell")
        gameDisplayCell.backgroundColor = .black
        
        if let game = games?[indexPath.row] {
         print("game with index: \(indexPath.row) in tableView cellforrow at has id: \(game.gameID). Grid empty: \(game.board.grid.isEmpty)")
        let gameBoardDisplay = game.board.convertBoardToView(tilew: tilew , tileh: tileh)
   
            if game.currentPlayerID == FirebaseConstants.CurrentUserID {
                    gameBoardDisplay.layer.borderColor = UIColor(red: 57/255, green: 255/255, blue: 20/255, alpha: 1.0).cgColor
                
                    gameBoardDisplay.layer.borderWidth = 5.0
            }
            
        let insetWidth = (gameDisplayCell.frame.size.width - gameBoardDisplay.frame.size.width)/2
        //gameDisplayCell.backgroundColor = .white
        gameDisplayCell.contentView.addSubview(gameBoardDisplay)
            let insetView = UIView()
            insetView.backgroundColor = .black
            insetView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: insetWidth, height: gameBoardDisplay.frame.size.height))
            gameDisplayCell.addSubview(insetView)
            
        gameBoardDisplay.frame.origin.x = insetView.frame.maxX
            
            let gameLbl = UILabel(frame: CGRect(x: gameBoardDisplay.frame.maxX + 5, y: 0, width: insetWidth, height: gameBoardDisplay.frame.size.height))
            gameLbl.text = "\(game.player1.userName!.capitalized)\n vs.\n \(game.player2.userName!.capitalized)"
            gameDisplayCell.contentView.addSubview(gameLbl)
            gameLbl.numberOfLines = 0
            gameLbl.textColor = .yellow 
           
     //  gameDisplayCell.separatorInset = UIEdgeInsets(top: 0, left: tableView.frame.size.width, bottom: 0, right: 0)
      
        }
    
      return gameDisplayCell
        
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
         for game in games {
                print("gameID: \(game.gameID)")
            }
            let game = games[indexPath.row]
               if let gameVC = /*UIApplication.shared.keyWindow?.rootViewController*/ presentingViewController as? GameViewController {
          
                if let view =  gameVC.view as? SKView {
                    gameVC.dismiss(animated: true, completion: nil)
                    hamburgerControl.removeSlideOut()
                    if let scene = GameplayScene(fileNamed: "GameplayScene") {
                        scene.name = "Shiso GameScene"
                        scene.game = game
                        scene.size = view.bounds.size
                        scene.scaleMode = .aspectFit
                        view.presentScene(scene)
                       
                       
                    }
                }
                else {
                    print("can't let game vc have skview")
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
    
    deinit {
        print("Game display VC deinitialized!")
    }

}
