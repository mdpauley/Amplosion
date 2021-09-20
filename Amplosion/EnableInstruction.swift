//
//  EnableInstruction.swift
//  EnableInstruction
//
//  Created by Christian Selig on 2021-09-09.
//

import UIKit

enum EnableInstruction: CaseIterable {
    case settings
    case safari
    case extensions
    case amplosion
    case turnOn
    case allWebsites
    
    var icon: UIImage {
        // Extensions icon is a wee bit big
        let fontIncreaser = self == .extensions ? 0.0 : 2.0
        
        let font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize + fontIncreaser, weight: .medium)
        let config = UIImage.SymbolConfiguration(font: font)
        
        switch self {
        case .settings:
            return UIImage(systemName: "gear", withConfiguration: config)!
        case .safari:
            return UIImage(systemName: "safari", withConfiguration: config)!
        case .extensions:
            return UIImage(systemName: "puzzlepiece.extension", withConfiguration: config)!
        case .amplosion:
            return UIImage(systemName: "bolt.fill", withConfiguration: config)!
        case .turnOn:
            return UIImage(systemName: "switch.2", withConfiguration: config)!
        case .allWebsites:
            return UIImage(systemName: "checkmark", withConfiguration: config)!
        }
    }
    
    var iconColor: UIColor {
        switch self {
        case .settings:
            return .systemGray
        case .safari:
            return .systemBlue
        case .extensions:
            return .systemPurple
        case .amplosion:
            return .systemOrange
        case .turnOn:
            return .systemGreen
        case .allWebsites:
            return .systemBlue
        }
    }
    
    /// Retusn a size that bounds all the icons
    static func largestIconSize() -> CGSize {
        let width = EnableInstruction.allCases.map { $0.icon.size }.sorted { $0.width > $1.width }.first!.width
        let height = EnableInstruction.allCases.map { $0.icon.size }.sorted { $0.height > $1.height }.first!.height
        return CGSize(width: width, height: height)
    }
    
    var attributedText: NSAttributedString {
        switch self {
        case .settings:
            return createAttributedString(fromString: "Open the Settings app", keyword: "Settings")
        case .safari:
            return createAttributedString(fromString: "Select Safari", keyword: "Safari")
        case .extensions:
            return createAttributedString(fromString: "Select Extensions", keyword: "Extensions")
        case .amplosion:
            return createAttributedString(fromString: "Select Amplosion", keyword: "Amplosion")
        case .turnOn:
            return createAttributedString(fromString: "Turn Amplosion On", keyword: "On")
        case .allWebsites:
            return createAttributedString(fromString: "Turn on “All Websites”", keyword: "All Websites")
        }
    }
    
    private func createAttributedString(fromString string: String, keyword: String) -> NSAttributedString {
        var attributedString = AttributedString(string)
        attributedString.font = UIFont.preferredFont(forTextStyle: .body).rounded()
        let range = attributedString.range(of: keyword)!
        attributedString[range].font = .preferredFont(forTextStyle: .body).rounded(withWeight: .medium)
        return NSAttributedString(attributedString)
    }
    
    var hasMoreInfo: Bool {
        switch self {
        case .settings, .safari, .extensions, .amplosion, .turnOn:
            return false
        case .allWebsites:
            return true
        }
    }
}
