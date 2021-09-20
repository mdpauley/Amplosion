//
//  Dog.swift
//  DogWalk
//
//  Created by Christian Selig on 2021-08-24.
//

import UIKit

enum DogState: Equatable {
    case walkingSide(isFacingLeft: Bool, frame: Int)
    case walkingUp(frame: Int)
    case walkingDown(frame: Int)
    case sittingFront(frame: Int)
    case sittingSide(isFacingLeft: Bool, frame: Int)
    case happy(frame: Int)
    case sleeping(frame: Int)
    case digging(isFacingLeft: Bool, frame: Int)
    case bark
    case bendDown
    
    var isFacingLeft: Bool {
        switch self {
        case .walkingSide(let isFacingLeft, _):
            return isFacingLeft
        case .walkingUp(_):
            return false
        case .walkingDown(_):
            return false
        case .sittingFront(_):
            return false
        case .sittingSide(let isFacingLeft, _):
            return isFacingLeft
        case .happy(_):
            return false
        case .sleeping(_):
            return false
        case .digging(let isFacingLeft, _):
            return isFacingLeft
        case .bark:
            return false
        case .bendDown:
            return false
        }
    }
    
    var label: String {
        switch self {
        case .walkingSide:
            return "Walking to the side."
        case .walkingUp:
            return "Walking upward."
        case .walkingDown:
            return "Walking downward."
        case .sittingFront:
            return "Sitting, front-facing."
        case .sittingSide:
            return "Sitting, side-facing."
        case .happy:
            return "Happy, tongue panting."
        case .sleeping:
            return "Sleeping."
        case .digging:
            return "Digging."
        case .bark:
            return "Barking."
        case .bendDown:
            return "Bending down to sniff or dig."
        }
    }
}

class Dog: UIImageView {
    // Creating a variable called just `state` on a large Apple subclass seems unwise, so `dogState` it is!
    var dogState: DogState {
        didSet {
            setImage()
            updateAccessibilityLabel()
        }
    }
    
    init(dogState: DogState) {
        self.dogState = dogState
        
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: DogProperties.spriteSize, height: DogProperties.spriteSize)))
        
        contentMode = .scaleAspectFit
        layer.minificationFilter = .nearest
        layer.magnificationFilter = .nearest
        
        isAccessibilityElement = true
        accessibilityLabel = "Lord Waffles the Dog."
        accessibilityTraits = [.updatesFrequently, .button]
        accessibilityHint = "Tell dog to speak."
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    func updateForBandanaChange() {
        setImage()
    }
    
    private func setImage() {
        switch dogState {
        case .walkingSide(let isFacingLeft, let frame):
            let baseImage = UIImage(named: "walk-right-\(frame)\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!
            self.image = isFacingLeft ? baseImage.withHorizontallyFlippedOrientation() : baseImage
        case .walkingUp(let frame):
            if frame == 3 {
                self.image = UIImage(named: "walk-up-1\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!.withHorizontallyFlippedOrientation()
            } else {
                self.image = UIImage(named: "walk-up-\(frame)\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!
            }
        case .walkingDown(let frame):
            if frame == 3 {
                self.image = UIImage(named: "walk-down-1\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!.withHorizontallyFlippedOrientation()
            } else {
                self.image = UIImage(named: "walk-down-\(frame)\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!
            }
        case .sittingFront(let frame):
            self.image = UIImage(named: "sit-front-\(frame)\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!
        case .sittingSide(let isFacingLeft, let frame):
            let baseImage = UIImage(named: "sit-right-\(frame)\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!
            self.image = isFacingLeft ? baseImage.withHorizontallyFlippedOrientation() : baseImage
        case .happy(let frame):
            self.image = UIImage(named: "happy-\(frame)\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!
        case .sleeping(let frame):
            self.image = UIImage(named: "sleep-\(frame)\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!
        case .digging(let isFacingLeft, let frame):
            let baseImage = UIImage(named: "dig-right-\(frame)")!
            self.image = isFacingLeft ? baseImage.withHorizontallyFlippedOrientation() : baseImage
        case .bark:
            self.image = UIImage(named: "bark\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!
        case .bendDown:
            self.image = UIImage(named: "bend-down")!
        }
    }
    
    private func bandanaSuffix(forBandana bandana: Bandana?) -> String {
        guard let bandana = bandana else { return "" }
        return "-\(bandana.rawValue)"
    }
    
    private func updateAccessibilityLabel() {
        accessibilityLabel = "Lord Waffles the Dog. \(dogState.label)"
    }
}
