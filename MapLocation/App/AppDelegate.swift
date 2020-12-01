//
//  AppDelegate.swift
//  MapLocation
//
//  Created by Pawan  on 01/12/2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MapLocatoionViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

