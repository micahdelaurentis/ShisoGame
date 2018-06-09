//
//  LoginVC.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 2/24/18.
//  Copyright © 2018 Micah DeLaurentis. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FirebaseAuth

class LoginVC: UIViewController,UITextFieldDelegate , FBSDKLoginButtonDelegate  {
 

    var loginBtn: UIButton!
    var registerButton: UIButton!
    var passwordField: UITextField!
    var emailField: UITextField!
    var nameField: UITextField!
    var loginButton = FBSDKLoginButton()
   
    var backBtn: UIButton = {
        let bb = UIButton()
        bb.frame = CGRect(origin: CGPoint(x: 10, y: 50), size: CGSize(width: 70, height: 30))
        bb.backgroundColor = .yellow
        bb.setTitle("🔙", for: .normal)
        
        return bb
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
       print("In loginc VC!!!")
       

        backBtn.addTarget(self, action: #selector(backbtnPushed), for: .touchUpInside)
     
        nameField = UITextField(frame: CGRect(x: view.frame.size.width/4, y: view.frame.size.height/3, width: 200, height: 30))
        
        emailField = UITextField(frame: CGRect(x: nameField.frame.origin.x, y: nameField.frame.origin.y + 35, width: nameField.frame.size.width , height: nameField.frame.size.height))
        
        passwordField = UITextField(frame: CGRect(x: emailField.frame.origin.x, y: emailField.frame.origin.y + 35, width: emailField.frame.size.width, height: emailField.frame.size.height))
        
        
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        
        
        setUpTextField(tf: nameField, placeHolderTxt: "Username")
        setUpTextField(tf: emailField, placeHolderTxt: "Email")
        setUpTextField(tf: passwordField, placeHolderTxt: "Password")
        passwordField.isSecureTextEntry = true
  
        
        loginBtn = UIButton()
        loginBtn.setTitle("Login", for: .normal)
        loginBtn.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 30)
        loginBtn.frame.origin.y = passwordField.frame.maxY + 20
        loginBtn.frame.origin.x = passwordField.frame.origin.x
        loginBtn.frame.size = CGSize(width: passwordField.frame.size.width, height: passwordField.frame.size.height)
        loginBtn.backgroundColor = .blue
        loginBtn.layer.cornerRadius = 4
        loginBtn.layer.masksToBounds = true
        loginBtn.titleLabel?.textColor = .white
        loginBtn.addTarget(self, action: #selector(loginBtnPressed), for: .touchUpInside)
        
        registerButton = UIButton()
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = UIFont(name:"AppleSDGothicNeo-Regular", size: 30)
        registerButton.frame.origin.y = loginBtn.frame.maxY + 10
        registerButton.frame.origin.x = passwordField.frame.origin.x
        registerButton.frame.size = CGSize(width: passwordField.frame.size.width, height: passwordField.frame.size.height)
        registerButton.backgroundColor = .blue
        registerButton.layer.cornerRadius = 4
        registerButton.layer.masksToBounds = true
        registerButton.titleLabel?.textColor = .white
        registerButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        
        view.addSubview(backBtn)
        view.addSubview(loginBtn)
        view.addSubview(registerButton)
        
        
        loginButton = FBSDKLoginButton(frame: CGRect(x: registerButton.frame.origin.x , y: registerButton.frame.maxY + 30,
                                                     width: registerButton.frame.size.width, height: registerButton.frame.size.height))
        loginButton.readPermissions = ["public_profile", "email"]
        loginButton.delegate  = self
        view.addSubview(loginButton)
    }
    
    func backbtnPushed() {
        self.dismiss(animated: true, completion: nil)
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
            
            FirebaseConstants.UsersNode.child((user!.uid)).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    print("Already exists!!---\(snapshot)")
                    return
                }
                else {
                    print("No user in database yet!!!!!!")
                    FirebaseConstants.UsersNode.child((user!.uid)).updateChildValues([FirebaseConstants.UserName : user!.displayName ?? "",
                     FirebaseConstants.UserEmail:  user!.email ?? "",                                                               FirebaseConstants.UserID: user!.uid])
                }
            })
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out")
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
        tf.autocapitalizationType = .none
        
        tf.delegate = self
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    func loginBtnPressed() {
        Fire.dataService.loginUser(email: emailField.text!, password: passwordField.text!, errorHandler: self) {
            FirebaseConstants.CurrentUserID = Auth.auth().currentUser?.uid
            guard let uid = FirebaseConstants.CurrentUserID else {
                print("After loggin in no user ID!")
                return
            }
            FirebaseConstants.CurrentUserPath = FirebaseConstants.UsersNode.child(uid)
          // self.dismiss(animated: true, completion: nil)
            
            
         if let mainVC = UIApplication.shared.keyWindow?.rootViewController {
                self.dismiss(animated: true, completion: nil)
                mainVC.present(GameDisplayTableVC(), animated: true, completion: nil)
                
            }
            else {
                print("can't let main vc present display vc from loginvc")
            }
            /*if self.presentingViewController is GameDisplayTableVC {
                print("presenting is game vc. about to dismiss login vc")
                self.dismiss(animated: true, completion: nil)
            }
            else {
                print("presenting vc is: \(self.presentingViewController)")
                self.present(GameDisplayTableVC(), animated: true, completion: nil)
            }
 */
            
            
        }
    }
    
    func registerButtonPressed() {
        print("In register button pressed function")
        guard emailField.text != nil else {
            return
        }
        guard nameField.text != nil else {
            return
        }
        guard passwordField.text != nil else {
            return
        }
        
        Fire.dataService.registerUser(email: emailField.text!, password: passwordField.text!, username: nameField.text!, errorHandler: self) {
   
            self.present(GameDisplayTableVC(), animated: true, completion: nil)
            print("register success: userID: \(Auth.auth().currentUser?.uid)")
        }
       
    
    }
    
    deinit {
        print("Login VC deinitialized!")
    }
    
    
}
