//
//  AmplosionStatsTableViewCell.swift
//  AmplosionStatsTableViewCell
//
//  Created by Christian Selig on 2021-08-25.
//

import UIKit

class AmplosionStatsTableViewCell: UITableViewCell {
    let convertButton: UIButton
    let flipCounter: FlipCounter
    let statsButton = UIButton(type: .system)
    
    let flipCounterVerticalSpacing = 10.0
    let sideSpacing = 25.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.flipCounter = FlipCounter(value: UserDefaults.groupSuite.totalAmplosionsOnLastAppExit())
        
        let convertImageConfiguration = UIImage.SymbolConfiguration(weight: .semibold).applying(UIImage.SymbolConfiguration.preferringMulticolor())
        let convertImage = UIImage(named: "custom.arrow.left.arrow.right", in: nil, with: convertImageConfiguration)
        
        var convertButtonConfig = UIButton.Configuration.plain()
        convertButtonConfig.image = convertImage
        
        convertButton = UIButton(configuration: convertButtonConfig)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [convertButton, flipCounter, statsButton].forEach { contentView.addSubview($0) }
        
        isAccessibilityElement = false
        selectionStyle = .none
        
        convertButton.accessibilityLabel = "Convert"
        convertButton.accessibilityHint = "Converts total Amplosions to dollars saved."
        
        statsButton.setImage(UIImage(systemName: "chart.bar.fill"), for: .normal)
        statsButton.accessibilityLabel = "Stats"
        statsButton.accessibilityHint = "Shows a breakdown of Amplosion stats."
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let convertButtonSize = convertButton.sizeThatFits(.zero)
        convertButton.frame = CGRect(x: sideSpacing, y: (bounds.height - convertButtonSize.height) / 2.0, width: convertButtonSize.width, height: convertButtonSize.height)
        
        let flipCounterSize = flipCounter.intrinsicContentSize
        let flipCounterX = ((contentView.bounds.width - flipCounterSize.width) / 2.0).rounded()
        flipCounter.frame = CGRect(x: flipCounterX, y: flipCounterVerticalSpacing, width: flipCounterSize.width, height: flipCounterSize.height)
        
        let statsButtonSize = statsButton.sizeThatFits(.zero)
        statsButton.frame = CGRect(x: bounds.width - sideSpacing - statsButtonSize.width, y: (bounds.height - statsButtonSize.height) / 2.0, width: statsButtonSize.width, height: statsButtonSize.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = flipCounter.intrinsicContentSize.height + flipCounterVerticalSpacing * 2.0
        return CGSize(width: size.width, height: height)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        animateTotalAmplosionsCountChangeIfNecessary()
    }
    
    func animateTotalAmplosionsCountChangeIfNecessary() {
        let totalAmplosionsOnExit = UserDefaults.groupSuite.totalAmplosionsOnLastAppExit()
        let currentTotalAmplosions = UserDefaults.groupSuite.totalAmplosions()
        
        guard currentTotalAmplosions > totalAmplosionsOnExit else { return }
                    
        flipCounter.changeValue(to: currentTotalAmplosions, applyValueAfterward: true)
    }
}
