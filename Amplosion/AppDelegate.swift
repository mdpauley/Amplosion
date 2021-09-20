//
//  AppDelegate.swift
//  Amplosion
//
//  Created by Christian Selig on 2021-08-10.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont.rounded(ofSize: 34.0, weight: .bold)]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont.preferredFont(forTextStyle: .body).rounded(withWeight: .semibold)]
        
        var totalLaunches = UserDefaults.standard.integer(forKey: DefaultsKey.totalLaunches)
        totalLaunches += 1
        UserDefaults.standard.set(totalLaunches, forKey: DefaultsKey.totalLaunches)
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.groupSuite.setTotalAmplosionsOnLastAppExit(UserDefaults.groupSuite.totalAmplosions())
    }
}
