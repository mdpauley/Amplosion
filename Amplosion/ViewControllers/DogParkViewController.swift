//
//  DogParkViewController.swift
//  DogParkViewController
//
//  Created by Christian Selig on 2021-08-30.
//

import UIKit

/// Wraps `DogPark` as an individual view controller for use when it won't fit on the normal
class DogParkViewController: UIViewController, InventoryBarDelegate {
    var dogPark = DogPark()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Lord Waffles"

        view.backgroundColor = .systemBackground
                
        NotificationCenter.default.addObserver(self, selector: #selector(unlockedBandanaNotificationReceived(notification:)), name: .unlockedBandana, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.dogPark.superview != nil {
            self.dogPark.removeFromSuperview()
        }

        // Reset on every rotation/bounds change, this is a cheap and easy way to ensure the dog and objects never go off screen during rotation
        self.dogPark = DogPark()
        dogPark.inventoryBar.delegate = self
        view.addSubview(dogPark)

        let roamingAreaInsets = UIEdgeInsets(top: navigationController?.navigationBar.bounds.height ?? 0.0, left: 0.0, bottom: dogPark.inventoryBarHeight(), right: 0.0)
        
        dogPark.roamingAreaInsets = roamingAreaInsets
        dogPark.frame = view.bounds
    }
    
    // MARK: - Shake Device
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        showDebugMenu()
    }
    
    // MARK: - Other
    
    @objc private func unlockedBandanaNotificationReceived(notification: Notification) {
        if Bandana.unlockedBandanas.count == 1 {
            UIView.animate(withDuration: 1.5, delay: 0.25, options: [.curveLinear, .preferredFramesPerSecond30], animations: {
                self.dogPark.inventoryBar.alpha = Bandana.unlockedBandanas.isEmpty ? 0.0 : 1.0
            }, completion: nil)
        } else {
            dogPark.inventoryBar.alpha = Bandana.unlockedBandanas.isEmpty ? 0.0 : 1.0
        }
        
        dogPark.dog.updateForBandanaChange()
    }
    
    private func showDebugMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "🟨 Bounding Boxes", style: .default, handler: { [weak self] action in
            self?.dogPark.toggleDebugBoxes()
        }))
        
        alertController.addAction(UIAlertAction(title: "🧣 Clear All Bandanas", style: .default, handler: { [weak self] action in
            UserDefaults.standard.removeObject(forKey: DefaultsKey.unlockedBandanas)
            self?.dogPark.inventoryBar.selectedIndex = nil
            self?.dogPark.inventoryBar.updateImageViews()
            self?.dogPark.dog.updateForBandanaChange()
        }))
        
        // If unlocked all
        if Bandana.lockedBandanas.isEmpty {
            alertController.addAction(UIAlertAction(title: "🧦 Clear 1 Bandana", style: .default, handler: { [weak self] action in
                let rawBandanas = Bandana.ordered.dropLast().map { $0.rawValue }
                UserDefaults.standard.set(rawBandanas, forKey: DefaultsKey.unlockedBandanas)
                self?.dogPark.inventoryBar.selectedIndex = nil
                self?.dogPark.inventoryBar.updateImageViews()
                self?.dogPark.dog.updateForBandanaChange()
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        addiPadCompatibility(toAlertController: alertController)
        present(alertController, animated: true, completion: nil)
    }
    
    private func addiPadCompatibility(toAlertController alertController: UIAlertController) {
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0.0, height: 0.0)
    }
    
    func selectedBandana(atIndex index: Int) {
        dogPark.dog.updateForBandanaChange()
    }
}
