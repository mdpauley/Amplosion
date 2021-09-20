//
//  AppIcon.swift
//  AppIcon
//
//  Created by Christian Selig on 2021-08-24.
//

import UIKit

enum AppIcon: String, CaseIterable, Hashable {
    case `default` = "AppIcon"
    case blueLightning = "blue-lightning"
    case greenLightning = "green-lightning"
    case blackLightning = "black-lightning"
    case darkBlueLightning = "darkblue-lightning"
    case rainbowLightning = "rainbow-lightning"
    case blueprintLightning = "blueprint-lightning"
    case simpleRedLightning = "simplered-lightning"
    case simpleBrownLightning = "simplebrown-lightning"
    case brownDog = "brown-dog"
    case redDog = "red-dog"
    case orangeDog = "orange-dog"
    case yellowDog = "yellow-dog"
    case greenDog = "green-dog"
    case blueDog = "blue-dog"
    case purpleDog = "purple-dog"
    case blackDog = "black-dog"
    case whiteDog = "white-dog"

    static var currentAppIcon: AppIcon {
        guard let name = UIApplication.shared.alternateIconName else { return .default}
        
        guard let appIcon = AppIcon(rawValue: name) else {
            fatalError("Provided unknown app icon value")
        }
        
        return appIcon
    }
    
    var isUnlocked: Bool {
        switch self {
        case .default:
            return true
        case .blueLightning:
            return true
        case .greenLightning:
            return true
        case .blackLightning:
            return true
        case .darkBlueLightning:
            return true
        case .rainbowLightning:
            return true
        case .blueprintLightning:
            return true
        case .simpleRedLightning:
            return true
        case .simpleBrownLightning:
            return true
        case .brownDog:
            return true
        case .redDog:
            return Bandana.unlockedBandanas.contains(.red)
        case .orangeDog:
            return Bandana.unlockedBandanas.contains(.orange)
        case .yellowDog:
            return Bandana.unlockedBandanas.contains(.yellow)
        case .greenDog:
            return Bandana.unlockedBandanas.contains(.green)
        case .blueDog:
            return Bandana.unlockedBandanas.contains(.blue)
        case .purpleDog:
            return Bandana.unlockedBandanas.contains(.purple)
        case .blackDog:
            return Bandana.unlockedBandanas.contains(.black)
        case .whiteDog:
            return Bandana.unlockedBandanas.contains(.white)
        }
    }
    
    var thumbnail: UIImage {
        if self == .default {
            return UIImage(named: "thumb-red-lightning")!
        } else {
            return UIImage(named: "thumb-\(self.rawValue)")!
        }
    }
    
    var title: String {
        switch self {
        case .default:
            return "Crimson Clouds"
        case .blueLightning:
            return "Elysian Blueberry"
        case .greenLightning:
            return "Emerald Caucophony"
        case .blackLightning:
            return "Beard of Zeus"
        case .darkBlueLightning:
            return "Great Odin’s Raven"
        case .rainbowLightning:
            return "Seven Colors"
        case .blueprintLightning:
            return "Scheming Schematics"
        case .simpleRedLightning:
            return "Scarlet Moon"
        case .simpleBrownLightning:
            return "Lightning Bagels"
        case .brownDog:
            return "Lord Waffles"
        case .redDog:
            return "Fire Truck"
        case .orangeDog:
            return "Candy Corn"
        case .yellowDog:
            return "Lemony Lemon"
        case .greenDog:
            return "Not a Frog"
        case .blueDog:
            return "Halcyon"
        case .purpleDog:
            return "Tiny Tulip"
        case .blackDog:
            return "Lights Out"
        case .whiteDog:
            return "Fun in the Snow"
        }
    }
    
    var subtitle: String {
        switch self {
        case .default:
            return "AKA electrocuted tomato soup"
        case .blueLightning:
            return "Will go great with my cereal"
        case .greenLightning:
            return "Sounds like an early 2000s punk band"
        case .blackLightning:
            return "He sports a colorful bathrobe"
        case .darkBlueLightning:
            return "Caw! Cawww! Do you speak raven?"
        case .rainbowLightning:
            return "With infinite colors in between"
        case .blueprintLightning:
            return "As earnest as pineapples on pizza"
        case .simpleRedLightning:
            return "Not a farming simulator"
        case .simpleBrownLightning:
            return "I think my toaster’s broken"
        case .brownDog:
            return "He really loves to be pet"
        case .redDog:
            return "Little Red Waffling Hood"
        case .orangeDog:
            return "Like a happy little pylon"
        case .yellowDog:
            return "Fun fact: it’s pure gold"
        case .greenDog:
            return "Has been known to ribbit, though"
        case .blueDog:
            return "Grants +4 to swimming dexterity"
        case .purpleDog:
            return "Oh dear, oh dear. Gorgeous"
        case .blackDog:
            return "Scorched by a dragon. They’re friends now"
        case .whiteDog:
            return "Uses the best detergent to keep pristine"
        }
    }
    
    var accessibilityDescription: String {
        let visualDescription: String = {
            switch self {
            case .default:
                return "Yellow lightning bolt exploding in half on a red background."
            case .blueLightning:
                return "Yellow lightning bolt exploding in half on a blue background."
            case .greenLightning:
                return "Yellow lightning bolt exploding in half on a green background."
            case .blackLightning:
                return "Yellow lightning bolt exploding in half on a black background."
            case .darkBlueLightning:
                return "Yellow lightning bolt exploding in half on a dark-blue background."
            case .rainbowLightning:
                return "Light-gray lightning bolt exploding in half on a rainbow background of the following stacked colors: green, yellow, orange, red, purple, blue."
            case .blueprintLightning:
                return "Blue lightning bolt exploding in half on a blueprint/schematic/TestFlight-style background."
            case .simpleRedLightning:
                return "Yellow lightning bolt cut in half in front of a red circle which is set on a dark blue background."
            case .simpleBrownLightning:
                return "Yellow lightning bolt cut in half in front of a brown circle which is set on a cream-colored background."
            case .brownDog:
                return "Brown dog with a white snout and belly, standing on all fours facing the right. Yellow lightning bolt in top-left corner. Background is light brown."
            case .redDog:
                return "Brown dog with a white snout and belly wearing a red bandana, standing on all fours facing the right. Yellow lightning bolt in top-left corner. Background is red."
            case .orangeDog:
                return "Brown dog with a white snout and belly wearing a orange bandana, standing on all fours facing the right. Yellow lightning bolt in top-left corner. Background is orange."
            case .yellowDog:
                return "Brown dog with a white snout and belly wearing a yellow bandana, standing on all fours facing the right. Yellow lightning bolt in top-left corner. Background is yellow."
            case .greenDog:
                return "Brown dog with a white snout and belly wearing a green bandana, standing on all fours facing the right. Yellow lightning bolt in top-left corner. Background is green."
            case .blueDog:
                return "Brown dog with a white snout and belly wearing a blue bandana, standing on all fours facing the right. Yellow lightning bolt in top-left corner. Background is blue."
            case .purpleDog:
                return "Brown dog with a white snout and belly wearing a purple bandana, standing on all fours facing the right. Yellow lightning bolt in top-left corner. Background is purple."
            case .blackDog:
                return "Brown dog with a white snout and belly wearing a black bandana, standing on all fours facing the right. Yellow lightning bolt in top-left corner. Background is black."
            case .whiteDog:
                return "Brown dog with a white snout and belly wearing a white bandana, standing on all fours facing the right. Yellow lightning bolt in top-left corner. Background is white."
            }
        }()
        
        return "Alternate app icon. " + visualDescription + " Title: \(title). Subtitle: \(subtitle)."
    }
    
    static var unlockedIcons: [AppIcon] {
        return AppIcon.allCases.filter { $0.isUnlocked }
    }
}
