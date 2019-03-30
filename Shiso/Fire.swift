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
private var databaseHandle = DatabaseHandle()
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
           
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            guard error == nil else {
             
                let registerError = UIAlertController(title: "Oops!", message: error!.localizedDescription, preferredStyle: .alert)
                registerError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                errorHandler.present(registerError, animated: true, completion: nil)
                    
                
                return
            }
            
            guard let userID =  user?.uid else {
                print("no user id")
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

    func getCurrentUserName(completion: @escaping (String?) -> Void){
        guard FirebaseConstants.CurrentUserID != nil else {print("No user ID. can't getCurrentUserName")
            return }
        print("Current user path: \(FirebaseConstants.CurrentUserPath)")
        FirebaseConstants.CurrentUserPath?.observeSingleEvent(of: .value, with: { (snap) in
            if let userSnapshot = snap.value as? [String: Any] {
                print("got user snapshot as dict")
                if let userName = userSnapshot[FirebaseConstants.UserName] as? String {
                    
                    completion(userName)
                }
            }
        })
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
    func postChallenge(opponentUserName: String, completion: ((Bool) -> Void)?){
        FirebaseConstants.CurrentUserPath?.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            print("in postChallenge current user path: \(FirebaseConstants.CurrentUserPath!)")
            
            
            if let userDict = snapshot.value as? [String: Any] {
                
                guard let userName = userDict[FirebaseConstants.UserName] as? String else {
                    print("no user name....returning!!!")
                    if completion != nil {
                        completion!(false)
                    }
                    return
                    
                    
                }
                
                print("Post challenge: userName posting challenge = \(userName)")
                
                guard opponentUserName != userName else {
                    print("Can't challenge YOURSELF to a game. Try again!!!")
                    if completion != nil {
                        completion!(false)
                    }
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
                            if completion != nil {
                                completion!(false)
                            }
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
                                completion!(true)
                            }
                        }
                        
                    })
                    
                }
            }
        })
    }
    
    func loadInvites(completion: (([Invite]?)->())?) {
    
        var invites = [Invite](){
            didSet {
            print("in loadInvites...count = \(invites.count)")
            }
        }
        
        print("Running loadInvites in Fire.....right now invites has a count of \(invites.count)")
        print("CurrentUserID: \(FirebaseConstants.CurrentUserID)")
        
        FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.ChallengesReceived).removeAllObservers()
        
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
                invites.removeAll()
                print("invites count: \(invites.count) invites: \(invites)")
            }
            
            if completion != nil {
                print("in loadInvites completion with invites: \(invites)")
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
    
    func createGame(invite: Invite, completion: (() -> ())?) {
        // delete invitation from challenger in current User's node
        
        FirebaseConstants.CurrentUserPath?.child("challenges_received/\(invite.inviteID)").removeValue()
        FirebaseConstants.UsersNode.child("\(invite.senderID)/challenges_sent/\(invite.inviteID)").removeValue()
        
        print("in Fire createGame, with invite: \(invite)")
        
        //find opponent's userID
     
        let challengerID = invite.senderID
        let challengerUserName = invite.senderUserName
        
        
        print("Challenger name: \(challengerUserName). challenger ID: \(challengerID)")
        print("Current receiver ID receiver id: \(invite.receiverID)")
                let gamePath =  FirebaseConstants.GamesNode.childByAutoId()
                let gameID = gamePath.key
                let board = Board()
                FirebaseConstants.CurrentUserPath?.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let currentUserDict = snapshot.value as? [String: Any] {
                        if let currentUserName = currentUserDict[FirebaseConstants.UserName] as? String, let currentUserID = currentUserDict[FirebaseConstants.UserID] as? String {
                            
                            print("Current User ID, should be receiver ID,: \(currentUserID)")
                            
                            /*** this creates an un-needed sprite node... ***/
                            let _ = board.setUpBoard()
                            
                            let player1Assignment = arc4random_uniform(100) > 50
                            print("player 1 assignment for challenger \(challengerID) = \(player1Assignment).")
                            
                            
                            gamePath.updateChildValues(
                                
                                ["/\(FirebaseConstants.GamePlayersNode)/\(challengerID)/\(FirebaseConstants.UserTileRack)": "",
                                 "/\(FirebaseConstants.GamePlayersNode)/\(challengerID)/\(FirebaseConstants.UserPlayer1)": player1Assignment,
                                 "/\(FirebaseConstants.GamePlayersNode)/\(challengerID)/\(FirebaseConstants.UserScore)": 0,
                                 "/\(FirebaseConstants.GamePlayersNode)/\(challengerID)/\(FirebaseConstants.UserID)": challengerID,
                                 "/\(FirebaseConstants.GamePlayersNode)/\(challengerID)/\(FirebaseConstants.UserName)": "\(challengerUserName)",
                                    

                                    
                                    "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserTileRack)": "",
                                    "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserPlayer1)": !player1Assignment,
                                    "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserScore)": 0,
                                    "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserID)": currentUserID,
                                    "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserName)": "\(currentUserName)",
                                    
                                    "/\(FirebaseConstants.GameCurrentPlayerID)": player1Assignment == true ? challengerID : currentUserID,
                                    
                                    "/\(FirebaseConstants.GameBoard)": board.convertToDict(),
                                    
                                    "/\(FirebaseConstants.GameNew)": true,
                                    FirebaseConstants.GameLastUpdated :  Int(NSDate().timeIntervalSince1970)])
                            
                            FirebaseConstants.UsersNode.updateChildValues(
                                ["/\(challengerID)/\(FirebaseConstants.UserGames)/\(gameID)": 1,
                                 
                                 
                                 "/\(currentUserID)/\(FirebaseConstants.UserGames)/\(gameID)": 1
                                ])
                            
                            
                        }
                    }
            
        })
        
        if completion != nil {
         completion!()
        }
    }
    
    func createGame(p1: Player,p2: Player) {
        print("in create game")
        
        let gamePath =  FirebaseConstants.GamesNode.childByAutoId()
        let gameID = gamePath.key
        let board = Board()
        let _ = board.setUpBoard()
        
        let player1Assignment = arc4random_uniform(100) > 50
        guard p1.userID != nil && p2.userID != nil && p1.userName != nil && p2.userName != nil else {
            print("p1 or p2 username or userid is nil! returning from fire.createGame()")
            return
        }
  
        
        gamePath.updateChildValues(
            
            ["/\(FirebaseConstants.GamePlayersNode)/\(p1.userID!)/\(FirebaseConstants.UserTileRack)": "",
             "/\(FirebaseConstants.GamePlayersNode)/\(p1.userID!)/\(FirebaseConstants.UserPlayer1)": player1Assignment,
             "/\(FirebaseConstants.GamePlayersNode)/\(p1.userID!)/\(FirebaseConstants.UserScore)": 0,
             "/\(FirebaseConstants.GamePlayersNode)/\(p1.userID!)/\(FirebaseConstants.UserID)": p1.userID!,
             "/\(FirebaseConstants.GamePlayersNode)/\(p1.userID!)/\(FirebaseConstants.UserName)": p1.userName!,
                
                
                
                "/\(FirebaseConstants.GamePlayersNode)/\(p2.userID!)/\(FirebaseConstants.UserTileRack)": "",
                "/\(FirebaseConstants.GamePlayersNode)/\(p2.userID!)/\(FirebaseConstants.UserPlayer1)": !player1Assignment,
                "/\(FirebaseConstants.GamePlayersNode)/\(p2.userID!)/\(FirebaseConstants.UserScore)": 0,
                "/\(FirebaseConstants.GamePlayersNode)/\(p2.userID!)/\(FirebaseConstants.UserID)": p2.userID!,
                "/\(FirebaseConstants.GamePlayersNode)/\(p2.userID!)/\(FirebaseConstants.UserName)": p2.userName!,
                
                "/\(FirebaseConstants.GameCurrentPlayerID)": player1Assignment ? p1.userID! : p2.userID!,
                
                "/\(FirebaseConstants.GameBoard)": board.convertToDict(),
                
                "/\(FirebaseConstants.GameNew)": true,
                FirebaseConstants.GameLastUpdated :  Int(NSDate().timeIntervalSince1970)])
        
        FirebaseConstants.UsersNode.updateChildValues(
            ["/\(p1.userID!)/\(FirebaseConstants.UserGames)/\(gameID)": 1,
             
             
             "/\(p2.userID!)/\(FirebaseConstants.UserGames)/\(gameID)": 1
            ])
        
        
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
   
  
 func updateStatsAndRemoveGame(game: Game){
    
        var keyToIncrement: String = ""
        var oppKeyToIncrement: String = ""
        guard let opponentID = (game.player1.userID == Auth.auth().currentUser?.uid ? game.player2.userID : game.player1.userID) else {return}
        
        let currentUserStatPath =  FirebaseConstants.CurrentUserPath!.child("Stats")
        let opponentStatPath =   FirebaseConstants.UsersNode.child("\(opponentID)/Stats")
    
        if game.player1.score == game.player2.score {
            keyToIncrement = FirebaseConstants.StatsTies
            oppKeyToIncrement = FirebaseConstants.StatsTies
        }
      
        
       else if Auth.auth().currentUser?.uid  == (game.player1.score > game.player2.score ? game.player1.userID : game.player2.userID) {
            keyToIncrement = FirebaseConstants.StatsWins
            oppKeyToIncrement = FirebaseConstants.StatsLosses
            incrementValue(atPath: currentUserStatPath, forKey: FirebaseConstants.StatsTotalWins)
            incrementValue(atPath: opponentStatPath, forKey: FirebaseConstants.StatsTotalLosses)
         }
        else {
            keyToIncrement = FirebaseConstants.StatsLosses
            oppKeyToIncrement = FirebaseConstants.StatsWins
            incrementValue(atPath: currentUserStatPath, forKey: FirebaseConstants.StatsTotalLosses)
            incrementValue(atPath: opponentStatPath, forKey: FirebaseConstants.StatsTotalWins)
        }
        
          let currentPlayerScore = Auth.auth().currentUser?.uid == game.player1.userID ? game.player1.score : game.player2.score
        
         let opponentScore = Auth.auth().currentUser?.uid == game.player1.userID ? game.player2.score : game.player1.score
        
        incrementValue(atPath: currentUserStatPath.child(opponentID), forKey: keyToIncrement)
        updateHighScore(atPath: currentUserStatPath, currentScore: currentPlayerScore)
        updateHighScore(atPath: currentUserStatPath.child(opponentID), currentScore: currentPlayerScore)
        incrementValue(atPath: currentUserStatPath, forKey: FirebaseConstants.StatsNumberOfGames)
       
        incrementValue(atPath:  opponentStatPath.child(FirebaseConstants.CurrentUserID!), forKey: keyToIncrement)
        updateHighScore(atPath: opponentStatPath, currentScore: opponentScore)
        updateHighScore(atPath: opponentStatPath.child(FirebaseConstants.CurrentUserID!), currentScore: opponentScore)
        incrementValue(atPath: opponentStatPath, forKey: FirebaseConstants.StatsNumberOfGames)
        
        let currentPlayerWon = currentPlayerScore > opponentScore ? 1 : 0
        updateWinningStreak(path: currentUserStatPath, win: currentPlayerWon )
        updateWinningStreak(path: opponentStatPath, win: 1 - currentPlayerWon)
        
        guard let gameID = game.gameID else {return}
        
        
        FirebaseConstants.CurrentUserPath!.child(FirebaseConstants.UserGames).child(gameID).removeValue()
    }
    
    func incrementValue(atPath path: DatabaseReference, forKey k: String, incrementBy value: Int = 1){
    
        path.observeSingleEvent(of: .value, with: {(snap) in
            if let snapshot = snap.value as? [String: Any] {
                if let oldVal = snapshot[k] as? Int {
                    let newVal = oldVal + value
                
                    path.updateChildValues(["\(k)": newVal])
                }
                else {
                    path.updateChildValues(["\(k)": 1])
                }
            }
            else {
                path.updateChildValues(["\(k)": 1])
            }
            
        })
    }
    
 
    func updateHighScore(atPath path: DatabaseReference, currentScore: Int, singlePlayerMode: Bool = false, completion: (()->())? = nil ){
     
        let keyToUpdate = singlePlayerMode == false ? FirebaseConstants.StatsHighScore : FirebaseConstants.StatsSinglePlayer_2Min_HighScore
        
        path.observeSingleEvent(of: .value, with: {(snap) in
            
            if let snapshot = snap.value as? [String: Any] {
                
            
                
                if let prevHS = snapshot[keyToUpdate] as? Int {
                    print("we can find prevHS in this snapshot")
                    if prevHS < currentScore {
                   path.updateChildValues([keyToUpdate: currentScore])
                      
                    }
                }
                else {
                    print("no prevHS so far...putting in current score")
                    
                    path.updateChildValues([keyToUpdate: currentScore])
                    
                }
                
            
            }

            else {
                print("couldn't find this key, so creating it now")
              path.updateChildValues([keyToUpdate: currentScore])
               
            }
         
        })
    }

    func updateHighScore(atPath path: DatabaseReference,game: Game, completion: ((Bool?)->())? = nil ){
         let timeDict: [TimeSelection: String] = [.twoMinute: FirebaseConstants.StatsSinglePlayer_2Min_HighScore, .fiveMinute: FirebaseConstants.StatsSinglePlayer_5Min_HighScore, .tenMinute: FirebaseConstants.StatsSinglePlayer_10Min_HighScore]
     
        let keyToUpdate = game.singlePlayerMode == false ? FirebaseConstants.StatsHighScore : timeDict[game.timeSelection]
        
        guard  keyToUpdate != nil else {return }
        print("key to update is: \(keyToUpdate) at path: \(path)")
        path.observeSingleEvent(of: .value, with: {(snap) in
            
            if let snapshot = snap.value as? [String: Any] {
                
                
                
                if let prevHS = snapshot[keyToUpdate!] as? Int {
                    print("the prevHS for \(keyToUpdate!) is \(prevHS) and the current player score is:\(game.player1.score)")
                    if prevHS < game.player1.score {
                        print("prevHS is less than \(game.player1.score) so new high score!")
                        path.updateChildValues([keyToUpdate!: game.player1.score])
                        print("updating path: \(path) at \(keyToUpdate!)")
                        if completion != nil {
                            print("completion being run")
                            completion!(true)
                        }
                    }
                }
                else {
                    print("no prevHS so far...putting in current score")
                    
                    path.updateChildValues([keyToUpdate!: game.player1.score])
                    
                }
                
                
            }
                
            else {
                print("couldn't find key \(keyToUpdate!), so creating it now for: \(FirebaseConstants.CurrentUserPath!) with stats child")
               let statsRef = FirebaseConstants.CurrentUserPath!.child("Stats")
                statsRef.updateChildValues([keyToUpdate!: game.player1.score])
                
            }
            
        })
        
       
    }
    
    
    func updateWinningStreak(path: DatabaseReference, win: Int){
        
        path.observeSingleEvent(of: .value, with: { (snap) in
            if let snapshot = snap.value as? [String: Any] {
                if let winningStreak = snapshot[FirebaseConstants.StatsWinningStreak] as? Int {
                    if win == 1 {
                        path.updateChildValues([FirebaseConstants.StatsWinningStreak: winningStreak + 1])
                        if let longestWinningStreak = snapshot[FirebaseConstants.StatsLongestWinningStreak] as? Int {
                            if winningStreak + 1 > longestWinningStreak {
                                path.updateChildValues([FirebaseConstants.StatsLongestWinningStreak: winningStreak + 1])
                            }
                        }
                        else {
                            path.updateChildValues([FirebaseConstants.StatsLongestWinningStreak: 1])
                        }
                    }
                    else {
                    path.updateChildValues([FirebaseConstants.StatsWinningStreak: 0])
                    
                        
                    }
                }
                else {
                    path.updateChildValues([FirebaseConstants.StatsWinningStreak: win])
                    path.updateChildValues([FirebaseConstants.StatsLongestWinningStreak: win])
                    
                }
                
            }
            else {
                 path.updateChildValues([FirebaseConstants.StatsWinningStreak: win])
                path.updateChildValues([FirebaseConstants.StatsLongestWinningStreak: win])
                
            }
            })
    }

 
  
    func getHighScores_2Min_pctl(completion: @escaping ([Int], [Int]) -> Void) {
        var hs2min = [Int]()
        var hs5min = [Int]()
       // var hs10min = [Int]()
        
        let usersPath = FirebaseConstants.UsersNode
        usersPath.observeSingleEvent(of: .value, with:{(snapshot)
            
            in
           
            print("snapshot children count: \(snapshot.childrenCount)")
            for child in snapshot.children.allObjects {
                if let s = child as? DataSnapshot {
                    if let s1 = s.value as? [String: Any] {
                     
                        
                        if let statsDict = s1["Stats"] as? [String: Any]
                        {
                        
                        if let hs2 = statsDict["SinglePlayer_2Min_HighScore"] as? Int {
                            print("Yes, single 2 min hs is an Int")
                             hs2min.append(hs2)
                        }
                            
                            if let hs5 = statsDict["SinglePlayer_5Min_HighScore"] as? Int {
                                hs5min.append(hs5)
                            }
                        }

                    }
                }
                else {
                print("can't do any of htis single player sdtats stuff")
                }
            }
            completion(hs2min, hs5min)
        })
    
    }
    
    
    
    func getSinglePlayerHighScore_Rankings(forSinglePlayerHSKeys keys: [String], completion: @escaping ([Int]?, [Int]?) -> Void) {
      
        
        
      let hs2min = [Int]()
      let hs5min = [Int]()
        
        var d: [String: [Int]] = [FirebaseConstants.StatsSinglePlayer_2Min_HighScore: hs2min, FirebaseConstants.StatsSinglePlayer_5Min_HighScore: hs5min]
        
      let usersPath = FirebaseConstants.UsersNode
        usersPath.observeSingleEvent(of: .value, with:{(snapshot)
            
            in
            
            for child in snapshot.children.allObjects {
                if let s = child as? DataSnapshot {
                    if let s1 = s.value as? [String: Any] {
                        if let statsDict = s1["Stats"] as? [String: Any]
                        {
                            
                            for k in keys {
                                if let hs = statsDict[k] as? Int {
                                    d[k]?.append(hs)
                                    
                                }
                            }
                        }
                    }
                }
              
            }
          completion(d[FirebaseConstants.StatsSinglePlayer_2Min_HighScore], d[FirebaseConstants.StatsSinglePlayer_5Min_HighScore])
        })

    }
    
    
    func getStats(forUserID userID: String, completion: @escaping (UserStats, [Int]?, [Int]?) -> ())  {
        let path = FirebaseConstants.UsersNode.child("\(userID)/\(FirebaseConstants.StatsNode)")
        var userstats = UserStats()
        
        
        
        path.observeSingleEvent(of: .value, with: {
            (snap) in
            if let snapshot = snap.value as? [String:Any] {
                
                var singlePlayerKeys = [String]()
                
                print("got stats snapshot at path: \(path). userstats: \(userstats)")
                if let nGames = snapshot[FirebaseConstants.StatsNumberOfGames] as? Int {
                    userstats.numberOfGames = nGames
                    print("nGames: \(nGames)")
                }
                else {
                    print("can't get Ngames stat as integer!")
                }
                if let nWins = snapshot[FirebaseConstants.StatsTotalWins] as? Int {
                    userstats.numberOfWins = nWins
                }
                if let nLosses = snapshot[FirebaseConstants.StatsTotalLosses] as? Int {
                    userstats.numberOfLosses = nLosses
                }
                if let longestWinStreak = snapshot[FirebaseConstants.StatsWinningStreak] as? Int {
                    userstats.longestWinStreak = longestWinStreak
                }
                if let winStreak = snapshot[FirebaseConstants.StatsWinningStreak] as? Int {
                    userstats.winStreak = winStreak
                }
                
                if let singlePlayer_2min_HighScore = snapshot[FirebaseConstants.StatsSinglePlayer_2Min_HighScore] as? Int {
                    print("2min hs: \(singlePlayer_2min_HighScore)")
                    userstats.singlePlayer_2min_HighScore = singlePlayer_2min_HighScore
                    singlePlayerKeys.append(FirebaseConstants.StatsSinglePlayer_2Min_HighScore)
                }
               
                if let singlePlayer_5min_highScore = snapshot[FirebaseConstants.StatsSinglePlayer_5Min_HighScore] as? Int {
                    userstats.singlePlayer_5min_HighScore = singlePlayer_5min_highScore
                    print("5 min score: \(singlePlayer_5min_highScore)")
                    singlePlayerKeys.append(FirebaseConstants.StatsSinglePlayer_5Min_HighScore)
                }
                if let singlePlayer_10min_HighScore = snapshot[FirebaseConstants.StatsSinglePlayer_10Min_HighScore] as? Int {
                    userstats.singlePlayer_10min_HighScore = singlePlayer_10min_HighScore
                
                }
                if singlePlayerKeys.count > 0 {
                    self.getSinglePlayerHighScore_Rankings(forSinglePlayerHSKeys: singlePlayerKeys){
                        (highScoresFor2Min, highScoresFor5Min)
                        in
                        
                        completion(userstats, highScoresFor2Min, highScoresFor5Min)
                    
                
                    }
                }
        
            }
                    
                    
                    
            else {
                
                print("Can't get stats snapshot for path: \(path)")
                completion(userstats,nil, nil)
            }
         
        })

   

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
                    
                    FirebaseConstants.GamesNode.child(gameID).observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    
    
    func loadGame1(completion: @escaping ((Game) -> Void))  {
        
        
        
        //      print("Current user path: \(FirebaseConstants.CurrentUserPath)")
        FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.UserGames).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userGameDict = snapshot.value as? [String: Any] {
                
                if let gameID = userGameDict.keys.first {
                    
                    print("gameID: \(gameID)")
                    
                    FirebaseConstants.GamesNode.child(gameID).observeSingleEvent(of: .value, with: { (snapshot) in
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
    func checkIfAnyGames(completion: @escaping ((Bool) -> Void)) {
        print("Checking any games at path: \(FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.UserGames))")
        FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.UserGames).observeSingleEvent(of: .value, with: {(snapshot) in
          
            if snapshot.exists() {
                
                completion(true)
            }
            else {
                completion(false)
            }
            
        })
    }
    func loadGames(completion: (([Game])-> Void)?)  {
        print("IN LOADGAMES: Loading game IDs....")
        var games=[Game]()
        print("games just set in loadGames(), should have 0 count. Games count: \(games.count)")
        FirebaseConstants.CurrentUserPath?.child(FirebaseConstants.UserGames).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userGamesDict = snapshot.value as? [String: Any] {
                print("userGamesDict: \(userGamesDict)")
                for (n,gameID) in userGamesDict.keys.enumerated() {
                    print("in load games, looping through game ids: n=\(n)")
                      print("looking at game \(n) in games which is game \(gameID)")
                    FirebaseConstants.GamesNode.child(gameID).observeSingleEvent(of: .value, with: { (snapshot) in
                         print("observing game node in load games!! n=\(n) with gameID: \(gameID)")
                        let game = Game()
                        print("LOAD GAMES games var has a count of: \(games.count)")
                    /*    if n == 0 {
                            games.removeAll()
                           print("after removing games on first run....LOAD GAMES games var has a count of: \(games.count)")
                            
                        }
                        else {
                            print("Games weren't emptied because n != 0. N=\(n)")
                        }
 */
                        game.gameID = gameID
                        
                        if let gameDict = snapshot.value as? [String: Any] {
                            print("GOT GAME DICT FOR: \(gameID)")
                            if let tilesLeft = gameDict[FirebaseConstants.GameTilesLeft] as? Int {
                                game.tilesLeft = tilesLeft
                            }
                            if let gameOver = gameDict[FirebaseConstants.GameOver] as? Bool {
                                game.gameOver = gameOver
                            }
                            if let lastTurnPassed = gameDict[FirebaseConstants.LastTurnPassed] as? Bool {
                                game.lastTurnPassed = lastTurnPassed
                            }
                            if let currentTurnPassed = gameDict[FirebaseConstants.GameCurrentTurnPassed] as? Bool {
                                game.currentTurnPassed = currentTurnPassed
                            }
                            if let lastUpdated = gameDict[FirebaseConstants.GameLastUpdated] as? Int {
                                game.lastUpdated = lastUpdated
                            }
                            
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
                            
                            if games.count == userGamesDict.keys.count  && completion != nil {
                                
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
 
    
//    func saveGameData(game: Game, completion: (()->())? ) {
//
//        print("In saveGameData...")
//
//
//        guard let gameID = game.gameID else {
//            print("no game ID in saveGameData")
//            return
//        }
//
//        FirebaseConstants.GamesNode.child(gameID).observeSingleEvent(of: .value, with: { (snapshot) in
//            if let FBGameDict = snapshot.value as? [String: Any], let currentPlayerID = FBGameDict[FirebaseConstants.GameCurrentPlayerID] as? String {
//
//                let currentPlayer = game.player1.userID == game.currentPlayerID ? game.player1! : game.player2!
//                let currentPlayerID = currentPlayer.userID!
//                let newCurrentPlayerID = currentPlayerID == game.player1.userID ? game.player2.userID! : game.player1.userID!
//
//                // Save current player data
//
//                print("about to save data with updateChildValues")
//                print("current Player was: \(currentPlayer.userName!). Score: \(currentPlayer.score)")
//                FirebaseConstants.GamesNode.child(gameID).updateChildValues(
//                    [FirebaseConstants.GameNew: false,
//                     FirebaseConstants.GameCurrentPlayerID: newCurrentPlayerID,
//                     FirebaseConstants.GameTilesLeft : game.tilesLeft,
//                     FirebaseConstants.LastTurnPassed: game.lastTurnPassed,
//                     FirebaseConstants.GameOver : game.gameOver,
//                     FirebaseConstants.GameLastUpdated: game.lastUpdated,
//                     FirebaseConstants.GameBoard : game.board.convertToDict(),
//                "/\(FirebaseConstants.GamePlayersNode)/\(currentPlayerID)/\(FirebaseConstants.UserScore)": currentPlayer.score,
//                "/\( FirebaseConstants.GamePlayersNode)/\(currentPlayerID)/\(FirebaseConstants.UserTileRack)": currentPlayer.tileRack.convertToDict()
//
//                ])
//
//
//                 if completion != nil { completion!()}
//
//                }
//            else {
//                print("save game data: Cannot get game dict" )
//            }
//
//
//        })
//
//    }
    
    
    func convertTilesToDict(tiles: [Tile]) -> [String: Any] {
        var tileDict = [String: Any]()
        for (n, tile) in tiles.enumerated(){
            
            tileDict["STile_\(n)"] = tile.convertToDict()
        }
        
        return tileDict
    }
    
    
    func saveGameData1(game: Game, completion: (() -> ())?) {
        
    
         guard let gameID = game.gameID else {
            print("no game ID in saveGameData")
            return
        }
        print("saving game with currentTurnPassed = \(game.currentTurnPassed) and last turn passed: \(game.lastTurnPassed)")
        
        //CHANGED from current player ID to current User ID....1/27/19
        let currentUser = game.player1.userID == FirebaseConstants.CurrentUserID ? game.player1! : game.player2!
        let currentUserID = currentUser.userID!
        
        
    /*
        FirebaseConstants.GamesNode.child(gameID).updateChildValues(
            [FirebaseConstants.GameNew: false,
             FirebaseConstants.GameCurrentPlayerID: currentPlayerID,
             FirebaseConstants.GameTilesLeft : game.tilesLeft,
             FirebaseConstants.LastTurnPassed: game.lastTurnPassed,
             FirebaseConstants.GameOver : game.gameOver,
             FirebaseConstants.GameLastUpdated: game.lastUpdated,
             FirebaseConstants.GameBoard : game.board.convertToDict(),
             "/\(FirebaseConstants.GamePlayersNode)/\(currentPlayerID)/\(FirebaseConstants.UserScore)": currentPlayer.score,
             "/\( FirebaseConstants.GamePlayersNode)/\(currentPlayerID)/\(FirebaseConstants.UserTileRack)": currentPlayer.tileRack.convertToDict()
                
            ])
*/
        FirebaseConstants.GamesNode.child(gameID).updateChildValues(
            [FirebaseConstants.GameNew: false,
             FirebaseConstants.GameCurrentPlayerID: game.currentPlayerID,
             FirebaseConstants.GameTilesLeft : game.tilesLeft,
             FirebaseConstants.LastTurnPassed: game.lastTurnPassed,
             FirebaseConstants.GameCurrentTurnPassed: game.currentTurnPassed,
             FirebaseConstants.GameOver : game.gameOver,
             FirebaseConstants.GameLastUpdated: game.lastUpdated,
             FirebaseConstants.GameBoard : game.board.convertToDict(),
             "/\(FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserScore)": currentUser.score,
             "/\( FirebaseConstants.GamePlayersNode)/\(currentUserID)/\(FirebaseConstants.UserTileRack)": currentUser.tileRack.convertToDict(),
             FirebaseConstants.GameSelectedPlayerTiles: convertTilesToDict(tiles: game.selectedPlayerTiles)
                
            ])
        if completion != nil {
        completion!()
        }
//      FirebaseConstants.GamesNode.child(gameID).observe(.value, with: { (snapshot) in
//
//            print("in observe in save game data1 with gameID: \(gameID)")
//            let game = Game()
//            game.gameID = gameID
//
//            if let gameDict = snapshot.value as? [String: Any] {
//                if let currentPlayerID = gameDict[FirebaseConstants.GameCurrentPlayerID] as? String {
//                    print("current player ID as string: \(currentPlayerID)")
//                }
//                else {
//                    print("Can't get current player id as string")
//                }
//                if let lastTurnPassed = gameDict[FirebaseConstants.LastTurnPassed] as? Bool {
//                    game.lastTurnPassed = lastTurnPassed
//                }
//                if let tilesLeft = gameDict[FirebaseConstants.GameTilesLeft] as? Int {
//                    game.tilesLeft = tilesLeft
//                }
//                if let currentTurnPassed = gameDict[FirebaseConstants.GameCurrentTurnPassed] as? Bool {
//                    game.currentTurnPassed = currentTurnPassed
//                }
//                if let boardValues = gameDict[FirebaseConstants.GameBoard] as? [String:Any] {
//                    print("got board values")
//                    for i in 0 ... GameConstants.BoardNumRows {
//                        var tileRow = [Tile]()
//                        for j in 0 ... GameConstants.BoardNumCols {
//                            if let tileDict = boardValues["Row\(i)_Col\(j)"] as? [String: Any] {
//                                let tile = Tile.initializeFromDict(dict: tileDict)
//
//                                tileRow.append(tile)
//                                if j == GameConstants.BoardNumCols {
//                                    game.board.appendTileRowInGrid(tileRow: tileRow)
//
//                                }
//                            }
//                        }
//                    }
//                }
//                else {
//                    print("cannot get board values")
//                }
//
//                if let currentPlayerID = gameDict[FirebaseConstants.GameCurrentPlayerID] as? String {
//                    print("got current player ID")
//                    game.currentPlayerID = currentPlayerID
//
//                    if let playersDict = gameDict[FirebaseConstants.GamePlayersNode] as? [String: Any] {
//                        print("Got players dict")
//                        for player in playersDict.values {
//                            // print("player in playerDict: \(player)")
//                            if let playerDict = player as? [String:Any] {
//                                print("got player dict again, correct")
//                                let player = Player()
//                                var playerN = ""
//                                if let isPlayer1 = playerDict[FirebaseConstants.UserPlayer1] as? Bool {
//                                    player.player1 = isPlayer1
//                                    playerN = isPlayer1 == true ? "Player 1" : "Player 2"
//                                }
//                                if  let playerScore = playerDict[FirebaseConstants.UserScore] as? Int {
//                                    player.score = playerScore
//                                }
//                                if let playerName = playerDict[FirebaseConstants.UserName] as? String {
//
//                                    player.userName = playerName
//                                }
//                                if let playerID = playerDict[FirebaseConstants.UserID] as? String {
//                                    player.userID = playerID
//                                }
//
//                                if let playerTileRack = playerDict[FirebaseConstants.UserTileRack] as?
//                                    [String:Any] {
//
//                                    player.tileRack = TileRack.convertFromDictToTileRack(dict: playerTileRack)
//
//                                }
//                                else {
//
//                                    print("no tile rack available for \(playerN)")
//
//                                }
//
//                                if player.player1 == true {
//                                    game.player1 = player
//                                }
//                                else {
//                                    game.player2 = player
//                                }
//                            }
//                        }
//
//
//                        //print("showing board grid now...")
//                        //game.board.showBoard()
//
//                    }
//
//
//                }
//
//                if completion != nil {
//                    print("about to run completion. game current turn passed = \(game.currentTurnPassed)")
//                    completion!(game)
//                }
//                else {
//                    print("completion is nil, not running")
//                }
//
//            }
//
//
//        })
      
        
    }
    
    
 
    
    func loadGameWithObserver(gameID: String, completion: ((Game) -> ())?){
        guard gameID != nil else {
            print("NO GAME ID in load game with obs. -- returning")
            return
        }
        FirebaseConstants.GamesNode.child(gameID).observe(.value, with: { (snapshot) in
            
            print("in loadGameWithObserver")
            let game = Game()
            game.gameID = gameID
            
            if let gameDict = snapshot.value as? [String: Any] {
              
                if let lastTurnPassed = gameDict[FirebaseConstants.LastTurnPassed] as? Bool {
                    game.lastTurnPassed = lastTurnPassed
                }
                if let tilesLeft = gameDict[FirebaseConstants.GameTilesLeft] as? Int {
                    game.tilesLeft = tilesLeft
                }
                if let currentTurnPassed = gameDict[FirebaseConstants.GameCurrentTurnPassed] as? Bool {
                    game.currentTurnPassed = currentTurnPassed
                }
                if let gameOver =  gameDict[FirebaseConstants.GameOver] as? Bool {
                    game.gameOver = gameOver 
                }
                
                if let selectedTilesDict = gameDict[FirebaseConstants.GameSelectedPlayerTiles] as? [String:Any] {
                    for tilesDict in selectedTilesDict.values {
                        if let tDict = tilesDict as? [String:Any] {
                            game.selectedPlayerTiles.append(Tile.initializeFromDict(dict: tDict))
                           
                        }
                    }
                }
                if let boardValues = gameDict[FirebaseConstants.GameBoard] as? [String:Any] {
                    print("got board values")
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
                    print("cannot get board values")
                }
                
                if let currentPlayerID = gameDict[FirebaseConstants.GameCurrentPlayerID] as? String {
                    print("got current player ID")
                    game.currentPlayerID = currentPlayerID
                    
                    if let playersDict = gameDict[FirebaseConstants.GamePlayersNode] as? [String: Any] {
                        print("Got players dict")
                        for player in playersDict.values {
                            // print("player in playerDict: \(player)")
                            if let playerDict = player as? [String:Any] {
                                print("got player dict again, correct")
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
                                else {
                                    
                                    print("no tile rack available for \(playerN)")
                                    
                                }
                                
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
                        
                    }
                    
                    
                }
                
                if completion != nil {
                    print("about to run completion in loadGameWithObserver")
                    completion!(game)
                }
            
                
            }
            
            
        })
    }
    
    
    func removeObserversFromGamesNode(game: Game) {
         FirebaseConstants.GamesNode.child(game.gameID).removeObserver(withHandle: databaseHandle)
        FirebaseConstants.GamesNode.child(game.gameID).removeAllObservers()
        
        print("REMOVED OBSERVERS CODE RUN")
    }
    func createOpenInvite() {
      let openInviteRef = FirebaseConstants.OpenInvites.childByAutoId()
      let openInviteKey = openInviteRef.key
        openInviteRef.updateChildValues(["inviteID" : "\(openInviteKey)", "senderID": FirebaseConstants.CurrentUserID,
                                         "timestamp": Int(NSDate().timeIntervalSince1970)])
       
        
        FirebaseConstants.OpenInvites.observeSingleEvent(of: .value,  with: { (snapshot) in
            if let openInvites = snapshot.value as? [String: Any] {
                for actualInvite in openInvites.values {
                    if let invite = actualInvite as? [String: Any] {
                        if let receiverID = invite["senderID"] as? String, receiverID != FirebaseConstants.CurrentUserID {
                         /******** get players names based on IDs *************/
                            FirebaseConstants.UsersNode.child(receiverID).observeSingleEvent(of: .value, with: { (snapshot) in
                                if let userSnap = snapshot.value as? [String: Any] {
                                    guard let receiverUserName = userSnap[FirebaseConstants.UserName] as? String else {return}
                                    FirebaseConstants.CurrentUserPath?.observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let senderSnap = snapshot.value as? [String: Any] {
                                            if let senderUserName = senderSnap[FirebaseConstants.UserName] as? String {
                                                
                                                let newInvite = Invite(inviteID: invite["inviteID"] as! String, senderID: FirebaseConstants.CurrentUserID!, receiverID: receiverID, receiverUserName: receiverUserName, senderUserName: senderUserName)
                                            
                                                FirebaseConstants.OpenInvites.child(invite["inviteID"] as! String).removeValue()
                                            
                                         /******** create game *************/
                                                
                                                let gamePath = FirebaseConstants.GamesNode.childByAutoId()
                                                let gameID = gamePath.key
                                                let board = Board()
                                                let _ = board.setUpBoard()
                                                let player1Assignment = arc4random_uniform(100) > 50
                                                gamePath.updateChildValues(
                                                    ["/\(FirebaseConstants.GamePlayersNode)/\(FirebaseConstants.CurrentUserID!)/\(FirebaseConstants.UserID)":
                                                    FirebaseConstants.CurrentUserID,
                                                     "/\(FirebaseConstants.GamePlayersNode)/\(FirebaseConstants.CurrentUserID!)/\(FirebaseConstants.UserPlayer1)": player1Assignment ,
                                                     
                                                     "/\(FirebaseConstants.GamePlayersNode)/\(FirebaseConstants.CurrentUserID!)/\(FirebaseConstants.UserTileRack)": "",
                                                     "/\(FirebaseConstants.GamePlayersNode)/\(FirebaseConstants.CurrentUserID!)/\(FirebaseConstants.UserScore)": 0,
                                                     "/\(FirebaseConstants.GamePlayersNode)/\(FirebaseConstants.CurrentUserID!)/\(FirebaseConstants.UserName)": senderUserName,
                                                    
                                                     "/\(FirebaseConstants.GamePlayersNode)/\(receiverID)/\(FirebaseConstants.UserID)":
                                                       receiverID,
                                                     "/\(FirebaseConstants.GamePlayersNode)/\(receiverID)/\(FirebaseConstants.UserPlayer1)": !player1Assignment,
                                                     
                                                     "/\(FirebaseConstants.GamePlayersNode)/\(receiverID)/\(FirebaseConstants.UserTileRack)": "",
                                                     "/\(FirebaseConstants.GamePlayersNode)/\(receiverID)/\(FirebaseConstants.UserScore)": 0,
                                                     "/\(FirebaseConstants.GamePlayersNode)/\(receiverID)/\(FirebaseConstants.UserName)": receiverUserName,
                                                    
                                                     FirebaseConstants.GameCurrentPlayerID: FirebaseConstants.CurrentUserID,
                                                     FirebaseConstants.GameBoard: board.convertToDict(),
                                                        FirebaseConstants.GameNew: true,
                                                        FirebaseConstants.GameLastUpdated: Int(NSDate().timeIntervalSince1970)
                                                    ])
                                            
                                               
                                                 FirebaseConstants.UsersNode.updateChildValues(["/\(FirebaseConstants.CurrentUserID!)/\(FirebaseConstants.UserGames)/\(gameID)": 1])
                                                
                                             FirebaseConstants.UsersNode.updateChildValues(["/\(receiverID)/\(FirebaseConstants.UserGames)/\(gameID)": 1])
                                            }
                                        }
                                    })
                            
                                }
                                
                                   FirebaseConstants.OpenInvites.child(openInviteKey).removeValue()
                            })
                            
                            
                            
                            
                            break
                        }
                    }
                }
            }
        })
        
    
    }
    
    /*
 
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
 
 */
    
    
}
    
    
    //end of class

    
    


    
 
