//
//  SafariWebExtensionHandler.swift
//  Amplosion Extension
//
//  Created by Christian Selig on 2021-08-10.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey]

        let messageDictionary = message as? [String: String]
        let extensionMessage = messageDictionary?["message"]
        
        if extensionMessage == "incrementHostname" {
            if let itemToIncrement = messageDictionary?["item"] {
                UserDefaults.groupSuite.incrementAmplosionStat(forHostname: itemToIncrement)
                context.completeRequest(returningItems: nil, completionHandler: nil)
            } else {
            }
        } else if extensionMessage == "getAllowlist" {
            let response = NSExtensionItem()
            let allowlistItems = UserDefaults.groupSuite.allowlistItems()
            response.userInfo = [ SFExtensionMessageKey: allowlistItems ]
            context.completeRequest(returningItems: [response], completionHandler: nil)
        } else if extensionMessage == "addToAllowlist" {
            if let itemToAdd = messageDictionary?["item"] {
                var allowlistItems = UserDefaults.groupSuite.allowlistItems()
                allowlistItems.append(itemToAdd)
                UserDefaults.groupSuite.set(allowlistItems, forKey: DefaultsKey.allowlistItems)
            
                let response = NSExtensionItem()
                response.userInfo = [ SFExtensionMessageKey: "added \(itemToAdd) to userdefs" ]
                context.completeRequest(returningItems: [response], completionHandler: nil)
            } else {
                os_log(.default, "No item specified when adding to allowlist")
                
                let response = NSExtensionItem()
                response.userInfo = [ SFExtensionMessageKey: "no item specified" ]
                context.completeRequest(returningItems: [response], completionHandler: nil)
            }
        } else if extensionMessage == "bgFetchWebsiteInfo" {
            if let hostname = messageDictionary?["item"] {
                let amplosions = UserDefaults.groupSuite.totalAmplosions(forHostname: hostname)
                let response = NSExtensionItem()
                
                let isOnAllowlist = UserDefaults.groupSuite.allowlistItems().contains(hostname)
                
                response.userInfo = [ SFExtensionMessageKey: [ "amplosions": amplosions, "hostname": hostname, "isOnAllowlist": isOnAllowlist ]]
                context.completeRequest(returningItems: [response], completionHandler: nil)
            }
        } else if extensionMessage == "addToAllowlist" {
            if let hostname = messageDictionary?["item"] {
                UserDefaults.groupSuite.addToAllowlist(hostname: hostname)
                context.completeRequest(returningItems: nil, completionHandler: nil)
            }
        } else if extensionMessage == "removeFromAllowlist" {
            if let hostname = messageDictionary?["item"] {
                UserDefaults.groupSuite.removeFromAllowlist(hostname: hostname)
                context.completeRequest(returningItems: nil, completionHandler: nil)
            }
        } else {
            assertionFailure("Unknown message, someone is being a sussy baka. https://www.youtube.com/watch?v=6cmzCU5Z3Os")
            context.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
}
