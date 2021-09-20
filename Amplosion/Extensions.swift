//
//  Extensions.swift
//  DogWalk
//
//  Created by Christian Selig on 2021-08-17.
//

import UIKit

extension CGPoint {
    func rounded() -> CGPoint {
        return CGPoint(x: self.x.rounded(), y: self.y.rounded())
    }
}

extension Bool {
    /// Returns true if a dice was rolled and your desired outcome occurred. e.g.: 15 -> true if the 15% chance occurred.
    static func percentChance(_ percent: Int) -> Bool {
        let oneHundredSidedDie = 1 ... 100
        
        guard oneHundredSidedDie.contains(percent) else { fatalError("Percent must be between 1 and 100") }
        
        let diceRoll = oneHundredSidedDie.randomElement()!
        
//        print("🎲 Dice roll! Wanted: < \(percent), got: \(diceRoll)")
        
        if diceRoll <= percent {
            return true
        } else {
            return false
        }
    }
}

extension CGFloat {
    func moveToPixelBoundary() -> CGFloat {
        // Since the pixel grid is upscaled, keep on even number pixels
        let floored = Int(self)
        return floored.isMultiple(of: 2) ? CGFloat(floored) : CGFloat(floored - 1)
    }
}

extension UIFont {
    func rounded(withWeight weight: UIFont.Weight? = nil) -> UIFont {
        guard let weight = weight else {
            guard let descriptor = fontDescriptor.withDesign(.rounded) else { return self }
            return UIFont(descriptor: descriptor, size: pointSize)
        }
        
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor: UIFontDescriptor = {
            let baseDescriptor = UIFontDescriptor(fontAttributes: attributes)
            return baseDescriptor.withDesign(.rounded) ?? baseDescriptor
        }()

        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}

extension Int {
    var totalDigits: Int {
        return "\(self)".count
    }
    
    var digits: [Int] {
        return "\(self)".map { $0.wholeNumberValue! }
    }
}

extension UIAlertController {
    /// Creates a view controller for notifying the user that a conversion is occurring. Accepts a block that is executed upon conversion completion.
    static func createConvertingAlertController(onConversionCompletion: @escaping () -> Void) -> UIAlertController {
        // The title font corresponds to Dynamic Type style "Headline"
        let titleFont = UIFont.preferredFont(forTextStyle: .headline)
        let calculatorImageView = UIImageView(image: UIImage(named: "calculator.fill", in: nil, with: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: titleFont.pointSize * 2.0, weight: .semibold))))
        let measuringAttributedStringHeight = NSAttributedString(string: "Penguin", attributes: [.font: titleFont]).boundingRect(with: .zero, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).height
        let desiredOffset = 15.0 + calculatorImageView.bounds.height
        let totalNewlinePrefixes = Int((desiredOffset / measuringAttributedStringHeight).rounded())
        
        let alertController = UIAlertController(title: convertingTitle(withTotalNewlines: totalNewlinePrefixes), message: "Trying to remember long division… carry the 4…", preferredStyle: .alert)
        
        let yOffset = 20.0
        calculatorImageView.frame.origin = CGPoint(x: (alertController.view.bounds.width - calculatorImageView.bounds.width) / 2.0, y: yOffset)
        calculatorImageView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        calculatorImageView.tintColor = .secondaryLabel
        alertController.view.addSubview(calculatorImageView)
        
        let displayDurationMS = (2_500 ... 4_200).randomElement()!
        let displayDurationSeconds = TimeInterval(displayDurationMS) / 1_000
        
        let numbersTimer = Timer.scheduledTimer(withTimeInterval: 0.085, repeats: true) { timer in
            alertController.title = convertingTitle(withTotalNewlines: totalNewlinePrefixes)
        }
        
        delay(displayDurationSeconds) {
            numbersTimer.invalidate()
            alertController.dismiss(animated: true) {
                onConversionCompletion()
            }
        }
        
        return alertController
    }
    
    private static func convertingTitle(withTotalNewlines totalNewlines: Int) -> String {
        let newlinePrefixes = [String](repeating: "\n", count: totalNewlines).joined()
        let numberRange = 100 ... 999
        return "\(newlinePrefixes)Converting… \(numberRange.randomElement()!)"
    }
}

extension Locale {
    /// Returns an SF Symbol currency image that match's the device's current locale, for instance dollar in North America, Indian rupee in India, etc.
    func currencySFSymbol(filled: Bool, withConfiguration configuration: UIImage.Configuration? = nil) -> UIImage {
        // Default currency symbol will be the Animal Crossing Leaf coin 􁂬 to remain impartial to any specific country
        let defaultSymbol = UIImage(systemName: "leaf.circle\(filled ? ".fill" : "")")!
        
        guard let currencySymbolName = currencySymbolNameForSFSymbols() else { return defaultSymbol }
        
        let systemName = "\(currencySymbolName).circle\(filled ? ".fill" : "")"
        return UIImage(systemName: systemName, withConfiguration: configuration) ?? defaultSymbol
    }
    
    private func currencySymbolNameForSFSymbols() -> String? {
        guard let currencySymbol = currencySymbol else { return nil }
        
        let symbols: [String: String] = [
            "$": "dollar",
            "¢": "cent",
            "¥": "yen",
            "£": "sterling",
            "₣": "franc",
            "ƒ": "florin",
            "₺": "turkishlira",
            "₽": "ruble",
            "€": "euro",
            "₫": "dong",
            "₹": "indianrupee",
            "₸": "tenge",
            "₧": "peseta",
            "₱": "peso",
            "₭": "kip",
            "₩": "won",
            "₤": "lira",
            "₳": "austral",
            "₴": "hryvnia",
            "₦": "naira",
            "₲": "guarani",
            "₡": "coloncurrency",
            "₵": "cedi",
            "₢": "cruzeiro",
            "₮": "tugrik",
            "₥": "mill",
            "₪": "shekel",
            "₼": "manat",
            "₨": "rupee",
            "฿": "baht",
            "₾": "lari",
            "R$":" brazilianreal"
        ]
        
        guard let currencySymbolName = symbols[currencySymbol] else { return nil }
        return "\(currencySymbolName)sign"
    }
}

extension Int {
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = (Locale.current as NSLocale).object(forKey: NSLocale.Key.groupingSeparator) as? String
        formatter.groupingSize = 3
        
        let number = formatter.string(from: NSNumber(integerLiteral: self)) ?? "\(self)"
        return number
    }
}

extension UINavigationController {
    func setToNonFullWidthInLandscape() {
        if let sheetController = presentationController as? UISheetPresentationController {
            sheetController.prefersEdgeAttachedInCompactHeight = true
            sheetController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
    }
}
