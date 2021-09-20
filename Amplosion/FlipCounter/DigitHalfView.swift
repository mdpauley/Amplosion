//
//  DigitHalf.swift
//  DigitHalf
//
//  Created by Christian Selig on 2021-08-28.
//

import UIKit

/// Similar to `UILabel`, but just draws a single digit and draws it from either the top or bottom, where `UILabel` only draws from the center. This gives us control over clipping.
class DigitHalfView: UIView {
    enum DigitHalf {
        case top, bottom
    }
    
    var digit: Int {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    let half: DigitHalf
    
    var sidePadding: CGFloat {
        return (digitFont.pointSize / 5.0).rounded()
    }
    
    var digitFont: UIFont {
        return UIFont.rounded(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize, weight: .semibold)
    }
    
    /// Have a standard placeholder digit we use to measure to keep all numbers a consistent width. (9 is quite wide)
    private let placeholderDigit: Int = 9
    
    init(digit: Int, half: DigitHalf) {
        self.digit = digit
        self.half = half
    
        super.init(frame: .zero)
        
        isOpaque = false
        layer.masksToBounds = true
        layer.cornerRadius = 3.0
        layer.cornerCurve = .continuous
        backgroundColor = half == .top ? UIColor(named: "flip-counter-top") : UIColor(named: "flip-counter-bottom")
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func draw(_ rect: CGRect) {
        let intrinsicSize = intrinsicContentSize
        let size = attributedString(withDigit: digit).boundingRect(with: .zero, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size
        
        // Looks better horizontally centered with 1pt to the right movement
        let xFudge = 1.0
        
        switch half {
        case .top:
            let point = CGPoint(x: ((intrinsicSize.width - size.width) / 2.0) + xFudge, y: 0.0)
            attributedString(withDigit: digit).draw(at: point)
        case .bottom:
            let point = CGPoint(x: ((intrinsicSize.width - size.width) / 2.0) + xFudge, y: -intrinsicSize.height - 1.0)
            attributedString(withDigit: digit).draw(at: point)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let stringSize = attributedString(withDigit: placeholderDigit).boundingRect(with: .zero, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size
        let width = stringSize.width + sidePadding * 2.0
        let height = ceil(stringSize.height / 2.0)
        return CGSize(width: ceil(width), height: height)
    }
    
    func attributedString(withDigit digit: Int) -> NSAttributedString {
        return NSAttributedString(string: "\(digit)", attributes: [.font: digitFont, .foregroundColor: UIColor(named: "flip-counter-text")!])
    }
    
    func update() {
        setNeedsDisplay()
    }
}
