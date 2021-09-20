//
//  FlipCounterDigit.swift
//  FlipCounterDigit
//
//  Created by Christian Selig on 2021-08-28.
//

import UIKit

/// Contains both the tap and bottom half of the digit to represent a single digit in the number
class FlipCounterDigit: UIView {
    var digit: Int
    
    var topHalfView: DigitHalfView
    var bottomHalfView: DigitHalfView
    
    let coil1 = FlipCounterDigitCoil()
    let coil2 = FlipCounterDigitCoil()
    let coilSideSpacing = 2.0
    
    init(digit: Int) {
        self.digit = digit
        
        topHalfView = DigitHalfView(digit: digit, half: .top)
        bottomHalfView = DigitHalfView(digit: digit, half: .bottom)
        
        super.init(frame: .zero)
        
        [topHalfView, bottomHalfView, coil1, coil2].forEach { addSubview($0) }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let topHalfSize = topHalfView.intrinsicContentSize
        
        topHalfView.frame = CGRect(x: 0.0, y: 0.0, width: topHalfSize.width, height: topHalfSize.height)
        bottomHalfView.frame = CGRect(x: 0.0, y: topHalfView.frame.maxY + 1.0, width: topHalfSize.width, height: topHalfSize.height)
        
        let coilSize = coil1.intrinsicContentSize
        coil1.frame = CGRect(x: coilSideSpacing, y: (bounds.height - coilSize.height) / 2.0, width: coilSize.width, height: coilSize.height)
        coil2.frame = CGRect(x: bounds.width - coilSideSpacing - coilSize.width, y: (bounds.height - coilSize.height) / 2.0, width: coilSize.width, height: coilSize.height)
    }
    
    override var intrinsicContentSize: CGSize {
        let topHalfSize = topHalfView.intrinsicContentSize
        return CGSize(width: topHalfSize.width, height: topHalfSize.height * 2.0 + 1.0)
    }
    
    func increment(to newValue: Int, onCompletion: FlipCounterIncrementCompletion) {
        let currentValue = digit
        
        guard newValue != currentValue else { return }
        
        let incrementsRequired: Int = {
            if newValue > currentValue {
                return newValue - currentValue
            } else {
                return 10 - currentValue + newValue
            }
        }()
        
        let timePerIncrement = FlipCounter.incrementDuration / TimeInterval(incrementsRequired)
        recursivelyIncrementNTimes(n: incrementsRequired, currentIteration: 1, timePerIncrement: timePerIncrement, onCompletion: onCompletion)
    }
    
    private func recursivelyIncrementNTimes(n: Int, currentIteration: Int, timePerIncrement: TimeInterval, onCompletion: FlipCounterIncrementCompletion) {
        if currentIteration > n {
            onCompletion?()
            return
        }
        
        increment(animationDuration: timePerIncrement) {
            self.recursivelyIncrementNTimes(n: n, currentIteration: currentIteration + 1, timePerIncrement: timePerIncrement, onCompletion: onCompletion)
        }
    }
    
    func increment(animationDuration: TimeInterval, onCompletion: FlipCounterIncrementCompletion) {
        let currentValue = digit
        
        let tempTopHalf = DigitHalfView(digit: currentValue, half: .top)
        tempTopHalf.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        tempTopHalf.frame = topHalfView.frame
        addSubview(tempTopHalf)
        
        topHalfView.digit = topHalfView.digit == 9 ? 0 : topHalfView.digit + 1
        
        // Make sure our temp top half always overlays on top of the existing digit. Yes, a very high z-value seems needed.
        tempTopHalf.layer.zPosition = 1_000
        
        // But also put the coil EVEN HIGHER!
        coil1.layer.zPosition = 2_000
        coil2.layer.zPosition = 3_000
        
        // While the temp top half mimics the same value, since the bottom half starts invisible it mimics the incremented value
        let tempBottomHalf = DigitHalfView(digit: currentValue == 9 ? 0 : currentValue + 1, half: .bottom)
        tempBottomHalf.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        tempBottomHalf.frame = bottomHalfView.frame
        addSubview(tempBottomHalf)
        
        // Set to transformed position initially, animate into untranslated position
        do {
            var rotationAndPerspectiveTransform = CATransform3DIdentity
            rotationAndPerspectiveTransform.m34 = -1.0/40
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 90.0 * .pi / 180.0, 1.0, 0.0, 0.0)
            tempBottomHalf.transform3D = rotationAndPerspectiveTransform
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseIn]) {
            var rotationAndPerspectiveTransform = CATransform3DIdentity
            rotationAndPerspectiveTransform.m34 = 1.0/40
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 90.0 * .pi / 180.0, 1.0, 0.0, 0.0)
            tempTopHalf.transform3D = rotationAndPerspectiveTransform
        } completion: { didComplete in
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseOut]) {
                tempBottomHalf.transform3D = CATransform3DIdentity
            } completion: { didComplete in
                let newDigit = self.digit == 9 ? 0 : self.digit + 1
                self.digit = newDigit
                self.bottomHalfView.digit = newDigit
                tempTopHalf.removeFromSuperview()
                tempBottomHalf.removeFromSuperview()
                onCompletion?()
            }
        }
    }
    
    func update() {
        topHalfView.update()
        bottomHalfView.update()
    }
}

class FlipCounterDigitCoil: UIView {
    init() {
        super.init(frame: .zero)
        
        layer.masksToBounds = true
        layer.cornerRadius = 1.5
        layer.cornerCurve = .continuous
        
        backgroundColor = UIColor(named: "flip-counter-coil")
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 3.0, height: 6.0)
    }
}
