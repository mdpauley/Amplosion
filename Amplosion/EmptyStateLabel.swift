//
//  EmptyStateLabel.swift
//  EmptyStateLabel
//
//  Created by Christian Selig on 2021-09-02.
//

import UIKit

class EmptyStateLabel: UILabel {
    let insets = UIEdgeInsets(top: 40.0, left: 40.0, bottom: 40.0, right: 40.0)
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textRect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        return textRect.inset(by: UIEdgeInsets(top: -insets.top, left: -insets.left, bottom: -insets.bottom, right: -insets.right))
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}
