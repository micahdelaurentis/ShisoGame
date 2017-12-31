    //
//  LoginScene.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 9/1/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import GameKit
import FirebaseAuth
import Firebase
import FBSDKLoginKit
    

protocol TransitionDelegate: SKSceneDelegate  {
    func showLoginAlert(message: String)
    func showLoginError(message: String)
    func showLoginSuccess(message: String)
}

class LoginScene: SKScene, UITextFieldDelegate , FBSDKLoginButtonDelegate {
    
    var ref: DatabaseReference!
    var invite: Invite?
    var loginBtn = SKShapeNode()
    var loginTitle =  SKLabelNode()
    var registerButton = SKShapeNode()
    var registerTitle = SKLabelNode()
    var passwordField =  UITextField()
    var emailField = UITextField()
    var nameField  = UITextField()
    var opponentNameField = UITextField()
    var loginButton = FBSDKLoginButton()
    let acceptBox = SKLabelNode(text: "Accept")
    let declineBox = SKLabelNode(text: "Decline")
    override func didMove(to view: SKView) {
        
        
        
        ref = Database.database().reference()
        
        
        nameField = UITextField(frame: CGRect(x: view.frame.size.width/4, y: view.frame.size.height/3, width: 200, height: 30))
        
        emailField = UITextField(frame: CGRect(x: nameField.frame.origin.x, y: nameField.frame.origin.y + 35, width: nameField.frame.size.width , height: nameField.frame.size.height))
        
        passwordField = UITextField(frame: CGRect(x: emailField.frame.origin.x, y: emailField.frame.origin.y + 35, width: emailField.frame.size.width, height: emailField.frame.size.height))
        
        opponentNameField = UITextField(frame: CGRect(x: passwordField.frame.origin.x, y: passwordField.frame.origin.y + 35, width: passwordField.frame.size.width, height: passwordField.frame.size.height))
        
     loginButton = FBSDKLoginButton(frame: CGRect(x: opponentNameField.frame.origin.x , y: opponentNameField.frame.origin.y + 35,
                                                   width: opponentNameField.frame.size.width, height: opponentNameField.frame.size.height))
     
     loginButton.readPermissions = ["public_profile", "email"]
     loginButton.delegate  = self
    
        
 
          
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(opponentNameField)
        view.addSubview(loginButton)
        
        
        setUpTextField(tf: nameField, placeHolderTxt: "Username")
        setUpTextField(tf: emailField, placeHolderTxt: "Email")
        setUpTextField(tf: passwordField, placeHolderTxt: "Password")
        setUpTextField(tf: opponentNameField, placeHolderTxt: "Opponent's User Name")
        passwordField.isSecureTextEntry = true
        
        
        
        let vOrig = CGPoint(x: passwordField.frame.origin.x, y: passwordField.frame.origin.y + 250)
        let conOrig = convertPoint(fromView: vOrig)
        
    
        loginBtn = SKShapeNode(rect: CGRect(origin: conOrig, size: CGSize(width: self.frame.width/2 - 11, height: 60)), cornerRadius: 4.0)
        
        loginBtn.zPosition = 1
        loginBtn.fillColor = .blue
        
        loginTitle = SKLabelNode(text: "Login")
        loginTitle.zPosition = 2
        loginTitle.fontColor = .white
        loginTitle.fontSize = 45
        loginTitle.position.y = loginBtn.frame.midY
        loginTitle.position.x = loginBtn.frame.midX
        loginTitle.horizontalAlignmentMode = .center
        loginTitle.verticalAlignmentMode = .center
        loginTitle.fontName = "AppleSDGothicNeo-Regular"
        
        addChild(loginBtn)
        loginBtn.addChild(loginTitle)
        
        
        registerButton = SKShapeNode(rect: CGRect(origin: CGPoint(x: loginBtn.frame.origin.x, y: loginBtn.frame.origin.y + loginBtn.frame.height + 20), size: loginBtn.frame.size))
        
        registerButton.zPosition = 1
        registerButton.fillColor = .blue
        
        registerTitle = SKLabelNode(text: "Register")
        registerTitle.zPosition = 2
        registerTitle.fontColor = .white
        registerTitle.fontSize = 45
        registerTitle.position.y = registerButton.frame.midY
        registerTitle.position.x = registerButton.frame.midX
        registerTitle.horizontalAlignmentMode = .center
        registerTitle.verticalAlignmentMode = .center
        registerTitle.fontName = "AppleSDGothicNeo-Regular"
        
        
        addChild(registerButton)
        registerButton.addChild(registerTitle)
        
        
        
        
        
        
    }
    
    
    func setUpTextField(tf: UITextField, placeHolderTxt: String?) {
        if let txt = placeHolderTxt {
            tf.placeholder = txt
        }
        let leftPaddingView = UIView(frame: CGRect(origin: tf.frame.origin, size: CGSize(width: 15, height: tf.frame.size.height)))
        
        tf.backgroundColor = UIColor.white
        tf.layer.borderColor = UIColor.black.cgColor
        tf.layer.borderWidth = 0.5
        tf.layer.cornerRadius = 3.0
        tf.layer.masksToBounds = true
        tf.leftViewMode = .always
        tf.leftView = leftPaddingView
        tf.autocorrectionType = .no
    
        tf.delegate = self
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let loc = touch!.location(in: self)
        
        if nodes(at: loc).contains(registerButton) {
            guard emailField.text != nil else {
                return
            }
            guard nameField.text != nil else {
                return
            }
            guard passwordField.text != nil else {
                return
            }
            
            Fire.dataService.registerUser(email: emailField.text!, password: passwordField.text!, username: nameField.text!)
            
        }
        
        
    
        
        if nodes(at: loc).contains(loginBtn) {
            
            Fire.dataService.loginUser(email: emailField.text!, password: passwordField.text!, opponentUserName: opponentNameField.text!) {
                
                (invite)
                
                in
              
                guard invite != nil else {
                    print("failed to load invite")
                    return
                }
                
                self.invite = invite
                
                
                //self.addInviteBox(invite: invite!)
              
        /*
                if let scene = GameplayScene(fileNamed: GameConstants.GameplaySceneName) {
                    if let view = self.view {
                        self.emailField.removeFromSuperview()
                        self.nameField.removeFromSuperview()
                        self.passwordField.removeFromSuperview()
                        self.opponentNameField.removeFromSuperview()
                        self.loginButton.removeFromSuperview()
                        scene.scaleMode = .aspectFill
                        view.presentScene(scene)
                    }
     
                }
     */
                
                
                
                
            }
        }
        if nodes(at: loc).contains(acceptBox) {
            guard invite != nil else {return}
            FirebaseConstants.CurrentUserPath!.child("challenges_received/\(invite!.inviteID)").removeValue()
            FirebaseConstants.UsersNode.child("\(invite!.senderID)/challenges_sent/\(invite!.inviteID)").removeValue()
            
            
                Fire.dataService.createGame(invite: invite!)
            
            
        }
        if nodes(at: loc).contains(declineBox) {
            guard invite != nil else {return}
            FirebaseConstants.CurrentUserPath!.child("challenges_received/\(invite!.inviteID)").removeValue()
            
            FirebaseConstants.UsersNode.child("\(invite!.senderID)/challenges_sent/\(invite!.inviteID)").updateChildValues([GameConstants.Invite_status: GameConstants.Invite_status_declined])
            
        }
        
        
    }
    
    func addInviteBox(invite: Invite) {
     
    
        let inviteContainer = SKLabelNode(text: "\(invite.senderUserName) has challenged you to a game!")
        inviteContainer.fontName = GameConstants.TileLabelFontName

        acceptBox.fontName = GameConstants.TileLabelFontName

        declineBox.fontName = GameConstants.TileLabelFontName
        
        inviteContainer.position.y = self.nameField.frame.origin.y + 3*self.nameField.frame.height
        
        acceptBox.position.y = inviteContainer.position.y - inviteContainer.frame.size.height/2 - 20
        acceptBox.position.x = inviteContainer.frame.midX - acceptBox.frame.size.width/2 - 2
        declineBox.position.y  = acceptBox.position.y
        declineBox.position.x = acceptBox.position.x + declineBox.frame.size.width + 5
        
        acceptBox.fontColor = .green
        declineBox.fontColor = .red
        self.addChild(inviteContainer)
        self.addChild(acceptBox)
        self.addChild(declineBox)
    }
    func presentGameScene(game: Game) {
        if let scene = GameplayScene(fileNamed: GameConstants.GameplaySceneName) {
            if let view = self.view {
                self.emailField.removeFromSuperview()
                self.nameField.removeFromSuperview()
                self.passwordField.removeFromSuperview()
                self.opponentNameField.removeFromSuperview()
                scene.scaleMode = .aspectFill
                scene.game = game

                view.presentScene(scene)
    
                
            }
            else {
                print("can't let view = self.view in presentGameScene!!!")
            }
        }
        else {
            print("can't let scene = gameplay scene in presentGameScene!!!!")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Error logging in with facebook: \(error.localizedDescription)")
            return
        }
     
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            
            if error != nil {
                print("Error loggin in with FB credentials in Firebase....\(error!.localizedDescription)")
            }
            
        
            guard user != nil else {return}
            
            FirebaseConstants.UsersNode.child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    print("Already exists!!---\(snapshot)")
                    return
                }
                else {
                    print("No user in database yet!!!!!!")
                    
                    FirebaseConstants.UsersNode.child((user?.uid)!).updateChildValues([FirebaseConstants.UserName : user?.displayName ?? "",
                                                                                       FirebaseConstants.UserEmail:  user?.email ?? "",
                                                                                       FirebaseConstants.UserID: user?.uid])
                }
            })
            
         
            
            
            
        }
        
        
        
        
            /*
         FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
                if error != nil {
                    print("error with graph request: \(error!.localizedDescription)")
                    return
                }
               
                print("Graph request result: \(result)")
            } */
    }
    
}
