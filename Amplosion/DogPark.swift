//
//  DogPark.swift
//  DogWalk
//
//  Created by Christian Selig on 2021-08-17.
//

import UIKit

typealias DogActionCompletion = (() -> Void)?

class DogPark: UIControl {
    let inventoryBar = InventoryBar()
    
    private var timer1: Timer?
    private var timer2: Timer?
    
    private var dirtTimer: Timer?
    
    private let frameDelay: TimeInterval = 0.2
    private var isFirstLayoutPass = true
    
    let dog = Dog(dogState: .walkingSide(isFacingLeft: false, frame: 2))
    
    private let dirt = UIImageView(image: MiscSprite.dirtLeaf)
    private var isDirtActive = false
    private var dirtWasSelected = false
    private var isDirtCooldownActive = false
    
    private let bandana = UIImageView(image: Bandana.sprite(forBandana: .yellow))

    private var debugBoxesActive = false
    
    private let bone = UIImageView(image: MiscSprite.bone)
    
    private let chatBox = UIImageView()
        
    var impactGenerator: UIImpactFeedbackGenerator?
    
    weak var tapOnAppIconCellDelegate: TapOnAppIconCellDelegate?
    
    /// The area within which to constrain the dog's normal wandering behavior
    var roamingAreaInsets: UIEdgeInsets = .zero
    
    /// Whether the user began an uninterruptible sequence and we're waiting for it to finish
    private var isPlayingOutUserInteraction = false
    
    let roamableAreaBackgroundView = UIView()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        roamableAreaBackgroundView.backgroundColor = UIColor(named: "dog-park-background")
        addSubview(roamableAreaBackgroundView)
     
        dog.dogState = .walkingSide(isFacingLeft: false, frame: 2)
        
        dog.accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: "Pet dog", target: self, selector: #selector(petDogA11Y))
        ]
        
        addSubview(dog)
        
        dirt.frame.size = CGSize(width: DogProperties.spriteSize, height: DogProperties.spriteSize)
        dirt.contentMode = .scaleAspectFit
        dirt.layer.magnificationFilter = .nearest
        dirt.alpha = 0.0
        dirt.isAccessibilityElement = true
        dirt.accessibilityLabel = "Dirt."
        dirt.accessibilityHint = "Summons dog to dig up dirt, potentially finding a treat."
        dirt.accessibilityTraits = [.updatesFrequently, .button]
        
        // Don't worry about z-index currently, will dynamically change (dog is above normally, but below when digging)
        addSubview(dirt)
        
        bandana.frame.size = Bandana.bandanaSpriteSize
        bandana.contentMode = .scaleAspectFit
        bandana.layer.magnificationFilter = .nearest
        bandana.alpha = 0.0
        addSubview(bandana)
        
        bone.frame.size = CGSize(width: DogProperties.spriteSize, height: DogProperties.spriteSize)
        bone.contentMode = .scaleAspectFit
        bone.layer.magnificationFilter = .nearest
        bone.alpha = 0.0
        insertSubview(bone, aboveSubview: dog)
        
        chatBox.contentMode = .scaleAspectFit
        chatBox.layer.magnificationFilter = .nearest
        chatBox.alpha = 0.0
        addSubview(chatBox)
        
        inventoryBar.alpha = Bandana.unlockedBandanas.isEmpty ? 0.0 : 1.0
        addSubview(inventoryBar)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(tapGestureRecognizer:)))
        addGestureRecognizer(tapGestureRecognizer)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swiped(swipeGestureRecognizer:)))
        swipeGestureRecognizer.numberOfTouchesRequired = 1
        swipeGestureRecognizer.direction = [.up, .down]
        addGestureRecognizer(swipeGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    private func summonTheDoggy() {
        let roamingArea = bounds.inset(by: roamingAreaInsets)
        let dogStartingPosition = CGPoint(x: (roamingArea.origin.x + roamingArea.width / 2.0).moveToPixelBoundary(), y: (roamingArea.origin.y + roamingArea.height / 2.0).moveToPixelBoundary())
        dog.frame.origin = dogStartingPosition
        
        startDirtCooldown()
        
        // Every so often, have a chance of the dirt spawning if not already active
        dirtTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] timer in
            guard let strongSelf = self else { return }
            guard !strongSelf.isDirtActive else { return }
            
            // Prevent dirt from spawning too quickly after it despawned or 'game' opened
            guard !strongSelf.isDirtCooldownActive else { return }
            
            let shouldDirtAppear = Bool.percentChance(20)
            
            if shouldDirtAppear {
                // Small chance of the leaf being a carrot. Spicy. Now this is game dev.
                strongSelf.dirt.image = Bool.percentChance(8) ? MiscSprite.dirtCarrot : MiscSprite.dirtLeaf
                
                strongSelf.sendSubviewToBack(strongSelf.dirt)
                strongSelf.sendSubviewToBack(strongSelf.roamableAreaBackgroundView)
                strongSelf.isDirtActive = true
                let dirtLocation = strongSelf.randomDirtLocation()
                strongSelf.dirt.frame.origin = dirtLocation
                
                strongSelf.toggleImageViewWithAnimation(strongSelf.dirt, show: true)
                strongSelf.startDirtExpirationCountdown(seconds: 6)
            }
        })
        
        doNewDogAIAction()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isFirstLayoutPass {
            isFirstLayoutPass = false
            
            // We want to wait until we've been given a proper size so we can know the bounds of our lil dog park to calculate where the dog can walk
            summonTheDoggy()
        }
                
        let inventoryBarY = bounds.height - inventoryBarHeight()
        inventoryBar.frame = CGRect(x: 0.0, y: inventoryBarY, width: bounds.width, height: inventoryBarHeight())
        
        roamableAreaBackgroundView.frame = bounds.inset(by: roamingAreaInsets)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let touchableArea = bounds.inset(by: roamingAreaInsets)
        
        if touchableArea.contains(point) || inventoryBar.frame.contains(point) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Actions
    
    func move(toPoint point: CGPoint, onCompletion: DogActionCompletion) {
        // Interrupt any existing movement if active
        invalidateDogTimers()
        
        move(toPoint: point.y, onAxis: .y) { [weak self] in
            self?.move(toPoint: point.x, onAxis: .x, onCompletion: onCompletion)
        }
    }
    
    func moveBackToCenter(onCompletion: DogActionCompletion) {
        let movableArea = bounds.inset(by: roamingAreaInsets)
        let centerPoint = CGPoint(x: movableArea.midX, y: movableArea.midY)
        
        move(toPoint: centerPoint, onCompletion: onCompletion)
    }
    
    func move(toPoint point: CGFloat, onAxis axis: DogAxis, onCompletion: DogActionCompletion) {
        invalidateDogTimers()
        
        // Check if any movement is even required
        switch axis {
        case .x:
            if point == dog.frame.origin.x {
                onCompletion?()
                return
            }
        case .y:
            if point == dog.frame.origin.y {
                onCompletion?()
                return
            }
        }
        
        // Base directions are down/right (UIKit axes), if inverse it means moving up/left
        let isInverseDirection: Bool = {
            switch axis {
            case .x:
                return point < self.dog.frame.origin.x
            case .y:
                return point < self.dog.frame.origin.y
            }
        }()
        
        let movementPerSecond = 75
        let movementFramesPerSecond = 24
        let movementDelay = TimeInterval(1.0) / TimeInterval(movementFramesPerSecond)
        let movementPerFrame = CGFloat(movementPerSecond) / CGFloat(movementFramesPerSecond)
        
        var frame: Int = 0
        
        func doFlipBook() {
            let normalizedFrame = frame % 4
            
            switch axis {
            case .x:
                if normalizedFrame == 0 {
                    self.dog.dogState = .walkingSide(isFacingLeft: isInverseDirection, frame: 2)
                } else if normalizedFrame == 1 {
                    self.dog.dogState = .walkingSide(isFacingLeft: isInverseDirection, frame: 1)
                } else if normalizedFrame == 2 {
                    self.dog.dogState = .walkingSide(isFacingLeft: isInverseDirection, frame: 2)
                } else {
                    self.dog.dogState = .walkingSide(isFacingLeft: isInverseDirection, frame: 3)
                }
            case .y:
                if normalizedFrame == 0 {
                    self.dog.dogState = isInverseDirection ? .walkingUp(frame: 2) : .walkingDown(frame: 2)
                } else if normalizedFrame == 1 {
                    self.dog.dogState = isInverseDirection ? .walkingUp(frame: 1) : .walkingDown(frame: 1)
                } else if normalizedFrame == 2 {
                    self.dog.dogState = isInverseDirection ? .walkingUp(frame: 2) : .walkingDown(frame: 2)
                } else {
                    self.dog.dogState = isInverseDirection ? .walkingUp(frame: 3) : .walkingDown(frame: 3)
                }
            }
                       
            frame += 1
        }
        
        func doMovement() {
            let tentativeValue = dogOrigin(forAxis: axis) + (isInverseDirection ? -movementPerFrame : movementPerFrame)
            let wouldExceedDestination = isInverseDirection ? tentativeValue <= point : tentativeValue >= point
            
            if wouldExceedDestination {
                switch axis {
                case .x:
                    self.dog.frame.origin.x = point
                case .y:
                    self.dog.frame.origin.y = point
                }
                
                switch axis {
                case .x:
                    self.dog.dogState = .walkingSide(isFacingLeft: isInverseDirection, frame: 2)
                case .y:
                    self.dog.dogState = isInverseDirection ? .walkingUp(frame: 2) : .walkingDown(frame: 2)
                }
                
                invalidateDogTimers()
                onCompletion?()
            } else {
                switch axis {
                case .x:
                    self.dog.frame.origin.x = tentativeValue
                case .y:
                    self.dog.frame.origin.y = tentativeValue
                }
            }
        }
        
        timer1 = Timer.scheduledTimer(withTimeInterval: frameDelay, repeats: true) { timer in
            doFlipBook()
        }
        
        timer2 = Timer.scheduledTimer(withTimeInterval: movementDelay, repeats: true) { timer in
            doMovement()
        }
        
        // Make first ticks immediate
        timer1?.fire()
        timer2?.fire()
    }
    
    func sleep(duration: TimeInterval, onCompletion: DogActionCompletion) {
        invalidateDogTimers()
        
        var frame = 1
        let frameDuration: TimeInterval = 1.0
        let framesToShow = Int((duration / frameDuration).rounded())
        
        timer1 = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true, block: { [weak self] timer in
            guard let strongSelf = self else { return }
            
            if frame > framesToShow {
                strongSelf.invalidateDogTimers()
                onCompletion?()
                return
            }
            
            let normalizedFrame = frame % 2
            strongSelf.dog.dogState = .sleeping(frame: normalizedFrame + 1)
            
            frame += 1
        })
        
        timer1?.fire()
    }
    
    func bork() {
        isPlayingOutUserInteraction = true
        dirtWasSelected = false
        startDirtExpirationCountdown(seconds: 2)
        invalidateDogTimers()
        
        let tenPercentChance = Bool.percentChance(10)
        
        self.dog.dogState = .sittingFront(frame: 1)
        
        delay(0.5) {
            if tenPercentChance {
                self.chatBox.alpha = 1.0
                
                // Low chance of Japanese text, わたしはロドワッフルです
                let twentyPercentChance = Bool.percentChance(20)
                self.chatBox.image = MiscSprite.chatBox(frame: 1, isJapanese: twentyPercentChance)
                self.sizeAndPositionChatBox(isJapanese: twentyPercentChance)
                
                delay(0.5) {
                    self.chatBox.image = MiscSprite.chatBox(frame: 2, isJapanese: twentyPercentChance)
                    
                    delay(0.5) {
                        self.chatBox.image = MiscSprite.chatBox(frame: 3, isJapanese: twentyPercentChance)
                        
                        delay(2.5) {
                            self.chatBox.alpha = 0.0
                            
                            delay(1.0) {
                                self.isPlayingOutUserInteraction = false
                                
                                self.idle(dogIsFacingLeft: Bool.percentChance(50), duration: self.randomIdleDuration()) {
                                    self.doNewDogAIAction()
                                }
                            }
                        }
                    }
                }
            } else {
                self.dog.dogState = .bark
                MusicBox.shared.play(music: .bork)
                
                delay(0.5) {
                    self.dog.dogState = .sittingFront(frame: 1)
                    
                    delay(1.0) {
                        self.isPlayingOutUserInteraction = false
                        
                        self.idle(dogIsFacingLeft: Bool.percentChance(50), duration: self.randomIdleDuration()) {
                            self.doNewDogAIAction()
                        }
                    }
                }
            }
        }
    }
    
    func pantHappily(onCompletion: DogActionCompletion) {
        invalidateDogTimers()
        
        let flipBookDuration: TimeInterval = 3.0
        let totalFrames = Int(flipBookDuration / frameDelay)
        var frame = 1
        
        timer1 = Timer.scheduledTimer(withTimeInterval: frameDelay, repeats: true) { [weak self] timer in
            guard let strongSelf = self else { return }
            
            if frame > totalFrames {
                strongSelf.invalidateDogTimers()
                onCompletion?()
                return
            }
            
            let normalizedFrame = frame % 2
            strongSelf.dog.dogState = .happy(frame: normalizedFrame + 1)
            
            frame += 1
        }
        
        timer1?.fire()
        
        MusicBox.shared.play(music: .pant)
    }
    
    func lookAround(dogIsFacingLeft: Bool, onCompletion: DogActionCompletion) {
        invalidateDogTimers()
        
        let totalFrames = 4
        var frame = 1
        
        self.dog.dogState = .walkingSide(isFacingLeft: dogIsFacingLeft, frame: 1)

        timer1 = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { [weak self] timer in
            guard let strongSelf = self else { return }
            
            if frame > totalFrames {
                strongSelf.invalidateDogTimers()
                onCompletion?()
                return
            }
            
            let normalizedLookie = frame % 2
            
            if normalizedLookie == 0 {
                strongSelf.dog.transform = .identity
            } else {
                strongSelf.dog.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
            
            frame += 1
        })
    }
    
    func sitDown(direction: DogSittingDirection, duration: TimeInterval, wagSpeed: TimeInterval, onCompletion: DogActionCompletion) {
        invalidateDogTimers()
        
        var frame = 1
        let frameDuration = wagSpeed
        
        let framesToShow = Int((duration / frameDuration).rounded())
        
        timer1 = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true, block: { [weak self] timer in
            guard let strongSelf = self else { return }
            
            if frame > framesToShow {
                strongSelf.invalidateDogTimers()
                onCompletion?()
                return
            }
            
            let normalizedFrame = frame % 2
            
            switch direction {
            case .front:
                strongSelf.dog.dogState = .sittingFront(frame: normalizedFrame + 1)
            case .left:
                strongSelf.dog.dogState = .sittingSide(isFacingLeft: true, frame: normalizedFrame + 1)
            case .right:
                strongSelf.dog.dogState = .sittingSide(isFacingLeft: false, frame: normalizedFrame + 1)
            }
            
            frame += 1
            
        })
        
        timer1?.fire()
    }
    
    func jumpInPlace(onCompletion: DogActionCompletion) {
        let movementFramesPerSecond = 24
        let movementDelay = TimeInterval(1.0) / TimeInterval(movementFramesPerSecond)
        
        let transformMultiplierValuesPerFrame: [CGFloat] = [-1, -2, -3, -4, -5, -6, -5, -4, -3, -2, -1, 0].map { $0 * 2 }
        var frame = 1
        
        timer1 = Timer.scheduledTimer(withTimeInterval: movementDelay, repeats: true, block: { [weak self] timer in
            guard let strongSelf = self else { return }
            
            if frame > transformMultiplierValuesPerFrame.count - 1 {
                strongSelf.dog.transform = .identity
                strongSelf.invalidateDogTimers()
                onCompletion?()
                return
            }
            
            let multiplier = transformMultiplierValuesPerFrame[frame]
            strongSelf.dog.transform = CGAffineTransform(translationX: 0.0, y: multiplier)
            
            frame += 1
        })
        
        timer1?.fire()
    }
    
    func dig(approachedDirtFromLeft: Bool, times: Int = 5, onCompletion: DogActionCompletion) {
        // If this was a random action and we didn't have time to prepare the feedback generator, do so now
        if impactGenerator == nil {
            impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
            impactGenerator?.prepare()
        }
        
        let frameDuration: TimeInterval = 0.5
        var frame = 1
        
        timer1 = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true, block: { [weak self] timer in
            guard let strongSelf = self else { return }
            
            if frame > times {
                strongSelf.invalidateDogTimers()
                strongSelf.impactGenerator = nil
                onCompletion?()
                return
            }
            
            if let impactGenerator = strongSelf.impactGenerator {
                impactGenerator.impactOccurred(intensity: 0.35)
            } else {
                assertionFailure("Impact generator should be non-nil at this point")
            }
            
            let normalizedFrame = frame % 2
            strongSelf.dog.dogState = .digging(isFacingLeft: !approachedDirtFromLeft, frame: normalizedFrame + 1)

            frame += 1
        })
        
        timer1?.fire()
    }
    
    func interactWithDirt() {
        // Ensure the dirt is active (could be animating out) and that the user didn't already select it
        guard isDirtActive && !isPlayingOutUserInteraction else { return }
        
        impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
        impactGenerator?.prepare()
        
        dirtWasSelected = true
        isPlayingOutUserInteraction = true
        
        bringSubviewToFront(dirt)
        
        if let info = infoNeededToHandleDogAndDirtInSameColumn() {
            let dirtLocation = calculateDogDirtPosition(isApproachingDirtFromLeft: info.isApproachingDirtFromLeft)
            
            move(toPoint: self.dog.frame.origin.x + info.offset, onAxis: .x) { [weak self] in
                self?.move(toPoint: dirtLocation) { [weak self] in
                    self?.digUpSomething(approachedDirtFromLeft: info.isApproachingDirtFromLeft)
                }
            }
        } else {
            let isApproachingDirtFromLeft = dog.frame.origin.x < dirt.frame.origin.x
            let dirtLocation = calculateDogDirtPosition(isApproachingDirtFromLeft: isApproachingDirtFromLeft)
            
            self.move(toPoint: dirtLocation) { [weak self] in
                self?.digUpSomething(approachedDirtFromLeft: isApproachingDirtFromLeft)
            }
        }
    }
    
    private func digUpSomething(approachedDirtFromLeft: Bool) {
        self.dig(approachedDirtFromLeft: approachedDirtFromLeft, onCompletion: nil)
        
        delay(1.75) {
            let totalDigs = UserDefaults.standard.integer(forKey: DefaultsKey.totalDigs)
            
            let rolledABandana: Bool = {
                // If we've unlocked all the bandanas, always roll bones henceforth
                if Bandana.lockedBandanas.isEmpty {
                    return false
                }
                
                if totalDigs == 0 {
                    // First dig! Always will be a bone.
                    return false
                } else if totalDigs == 1 {
                    // Second dig! Always will be a bandana.
                    return true
                } else {
                    // Everything after the second dig is a random chance
                    return Bool.percentChance(20)
                }
            }()
            
            UserDefaults.standard.set(totalDigs + 1, forKey: DefaultsKey.totalDigs)
            
            if rolledABandana {
                self.showBandanaUnlockAnimation(approachedDirtFromLeft: approachedDirtFromLeft)
            } else {
                self.startConsumingBone(approachedDirtFromLeft: approachedDirtFromLeft)
            }
        }
    }
    
    private func showBandanaUnlockAnimation(approachedDirtFromLeft: Bool) {
        guard !Bandana.lockedBandanas.isEmpty else { fatalError("Should not be called if all bandanas are already unlocked") }
        
        let bandanaUnlocked = Bandana.lockedBandanas.randomElement()!
        
        self.bandana.image = Bandana.sprite(forBandana: bandanaUnlocked)
        self.bandana.frame.origin = CGPoint(x: self.dirt.frame.origin.x + 20.0, y: self.dirt.frame.origin.y + 14.0)
        
        // Show bandana and hide dirt
        self.toggleImageViewWithAnimation(self.dirt, show: false)
        self.toggleImageViewWithAnimation(self.bandana, show: true)
        
        delay(0.5) {
            let currentPoint = self.dog.frame.origin
            let offset: CGFloat = approachedDirtFromLeft ? 20.0 : -24.0
            let newPoint = CGPoint(x: currentPoint.x + offset, y: currentPoint.y)
                
            self.move(toPoint: newPoint) {
                self.dog.dogState = .sittingFront(frame: 1)
                
                delay(0.5) {
                    self.dog.dogState = .bendDown

                    delay(1.0) {
                        self.bandana.frame.origin.x -= 2.0
                        self.bandana.frame.origin.y -= 70.0
                        self.dog.dogState = .sittingFront(frame: 1)
                        
                        delay(0.05) {
                            // If there's only one left, we're about to unlock that one, so we unlocked all!
                            let didUnlockAllBandanas = Bandana.lockedBandanas.count == 1
                            
                            if didUnlockAllBandanas {
                                // Have we unlocked all? If so, hurray! 🥳🎉🎊🍾🧇🧣
                                MusicBox.shared.play(music: .unlockedAll)
                                
                                self.playUnlockedAllBandanaFlashDance()
                            } else {
                                // Just unlocked one? Okay still celebrate a bit. 🎺
                                MusicBox.shared.play(music: .unlocked)
                            }
                        }
                        
                        self.hoverBandanaInPlace {
                            delay(0.1) {
                                self.bandana.alpha = 0.0
                                self.bandana.transform = .identity
                                
                                Bandana.unlock(bandanaUnlocked)
                                
                                // If they just got an awesome bandana, might be a great time to prompt for a review, but give them a second so we're not too jumpy
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6)) {
                                    (self.window?.windowScene?.delegate as? SceneDelegate)?.maybeRequestReview()
                                }
                                
                                delay(1.0) {
                                    self.dirtWasSelected = false
                                    self.isDirtActive = false
                                    self.isPlayingOutUserInteraction = false
                                    
                                    self.idle(dogIsFacingLeft: Bool.percentChance(50), duration: self.randomIdleDuration()) {
                                        self.doNewDogAIAction()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
        
    private func startConsumingBone(approachedDirtFromLeft: Bool) {
        self.bone.frame.origin = CGPoint(x: self.dirt.frame.origin.x, y: self.dirt.frame.origin.y + 4.0)
        
        // Show bone and hide dirt
        self.toggleImageViewWithAnimation(self.dirt, show: false)
        self.toggleImageViewWithAnimation(self.bone, show: true)
        
        delay(0.5) {
            let currentPoint = self.dog.frame.origin
            let offset: CGFloat = approachedDirtFromLeft ? 20.0 : -24.0
            let newPoint = CGPoint(x: currentPoint.x + offset, y: currentPoint.y)
                
            self.move(toPoint: newPoint) {
                self.dog.dogState = .sittingFront(frame: 1)
                
                delay(0.5) {
                    self.dog.dogState = .bendDown

                    delay(1.0) {
                        self.bone.alpha = 0.0

                        delay(0.25) {
                            self.dog.dogState = .sittingFront(frame: 1)
                            
                            delay(0.25) {
                                self.pantHappily {
                                    self.isPlayingOutUserInteraction = false
                                    self.dirtWasSelected = false
                                    self.isDirtActive = false
                                    
                                    self.idle(dogIsFacingLeft: Bool.percentChance(50), duration: self.randomIdleDuration()) {
                                        self.doNewDogAIAction()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func hoverBandanaInPlace(onCompletion: DogActionCompletion) {
        let movementFramesPerSecond = 24
        let movementDelay = TimeInterval(1.0) / TimeInterval(movementFramesPerSecond)
        
        let transformMultiplierValuesPerFrame: [CGFloat] = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 17, 15, 13, 11, 9, 7, 5, 3, 2, 1, -1, -3, -5, -7, -9, -11, -13, -15, -17, -19, -17, -15, -13, -11, -9, -7, -5, -3, -2, -1, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 17, 15, 13, 11, 9, 7, 5, 3, 1, -1, -3, -5, -7, -9, -11, -13, -15, -17, -19, -17, -15, -13, -11, -9, -7, -5, -3, -1, 0].map { $0 * 0.16 }
        var frame = 1
        
        delay(0.1) {
            self.timer1 = Timer.scheduledTimer(withTimeInterval: movementDelay, repeats: true, block: { [weak self] timer in
                guard let strongSelf = self else { return }
                
                if frame > transformMultiplierValuesPerFrame.count - 1 {
                    strongSelf.bandana.transform = .identity
                    strongSelf.invalidateDogTimers()
                    onCompletion?()
                    return
                }
                
                let multiplier = transformMultiplierValuesPerFrame[frame]
                strongSelf.bandana.transform = CGAffineTransform(translationX: 0.0, y: multiplier)
                
                frame += 1
            })
            
            self.timer1?.fire()
        }
    }
    
    private func idle(dogIsFacingLeft: Bool, duration: TimeInterval, onCompletion: DogActionCompletion) {
        UIAccessibility.post(notification: .screenChanged, argument: dog)
        
        dog.dogState = .walkingSide(isFacingLeft: dogIsFacingLeft, frame: 2)
        
        delay(duration) {
            onCompletion?()
        }
    }
    
    /// 🧣 💥 🧣 💥 🧣 💥 🧣 💥 🎵
    func playUnlockedAllBandanaFlashDance() {
        flashAllBandanas {
            delay(0.5) {
                self.flashEachBandana {
                    self.flashAllBandanas(onCompletion: nil)
                }
            }
        }
    }
    
    func flashAllBandanas(onCompletion: DogActionCompletion) {
        inventoryBar.bandanaImageViews.forEach { $0.alpha = 0.0 }
        
        delay(0.4) {
            self.inventoryBar.bandanaImageViews.forEach { $0.alpha = 1.0 }
            
            delay(0.4) {
                self.inventoryBar.bandanaImageViews.forEach { $0.alpha = 0.0 }
                
                delay(0.4) {
                    self.inventoryBar.bandanaImageViews.forEach { $0.alpha = 1.0 }
                    
                    delay(0.4) {
                        self.inventoryBar.bandanaImageViews.forEach { $0.alpha = 0.0 }
                        
                        delay(0.4) {
                            self.inventoryBar.bandanaImageViews.forEach { $0.alpha = 1.0 }
                            onCompletion?()
                        }
                    }
                }
            }
        }
    }
    
    func flashEachBandana(onCompletion: DogActionCompletion) {
        inventoryBar.bandanaImageViews[0].alpha = 0.0
        
        delay(0.2) {
            self.inventoryBar.bandanaImageViews[0].alpha = 1.0
            
            delay(0.2) {
                self.inventoryBar.bandanaImageViews[1].alpha = 0.0
                
                delay(0.2) {
                    self.inventoryBar.bandanaImageViews[1].alpha = 1.0
                    
                    delay(0.2) {
                        self.inventoryBar.bandanaImageViews[2].alpha = 0.0
                        
                        delay(0.2) {
                            self.inventoryBar.bandanaImageViews[2].alpha = 1.0
                            
                            delay(0.2) {
                                self.inventoryBar.bandanaImageViews[3].alpha = 0.0
                                
                                delay(0.2) {
                                    self.inventoryBar.bandanaImageViews[3].alpha = 1.0
                                    
                                    delay(0.2) {
                                        self.inventoryBar.bandanaImageViews[4].alpha = 0.0
                                        
                                        delay(0.2) {
                                            self.inventoryBar.bandanaImageViews[4].alpha = 1.0
                                            
                                            delay(0.2) {
                                                self.inventoryBar.bandanaImageViews[5].alpha = 0.0
                                                
                                                delay(0.2) {
                                                    self.inventoryBar.bandanaImageViews[5].alpha = 1.0
                                                    
                                                    delay(0.2) {
                                                        self.inventoryBar.bandanaImageViews[6].alpha = 0.0
                                                        
                                                        delay(0.2) {
                                                            self.inventoryBar.bandanaImageViews[6].alpha = 1.0
                                                            
                                                            delay(0.2) {
                                                                self.inventoryBar.bandanaImageViews[7].alpha = 0.0
                                                                
                                                                delay(0.2) {
                                                                    self.inventoryBar.bandanaImageViews[7].alpha = 1.0
                                                                    onCompletion?()
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func dogOrigin(forAxis axis: DogAxis) -> CGFloat {
        switch axis {
        case .x:
            return self.dog.frame.origin.x
        case .y:
            return self.dog.frame.origin.y
        }
    }
    
    private func invalidateDogTimers() {
        self.timer1?.invalidate()
        self.timer2?.invalidate()
        
        self.timer1 = nil
        self.timer2 = nil
    }
    
    private func randomDirtLocation() -> CGPoint {
        let leftInsets: Int = 30 + Int(roamingAreaInsets.left)
        let rightInsets: Int = 60 + Int(roamingAreaInsets.right) // Add a bit more for right side because we travel right after digging
        let topInset: Int = 30 + Int(roamingAreaInsets.top)
        let bottomInset: Int = 30 + Int(DogProperties.spriteSize) + Int(roamingAreaInsets.bottom)
        
        let xRange = leftInsets ..< (Int(bounds.width) - rightInsets)
        let yRange = topInset ..< Int(bounds.height) - bottomInset
        
        let x = xRange.randomElement()!
        let y = yRange.randomElement()!
        
        let prospectivePoint = CGPoint(x: x, y: y)
        
        // Create an area around the dog where dirt can't spawn
        let dogBuffer: CGFloat = 75.0
        let expandedDogArea = dog.frame.insetBy(dx: -dogBuffer, dy: -dogBuffer) // Adds n/2 on each side
        
        if expandedDogArea.contains(prospectivePoint) {
            // Re-roll
            return randomDirtLocation()
        } else {
            return prospectivePoint
        }
    }
    
    private func startDirtCooldown() {
        isDirtCooldownActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.isDirtCooldownActive = false
        }
    }
    
    func startDirtExpirationCountdown(seconds: Int) {
        // Give user n seconds to interact with dirt
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) {
            guard !self.dirtWasSelected else { return }
            
            self.isDirtActive = false
            self.startDirtCooldown()
            self.toggleImageViewWithAnimation(self.dirt, show: false)
        }
    }
    
    func toggleDebugBoxes() {
        if debugBoxesActive {
            dog.backgroundColor = .clear
            dirt.backgroundColor = .clear
            bone.backgroundColor = .clear
        } else {
            dog.backgroundColor = .systemYellow.withAlphaComponent(0.3)
            dirt.backgroundColor = .systemGreen.withAlphaComponent(0.3)
            bone.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        }
        
        debugBoxesActive.toggle()
    }
    
    private func toggleImageViewWithAnimation(_ imageView: UIImageView, show: Bool) {
        if show {
            imageView.transform = CGAffineTransform(translationX: 0.0, y: 3.0).scaledBy(x: 1.0, y: 0.5)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveLinear, .preferredFramesPerSecond30], animations: {
            if show {
                imageView.alpha = 1.0
                imageView.transform = .identity
            } else {
                imageView.alpha = 0.0
                imageView.transform = CGAffineTransform(translationX: 0.0, y: 3.0).scaledBy(x: 1.0, y: 0.5)
            }
        }, completion: { didComplete in
            imageView.transform = .identity
        })
    }

    private func calculateDogDirtPosition(isApproachingDirtFromLeft: Bool) -> CGPoint {
        let x: CGFloat = {
            if isApproachingDirtFromLeft {
                return dirt.frame.origin.x - 20.0
            } else {
                return dirt.frame.origin.x + 24.0
            }
        }()
        
        let y = dirt.frame.origin.y - 26.0
       
        return CGPoint(x: x, y: y)
    }
    
    /// If the dog and the dirt are in the same column, returns the offset the dog needs to go the the right (or negative if left) to begin movement properly, as well as whether the dog is approaching the dirt from the left. (Nil if not in same column.)
    /// - Note: If the dog is in the same column but *above* the dirt, it wouldn't look weird, so this doesn't apply
    private func infoNeededToHandleDogAndDirtInSameColumn() -> (offset: CGFloat, isApproachingDirtFromLeft: Bool)? {
        let isOccupyingSameVerticalColumn = (dog.frame.origin.x ... dog.frame.maxX).contains(dirt.frame.origin.x) || (dog.frame.origin.x ... dog.frame.maxX).contains(dirt.frame.maxX) && dog.frame.origin.y > dirt.frame.origin.y
        guard isOccupyingSameVerticalColumn else { return nil }
        
        let dogX = dog.frame.origin.x
        let isDogLeftOfDirt = dogX < dirt.frame.origin.x
        
        // Note that since there's whitespace in the sprite, we allow/want them to overlap slightly
        let fudge: CGFloat = 15.0
        
        if isDogLeftOfDirt {
            let tentativeOffset = -(dog.frame.maxX - dirt.frame.origin.x)
            
            if dogX + tentativeOffset < 0.0 {
                // Would go off the left side of the screen, so go right
                return (dirt.frame.maxX - dogX - fudge, false)
            } else {
                return (tentativeOffset + fudge, true)
            }
        } else {
            let tentativeOffset = dirt.frame.maxX - dogX

            // Would go off the right side of the screen, so go left
            if dogX + tentativeOffset > bounds.width {
                return (-(dog.frame.maxX - dirt.frame.origin.x) + fudge, true)
            } else {
                return (tentativeOffset - fudge, false)
            }
        }
    }
    
    private func randomIdleDuration() -> TimeInterval {
        return TimeInterval((4 ... 8).randomElement()!)
    }
    
    func inventoryBarHeight() -> CGFloat {
        if safeAreaInsets.bottom != 0.0 {
            // This is a certifiable bad idea, but safe area insets visually add a bit too much to the bottom, so hardcode this
            return 16.0 + InventoryBar.baseHeight
        } else {
            return InventoryBar.baseHeight
        }
    }
    
    // MARK: - State Transitions
    
    private func doNewDogAIAction() {
        // If the user selected the dirt, don't interrupt their diggin'! (Or any other manual actions)
        guard !isPlayingOutUserInteraction else { return }
        
        // Allow the dog to open the app icon settings if A) there is something that can respond to it (this isn't the case on the individual DogVC screen) and B) we're still displayed on screen (have a window) otherwise we don't want the dog adding VCs in the background
        let allowOpenAppIcon = tapOnAppIconCellDelegate != nil && window != nil
        
        let actionToPerform = DogAIAction.rollDice(currentDogPosition: self.dog.frame.origin, dogIsFacingLeft: self.dog.dogState.isFacingLeft, inArea: self.bounds.size, insets: roamingAreaInsets, rectsToAvoid: [self.dirt.frame], allowOpenAppIcon: allowOpenAppIcon)
                
        switch actionToPerform {
        case .walk(let destination):
            move(toPoint: destination) { [weak self] in
                guard let strongSelf = self else { return }
                guard !strongSelf.isPlayingOutUserInteraction else { return }
                strongSelf.idle(dogIsFacingLeft: Bool.percentChance(50), duration: strongSelf.randomIdleDuration()) { [weak self] in
                    self?.doNewDogAIAction()
                }
            }
        case .sleep(let duration):
            sleep(duration: duration) { [weak self] in
                guard let strongSelf = self else { return }
                guard !strongSelf.isPlayingOutUserInteraction else { return }
                strongSelf.idle(dogIsFacingLeft: Bool.percentChance(50), duration: strongSelf.randomIdleDuration()) { [weak self] in
                    self?.doNewDogAIAction()
                }
            }
        case .lookAround(let dogIsFacingLeft):
            lookAround(dogIsFacingLeft: dogIsFacingLeft) { [weak self] in
                guard let strongSelf = self else { return }
                guard !strongSelf.isPlayingOutUserInteraction else { return }
                strongSelf.idle(dogIsFacingLeft: Bool.percentChance(50), duration: strongSelf.randomIdleDuration()) { [weak self] in
                    self?.doNewDogAIAction()
                }
            }
        case .dig(let times):
            dig(approachedDirtFromLeft: Bool.percentChance(50), times: times) { [weak self] in
                guard let strongSelf = self else { return }
                guard !strongSelf.isPlayingOutUserInteraction else { return }
                strongSelf.idle(dogIsFacingLeft: Bool.percentChance(50), duration: strongSelf.randomIdleDuration()) { [weak self] in
                    self?.doNewDogAIAction()
                }
            }
        case .sitDown(let direction, let duration, let wagSpeed):
            sitDown(direction: direction, duration: duration, wagSpeed: wagSpeed) { [weak self] in
                guard let strongSelf = self else { return }
                guard !strongSelf.isPlayingOutUserInteraction else { return }
                strongSelf.idle(dogIsFacingLeft: Bool.percentChance(50), duration: strongSelf.randomIdleDuration()) {
                    self?.doNewDogAIAction()
                }
            }
        case .openAppIcon:
            tapOnAppIconCellDelegate?.dogWantsToTapOnAppIconCell { [weak self] in
                self?.moveBackToCenter { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.idle(dogIsFacingLeft: Bool.percentChance(50), duration: strongSelf.randomIdleDuration()) { [weak self] in
                        self?.doNewDogAIAction()
                    }
                }
            }
        }
    }
    
    private func sizeAndPositionChatBox(isJapanese: Bool) {
        let width: CGFloat = isJapanese ? 224.0 : 206.0
        let height: CGFloat = 32.0
        let verticalSpacing: CGFloat = 10.0
        
        // Don't want it to go off the right side
        let x: CGFloat = {
            let tentativeX = dog.frame.origin.x
            let sideSpacing: CGFloat = 16.0
            let endPoint = tentativeX + width + sideSpacing
            
            if endPoint < bounds.width {
                return tentativeX
            } else {
                let exceededBy = endPoint - bounds.width
                return tentativeX - exceededBy
            }
        }()
        
        chatBox.frame = CGRect(x: x, y: dog.frame.origin.y - verticalSpacing - height, width: width, height: height)
    }
}

// MARK: - Gestures / Target Action

extension DogPark {
    @objc private func tapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let roundedTouchPoint = tapGestureRecognizer.location(in: self).rounded()
        
        if dog.frame.contains(roundedTouchPoint) {
            bork()
        } else if dirt.frame.contains(roundedTouchPoint) {
            interactWithDirt()
        }
    }
    
    @objc private func swiped(swipeGestureRecognizer: UISwipeGestureRecognizer) {
        // Add a hit slop area around the dog to make swiping easier
        let expandedDogArea = dog.frame.insetBy(dx: -15.0, dy: -15.0)
        let swipeLocation = swipeGestureRecognizer.location(in: self)
        
        guard expandedDogArea.contains(swipeLocation) else { return }
        
        triggerDogPet()
    }
    
    @objc private func petDogA11Y() -> Bool {
        triggerDogPet()
        return true
    }
    
    private func triggerDogPet() {
        isPlayingOutUserInteraction = true
        dirtWasSelected = false
        startDirtExpirationCountdown(seconds: 2)
        
        pantHappily {
            self.isPlayingOutUserInteraction = false
            
            self.idle(dogIsFacingLeft: Bool.percentChance(50), duration: self.randomIdleDuration(), onCompletion: {
                self.doNewDogAIAction()
            })
        }
    }
}

enum DogAxis {
    case x, y
}

protocol TapOnAppIconCellDelegate: AnyObject {
    func dogWantsToTapOnAppIconCell(onCompletion: DogActionCompletion)
}
