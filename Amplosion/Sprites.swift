//
//  Sprites.swift
//  DogWalk
//
//  Created by Christian Selig on 2021-08-24.
//

import UIKit

struct MiscSprite {
    static var dirtLeaf = UIImage(named: "dirt-leaf")!
    static var dirtCarrot = UIImage(named: "dirt-leaf")!
    static var bone = UIImage(named: "bone")!
    
    /// 🧇
    static func chatBox(frame: Int, isJapanese: Bool) -> UIImage {
        let suffix = isJapanese ? "-jp" : ""
        return UIImage(named: "lord-waffles-\(frame)\(suffix)")!
    }
}

