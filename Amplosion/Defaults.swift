//
//  Defaults.swift
//  Defaults
//
//  Created by Christian Selig on 2021-09-03.
//

import Foundation

extension UserDefaults {
    static var groupSuite = UserDefaults(suiteName: "group.com.christianselig.apollo")!
    
    // MARK: - Stats
    
    func totalAmplosions() -> Int {
        return amplosionStats().reduce(0, { $0 + $1.totalAmplosions })
    }
    
    func totalAmplosions(forHostname hostname: String) -> Int {
        return amplosionStats().first { $0.hostname == hostname }?.totalAmplosions ?? 0
    }
    
    func totalAmplosionsOnLastAppExit() -> Int {
        return integer(forKey: DefaultsKey.totalAmplosionsOnLastAppExit)
    }
    
    func setTotalAmplosionsOnLastAppExit(_ totalAmplosionsOnLastAppExit: Int) {
        set(totalAmplosionsOnLastAppExit, forKey: DefaultsKey.totalAmplosionsOnLastAppExit)
    }
    
    /// Returns site-specific Amplosion stats, sorted in descending order of sites with most Amplosions
    func amplosionStats() -> [AmplosionStat] {
        let statsDictionary = (dictionary(forKey: DefaultsKey.stats) as? [String: Int]) ?? [:]
        let stats = createAmplosionStats(fromDictionary: statsDictionary)
        return stats.sorted { $0.totalAmplosions > $1.totalAmplosions }
    }
    
    /// If already set, increments the hostname in the stats. If not set, sets it to 1.
    func incrementAmplosionStat(forHostname hostname: String) {
        var statsDictionary = (dictionary(forKey: DefaultsKey.stats) as? [String: Int]) ?? [:]
        
        if let preExistingValue = statsDictionary[hostname] {
            statsDictionary[hostname] = preExistingValue + 1
        } else {
            statsDictionary[hostname] = 1
        }
        
        set(statsDictionary, forKey: DefaultsKey.stats)
    }
    
    func removeAmplosionStat(forHostname hostname: String) {
        var statsDictionary = (dictionary(forKey: DefaultsKey.stats) as? [String: Int]) ?? [:]
        statsDictionary.removeValue(forKey: hostname)
        set(statsDictionary, forKey: DefaultsKey.stats)
    }
    
    func setAmplosionStats(_ stats: [AmplosionStat]) {
        let dictionary = dictionary(fromAmplosionStats: stats)
        set(dictionary, forKey: DefaultsKey.stats)
    }
    
    func clearAllStats() {
        removeObject(forKey: DefaultsKey.stats)
    }
    
    private func createAmplosionStats(fromDictionary dictionary: [String: Int]) -> [AmplosionStat] {
        var stats: [AmplosionStat] = []
        
        for (key, value) in dictionary {
            stats.append(AmplosionStat(hostname: key, totalAmplosions: value))
        }
        
        return stats
    }
    
    private func dictionary(fromAmplosionStats amplosionStats: [AmplosionStat]) -> [String: Int] {
        var dictionary: [String: Int] = [:]
        amplosionStats.forEach { dictionary[$0.hostname] = $0.totalAmplosions }
        return dictionary
    }
    
    // MARK: - Swear Jar Conversion
    
    func swearJarConversionRate() -> Double {
        let tentativeValue = double(forKey: DefaultsKey.swearJarConversionRate)
        
        if tentativeValue == 0.0 {
            // If it's 0, that means it's never been set, so return an approximately/hopefully somewhat accurate value
            return Double(Locale.current.chocolateBarCostForCurrency())
        } else {
            return tentativeValue
        }
    }
    
    func setSwearJarConversionRate(_ conversionRate: Double) {
        set(conversionRate, forKey: DefaultsKey.swearJarConversionRate)
    }
    
    // MARK: - Allowlist
    
    func allowlistItems() -> [String] {
        return stringArray(forKey: DefaultsKey.allowlistItems) ?? []
    }
    
    func addToAllowlist(hostname: String) {
        var allowlistItems = allowlistItems()
        guard !allowlistItems.contains(hostname) else { return }
        allowlistItems.append(hostname)
        set(allowlistItems, forKey: DefaultsKey.allowlistItems)
    }
    
    func removeFromAllowlist(hostname: String) {
        var allowlistItems = allowlistItems()
        guard let index = allowlistItems.firstIndex(of: hostname) else { assertionFailure("Requested to remove item that doesn't exist"); return }
        allowlistItems.remove(at: index)
        set(allowlistItems, forKey: DefaultsKey.allowlistItems)
    }
}

struct AmplosionStat: Codable, Hashable {
    let hostname: String
    let totalAmplosions: Int
}

struct DefaultsKey {
    static let stats = "AmplosionStats"
    static let allowlistItems = "AllowlistItems"
    static let swearJarConversionRate = "SwearJarConversionRate"
    static let totalDigs = "TotalDigs"
    static let unlockedBandanas = "UnlockedBandanas"
    static let selectedBandana = "SelectedBandanaIndex"
    static let totalAmplosionsOnLastAppExit = "TotalAmplosionsOnLastAppExit"
    static let lastReviewRequestDate = "LastReviewRequestDate"
    static let totalLaunches = "TotalLaunches"
}

extension Locale {
    /// Returns a clean, round number for approximately how much a chocolate bar would cost in each currency. e.g.: $ -> 1, ¥ -> 100, ₹ -> 100. This is not exact (and is rounded to the nearest 10^n or 5 x 10^n), and is meant just for fun to display an approximate cost for each violation in the the in-app Swear Jar, so that we're not showing "1¥" as the cost (which would be about a penny). If unable to determine, will return 1. Some of these are probably very off, but better than nothing and it's just for fun.
    func chocolateBarCostForCurrency() -> Int {
        guard let currencySymbol = currencySymbol else { return 1 }
        
        let costs: [String: Int] = [
            "$": 1,
            "¢": 100,
            "¥": 100,
            "£": 1,
            "₣": 5,
            "ƒ": 1,
            "₺": 10,
            "₽": 100,
            "€": 1,
            "₫": 10_000,
            "₹": 100,
            "₸": 500,
            "₧": 100,
            "₱": 10,
            "₭": 10_000,
            "₩": 1_000,
            "₤": 1_000,
            "₳": 100,
            "₴": 10,
            "₦": 100,
            "₲": 5_000,
            "₡": 500,
            "₵": 5,
            "₢": 5,
            "₮": 1_000,
            "₥": 1_000,
            "₪": 1,
            "₼": 1,
            "₨": 100,
            "฿": 10,
            "₾": 1,
            "R$": 5
        ]
        
        return costs[currencySymbol] ?? 1
    }
}
