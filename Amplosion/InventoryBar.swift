//
//  InventoryBar.swift
//  DogWalk
//
//  Created by Christian Selig on 2021-08-22.
//

import UIKit

class InventoryBar: UIView {
    let border = UIImageView(image: UIImage(named: "inventory-border"))
    let selectionBox = UIImageView(image: UIImage(named: "selection-box"))
    
    let topSeparator = UIView()
    
    let itemBoxes: [UIButton] = {
        // Can't just use the repeating:count: initializer because it uses the same object in every index
        return (0 ..< 8).map { index in
            var buttonConfig = UIButton.Configuration.plain()
            
            var backgroundConfiguration = UIBackgroundConfiguration.clear()
            backgroundConfiguration.customView = UIImageView(image: UIImage(named: "inventory-inner-box"))
            buttonConfig.background = backgroundConfiguration
            
            let button = UIButton(configuration: buttonConfig)
            button.tintColor = UIColor(named: "inventory-box")
            button.contentMode = .scaleAspectFill
            button.contentHorizontalAlignment = .fill
            button.contentVerticalAlignment = .fill
            button.addTarget(self, action: #selector(itemBoxTapped(sender:)), for: .touchUpInside)
            
            let isBandanaUnlockedForButton = Bandana.unlockedBandanas.contains(Bandana.allCases[index])
            button.isAccessibilityElement = isBandanaUnlockedForButton
            
            return button
        }
    }()
    
    var selectedIndex: Int? {
        didSet {
            selectionBox.alpha = selectedIndex == nil ? 0.0 : 1.0
            layoutSelectionBox()
            
            if let selectedIndex = selectedIndex {
                Bandana.setSelectedBandana(to: Bandana.ordered[selectedIndex])
            } else {
                Bandana.setSelectedBandana(to: nil)
            }
        }
    }
    
    let bandanaImageViews: [UIImageView] = {
        var bandanas: [UIImageView] = []
        
        for bandana in Bandana.ordered {
            let imageView = UIImageView(image: UIImage(named: "bandana-\(bandana.rawValue)"))
            imageView.contentMode = .scaleAspectFit
            imageView.layer.minificationFilter = .nearest
            imageView.layer.magnificationFilter = .nearest
            imageView.frame.size = InventoryBar.bandanaSize
            bandanas.append(imageView)
        }
        
        return bandanas
    }()
    
    weak var delegate: InventoryBarDelegate?
    
    // MARK: - Constants
    
    static let totalBoxes: Int = 8
    static let baseHeight: CGFloat = 72.0
    static let bandanaSize = CGSize(width: 26.0, height: 32.0)
    static let selectionBoxHeight: CGFloat = 52.0
    
    private let topInset: CGFloat = 8.0
    private let itemBoxHeight: CGFloat = 48.0
    private let onePixel: CGFloat = 2.0
    
    init() {
        selectedIndex = Bandana.selectedBandana?.index
        
        super.init(frame: .zero)
        
        backgroundColor = UIColor(named: "inventory-background")
        
        border.layer.minificationFilter = .nearest
        border.layer.magnificationFilter = .nearest
        border.tintColor = UIColor(named: "inventory-border")
        addSubview(border)
        
        itemBoxes.forEach { addSubview($0) }

        updateImageViews()
        
        selectionBox.alpha = selectedIndex == nil ? 0.0 : 1.0
        addSubview(selectionBox)
        
        topSeparator.backgroundColor = UIColor(named: "inventory-border")
        addSubview(topSeparator)
        
        NotificationCenter.default.addObserver(self, selector: #selector(unlockedBandanaNotificationReceived(notification:)), name: .unlockedBandana, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        let leftSideInset = safeAreaInsets.left != 0.0 ? safeAreaInsets.left : 10.0
        let rightSideInset = safeAreaInsets.right != 0.0 ? safeAreaInsets.left : 10.0
        
        let totalBoxesAvailableWidth = bounds.width - leftSideInset - rightSideInset
        let boxWidth: CGFloat = (totalBoxesAvailableWidth / CGFloat(InventoryBar.totalBoxes)).moveToPixelBoundary()
        
        // For total used size, note that they overlap each other by one pixel
        let totalBoxesUsedWith = boxWidth * (CGFloat(InventoryBar.totalBoxes)) - (onePixel * CGFloat(InventoryBar.totalBoxes - 1))
        let borderSizeWidth = totalBoxesUsedWith + onePixel * 4.0
        
        let borderX = ((bounds.width - borderSizeWidth) / 2.0).moveToPixelBoundary()
        let borderSizeHeight = itemBoxHeight + onePixel * 4.0
        border.frame = CGRect(x: borderX, y: topInset, width: borderSizeWidth, height: borderSizeHeight)
        
        for (index, box) in itemBoxes.enumerated() {
            let boxX: CGFloat = index == 0 ? borderX + onePixel * 2.0 : (itemBoxes[index - 1].frame.maxX - onePixel)
            let boxY = topInset + onePixel * 2.0
            box.frame = CGRect(x: boxX, y: boxY, width: boxWidth, height: itemBoxHeight)
            
            let bandanaX = boxX + ((boxWidth - InventoryBar.bandanaSize.width) / 2.0).moveToPixelBoundary()
            
            // Move up by one pixel, looks more visually centered
            let bandanaY = boxY + ((itemBoxHeight - InventoryBar.bandanaSize.height) / 2.0).moveToPixelBoundary() - onePixel
            
            bandanaImageViews[index].frame.origin = CGPoint(x: bandanaX, y: bandanaY)
        }
        
        layoutSelectionBox()
        
        topSeparator.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: onePixel)
    }
    
    private func layoutSelectionBox() {
        guard let selectedIndex = selectedIndex else { return }
        
        let selectedBox = itemBoxes[selectedIndex]
        
        let selectionBoxX = selectedBox.frame.origin.x - onePixel
        let selectionBoxY = selectedBox.frame.origin.y - onePixel
        let selectionBoxWidth = selectedBox.bounds.width + onePixel * 2.0
        
        selectionBox.frame = CGRect(x: selectionBoxX, y: selectionBoxY, width: selectionBoxWidth, height: InventoryBar.selectionBoxHeight)
    }
    
    @objc private func itemBoxTapped(sender: UIButton) {
        guard let index = itemBoxes.firstIndex(of: sender) else { return }
        
        // Only allow selection of unlocked bandanas
        let bandana = Bandana.ordered[index]
        guard Bandana.unlockedBandanas.contains(bandana) else { return }
        
        if let currentlySelectedIndex = selectedIndex, currentlySelectedIndex == index {
            // If they re-select the currently selceted one, interpret that as de-selecting it
            selectedIndex = nil
        } else {
            selectedIndex = index
        }
        
        delegate?.selectedBandana(atIndex: index)
    }
    
    @objc private func unlockedBandanaNotificationReceived(notification: Notification) {
        guard let rawBandana = notification.userInfo?["bandana"] as? String, let bandana = Bandana(rawValue: rawBandana) else { fatalError("Notification payload incorrect") }
        let index = Bandana.ordered.firstIndex(of: bandana)!
        
        UIView.animate(withDuration: 1.0, delay: 0.2, options: [.curveLinear, .preferredFramesPerSecond30], animations: {
            self.bandanaImageViews[index].alpha = 1.0
        }, completion: nil)
        
        self.selectedIndex = index
    }
    
    func updateImageViews() {
        for (index, bandana) in Bandana.ordered.enumerated() {
            let bandanaImageView = bandanaImageViews[index]
            bandanaImageView.alpha = Bandana.unlockedBandanas.contains(bandana) ? 1.0 : 0.0
            addSubview(bandanaImageView)
        }
    }
}

protocol InventoryBarDelegate: AnyObject {
    func selectedBandana(atIndex index: Int)
}
