// 
//  Fire.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 9/9/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import SpriteKit


let REF = FirebaseConstants.FBRef
let currentUserID = FirebaseConstants.CurrentUserID

class Fire {
    
    static let dataService = Fire()
   
    var userID: String?

    var currentPlayerPath: DatabaseReference {
        return FirebaseConstants.UsersNode.child(getCurrentPlayerID())
    }
    
    var currentGameID: String?
    
    var delegate: TransitionDelegate?
    
    func registerUser(email: String, password: String, username: String) {

//        var gameID: String?
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                self.delegate!.showLoginError(message: error!.localizedDescription)
               
            }
         
          
            guard let userID =  user?.uid else {
                print("No user ID!!!!!")
                return
            }
            
            
            
            self.updateValues(referencePath: FirebaseConstants.UsersNode.child("\(userID)"), values: [FirebaseConstants.UserName : username, FirebaseConstants.UserEmail:email, FirebaseConstants.UserID: userID], completion: nil)
        
            
            
            
           
        }
    }


    func loginUser(email: String, password: String,opponentUserName: String, completion: (()-> Void)?){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                self.delegate?.showLoginError(message: error!.localizedDescription)
            }
            
            guard user != nil else {
                return
            }
            
       
            FirebaseConstants.CurrentUserPath?.observe(DataEventType.value, with: { (snapshot) in
                
                if let userDict = snapshot.value as? [String: Any] {
                

                   
                  if  userDict[FirebaseConstants.UserCurrentGameID] == nil && opponentUserName != "" {
                        
                    let micahID = snapshot.key
                       // get opponent userID 
                        
                   
                    let markID = "OpzO34FmCsQjIxYKDBmw2aG9oXj2"
                                
                   let gamePath =  FirebaseConstants.GamesNode.childByAutoId()
                    print("game path: \(gamePath)")
                   let gameID = gamePath.key
                     gamePath.child("\(micahID)")
                    
                    FirebaseConstants.UsersNode.updateChildValues(["/\(markID)/\(FirebaseConstants.UserCurrentGameID)": gameID, "/\(micahID)/\(FirebaseConstants.UserCurrentGameID)": gameID
                    ])
                    
                  
                    gamePath.updateChildValues(
                        
                    ["/\(FirebaseConstants.GamePlayersNode)/\(micahID)/\(FirebaseConstants.UserTileRack)": "",
                    "/\(FirebaseConstants.GamePlayersNode)/\(micahID)/\(FirebaseConstants.UserPlayer1)": true,
                    "/\(FirebaseConstants.GamePlayersNode)/\(micahID)/\(FirebaseConstants.UserScore)": 0,
                    "/\(FirebaseConstants.GamePlayersNode)/\(micahID)/\(FirebaseConstants.UserID)": micahID,
                    "/\(FirebaseConstants.GamePlayersNode)/\(micahID)/\(FirebaseConstants.UserName)": "micah",
                    
                    
                    
                    "/\(FirebaseConstants.GamePlayersNode)/\(markID)/\(FirebaseConstants.UserTileRack)": "",
                    "/\(FirebaseConstants.GamePlayersNode)/\(markID)/\(FirebaseConstants.UserPlayer1)": false,
                    "/\(FirebaseConstants.GamePlayersNode)/\(markID)/\(FirebaseConstants.UserScore)": 0,
                    "/\(FirebaseConstants.GamePlayersNode)/\(markID)/\(FirebaseConstants.UserID)": markID,
                    "/\(FirebaseConstants.GamePlayersNode)/\(markID)/\(FirebaseConstants.UserName)": "mark",
                    
                    "/\(FirebaseConstants.GameCurrentPlayerID)": micahID,
                        "/\(FirebaseConstants.GameNew)": true])
                    
                    
                    }
                    
                
                     
                    
                 
                    if completion != nil {
                        print("about to run completion")
                        completion!()
                    }
                }
                else {
                    print("no user snapshot in loginUser func!")
                }
                
                
            })
            
        }
        
        
    }

    func updateValues(referencePath: DatabaseReference, values: Dictionary<String, Any>, completion: ((String) -> ())?){
    
        referencePath.updateChildValues(values) { (error, dbRef) in
            if error != nil {
                return
            }
            let gameID = values[FirebaseConstants.GameID]
            
            if completion != nil {
                completion!(gameID as! String)
            }
            
        }
        }
    
    
    func getCurrentPlayerID() -> String {
        var currentPlayerID: String = ""
        
        FirebaseConstants.UsersNode.child(FirebaseConstants.CurrentUserID!).observeSingleEvent(of: .value, with: {(snapshot) in
            if let userDict = snapshot.value as? [String: Any] {
                if let game_id = userDict[FirebaseConstants.GameID] as? String {
                    
                    FirebaseConstants.GamesNode.child(game_id).observeSingleEvent(of: .value, with: {(snapshot)
                        
                        in
                        
                        if let gameDict = snapshot.value as? [String:Any] {
                            if let currPlayerID = gameDict[FirebaseConstants.GameCurrentPlayerID] as? String {
                                currentPlayerID = currPlayerID
                            }
                        }
                        
                    })
                    
                }
            }
            
        })
        
        
    
        
       return currentPlayerID
    }
    
   
    
    var nTimesLoadGame = 0
    func loadGame(completion: @escaping ((Game) -> Void))  {
  
       
        
  //      print("Current user path: \(FirebaseConstants.CurrentUserPath)")
        FirebaseConstants.CurrentUserPath?.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? [String: Any] {
              //  print("snapshot in loadGame: \(snapshot.value)")
                if let gameID = userDict[FirebaseConstants.UserCurrentGameID] as? String {
                    
                    
                    FirebaseConstants.GamesNode.child(gameID).observe(.value, with: { (snapshot) in
                        let game = Game()
                        game.gameID = gameID
                        print("observing particular game in loadGame")
                        /*if game.board.grid.isEmpty == false {
                                game.board.showBoard()
                        }*/
                        self.nTimesLoadGame += 1
                        print("You have loaded the game \(self.nTimesLoadGame) times")
                        
                        
                        if let gameDict = snapshot.value as? [String: Any] {
                                print("got gameDict")
                            if let boardValues = gameDict[FirebaseConstants.GameBoard] as? [String:Any] {
                                print("got board Values")
                                
                                for i in 0 ... Board.numRows {
                                    var tileRow = [Tile]()
                                    for j in 0 ... Board.numCols {
                                        if let tileDict = boardValues["Row\(i)_Col\(j)"] as? [String: Any] {
                                            let tile = Tile.initializeFromDict(dict: tileDict)
                                           
                                            tileRow.append(tile)
                                            if j == Board.numCols {
                                             game.board.appendTileRowInGrid(tileRow: tileRow)
                                               
                                            }
                                        }
                                    }
                                }
                            }
                           
                            
                            if let currentPlayerID = gameDict[FirebaseConstants.GameCurrentPlayerID] as? String {
                                print("got current Player")
                                game.currentPlayerID = currentPlayerID
                               
                                if let playersDict = gameDict[FirebaseConstants.GamePlayersNode] as? [String: Any] {
                                    print("Got playersDict")
                                    
                                    for player in playersDict.values {
                                    // print("player in playerDict: \(player)")
                                        if let playerDict = player as? [String:Any] {
                                            var player = Player()
                                            var playerN = ""
                                            if let isPlayer1 = playerDict[FirebaseConstants.UserPlayer1] as? Bool {
                                                player.player1 = isPlayer1
                                                playerN = isPlayer1 == true ? "Player 1" : "Player 2"
                                            }
                                            if  let playerScore = playerDict[FirebaseConstants.UserScore] as? Int {
                                               player.score = playerScore
                                            }
                                            else {
                                                print("no score for \(playerN)")
                                            }
                                            if let playerName = playerDict[FirebaseConstants.UserName] as? String {
                                               
                                                player.userName = playerName
                                            } else {print("No name for \(playerN)")}
                                            if let playerID = playerDict[FirebaseConstants.UserID] as? String {
                                                player.userID = playerID
                                            }
                                                
                                           if let playerTileRack = playerDict[FirebaseConstants.UserTileRack] as?
                                            [String:Any] {
                                            
                                                player.tileRack = TileRack.convertFromDictToTileRack(dict: playerTileRack)
                                        
                                           }
                                           else { print("no tile rack available for \(playerN)")}
                                            
                                            if player.player1 == true {
                                                game.player1 = player
                                            }
                                            else {
                                               game.player2 = player
                                            }
                                             
                                            
                                                
                                        }
                                    }
                                    
                                    //print("showing board grid now...")
                                    //game.board.showBoard()
                                   
                                    completion(game)
                                 
                                }
                                
                            }
                            
                            
                        }
                    })
                    
                }
            }
        })
      
    }
 

    
    
    func saveGameData(game: Game, completion: (()->())? ) {
    
        print("In saveGameData...")
        

        guard let gameID = game.gameID else {
            print("no game ID in saveGameData")
            return
        }
    
        FirebaseConstants.GamesNode.child(gameID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let FBGameDict = snapshot.value as? [String: Any], let currentPlayerID = FBGameDict[FirebaseConstants.GameCurrentPlayerID] as? String {
                
                
              
                let currentPlayer = game.player1.userID == game.currentPlayerID ? game.player1! : game.player2!
                let currentPlayerID = currentPlayer.userID!
                let newCurrentPlayerID = currentPlayerID == game.player1.userID ? game.player2.userID! : game.player1.userID!
                
                // Save current player data
                
                print("about to save data with updateChildValues")
                print("current Player was: \(currentPlayer.userName!). Score: \(currentPlayer.score)")
                FirebaseConstants.GamesNode.child(gameID).updateChildValues(
                    [FirebaseConstants.GameNew: false, FirebaseConstants.GameCurrentPlayerID: newCurrentPlayerID,
                     FirebaseConstants.GameBoard : game.board.convertToDict(),
                "/\(FirebaseConstants.GamePlayersNode)/\(currentPlayerID)/\(FirebaseConstants.UserScore)": currentPlayer.score,
                "/\( FirebaseConstants.GamePlayersNode)/\(currentPlayerID)/\(FirebaseConstants.UserTileRack)": currentPlayer.tileRack.convertToDict()
                
                ])
                
                
                 if completion != nil { completion!()}
                
                }
            else {
                print("save game data: Cannot get game dict" )
            }
            
        
        })
      
    }
    
    
 
    
}
    
    
    //end of class

    
    


    
 
