//
//  Global.swift
//  DogWalk
//
//  Created by Christian Selig on 2021-08-18.
//

import Foundation

/// Delay a block by a precise amount of time. Similar to DispatchQueue.asyncAfter but… precise!
func delay(_ duration: TimeInterval, block: @escaping () -> Void) {
    Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { timer in
        block()
    }
}
