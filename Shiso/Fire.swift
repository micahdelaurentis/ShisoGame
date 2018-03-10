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
   
    var mainVC = UIApplication.shared.keyWindow?.rootViewController
    
    var userID: String?
    var registerUserVar = false
    var currentPlayerPath: DatabaseReference {
        return FirebaseConstants.UsersNode.child(getCurrentPlayerID())
    }
    
    var currentGameID: String?
    
    
    func registerUser(email: String, password: String, username: String, errorHandler: UIViewController, completion: @escaping ()->()) {
       
//        var gameID: String?
        
        /** check that username is unique and not blank **/
        guard username != "" else {
            
            let registerError = UIAlertController(title: "Oops!", message: "You must select a username to continue!", preferredStyle: .alert)
            registerError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            errorHandler.present(registerError, animated: true, completion: nil)
            return
        }
        /** check that it's not there **/
        
        
        checkUserNameUnique(username: username, email: email, password: password, errorHandler: errorHandler) {
            (email, password)
            in
            print("about to register user...")
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            guard error == nil else {
             
                let registerError = UIAlertController(title: "Oops!", message: error!.localizedDescription, preferredStyle: .alert)
                registerError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                errorHandler.present(registerError, animated: true, completion: nil)
                    
                
                return
            }
            
            guard let userID =  user?.uid else {
                return
            }
            self.updateValues(referencePath: FirebaseConstants.UsersNode.child("\(userID)"), values: [FirebaseConstants.UserName : username, FirebaseConstants.UserEmail:email, FirebaseConstants.UserID: userID], completion: nil)
            
                 completion()
        }
        }
        
   
    }

    func checkUserNameUnique(username: String, email: String, password: String, errorHandler: UIViewController, completion: @escaping ( String, String)->()) {
    
       
        FirebaseConstants.UsersNode.queryOrdered(byChild: FirebaseConstants.UserName).queryEqual(toValue: username).observeSingleEvent(of: .value, with: {(snapshot)
            
            in
            
            guard !snapshot.exists() else {
                
                let registerError = UIAlertController(title: "Oops!", message: "The user name \"\(username)\" already exists! Please choose another!", preferredStyle: .alert)
                registerError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                errorHandler.present(registerError, animated: true, completion: nil)
                
                
                
                return
            }
          
            completion(email, password)
        
        })
       
    }
    func logOutUser(completion: (()->Void)?){
        do {
            try Auth.auth().signOut()
            if Auth.auth().currentUser == nil {
                print("Successful log out!!!!")
                
                completion?()
            }
          
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
    }

   
    
    /*
    func loginUser(email: String, password: String, opponentUserName: String, completion: ((Invite?)-> Void)?){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                self.delegate?.showLoginError(message: error!.localizedDescription)
            }
            
            guard user != nil else {
                return
            }
            
            FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.ChallengesReceived).observe(.childAdded, with: { (snapshot) in
              
                if snapshot.exists() {
                    print("challenge received snapshot: \(snapshot)")
                
                    
                    if let challengeDict = snapshot.value as? [String:Any] {
                        if let invite = Invite(dict: challengeDict) {
                            print("Success creating invite: \(invite)")
                            if completion != nil {
                                completion!(invite)
                            }
                        }
                        else {
                            print("Failed to create invite from dict: \(challengeDict)!!")
                        }
                    }
                
                    /*
                    for snap in snapshot.children {
                        print(snap)
                    }
                    */
                    
                }
            })
                
            
              FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.ChallengesSent).observe(.childAdded, with: { (snapshot) in
                if let challengeDict = snapshot.value as? [String:Any] {
                    
                    if let status = challengeDict[GameConstants.Invite_status] as? String {
                        if status == GameConstants.Invite_status_declined {
                            print("Game Request Declined!!!!")
                            print("Game Request Declined!!!!")
                            print("Game Request Declined!!!!")
                            if let challengeID = challengeDict[GameConstants.InviteID] as? String {
                            FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.ChallengesSent).child(challengeID).removeValue()
                            }
                            
                        }
                    }
                }
              })
            
            FirebaseConstants.CurrentUserPath?.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                
                if let userDict = snapshot.value as? [String: Any] {
                    
                    guard let userName = userDict[FirebaseConstants.UserName] as? String else {
                        print("no user name....returning!!!")
                        return }
                    
                    if opponentUserName != "" {
                        let challengerID = snapshot.key
                        // get opponent userID
                        
                        
                        //find opponent's userID
                        
                        FirebaseConstants.UsersNode.queryOrdered(byChild: FirebaseConstants.UserName).queryEqual(toValue: opponentUserName).observeSingleEvent(of: .value, with: { (snapshot) in
                            guard snapshot.exists() else {
                                print("there is no user with this name!!!")
                                return
                            }
                            if let dict = snapshot.value as? [String: Any] {
                                guard let opponentID = dict.keys.first else {
                                    print("No opponent ID!!")
                                    return
                                }
                                
                                

                           
                        
                                let challengePath = FirebaseConstants.UsersNode.child(opponentID).child(FirebaseConstants.ChallengesReceived).childByAutoId()
                                
                                let challengeKey = challengePath.key
                                
                               /* let challenge: Invite = Invite(inviteID: challengeKey, senderID: currentUserID!, receiverID: opponentID, receiverUserName: opponentUserName, senderUserName: challengerUserName) */
                                let challenge: [String: Any] = [GameConstants.InviteID: challengeKey,
                                                                GameConstants.Invite_senderID: currentUserID!,
                                                                GameConstants.Invite_senderName: userName,
                                                                GameConstants.Invite_ReceiverID: opponentID,
                                                                GameConstants.Invite_receiverName: opponentUserName,
                                                                GameConstants.Invite_timestamp: Int(NSDate().timeIntervalSince1970),
                                                                GameConstants.Invite_status: GameConstants.Invite_statusPending]
                                
                                challengePath.updateChildValues(challenge)
                                FirebaseConstants.UsersNode.updateChildValues([
                                    "/\(challengerID)/contacts/": [opponentID: opponentUserName],
                                    "/\(challengerID)/\(FirebaseConstants.ChallengesSent)/\(challengeKey)": challenge,
                                    "/\(opponentID)/contacts/": [challengerID: userName]
                                    ])
                             }
                            
                        })
                        
                    }
                }
            })
            
        }
    }
    */
    
    func loginUser(email: String, password: String, errorHandler: UIViewController?, completion: @escaping () -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil && errorHandler != nil {
               
                let loginAlert = UIAlertController(title: "Login Error", message: error!.localizedDescription, preferredStyle: .alert)
                loginAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                errorHandler!.present(loginAlert, animated: true, completion: nil)
                
            }
            guard user != nil else {
                return
            }
            
            completion()
         
        }

    }
    func postChallenge(opponentUserName: String, completion: (() -> Void)?){
        FirebaseConstants.CurrentUserPath?.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            print("in postChallenge current user path: \(FirebaseConstants.CurrentUserPath!)")
            
            
            if let userDict = snapshot.value as? [String: Any] {
                
                guard let userName = userDict[FirebaseConstants.UserName] as? String else {
                    print("no user name....returning!!!")
                    return }
                
                print("Post challenge: userName posting challenge = \(userName)")
                
                guard opponentUserName != userName else {
                    print("Can't challenge YOURSELF to a game. Try again!!!")
                    return
                }
                if opponentUserName != "" {
                
                    print("Post challenge: opponent name being challenged: \(opponentUserName)")
                    let challengerID = snapshot.key
                    print("challengerID: \(challengerID) should be the same as userID: \(FirebaseConstants.CurrentUserID!)")
                    print("which should be the same as currentUserID: \(currentUserID!)")
                    // get opponent userID
                    
                    
                    //find opponent's userID
                    
                    FirebaseConstants.UsersNode.queryOrdered(byChild: FirebaseConstants.UserName).queryEqual(toValue: opponentUserName).observeSingleEvent(of: .value, with: { (snapshot) in
                        guard snapshot.exists() else {
                            print("there is no user with this name!!!")
                            return
                        }
                        if let dict = snapshot.value as? [String: Any] {
                           
                            guard let opponentID = dict.keys.first else {
                                print("No opponent ID!!")
                                return
                            }
                            print("Opponent_ID: \(opponentID)")
                     
                            let challengePath = FirebaseConstants.UsersNode.child(opponentID).child(FirebaseConstants.ChallengesReceived).childByAutoId()
                            let challengeKey = challengePath.key
                            
                            /* let challenge: Invite = Invite(inviteID: challengeKey, senderID: currentUserID!, receiverID: opponentID, receiverUserName: opponentUserName, senderUserName: challengerUserName) */
                            print("in postChallenge, before updating opponent's challenge field. current user ID (i.e. sender)\(FirebaseConstants.CurrentUserID)")
                            print("in postChallenge...userName(sender Name): \(userName). Opponent Name: \(opponentUserName). Opponent ID: \(opponentID)")
                            let challenge: [String: Any] = [GameConstants.InviteID: challengeKey,
                                                            GameConstants.Invite_senderID: FirebaseConstants.CurrentUserID,
                                                            GameConstants.Invite_senderName: userName,
                                                            GameConstants.Invite_ReceiverID: opponentID,
                                                            GameConstants.Invite_receiverName: opponentUserName,
                                                            GameConstants.Invite_timestamp: Int(NSDate().timeIntervalSince1970),
                                                            GameConstants.Invite_status: GameConstants.Invite_statusPending]
                            
                            challengePath.updateChildValues(challenge)
                            
                            FirebaseConstants.UsersNode.updateChildValues([
                                "/\(challengerID)/contacts/\(opponentID)/": opponentUserName,
                                "/\(challengerID)/\(FirebaseConstants.ChallengesSent)/\(challengeKey)": challenge,
                                "/\(opponentID)/contacts/": [challengerID: userName]
                                ])
                            
                            if completion != nil {
                                completion!()
                            }
                        }
                        
                    })
                    
                }
            }
        })
    }
    
    func loadInvites(completion: (([Invite]?)->())?) {
    
       var invites = [Invite]()
        
        print("Running loadInvites in Fire.....right now invites has a count of \(invites.count)")
        print("CurrentUserPath: \(FirebaseConstants.CurrentUserPath!)")
        print("CurrentUserID: \(FirebaseConstants.CurrentUserID)")
        
        FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.ChallengesReceived).observe(.value, with: { (snapshot) in
        
            if snapshot.exists() {
                invites.removeAll()
               
                print("Showing invites snapshot for \(FirebaseConstants.CurrentUserID!): \(snapshot)")
                if let dict1 = snapshot.value as? [String: Any] {
                    for dict2 in dict1.values {
                        if let inviteDict = dict2 as? [String:Any] {
                            if let invite = Invite(dict: inviteDict) {

                                invites.append(invite)
                            }
                        }
                    }
                }
                
            }
            else {
                print("No challenges snapshot exists!!")
            }
            
            if completion != nil {
                 completion!(invites)
            }
       
        })
        
        
    }
    
    func checkForChallengesReceived(completion: @escaping (Bool) -> Void) {
        FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.ChallengesReceived).observe(.value, with: { (snapshot) in
                completion(snapshot.exists())
        })
        
    }
    
    func loadContacts(completion: @escaping ([String]) -> Void) {

        var contacts =  [String]()
        print("loading Contacts for currentUser: \(FirebaseConstants.CurrentUserID).....")
        FirebaseConstants.CurrentUserPath?.child("contacts").observeSingleEvent(of: .value, with: { (snapshot) in
            if let contactDict = snapshot.value as? [String: Any] {
                for val in contactDict.values {
                    if let contactName = val as? String {
                        contacts.append(contactName)
                    }
                }
                completion(contacts)
            }
            else {
                print("No contacts!!!!")
            }
            
            
        })
    }
    
    func createGame(invite: Invite) {
        // delete invitation from challenger in current User's node
        
        FirebaseConstants.CurrentUserPath?.child("challenges_received/\(invite.inviteID)").removeValue()
        FirebaseConstants.UsersNode.child("\(invite.senderID)/challenges_sent/\(invite.inviteID)").removeValue()
        
        print("in Fire createGame, with invite: \(invite)")
        
        //find opponent's userID
     
        let challengerID = invite.senderID
        let challengerUserName = invite.senderUserName
        
        
        print("Challenger name: \(challengerUserName). challenger ID: \(challengerID)")
        
                let gamePath =  FirebaseConstants.GamesNode.childByAutoId()
                let gameID = gamePath.key
                let board = Board()
                FirebaseConstants.CurrentUserPath?.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let currentUserDict = snapshot.value as? [String: Any] {
                        if let currentUserName = currentUserDict[FirebaseConstants.UserName] as? String, let currentUserID = currentUserDict[FirebaseConstants.UserID] as? String {
                            
                            /*** this creates an un-needed sprite node... ***/
                            let _ = board.setUpBoard()
                            

                            gamePath.updateChildValues(
                                
                                ["/\(FirebaseConstants.GamePlayersNode)/\(challengerID)/\(FirebaseConstants.UserTileRack)": "",
                                 "/\(FirebaseConstants.GamePlayersNode)/\(challengerID)/\(FirebaseConstants.UserPlayer1)": true,
                                 "/\(FirebaseConstants.GamePlayersNode)/\(challengerID)/\(FirebaseConstants.UserScore)": 0,
                                 "/\(FirebaseConstants.GamePlayersNode)/\(challengerID)/\(FirebaseConstants.UserID)": challengerID,
                                 "/\(FirebaseConstants.GamePlayersNode)/\(challengerID)/\(FirebaseConstants.UserName)": "\(challengerUserName)",
                                    

                                    
                                    "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserTileRack)": "",
                                    "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserPlayer1)": false,
                                    "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserScore)": 0,
                                    "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserID)": currentUserID,
                                    "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserName)": "\(currentUserName)",
                                    
                                    "/\(FirebaseConstants.GameCurrentPlayerID)": challengerID,
                                    
                                    "/\(FirebaseConstants.GameBoard)": board.convertToDict(),
                                    
                                    "/\(FirebaseConstants.GameNew)": true])
                            
                            FirebaseConstants.UsersNode.updateChildValues(
                                ["/\(challengerID)/\(FirebaseConstants.UserGames)/\(gameID)": 1,
                                 
                                 
                                 "/\(currentUserID)/\(FirebaseConstants.UserGames)/\(gameID)": 1
                                ])
                            
                            
                        }
                    }
            
        })
    }
    
    func declineInvitation(invite: Invite) {
        
        FirebaseConstants.CurrentUserPath?.child("challenges_received/\(invite.inviteID)").removeValue()
        FirebaseConstants.UsersNode.child("\(invite.senderID)/challenges_sent/\(invite.inviteID)").removeValue()
        print("you have declined!!!!")
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
        FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.UserGames).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userGameDict = snapshot.value as? [String: Any] {
              
                if let gameID = userGameDict.keys.first {
                    
                    print("gameID: \(gameID)")
                    
                    FirebaseConstants.GamesNode.child(gameID).observe(.value, with: { (snapshot) in
                        let game = Game()
                        game.gameID = gameID
                        print("observing particular game in loadGame with ID: \(gameID)")
                        /*if game.board.grid.isEmpty == false {
                                game.board.showBoard()
                        }*/
                     
                        //print("Game Dict: \(snapshot)")
                        
                        
                        if let gameDict = snapshot.value as? [String: Any] {
                                print("got gameDict")
                            if let boardValues = gameDict[FirebaseConstants.GameBoard] as? [String:Any] {
                                print("got board Values")
                                
                                for i in 0 ... GameConstants.BoardNumRows {
                                    var tileRow = [Tile]()
                                    for j in 0 ... GameConstants.BoardNumCols {
                                        if let tileDict = boardValues["Row\(i)_Col\(j)"] as? [String: Any] {
                                            let tile = Tile.initializeFromDict(dict: tileDict)
                                           
                                            tileRow.append(tile)
                                            if j == GameConstants.BoardNumCols {
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
                                            let player = Player()
                                            var playerN = ""
                                            if let isPlayer1 = playerDict[FirebaseConstants.UserPlayer1] as? Bool {
                                                player.player1 = isPlayer1
                                                playerN = isPlayer1 == true ? "Player 1" : "Player 2"
                                            }
                                            if  let playerScore = playerDict[FirebaseConstants.UserScore] as? Int {
                                               player.score = playerScore
                                            }
                                            if let playerName = playerDict[FirebaseConstants.UserName] as? String {
                                               
                                                player.userName = playerName
                                            }
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
 /*
    func loadGames(completion: (([Game])-> Void)?)  {
        print("IN LOADGAMES: Loading game IDs....")
        var games=[Game]()
        FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.UserGames).observe(.value, with: { (snapshot) in
            if let userGamesDict = snapshot.value as? [String: Any] {
               // print("userGamesDict: \(userGamesDict)")
                for (n,gameID) in userGamesDict.keys.enumerated() {
                    print("in load games, looping through game ids: n=\(n)")
                  //  print("looking at \(n)th game in games which is game \(gameID)")
                    FirebaseConstants.GamesNode.child(gameID).observe(.value, with: { (snapshot) in
                        print("observing game node in load games!! n=\(n) with gameID: \(gameID)")
                        let game = Game()
                        print("LOAD GAMES games var has a count of: \(games.count)")
                        if n == 0 {
                            games.removeAll()
                            print("after removing games on first run....LOAD GAMES games var has a count of: \(games.count)")
                            
                        }
                         game.gameID = gameID
                       
                        if let gameDict = snapshot.value as? [String: Any] {
                            //print("got gameDict for \(gameID), n = \(n)")
                            if let boardValues = gameDict[FirebaseConstants.GameBoard] as? [String:Any] {
                                
                               // print("Got board Values for \(gameID)")
                                
                                for i in 0 ... GameConstants.BoardNumRows {
                                    var tileRow = [Tile]()
                                    for j in 0 ... GameConstants.BoardNumCols {
                                        if let tileDict = boardValues["Row\(i)_Col\(j)"] as? [String: Any] {
                                            let tile = Tile.initializeFromDict(dict: tileDict)
                                            
                                            tileRow.append(tile)
                                            if j == GameConstants.BoardNumCols {
                                                game.board.appendTileRowInGrid(tileRow: tileRow)
                                             
                                            }
                                        }
                                    }
                                }
                             
                            }
                            else {
                                print("Cannot get board values for \(gameID)")
                            }
                            
                            
                            
                            if let currentPlayerID = gameDict[FirebaseConstants.GameCurrentPlayerID] as? String {
                              //  print("got current Player")
                                game.currentPlayerID = currentPlayerID
                                
                                if let playersDict = gameDict[FirebaseConstants.GamePlayersNode] as? [String: Any] {
                              //      print("Got playersDict")
                                    
                                    for player in playersDict.values {
                                        // print("player in playerDict: \(player)")
                                        if let playerDict = player as? [String:Any] {
                                            let player = Player()
                                            var playerN = ""
                                            if let isPlayer1 = playerDict[FirebaseConstants.UserPlayer1] as? Bool {
                                                player.player1 = isPlayer1
                                                playerN = isPlayer1 == true ? "Player 1" : "Player 2"
                                            }
                                            if  let playerScore = playerDict[FirebaseConstants.UserScore] as? Int {
                                                player.score = playerScore
                                            }
                                            if let playerName = playerDict[FirebaseConstants.UserName] as? String {
                                                
                                                player.userName = playerName
                                            }
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
                            
                                }
                            }

                            
                            print("About to append game \(gameID) to games in loadGames")
                            games.append(game)
                            
                            if n == userGamesDict.keys.count - 1 && completion != nil {
                                completion!(games)
                                
                            }
                         }
                        else {
                            print("Cannot get gameDict for \(gameID)")
                        }
                    })
                 
                }
                
               
            }
        })
        
        
    }
    */
    func loadGames(completion: (([Game])-> Void)?)  {
        print("IN LOADGAMES: Loading game IDs....")
        var games=[Game]()
        FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.UserGames).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userGamesDict = snapshot.value as? [String: Any] {
                // print("userGamesDict: \(userGamesDict)")
                for (n,gameID) in userGamesDict.keys.enumerated() {
                    print("in load games, looping through game ids: n=\(n)")
                    //  print("looking at \(n)th game in games which is game \(gameID)")
                    FirebaseConstants.GamesNode.child(gameID).observeSingleEvent(of: .value, with: { (snapshot) in
                        print("observing game node in load games!! n=\(n) with gameID: \(gameID)")
                        let game = Game()
                        print("LOAD GAMES games var has a count of: \(games.count)")
                        if n == 0 {
                            games.removeAll()
                            print("after removing games on first run....LOAD GAMES games var has a count of: \(games.count)")
                            
                        }
                        game.gameID = gameID
                        
                        if let gameDict = snapshot.value as? [String: Any] {
                            //print("got gameDict for \(gameID), n = \(n)")
                            if let boardValues = gameDict[FirebaseConstants.GameBoard] as? [String:Any] {
                                
                                // print("Got board Values for \(gameID)")
                                
                                for i in 0 ... GameConstants.BoardNumRows {
                                    var tileRow = [Tile]()
                                    for j in 0 ... GameConstants.BoardNumCols {
                                        if let tileDict = boardValues["Row\(i)_Col\(j)"] as? [String: Any] {
                                            let tile = Tile.initializeFromDict(dict: tileDict)
                                            
                                            tileRow.append(tile)
                                            if j == GameConstants.BoardNumCols {
                                                game.board.appendTileRowInGrid(tileRow: tileRow)
                                                
                                            }
                                        }
                                    }
                                }
                                
                            }
                            else {
                                print("Cannot get board values for \(gameID)")
                            }
                            
                            
                            
                            if let currentPlayerID = gameDict[FirebaseConstants.GameCurrentPlayerID] as? String {
                                //  print("got current Player")
                                game.currentPlayerID = currentPlayerID
                                
                                if let playersDict = gameDict[FirebaseConstants.GamePlayersNode] as? [String: Any] {
                                    //      print("Got playersDict")
                                    
                                    for player in playersDict.values {
                                        // print("player in playerDict: \(player)")
                                        if let playerDict = player as? [String:Any] {
                                            let player = Player()
                                            var playerN = ""
                                            if let isPlayer1 = playerDict[FirebaseConstants.UserPlayer1] as? Bool {
                                                player.player1 = isPlayer1
                                                playerN = isPlayer1 == true ? "Player 1" : "Player 2"
                                            }
                                            if  let playerScore = playerDict[FirebaseConstants.UserScore] as? Int {
                                                player.score = playerScore
                                            }
                                            if let playerName = playerDict[FirebaseConstants.UserName] as? String {
                                                
                                                player.userName = playerName
                                            }
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
                                    
                                }
                            }
                            
                            
                            print("About to append game \(gameID) to games in loadGames")
                            games.append(game)
                            
                            if n == userGamesDict.keys.count - 1 && completion != nil {
                                completion!(games)
                                
                            }
                        }
                        else {
                            print("Cannot get gameDict for \(gameID)")
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

    
    


    
 
