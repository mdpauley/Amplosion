//
//  AppIconViewController.swift
//  DogWalk
//
//  Created by Christian Selig on 2021-08-26.
//

import UIKit

struct AppIconStatus: Hashable {
    let appIcon: AppIcon
    let isCurrentAppIcon: Bool
}

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
            
        return image.withRenderingMode(renderingMode)
    }
}

class AppIconViewController: IndentedTitleViewController, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // We can't use the AppIcon enum directly, as enums are static and computed properties on them won't be factored into the diffable data source calculations, so have a pseudo wrapper
    lazy var appIconStatuses: [AppIconStatus] = createAppIconStatuses()
    
    lazy var dataSource: AppIconDataSource = {
        let dataSource = AppIconDataSource(tableView: tableView) { tableView, indexPath, appIconStatus in
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
            
            var contentConfig = UIListContentConfiguration.subtitleCell()
            
            contentConfig.text = appIconStatus.appIcon.title
            contentConfig.textProperties.font = contentConfig.textProperties.font.rounded()
            contentConfig.textToSecondaryTextVerticalPadding = 3.0
            
            contentConfig.image = appIconStatus.appIcon.thumbnail.imageWith(newSize: CGSize(width: 68.0, height: 68.0))
            
            // Add a bit of extra vertical height
            contentConfig.imageProperties.reservedLayoutSize = CGSize(width: 68.0, height: 96.0)
            
            contentConfig.secondaryText = appIconStatus.appIcon.subtitle
            contentConfig.secondaryTextProperties.color = .secondaryLabel
            
            cell.contentConfiguration = contentConfig
            
            cell.accessoryType = appIconStatus.isCurrentAppIcon ? .checkmark : .none
            
            cell.accessibilityHint = "Changes home screen app icon."
            cell.accessibilityLabel = appIconStatus.appIcon.accessibilityDescription
            
            return cell
        }
        
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "App Icon"
        
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.cellLayoutMarginsFollowReadableWidth = true
        view.addSubview(tableView)
        
        refreshAppIcons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    private func createAppIconStatuses() -> [AppIconStatus] {
        var appIconStatuses: [AppIconStatus] = []
        
        for unlockedIcon in AppIcon.unlockedIcons {
            let status = AppIconStatus(appIcon: unlockedIcon, isCurrentAppIcon: AppIcon.currentAppIcon == unlockedIcon)
            appIconStatuses.append(status)
        }
        
        return appIconStatuses
    }
    
    private func refreshAppIcons() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AppIconStatus>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(appIconStatuses, toSection: 0)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let appIconStatus = dataSource.itemIdentifier(for: indexPath) else { return }

        let alternateIconName: String? = appIconStatus.appIcon == .default ? nil : appIconStatus.appIcon.rawValue
        
        UIApplication.shared.setAlternateIconName(alternateIconName) { [weak self] error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                let alertController = UIAlertController(title: "Error Setting Icon :(", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                strongSelf.present(alertController, animated: true, completion: nil)
            } else {
                strongSelf.appIconStatuses = strongSelf.createAppIconStatuses()
                strongSelf.refreshAppIcons()
            }
        }
    }
}

class AppIconDataSource: UITableViewDiffableDataSource<Int, AppIconStatus> {
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Lightning ⚡️ icons done by Matthew Skiles, and doggy 🐶 icons done by Lux"
    }
}
