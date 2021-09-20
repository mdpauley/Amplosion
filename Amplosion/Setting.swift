//
//  Setting.swift
//  Setting
//
//  Created by Christian Selig on 2021-08-30.
//

import UIKit

enum Setting: Hashable {
    case amplosionStats
    case howToEnable
    case appIcon
    case allowlist
    case about
    case dog
    
    var icon: UIImage? {
        switch self {
        case .amplosionStats:
            return nil
        case .howToEnable:
            return UIImage(named: "settings-how-to-enable")!
        case .appIcon:
            return UIImage(named: "settings-app-icon")!
        case .allowlist:
            return UIImage(named: "settings-allowlist")!
        case .about:
            return UIImage(named: "settings-about")!
        case .dog:
            return UIImage(named: "settings-dog")!
        }
    }
    
    var title: String {
        switch self {
        case .amplosionStats:
            return "Amplosion Stats"
        case .howToEnable:
            return "How to Enable"
        case .appIcon:
            return "App Icon"
        case .allowlist:
            return "Allowlist"
        case .about:
            return "About"
        case .dog:
            return ["Doggy", "Lord Waffles", "Dog", "good boy", "ロドワッフル"].randomElement()!
        }
    }
}
