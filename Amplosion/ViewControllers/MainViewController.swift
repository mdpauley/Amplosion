//
//  ViewController2.swift
//  ViewController2
//
//  Created by Christian Selig on 2021-08-25.
//

import UIKit
import AVFoundation

class MainViewController: IndentedTitleViewController, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    var dogPark: DogPark?
    
    var settings: [Setting] = MainViewController.sufficientRoomForDogSettings
    
    static let sufficientRoomForDogSettings: [Setting] = [.howToEnable, .appIcon, .allowlist, .about]
    static let insufficientRoomForDogSettings: [Setting] = [.howToEnable, .appIcon, .allowlist, .about, .dog]
    
    lazy var dataSource: UITableViewDiffableDataSource<Int, Setting> = {
        let dataSource = UITableViewDiffableDataSource<Int, Setting>(tableView: tableView) { tableView, indexPath, setting in
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AmplosionStatsCell", for: indexPath) as! AmplosionStatsTableViewCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
                var content = UIListContentConfiguration.valueCell()
                content.text = setting.title
                content.textProperties.font = content.textProperties.font.rounded()
                content.image = setting.icon
                content.imageProperties.reservedLayoutSize = CGSize(width: UIListContentConfiguration.ImageProperties.standardDimension, height: UIListContentConfiguration.ImageProperties.standardDimension)
                cell.contentConfiguration = content
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        }
        
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Amplosion"
        
        tableView.delegate = self
        tableView.register(AmplosionStatsTableViewCell.self, forCellReuseIdentifier: "AmplosionStatsCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        view.addSubview(tableView)
        
        addSettings()
        
        NotificationCenter.default.addObserver(self, selector: #selector(unlockedBandanaNotificationReceived(notification:)), name: .unlockedBandana, object: nil)
        
        
        for _ in 0 ..< 58 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "nbcnews.com")
        }
            
        for _ in 0 ... 39 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "reddit.com")
        }
        
        for _ in 0 ... 12 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "cnet.com")
        }
        
        for _ in 0 ... 12 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "cbc.ca")
        }
        
        for _ in 0 ... 19 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "techcrunch.com")
        }
        
        for _ in 0 ... 7 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "globalnews.com")
        }
        
        for _ in 0 ... 6 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "bgr.com")
        }
        
        for _ in 0 ... 19 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "forbes.com")
        }
        
        for _ in 0 ... 24 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "techradar.com")
        }
        
        for _ in 0 ... 21 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "tomsguide.com")
        }
        
        for _ in 0 ... 36 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "news.google.com")
        }
        
        for _ in 0 ... 29 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "usatoday.com")
        }
        
        for _ in 0 ... 23 {
            UserDefaults.groupSuite.incrementAmplosionStat(forHostname: "bbc.co.uk")
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
        // DogPark's presence is determined by the size of this view controller, so add/remove it here
        reconfigureDogParkIfNeeded()
        
        if let dogPark = dogPark {
            let roamingInsetsTop = tableView.contentSize.height - tableView.contentOffset.y - 20.0
            let roamingAreaInsets = UIEdgeInsets(top: roamingInsetsTop, left: 0.0, bottom: dogPark.inventoryBarHeight(), right: 0.0)
            
            dogPark.roamingAreaInsets = roamingAreaInsets
            dogPark.frame = view.bounds
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Fade the table deselection as the view controller is popped
        if let selectedIndexPath = tableView.indexPathForSelectedRow, let transitionCoordinator = transitionCoordinator {
            transitionCoordinator.animate { context in
                self.tableView.deselectRow(at: selectedIndexPath, animated: true)
            } completion: { context in
                if context.isCancelled {
                    self.tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
                }
            }
        }
    }
    
    private func reconfigureDogParkIfNeeded() {
        let shouldDogBeOnSeparateScreen = shouldDogBeOnSeparateScreen()
        
        if !shouldDogBeOnSeparateScreen {
            // iOSBUG: If you don't manually size the navigation bar the safe area insets will be wrong
            navigationController!.navigationBar.sizeToFit()
            tableView.contentOffset.y = -self.view.safeAreaInsets.top
        }
            
        tableView.isScrollEnabled = shouldDogBeOnSeparateScreen
        
        settings = shouldDogBeOnSeparateScreen ? MainViewController.insufficientRoomForDogSettings : MainViewController.sufficientRoomForDogSettings
        
        addSettings()
        
        if !shouldDogBeOnSeparateScreen {
            if self.dogPark?.superview != nil {
                self.dogPark?.removeFromSuperview()
            }
            
            let dogPark = DogPark()
            dogPark.inventoryBar.delegate = self
            dogPark.tapOnAppIconCellDelegate = self
            view.addSubview(dogPark)
            self.dogPark = dogPark
        } else if shouldDogBeOnSeparateScreen, let dogPark = dogPark {
            dogPark.removeFromSuperview()
            self.dogPark = nil
        }
    }
    
    func shouldDogBeOnSeparateScreen() -> Bool {
        var contentHeight = tableView.contentSize.height
        
        // Our content height evaluation should not include the size of the optional row, because we're deciding if that row should exist or not
        if settings.contains(.dog) {
            contentHeight -= tableView.rectForRow(at: IndexPath(row: 4, section: 1)).height
        }
        
        if contentHeight > view.bounds.height * 0.55 {
            // If table takes majority of view. This can happen in landscape, on short iOS devices, or when accessibility text sizes are high
            return true
        } else {
            return false
        }
    }
    
    // MARK: - UITableView
    
    private func addSettings() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Setting>()
        
        snapshot.appendSections([0])
        snapshot.appendItems([.amplosionStats], toSection: 0)
        
        snapshot.appendSections([1])
        snapshot.appendItems(settings, toSection: 1)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // The first section is weirdly close to the large navigation title, space that out a bit. This also makes it look better in landscape.
        return section == 0 ? 8.0 : 5.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Required in order for header height to take effect
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let setting = dataSource.itemIdentifier(for: indexPath) else { return }

        switch setting {
        case .amplosionStats:
            break
        case .howToEnable:
            // Doesn't work with the nice viewDidAppear API, do manually
            tableView.deselectRow(at: indexPath, animated: true)
            
            let howToEnableNavigationController = UINavigationController(rootViewController: HowToEnableViewController())
            howToEnableNavigationController.setToNonFullWidthInLandscape()
            
            navigationController?.present(howToEnableNavigationController, animated: true, completion: nil)
        case .appIcon:
            navigationController?.pushViewController(AppIconViewController(), animated: true)
        case .allowlist:
            navigationController?.pushViewController(AllowlistViewController(), animated: true)
        case .about:
            navigationController?.pushViewController(AboutViewController(), animated: true)
        case .dog:
            navigationController?.pushViewController(DogParkViewController(), animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? AmplosionStatsTableViewCell else { return }
        
        cell.convertButton.addTarget(self, action: #selector(convertButtonTapped(sender:)), for: .touchUpInside)
        cell.statsButton.addTarget(self, action: #selector(statsButtonTapped(sender:)), for: .touchUpInside)
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
                self.dogPark?.inventoryBar.alpha = Bandana.unlockedBandanas.isEmpty ? 0.0 : 1.0
            }, completion: nil)
        } else {
            dogPark?.inventoryBar.alpha = Bandana.unlockedBandanas.isEmpty ? 0.0 : 1.0
        }
        
        dogPark?.dog.updateForBandanaChange()
    }
    
    private func showDebugMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "🟨 Bounding Boxes", style: .default, handler: { [weak self] action in
            self?.dogPark?.toggleDebugBoxes()
        }))
        
        alertController.addAction(UIAlertAction(title: "🧣 Clear All Bandanas", style: .default, handler: { [weak self] action in
            UserDefaults.standard.removeObject(forKey: DefaultsKey.unlockedBandanas)
            self?.dogPark?.inventoryBar.selectedIndex = nil
            self?.dogPark?.inventoryBar.updateImageViews()
            self?.dogPark?.dog.updateForBandanaChange()
        }))
        
        // If unlocked all
        if Bandana.lockedBandanas.isEmpty {
            alertController.addAction(UIAlertAction(title: "🧦 Clear 1 Bandana", style: .default, handler: { [weak self] action in
                let rawBandanas = Bandana.ordered.dropLast().map { $0.rawValue }
                UserDefaults.standard.set(rawBandanas, forKey: DefaultsKey.unlockedBandanas)
                self?.dogPark?.inventoryBar.selectedIndex = nil
                self?.dogPark?.inventoryBar.updateImageViews()
                self?.dogPark?.dog.updateForBandanaChange()
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
    
    @objc private func convertButtonTapped(sender: UIButton) {
        let convertingAlertController = UIAlertController.createConvertingAlertController {
            let convertNavigationController = UINavigationController(rootViewController: ConvertViewController(totalAmplosions: UserDefaults.groupSuite.totalAmplosions()))
            self.present(convertNavigationController, animated: true, completion: nil)
        }
        
        present(convertingAlertController, animated: true, completion: nil)
    }
    
    @objc private func statsButtonTapped(sender: UIButton) {
        let statsNavigationController = UINavigationController(rootViewController: StatsViewController())
        present(statsNavigationController, animated: true, completion: nil)
    }
}

extension MainViewController: InventoryBarDelegate {
    func selectedBandana(atIndex index: Int) {
        dogPark?.dog.updateForBandanaChange()
    }
}

extension MainViewController: TapOnAppIconCellDelegate {
    func dogWantsToTapOnAppIconCell(onCompletion: DogActionCompletion) {
        guard let dogPark = dogPark else { fatalError("DogPark should be available if this was called") }
        guard let indexPath = dataSource.indexPath(for: .appIcon) else { fatalError("AppIcon cell should be retrievable") }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let cellFrameOnScreen = cell.convert(cell.bounds, to: self.view)
        let destinationY = cellFrameOnScreen.maxY - DogProperties.spriteSize - 8.0 // To look visually correct
        let destinationX = cellFrameOnScreen.origin.x + 85.0
        
        dogPark.move(toPoint: CGPoint(x: destinationX, y: destinationY)) {
            delay(0.5) {
                dogPark.jumpInPlace {
                    // Ensure that in the time it took to walk to this point/jump that the user didn't navigate away, in which case we don't want to throw another view controller over whatever they're doing
                    guard self.view.window != nil && self.presentedViewController == nil else {
                        onCompletion?()
                        return
                    }
                    
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    
                    delay(0.25) {
                        self.navigationController?.pushViewController(AppIconViewController(), animated: true)
                        
                        delay(0.5) {
                            onCompletion?()
                        }
                    }
                }
            }
        }
    }
}
