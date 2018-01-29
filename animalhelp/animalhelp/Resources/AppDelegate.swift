//
//  AppDelegate.swift
//  animalhelp
//
//  Created by Aamir  on 15/11/17.
//  Copyright © 2017 AamirAnwar. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleSignIn
import FacebookCore
var kClientID:String!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Private Setup for enivironment variables
        PrivateSetup.setup()
        
        // Initialize google maps SDK
        GMSServices.provideAPIKey(GoogleMapsAPIKey!)
        
        // Create window and primary view controller
        setupWindow()
        
        // Initialize login methods
        LoginManager.sharedInstance.initializeGoogleLogin()
        LoginManager.sharedInstance.initializeFacebookLogin(application: application, launchOptions: launchOptions)
        return true
    }

    func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = UIColor.white
        let tabBarController = UITabBarController()
        
        // Home Page
        let homeVC = HomeViewController()
        homeVC.viewModel = HomeViewModel()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem.title = "Clinics"
        
        // Account Page
        let accountVC = AccountViewController()
        let accountNav = UINavigationController(rootViewController: accountVC)
        accountNav.tabBarItem.title = "Account"
        
        // Pet Search Page
        let petSearchVC = PetSearchViewController()
        petSearchVC.viewModel = PetSearchViewModel()
        let petNav = UINavigationController(rootViewController: petSearchVC)
        petNav.tabBarItem.title = "Pet Search"
        
        tabBarController.viewControllers = [homeNav, petNav, accountNav]
        window?.rootViewController = tabBarController
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let didHandleGoogleURL =  GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        let didHandleFBURL = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        return didHandleFBURL || didHandleGoogleURL
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

