//
//  FlipCounter.swift
//  FlipCounter
//
//  Created by Christian Selig on 2021-08-29.
//

import UIKit

typealias FlipCounterIncrementCompletion = (() -> Void)?

class FlipCounter: UIView {
    var value: Int {
        didSet {
            self.accessibilityValue = "\(value)"
        }
    }
    
    var digitViews: [FlipCounterDigit]
    let totalAmplosionsLabel = UILabel()
    weak var intrinsicContentSizeDelegate: FlipCounterDelegate?
    
    // MARK: - Constants
    
    let intraItemSpacing = 7.0
    let labelVerticalSpacing: CGFloat = 5.0
    static let incrementDuration: TimeInterval = 0.7
    
    /// If the number is smaller than 3 digits, (e.g.: 47) it will pad with the necessary amount of 0s
    let minimumDigitsToShow = 3
    
    init(value: Int) {
        self.value = value
        
        var digitsToUse = value.digits
        
        if value.totalDigits < minimumDigitsToShow {
            let total0sToPadWith = minimumDigitsToShow - value.totalDigits
            
            for _ in 0 ..< total0sToPadWith {
                digitsToUse.insert(0, at: 0)
            }
        }
        
        digitViews = digitsToUse.map { FlipCounterDigit(digit: $0) }
        
        super.init(frame: .zero)
        
        digitViews.forEach { addSubview($0) }

        setTotalAmplosionsAttributedText()
        addSubview(totalAmplosionsLabel)

        isUserInteractionEnabled = true
        isAccessibilityElement = true
        accessibilityValue = "\(value)"
        accessibilityLabel = "Total Amplosions"
        accessibilityHint = "Shuffles to high value then back to normal."
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(tapGestureRecognizer:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !digitViews.isEmpty else { return }
        
        let individualSize = digitViews[0].intrinsicContentSize
        
        for (index, digitView) in digitViews.enumerated() {
            if index == 0 {
                digitView.frame = CGRect(x: 0.0, y: 0.0, width: individualSize.width, height: individualSize.height)
            } else {
                digitView.frame = CGRect(x: digitViews[index - 1].frame.maxX + intraItemSpacing, y: 0.0, width: individualSize.width, height: individualSize.height)
            }
        }
        
        let amplosionLabelSize = totalAmplosionsLabel.sizeThatFits(.zero)
        totalAmplosionsLabel.frame = CGRect(x: (bounds.width - amplosionLabelSize.width) / 2.0, y: digitViews[0].frame.maxY + labelVerticalSpacing, width: amplosionLabelSize.width, height: amplosionLabelSize.height)
    }
    
    override var intrinsicContentSize: CGSize {
        guard !digitViews.isEmpty else { return .zero }
        
        let individualSize = digitViews[0].intrinsicContentSize
        let width = (individualSize.width * CGFloat(digitViews.count)) + (intraItemSpacing * CGFloat(digitViews.count - 1))
        
        let labelHeight = totalAmplosionsLabel.sizeThatFits(.zero).height
        let height = individualSize.height + labelVerticalSpacing + labelHeight
        
        return CGSize(width: width, height: height)
    }
    
    func changeValue(to newValue: Int, applyValueAfterward: Bool) {
        guard newValue != value else { return }
        
        let newTotalDigits = max(minimumDigitsToShow, newValue.totalDigits)
        let currentTotalDigits = max(minimumDigitsToShow, value.totalDigits)
        
        // Cover increasing (422 -> 5230) or decreasing (1442 -> 002) the amount of digits
        if newTotalDigits != currentTotalDigits {
            digitViews.forEach { $0.removeFromSuperview() }
            
            // Reset and re-setup
            if newTotalDigits > currentTotalDigits {
                // Greater than
                var newDigitsToShow = value.digits
                
                let total0sToPadWith = newValue.totalDigits - value.totalDigits
                
                for _ in 0 ..< total0sToPadWith {
                    newDigitsToShow.insert(0, at: 0)
                }
                
                digitViews = newDigitsToShow.map { FlipCounterDigit(digit: $0) }
            } else {
                // Less than
                let newDigitsToShow = [Int](repeating: 0, count: minimumDigitsToShow)
                digitViews = newDigitsToShow.map { FlipCounterDigit(digit: $0) }
            }
            
            digitViews.forEach { addSubview($0) }
            intrinsicContentSizeDelegate?.flipCounterIntrinsicContentSizeInvalidated()
        }
        // Cover case where we're decreasing the value but number of digits didn't change (742 -> 001)
        else if newValue < value {
            digitViews.forEach { $0.removeFromSuperview() }
            
            let newDigitsToShow = [Int](repeating: 0, count: max(minimumDigitsToShow, newValue.totalDigits))
            digitViews = newDigitsToShow.map { FlipCounterDigit(digit: $0) }
            
            digitViews.forEach { addSubview($0) }
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        // If we added any extra digits, a resize is necessary, and if we do that in the same iteration of the run loop our animations will be janky, so do the animations in the following iteration
        DispatchQueue.main.async {
            self.incrementDigitViews(toValue: newValue)
            
            if applyValueAfterward {
                self.value = newValue
            }
        }
    }
    
    /// Increments to show 9 in all digit places, then returns to normal.
    func haveFun() {
        let all9s = Int(digitViews.map { _ in return "9" }.joined(separator: ""))!
        self.changeValue(to: all9s, applyValueAfterward: false)
        
        // Wait a beat, then restore to proper value
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.incrementDigitViews(toValue: self.value)
        }
    }
    
    private func incrementDigitViews(toValue newValue: Int) {
        var digits = newValue.digits
        
        if digits.count < self.minimumDigitsToShow {
            let total0sToPadWith = self.minimumDigitsToShow - digits.count
            
            for _ in 0 ..< total0sToPadWith {
                digits.insert(0, at: 0)
            }
        }
        
        for (index, digit) in digits.enumerated() {
            let digitView = self.digitViews[index]
            digitView.increment(to: digit) {
                print("Completed :o!")
            }
        }
    }
    
    private func setTotalAmplosionsAttributedText() {
        let attributedString = NSMutableAttributedString(string: "AMPLOSIONS", attributes: [.font: UIFont.rounded(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .bold), .foregroundColor: UIColor.systemGray])
        
        // Increase the kerning, but don't add it to the last character as it creates whitespace after the layout if you do
        attributedString.addAttribute(.kern, value: 1.5, range: NSRange(location: 0, length: attributedString.length - 1))
        
        totalAmplosionsLabel.attributedText = attributedString
    }
    
    func update() {
        setTotalAmplosionsAttributedText()
        digitViews.forEach { $0.update() }
    }
    
    @objc private func tapped(tapGestureRecognizer: UITapGestureRecognizer) {
        haveFun()
    }
}

protocol FlipCounterDelegate: AnyObject {
    /// Unlike with Auto Layout, it doesn't seem like frame-based layout has a notification for intrinsic content size changing, so this function/protocol serves as a manual notification
    func flipCounterIntrinsicContentSizeInvalidated()
}
