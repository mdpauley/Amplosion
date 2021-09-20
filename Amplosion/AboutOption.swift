//
//  AboutOption.swift
//  AboutOption
//
//  Created by Christian Selig on 2021-09-10.
//

import UIKit

enum AboutOption {
    case twitter
    case subreddit
    case contact
    case openSource
    case privacyPolicy
    case shortStory
    case apollo
    case achoo
    
    var icon: UIImage {
        let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline))
        
        switch self {
        case .twitter:
            return UIImage(named: "twitter.fill", in: nil, with: config)!
        case .subreddit:
            return UIImage(named: "reddit.fill", in: nil, with: config)!
        case .contact:
            return UIImage(systemName: "envelope.fill", withConfiguration: config)!
        case .openSource:
            return UIImage(systemName: "chevron.left.forwardslash.chevron.right", withConfiguration: config)!
        case .privacyPolicy:
            return UIImage(systemName: "hand.raised.fill", withConfiguration: config)!
        case .shortStory:
            return UIImage(systemName: "book.fill", withConfiguration: config)!
        case .apollo:
            return UIImage(named: "thumb-apollo", in: nil, with: config)!
        case .achoo:
            return UIImage(named: "thumb-achoo", in: nil, with: config)!
        }
    }
    
    var title: String {
        switch self {
        case .twitter:
            return "Twitter"
        case .subreddit:
            return "Subreddit"
        case .contact:
            return "Contact"
        case .openSource:
            return "Source Code"
        case .privacyPolicy:
            return "Privacy Policy"
        case .shortStory:
            return "Short Story"
        case .apollo:
            return "Apollo for Reddit"
        case .achoo:
            return "Achoo"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .twitter, .subreddit, .contact, .openSource, .privacyPolicy, .shortStory:
            return nil
        case .apollo:
            return "Made by your friend at Apollo 🙂"
        case .achoo:
            return "I also make a Safari HTML viewer/editor!"
        }
    }
}
