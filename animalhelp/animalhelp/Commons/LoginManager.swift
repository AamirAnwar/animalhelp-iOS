//
//  LoginManager.swift
//  animalhelp
//
//  Created by Aamir  on 16/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import FacebookLogin
import FacebookCore
import GoogleSignIn

class User:NSObject {
    var name:String!
    var profilePictureURL:URL?
    
    override init() {
        super.init()
    }
    
    static func initWith(name:String) -> User {
        let user = User.init()
        user.name = name
        return user
    
    }
}

protocol LoginManagerDelegate {
    func didUpdateUserInfo()
}

class LoginManager:NSObject {
    
    static let sharedInstance = LoginManager()
    let facebookLoginManager = FacebookLogin.LoginManager.init()
    var uiDelegate:GIDSignInUIDelegate? = nil
    var delegate:LoginManagerDelegate? = nil
    var currentUser:User? = nil {
        didSet {
            UserDefaults.standard.setValue(self.currentUser?.name, forKey: kUserProfileNameKey)
            UserDefaults.standard.setValue(self.currentUser?.profilePictureURL?.absoluteString, forKey: kUserProfileImageURLKey)
            self.delegate?.didUpdateUserInfo()
        }
    }
    var isLoggedIn:Bool {
        get {
            // If we have either fb and google access tokens, then the user is logged in
            return (FacebookCore.AccessToken.current != nil || GIDSignIn.sharedInstance().currentUser != nil )
        }
    }
    
    func initializeGoogleLogin() {
        GIDSignIn.sharedInstance().clientID = kClientID
        GIDSignIn.sharedInstance().delegate = self
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }
    
    func initializeFacebookLogin(application:UIApplication, launchOptions:[UIApplicationLaunchOptionsKey: Any]?) {
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func loginWithFacebook() {
        facebookLoginManager.logIn(readPermissions: [.publicProfile], viewController: nil) { (result) in
            switch result {
            case .cancelled: self.postLoginNotification(success: false)
            case .failed(let error): print(error.localizedDescription);self.postLoginNotification(success: false)
            case .success(let grantedPermissions, let declinedPermissions, let token):
                print("Logged in through facebook with GP:\(grantedPermissions) DP:\(declinedPermissions) Token:\(token)")
                self.postLoginNotification(success: true)
                
                if let userID = token.userId {
                    FacebookCore.UserProfile.fetch(userId: userID, completion: { (result) in
                        switch result {
                        case .success(let profile):
                            print("Found a profile \(profile)")
                            if let fullName = profile.fullName {
                                let user = User.initWith(name: fullName)
                                self.currentUser = user
                                
                                
                                let req = GraphRequest.init(graphPath: "\(userID)/picture", parameters: ["height":kProfileImageHeight*UIScreen.main.scale, "width":UIScreen.main.bounds.size.width * UIScreen.main.scale], accessToken: token, httpMethod: .GET, apiVersion: GraphAPIVersion.defaultVersion)
                                req.start({ (response, result) in
                                    
                                    if let response = response, let url = response.url {
                                        self.currentUser?.profilePictureURL = url
                                        UserDefaults.standard.setValue(self.currentUser?.profilePictureURL?.absoluteString, forKey:kUserProfileImageURLKey)
                                        self.delegate?.didUpdateUserInfo()
                                    }
                                    
                                })


                            }
                        default: print("Dont care")
                        }
                    })
                }
            }
        }
    }
    
    func loginWithGoogle() {
        guard let uiDelegate = uiDelegate else {
            self.postLoginNotification(success: false)
            return
        }
        GIDSignIn.sharedInstance().uiDelegate = uiDelegate
        GIDSignIn.sharedInstance().signIn()
    }
    
    func logout() {
        if let _ = FacebookCore.AccessToken.current {
            self.facebookLoginManager.logOut()
        }
        else if GIDSignIn.sharedInstance().currentUser != nil {
            GIDSignIn.sharedInstance().signOut()
        }
        self.currentUser = nil
        self.postLogoutNotification(success: true)
    }
    
    func postLoginNotification(success:Bool) {
        if success {
            // Logged in successfully
            NotificationCenter.default.post(kNotificationLoggedInSuccessfully)
        }
        else {
            // Login failed
            NotificationCenter.default.post(kNotificationLoginFailed)
        }
    }
    
    func postLogoutNotification(success:Bool) {
        if success {
            // Logged out successfully
            NotificationCenter.default.post(kNotificationLoggedOutSuccessfully)
            
        }
        else {
            // Logout failed
            NotificationCenter.default.post(kNotificationLogOutFailed)
        }
    }
    
}

extension LoginManager:GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        self.postLoginNotification(success: error == nil)
        if (error == nil) {
            print("Login Sucessful!")
            let updatedUser = User.initWith(name: user.profile.name)
            if user.profile.hasImage {
                let dimension = round(kProfileImageHeight * UIScreen.main.scale);
                updatedUser.profilePictureURL = user.profile.imageURL(withDimension: UInt(dimension))
            }
            self.currentUser = updatedUser
        } else {
            print("\(error.localizedDescription)")
        }
        
    }
}
