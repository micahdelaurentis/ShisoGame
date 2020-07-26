    //
//  LoginScene.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 9/1/17.
//  Copyright © 2017 Micah DeLaurentis. All rights reserved.
//

import Foundation
import SpriteKit
import FirebaseAuth
import Firebase
import FBSDKLoginKit
    



    class LoginScene: SKScene, UITextFieldDelegate , LoginButtonDelegate {
    
    var ref: DatabaseReference!
    var invite: Invite?
    var loginBtn = SKShapeNode()
    var loginTitle =  SKLabelNode()
    var registerButton = SKShapeNode()
    var registerTitle = SKLabelNode()
    var passwordField =  UITextField()
    var emailField = UITextField()
    var nameField  = UITextField()
    
        var loginButton = FBLoginButton()
     var mainVC: UIViewController?
    
    
    override func didMove(to view: SKView) {
        
        
        
        ref = Database.database().reference()
        
        
        nameField = UITextField(frame: CGRect(x: view.frame.size.width/4, y: view.frame.size.height/3, width: 200, height: 30))
        
        emailField = UITextField(frame: CGRect(x: nameField.frame.origin.x, y: nameField.frame.origin.y + 35, width: nameField.frame.size.width , height: nameField.frame.size.height))
        
        passwordField = UITextField(frame: CGRect(x: emailField.frame.origin.x, y: emailField.frame.origin.y + 35, width: emailField.frame.size.width, height: emailField.frame.size.height))
        
     
        loginButton = FBLoginButton(frame: CGRect(x: passwordField.frame.origin.x , y: passwordField.frame.origin.y + 35,
                                                   width: passwordField.frame.size.width, height: passwordField.frame.size.height))
     
     loginButton.permissions = ["public_profile", "email"]
     loginButton.delegate  = self
    
        
 
          
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        
        
        setUpTextField(tf: nameField, placeHolderTxt: "Username")
        setUpTextField(tf: emailField, placeHolderTxt: "Email")
        setUpTextField(tf: passwordField, placeHolderTxt: "Password")
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
            
           // Fire.dataService.registerUser(email: emailField.text!, password: passwordField.text!, username: nameField.text!, errorHandler: UIViewController())
            
        }
        
        
    
        
        if nodes(at: loc).contains(loginBtn) {
            
            Fire.dataService.loginUser(email: emailField.text!, password: passwordField.text!, errorHandler: nil) {
                print("BEFORE: FirebaseConstants.currentUserID: \(FirebaseConstants.CurrentUserID) FirebaseConstants.CurrentUserPath: \(FirebaseConstants.CurrentUserPath). Actual userID: \(Auth.auth().currentUser?.uid)")
              
                /*
               FirebaseConstants.CurrentUserID = Auth.auth().currentUser?.uid
                guard let uid = FirebaseConstants.CurrentUserID else {
                    print("After loggin in no user ID!")
                    return
                }
                FirebaseConstants.CurrentUserPath = FirebaseConstants.UsersNode.child(uid)
                */
                
           
            
        
            }
        }
        
        
        
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
  
    
        func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {
        print("Did log out")
        
        
    }
    
        func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Error logging in with facebook: \(error.localizedDescription)")
            return
        }
     
            let accessToken = AccessToken.current
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            
            if error != nil {
                print("Error loggin in with FB credentials in Firebase....\(error!.localizedDescription)")
            }
            
        
            guard user != nil else {return}
            
            FirebaseConstants.UsersNode.child((user?.user.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    print("Already exists!!---\(snapshot)")
                    return
                }
                else {
                    print("No user in database yet!!!!!!")
                    
                    FirebaseConstants.UsersNode.child((user?.user.uid)!).updateChildValues([FirebaseConstants.UserName : user?.user.displayName ?? "",
                                                                                            FirebaseConstants.UserEmail:  user?.user.email ?? "",
                                                                                            FirebaseConstants.UserID: user?.user.uid])
                }
            })
   
        }
    }
    
}

