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
import Firebase

class LoginVC: UIViewController,UITextFieldDelegate , FBSDKLoginButtonDelegate  {
 
    var newUserBtn: UIButton!
    var registerMessageLbl: UILabel!
    var reverseBtn: UIButton!
    var loginBtn: UIButton!
    var registerButton: UIButton!
    var passwordField: UITextField!
    var emailField: UITextField!
    var nameField: UITextField!
    var loginButton = FBSDKLoginButton()
   
  
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    let shisoBackGroundImgView = UIImageView(frame: UIScreen.main.bounds)
        let shisoImg = UIImage(named: "GreenShisoLeavesCartoon")
        shisoBackGroundImgView.image = shisoImg
        shisoBackGroundImgView.contentMode = .scaleAspectFit
        view.addSubview(shisoBackGroundImgView)
        
  
    view.backgroundColor = .white
      
     

        
        nameField = UITextField(frame: CGRect(x: view.frame.size.width/4, y: view.frame.size.height/3, width: 200, height: 30))
        
        emailField = UITextField(frame: CGRect(x: nameField.frame.origin.x, y: nameField.frame.origin.y + 35, width: nameField.frame.size.width , height: nameField.frame.size.height))
        
        passwordField = UITextField(frame: CGRect(x: emailField.frame.origin.x, y: emailField.frame.origin.y + 35, width: emailField.frame.size.width, height: emailField.frame.size.height))
        
        
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        
        nameField.isHidden = true
        
        newUserBtn = UIButton()
        newUserBtn.setTitle("New User? Click here", for: .normal)
        newUserBtn.backgroundColor = .white
        newUserBtn.setTitleColor(.black, for: .normal)
        newUserBtn.layer.cornerRadius = 4
        newUserBtn.layer.masksToBounds = true
         newUserBtn.frame.size = CGSize(width: nameField.frame.size.width, height: nameField.frame.size.height)
        newUserBtn.frame.origin.x = nameField.frame.origin.x
        newUserBtn.frame.origin.y = 50
        newUserBtn.addTarget(self, action: #selector(newUserBtnTapped), for: .touchUpInside)
        view.addSubview(newUserBtn)
        
        registerMessageLbl = UILabel()
        view.addSubview(registerMessageLbl)
        registerMessageLbl.text = "Register below!"
        registerMessageLbl.translatesAutoresizingMaskIntoConstraints = false 
        registerMessageLbl.centerXAnchor.constraint(equalTo: newUserBtn.centerXAnchor).isActive = true
        registerMessageLbl.topAnchor.constraint(equalTo: newUserBtn.bottomAnchor).isActive = true
        registerMessageLbl.widthAnchor.constraint(equalToConstant: view.frame.size.width/3).isActive = true 
        registerMessageLbl.heightAnchor.constraint(equalTo: newUserBtn.heightAnchor).isActive = true
        registerMessageLbl.isHidden = true
     
        
        
        reverseBtn = UIButton()
        reverseBtn.setImage(UIImage(named: "goBackIconBlue"), for: .normal)
        reverseBtn.frame = CGRect(x: newUserBtn.frame.origin.x - reverseBtn.frame.size.width - 30, y: newUserBtn.frame.origin.y, width: newUserBtn.frame.size.height, height: newUserBtn.frame.size.height)
        reverseBtn.addTarget(self, action: #selector(reverseBtnTapped), for: .touchUpInside)
        view.addSubview(reverseBtn)
        reverseBtn.isHidden = true
        
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
        registerButton.frame.origin = loginBtn.frame.origin
        registerButton.frame.size = CGSize(width: passwordField.frame.size.width, height: passwordField.frame.size.height)
        registerButton.backgroundColor = .blue
        registerButton.layer.cornerRadius = 4
        registerButton.layer.masksToBounds = true
        registerButton.titleLabel?.textColor = .white
        registerButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        registerButton.isHidden = true

        view.addSubview(loginBtn)
        view.addSubview(registerButton)
        
        
        loginButton = FBSDKLoginButton(frame: CGRect(x: registerButton.frame.origin.x , y: registerButton.frame.maxY + 30,
                                                     width: registerButton.frame.size.width, height: registerButton.frame.size.height))
        loginButton.readPermissions = ["public_profile", "email"]
        loginButton.delegate  = self
        view.addSubview(loginButton)
    }
    
    func newUserBtnTapped() {
        loginBtn.isHidden = true
        registerButton.isHidden = false
        nameField.isHidden = false
        reverseBtn.isHidden = false
        registerMessageLbl.isHidden = false
    }
    
    func reverseBtnTapped() {
        loginBtn.isHidden = false
        registerButton.isHidden = true
        nameField.isHidden = true
        registerButton.isHidden = true
        reverseBtn.isHidden = true
        registerMessageLbl.isHidden = true
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
           
            guard let uid = Auth.auth().currentUser?.uid else {
                print("in register function: After logging in no user ID!")
                return
            }
             FirebaseConstants.CurrentUserID = uid
          FirebaseConstants.CurrentUserPath = FirebaseConstants.UsersNode.child(uid) 
          // self.dismiss(animated: true, completion: nil)
            
            Fire.dataService.checkIfAnyGames(){
                (anyGames)
                in
                print("any games? \(anyGames)")
                if anyGames {
                    if let gameVC = self.presentingViewController as? GameViewController {
                        self.dismiss(animated: true, completion: nil)
                            gameVC.presentDisplayVC()
                        
                    }
                    else {
                        print(" in login VC: can't get presenting vc be game VC!")
                    }
                }
                else {
                    if let gameVC = self.presentingViewController as? GameViewController {
                        self.dismiss(animated: true, completion: nil)
                        gameVC.presentStartNewGameVC()
                        
                    }
                    else {
                        print(" in login VC: can't get presenting vc be game VC!")
                    }
                }
            }
   
            
            
            /*
            
            if let gameVC = self.presentingViewController as? GameViewController {
                self.dismiss(animated: true, completion: nil)
                gameVC.presentDisplayVC()
                
            }
          
        
            else {
                print("can't let game vc present display vc from loginvc")
            }*/
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
            
            guard let uid = Auth.auth().currentUser?.uid else {
                print("After loggin in no user ID!")
                return
            }
            print("User ID after registering:  \(uid)")
            FirebaseConstants.CurrentUserPath = FirebaseConstants.UsersNode.child(uid)
            FirebaseConstants.CurrentUserID = Auth.auth().currentUser?.uid
            let blackView = UIView(frame: self.view.frame)
            blackView.backgroundColor = .black
            self.view.addSubview(blackView)
        
            self.present(StartNewGameVC(), animated: true, completion: nil)
         
        }
      
    }
    
    deinit {
        print("Login VC deinitialized!")
    }
    
    
}
