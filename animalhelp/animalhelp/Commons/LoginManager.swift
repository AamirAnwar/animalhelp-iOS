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

struct User {
    var name:String
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
                                self.currentUser = User(name: fullName)
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
            self.currentUser = User(name: user.profile.name)
            // Perform any operations on signed in user here.
            //            let userId = user.userID                  // For client-side use only!
            //            let idToken = user.authentication.idToken // Safe to send to the server
            //            let fullName = user.profile.name
            //            let givenName = user.profile.givenName
            //            let familyName = user.profile.familyName
            //            let email = user.profile.email
            // ...
        } else {
            print("\(error.localizedDescription)")
        }
        
    }
}
