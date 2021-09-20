//
//  SceneDelegate.swift
//  Amplosion
//
//  Created by Christian Selig on 2021-08-10.
//

import UIKit
import StoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    /// Whether the stat at the top of the main view controller needs to animate the difference in Amplosions between the last close and now. Set to false when it's been handled. Note that on the first launch it'll be handled automatically by the cell internally, so no need to set it the first time.
    var needsToShowUpdatedAmplosionCount = false {
        didSet {
            // Sniffy sniff. Check this variable is set if the stats cell is currently visible and if we can update it. If not, it'll automatically update itself internally when it becomes visible.
            guard let amplosionStatsTableViewCell = ((self.window?.rootViewController as? UINavigationController)?.visibleViewController as? MainViewController)?.tableView.visibleCells.compactMap({ $0 as? AmplosionStatsTableViewCell }).first else { return }
            amplosionStatsTableViewCell.animateTotalAmplosionsCountChangeIfNecessary()
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController(rootViewController: MainViewController())
        window.rootViewController = navigationController
        
        window.makeKeyAndVisible()
        
        self.window = window
        
        let isFirstLaunch = UserDefaults.standard.integer(forKey: DefaultsKey.totalLaunches) == 1
        
        if isFirstLaunch {
            // Wait half a second then present the How to Enable screen on first launch
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                let howToEnableNavigationController = UINavigationController(rootViewController: HowToEnableViewController())
                howToEnableNavigationController.setToNonFullWidthInLandscape()
                navigationController.present(howToEnableNavigationController, animated: true, completion: nil)
            }
        }
        
        maybeRequestReview()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // set on appdelegate
        needsToShowUpdatedAmplosionCount = true
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        UserDefaults.groupSuite.setTotalAmplosionsOnLastAppExit(UserDefaults.groupSuite.totalAmplosions())
    }
    
    // MARK: - Review Requests
    
    func maybeRequestReview() {
        guard hasTwoWeeksPassed() else { return }
        
        let sufficientAmplosions = UserDefaults.groupSuite.totalAmplosions() >= 2
        let sufficientBandanas = Bandana.unlockedBandanas.count >= 2
        
        if sufficientAmplosions || sufficientBandanas {
            requestReview()
        }
    }
    
    private func requestReview() {
        // Delay a little bit so as to not annoy them as soon as the app launches
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            guard let windowScene = self.window?.windowScene else { return }
            
            UserDefaults.standard.set(Date(), forKey: DefaultsKey.lastReviewRequestDate)
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func hasTwoWeeksPassed() -> Bool {
        if let lastRequestedDate = UserDefaults.standard.object(forKey: DefaultsKey.lastReviewRequestDate) as? Date {
            let now = Date()
            let timeSince = now.timeIntervalSince(lastRequestedDate)
            let twoWeeksInSeconds = TimeInterval(1_210_000)
            return timeSince >= twoWeeksInSeconds
        } else {
            return true
        }
    }
}
