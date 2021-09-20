//
//  EnableInstructionView.swift
//  EnableInstructionView
//
//  Created by Christian Selig on 2021-09-09.
//

import UIKit

class EnableInstructionView: UIView {
    let instruction: EnableInstruction
    
    let icon = UIImageView()
    let label = UILabel()
    let moreInfoButton: UIButton?
    
    let iconToLabelSpacing: CGFloat = 28.0
    
    weak var delegate: EnableInstructionViewDelegate?
    
    init(instruction: EnableInstruction) {
        self.instruction = instruction
        self.moreInfoButton = instruction.hasMoreInfo ? UIButton(type: .system) : nil
        
        super.init(frame: .zero)
        
        icon.image = instruction.icon
        icon.contentMode = .center
        icon.tintColor = instruction.iconColor
        addSubview(icon)
        
        label.attributedText = instruction.attributedText
        label.numberOfLines = 0
        addSubview(label)
        
        if let moreInfoButton = moreInfoButton {
            let buttonImage = UIImage(systemName: "info.circle.fill", withConfiguration: UIImage.SymbolConfiguration(textStyle: .subheadline))
            moreInfoButton.setImage(buttonImage, for: .normal)
            moreInfoButton.tintColor = .systemBlue
            moreInfoButton.addTarget(self, action: #selector(moreInfoButtonTapped(sender:)), for: .touchUpInside)
            addSubview(moreInfoButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Keep a consistent size between all the icons so that they're all lined up
        let iconSize = EnableInstruction.largestIconSize()
        icon.frame = CGRect(x: 0.0, y: 0.0, width: iconSize.width, height: iconSize.height)
        
        let moreInfoButtonSize: CGSize = {
            guard let moreInfoButton = moreInfoButton else { return .zero }
            return moreInfoButton.sizeThatFits(.zero)
        }()
        
        let maxLabelWidth = bounds.width - iconSize.width - iconToLabelSpacing - moreInfoButtonSize.width
        let labelSize = label.sizeThatFits(CGSize(width: maxLabelWidth, height: 0.0))
        
        let labelY = (bounds.height - labelSize.height) / 2.0
        label.frame = CGRect(x: icon.frame.maxX + iconToLabelSpacing, y: labelY, width: labelSize.width, height: labelSize.height)
        
        moreInfoButton?.frame = CGRect(x: label.frame.maxX + 5.0, y: label.frame.origin.y, width: moreInfoButtonSize.width, height: moreInfoButtonSize.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let iconSize = instruction.icon.size
        let labelWidth = size.width - iconSize.width - iconToLabelSpacing
        let labelHeight = label.sizeThatFits(CGSize(width: labelWidth, height: 0.0)).height
        return CGSize(width: size.width, height: max(iconSize.height, labelHeight))
    }
    
    @objc private func moreInfoButtonTapped(sender: UIButton) {
        delegate?.moreInfoTapped()
    }
}

protocol EnableInstructionViewDelegate: AnyObject {
    func moreInfoTapped()
}
