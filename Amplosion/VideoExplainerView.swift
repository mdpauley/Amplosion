//
//  VideoExplainerView.swift
//  VideoExplainerView
//
//  Created by Christian Selig on 2021-09-09.
//

import UIKit
import AVFoundation

class VideoExplainerView: UIView {
    var player: AVQueuePlayer?
    var playerLayer: AVPlayerLayer?
    var playerLooper: AVPlayerLooper?
    let thumbnail = UIImageView(image: UIImage(named: "explainer-thumb")!)
    
    let videoSize = CGSize(width: 828.0, height: 582.0)
    
    let restartButton = UIButton(type: .system)
    let restartButtonEdgeSpacing: CGFloat = 12.0
    
    init() {
        super.init(frame: .zero)

        print("🐶 Init of video explainer view did occur")
        
        setUpVideo()
        
        layer.masksToBounds = true
        layer.cornerRadius = 15.0
        layer.cornerCurve = .continuous
        addSubview(thumbnail)
        
        layer.addSublayer(playerLayer!)
        layer.borderColor = UIColor.red.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = 15.0
        layer.cornerCurve = .continuous

        let config = UIImage.SymbolConfiguration(textStyle: .title2)
        let image = UIImage(systemName: "arrow.clockwise.circle.fill", withConfiguration: config)!
        restartButton.setImage(image, for: .normal)
        restartButton.tintColor = .white
        restartButton.addTarget(self, action: #selector(restartButtonTapped(sender:)), for: .touchUpInside)
        
        // Flip horizontally because it looks more like a restart button. Do it on the image view itself as the SF Symbol image doesn't like being manipulated and loses config.
        restartButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        addShadowToRestartButton()
        addSubview(restartButton)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
     
        // Update the video too for a theme change
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else { return }
        setUpVideo()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        thumbnail.frame = bounds
        playerLayer?.frame = bounds
        
        let restartButtonSize = restartButton.sizeThatFits(.zero)
        restartButton.frame = CGRect(x: bounds.width - restartButtonSize.width - restartButtonEdgeSpacing, y: bounds.height - restartButtonSize.height - restartButtonEdgeSpacing, width: restartButtonSize.width, height: restartButtonSize.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let aspectRatio = videoSize.width / videoSize.height
        let height = size.width / aspectRatio
        return CGSize(width: size.width, height: height)
    }
    
    private func setUpVideo() {
        let asset = AVAsset(url: Bundle.main.url(forResource: "explainer-\(self.traitCollection.userInterfaceStyle == .light ? "light" : "dark")", withExtension: "mp4")!)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer(playerItem: playerItem)
        
        if let playerLayer = playerLayer {
            playerLayer.player = player
        } else {
            self.playerLayer = AVPlayerLayer(player: player)
        }
        
        self.player = player
        self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        
        // Prevents weird video artifacts like gray borders
        playerLayer?.shouldRasterize = true
        playerLayer?.rasterizationScale = UIScreen.main.scale
        playerLayer?.videoGravity = .resize
        
        if self.traitCollection.userInterfaceStyle == .dark {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                // Wait a second before playing because I'm a dummy and for the dark version I didn't add enough buffer before
                player.play()
            }
        } else {
            player.play()
        }
    }
    
    @objc private func restartButtonTapped(sender: UIButton) {
        player?.seek(to: .zero)
        player?.play()
    }
    
    private func addShadowToRestartButton() {
        restartButton.layer.shadowColor = UIColor.black.cgColor
        restartButton.layer.shadowOpacity = 0.5
        restartButton.layer.shadowOffset = .zero
        restartButton.layer.shadowRadius = 8.0
        restartButton.layer.shouldRasterize = true
        restartButton.layer.rasterizationScale = UIScreen.main.scale
    }
}
