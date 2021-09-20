//
//  Bandana.swift
//  DogWalk
//
//  Created by Christian Selig on 2021-08-23.
//

import UIKit

enum Bandana: String, CaseIterable {
    case red, orange, yellow, green, blue, purple, black, white
        
    var index: Int {
        switch self {
        case .red:
            return 0
        case .orange:
            return 1
        case .yellow:
            return 2
        case .green:
            return 3
        case .blue:
            return 4
        case .purple:
            return 5
        case .black:
            return 6
        case .white:
            return 7
        }
    }
    
    static let bandanaSpriteSize = CGSize(width: 26.0, height: 32.0)
    
    static var ordered: [Bandana] {
        let allBandanas = Bandana.allCases
        return allBandanas.sorted { $0.index < $1.index }
    }
    
    static var unlockedBandanas: [Bandana] {
        // Raw bandanas, not raw 🍌
        guard let rawBandanas = UserDefaults.standard.stringArray(forKey: DefaultsKey.unlockedBandanas) else { return [] }
        
        let unlockedBandanas = rawBandanas.map { Bandana(rawValue: $0)! }
        return unlockedBandanas
    }
    
    static var lockedBandanas: [Bandana] {
        let unlockedBandanasSet = Set(Bandana.unlockedBandanas)
        let allBandanasSet = Set(Bandana.ordered)
        
        let lockedBandanasSet = allBandanasSet.subtracting(unlockedBandanasSet)
        
        // Keep it ordered, because we might expect it to be
        let lockedBandanas = Array(lockedBandanasSet).sorted { $0.index < $1.index }
        
        return lockedBandanas
    }
    
    static func unlock(_ bandana: Bandana) {
        let newUnlockedBandanas = Bandana.unlockedBandanas + [bandana]
        let rawBandanas = newUnlockedBandanas.map { $0.rawValue }
        UserDefaults.standard.set(rawBandanas, forKey: DefaultsKey.unlockedBandanas)
        
        NotificationCenter.default.post(name: .unlockedBandana, object: nil, userInfo: ["bandana": bandana.rawValue])
    }
    
    static var selectedBandana: Bandana? {
        guard let selectedRawBandana = UserDefaults.standard.string(forKey: DefaultsKey.selectedBandana) else { return nil }
        return Bandana(rawValue: selectedRawBandana)
    }
    
    static func setSelectedBandana(to selectedBandana: Bandana?) {
        let rawBandana = selectedBandana?.rawValue
        UserDefaults.standard.set(rawBandana, forKey: DefaultsKey.selectedBandana)
    }
    
    static func sprite(forBandana bandana: Bandana) -> UIImage {
        return UIImage(named: "bandana-\(bandana.rawValue)")!
    }
}

extension Notification.Name {
    static let unlockedBandana = Notification.Name("com.christianselig.UnlockedBandana")
}
