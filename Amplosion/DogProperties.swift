//
//  DogProperties.swift
//  DogProperties
//
//  Created by Christian Selig on 2021-09-11.
//

import UIKit

struct DogProperties {
    static let spriteSize: CGFloat = 64.0
}

enum DogAIAction {
    case walk(destination: CGPoint)
    case sleep(duration: TimeInterval)
    case lookAround(dogIsFacingLeft: Bool)
    case dig(times: Int)
    case sitDown(direction: DogSittingDirection, duration: TimeInterval, wagSpeed: TimeInterval)
    case openAppIcon
    
    static func rollDice(currentDogPosition: CGPoint, dogIsFacingLeft: Bool, inArea area: CGSize, insets: UIEdgeInsets, rectsToAvoid: [CGRect], allowOpenAppIcon: Bool) -> DogAIAction {
        let diceNumbers = 1 ... 100
        let diceRoll = diceNumbers.randomElement()!
        
        switch diceRoll {
        case 1 ... 10:
            // Convert from milliseconds to seconds
            let wagSpeed = TimeInterval((150 ... 750).randomElement()!) / 1_000
            
            let direction: DogSittingDirection = {
                let nineSidedDiceRoll = (1 ... 9).randomElement()!
                
                switch nineSidedDiceRoll {
                case 1 ... 3:
                    return .front
                case 4 ... 6:
                    return .left
                default:
                    return .right
                }
            }()
            
            return .sitDown(direction: direction, duration: TimeInterval((6 ... 10).randomElement()!), wagSpeed: wagSpeed)
        case 11 ... 20:
            return .dig(times: (5 ... 9).randomElement()!)
        case 21 ... 30:
            return .lookAround(dogIsFacingLeft: dogIsFacingLeft)
        case 31 ... 40:
            return .sleep(duration: TimeInterval((7 ... 13).randomElement()!))
        default:
            if allowOpenAppIcon && diceRoll == 42 {
                print("🌌 Wow! Rolled openAppIcon. Dice roll: \(diceRoll) and one more to prove not a coincidence: \(diceNumbers.randomElement()!)")
                return .openAppIcon
            } else {
                return .walk(destination: randomWalkingDestination(fromCurrentPosition: currentDogPosition, inArea: area, insets: insets, rectsToAvoid: rectsToAvoid))
            }
        }
    }
    
    private static func randomWalkingDestination(fromCurrentPosition currentDogPosition: CGPoint, inArea area: CGSize, insets: UIEdgeInsets, rectsToAvoid: [CGRect]) -> CGPoint {
        let xRange = 75 ... 200
        let yRange = 75 ... 200
        
        let xMovement = CGFloat(xRange.randomElement()!) * (Bool.percentChance(50) ? -1.0 : 1.0)
        let yMovement = CGFloat(yRange.randomElement()!) * (Bool.percentChance(50) ? -1.0 : 1.0)
        
        let randomPosition = CGPoint(x: currentDogPosition.x + xMovement, y: currentDogPosition.y + yMovement)
        let newRect = CGRect(origin: randomPosition, size: CGSize(width: DogProperties.spriteSize, height: DogProperties.spriteSize))
        
        // Criteria: ensure it's not outside the bounds of the screen and not overlapping a dirt square
        let screenBounds = CGRect(origin: .zero, size: area).inset(by: insets)
        let isInSideScreenBounds = screenBounds.contains(newRect)
        let isOverlappingRectToAvoid = rectsToAvoid.first { $0.intersects(newRect) } != nil

        print(area, insets, rectsToAvoid, currentDogPosition, isInSideScreenBounds, isOverlappingRectToAvoid, screenBounds, newRect, xMovement, yMovement)
        
        if isInSideScreenBounds && !isOverlappingRectToAvoid {
            return randomPosition
        } else {
            // Re-roll! 🎲
            return randomWalkingDestination(fromCurrentPosition: currentDogPosition, inArea: area, insets: insets, rectsToAvoid: rectsToAvoid)
        }
    }
}

enum DogSittingDirection {
    case left, right, front
}
