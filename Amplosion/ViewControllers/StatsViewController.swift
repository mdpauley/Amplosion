//
//  StatsViewController.swift
//  StatsViewController
//
//  Created by Christian Selig on 2021-09-03.
//

import UIKit

class StatsViewController: IndentedTitleViewController, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    var stats: [AmplosionStat] {
        return UserDefaults.groupSuite.amplosionStats()
    }
    
    lazy var dataSource: StatsDataSource = {
        let dataSource = StatsDataSource(tableView: tableView) { tableView, indexPath, stat in
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatCell", for: indexPath)
            var contentConfig = UIListContentConfiguration.valueCell()
            
            contentConfig.image = UIImage(systemName: "chart.bar.fill")
            contentConfig.imageProperties.tintColor = UIColor.tertiaryLabel
            
            contentConfig.text = stat.hostname
            contentConfig.textProperties.font = contentConfig.textProperties.font.rounded()
            
            contentConfig.secondaryText = stat.totalAmplosions.formatted()
            contentConfig.secondaryTextProperties.font = contentConfig.secondaryTextProperties.font.rounded(withWeight: .medium)
            
            cell.contentConfiguration = contentConfig
            cell.selectionStyle = .none
            return cell
        }
        
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Stats"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemTapped(sender:)))
        setRightBarButtonItems(animated: false)
        
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StatCell")
        tableView.cellLayoutMarginsFollowReadableWidth = true
        view.addSubview(tableView)
        
        refreshStats()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    private func refreshStats() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AmplosionStat>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(stats, toSection: 0)
        
        if stats.isEmpty {
            tableView.backgroundView = StatsViewController.createEmptyLabel()
        } else {
            tableView.backgroundView = nil
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    
        tableView.setEditing(editing, animated: animated)
        setRightBarButtonItems(animated: true)
    }
    
    static func createEmptyLabel() -> UILabel {
        let label = EmptyStateLabel()
        
        let mainAttributedString = NSMutableAttributedString(string: "A tumbleweed rolled by…\n", attributes: [.font: UIFont.preferredFont(forTextStyle: .headline).rounded(), .foregroundColor: UIColor.label])
        mainAttributedString.append(NSAttributedString(string: "After using Amplosion, Stats will how many times Amplosion activated for each website.\n\nStats are purely local and never leave the device (for more details see the open source codebase and/or the privacy policy).", attributes: [.font: UIFont.preferredFont(forTextStyle: .callout).rounded(), .foregroundColor: UIColor.secondaryLabel]))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.paragraphSpacing = 5.0
        
        mainAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mainAttributedString.length))
        
        label.attributedText = mainAttributedString
        
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }
    
    @objc private func clearAllBarButtonItemTapped(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to clear all items? This cannot be undone.", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Clear All", style: .destructive, handler: { [weak self] action in
            UserDefaults.groupSuite.clearAllStats()
            self?.refreshStats()
            self?.setEditing(false, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func setRightBarButtonItems(animated: Bool) {
        let barButtonItems: [UIBarButtonItem] = {
            guard !stats.isEmpty else { return [] }
            
            if isEditing {
                return [
                    editButtonItem,
                    UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllBarButtonItemTapped(sender:)))
                ]
            } else {
                return [
                    editButtonItem
                ]

            }
        }()

        navigationItem.setRightBarButtonItems(barButtonItems, animated: false)
    }
    
    @objc private func doneBarButtonItemTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

class StatsDataSource: UITableViewDiffableDataSource<Int, AmplosionStat> {
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let totalItems = UserDefaults.groupSuite.amplosionStats().count
        return totalItems == 0 ? nil : "Total: \(UserDefaults.groupSuite.totalAmplosions()). How many times Amplosion activated for each site. Stats are purely on-device (see About section)."
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var currentStats = UserDefaults.groupSuite.amplosionStats()
        currentStats.remove(at: indexPath.row)
        UserDefaults.groupSuite.setAmplosionStats(currentStats)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, AmplosionStat>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(currentStats, toSection: 0)
        
        if currentStats.isEmpty {
            tableView.backgroundView = StatsViewController.createEmptyLabel()
        } else {
            tableView.backgroundView = nil
        }
        
        apply(snapshot, animatingDifferences: false)
        
        // iOSBUG: If we delete the last cell we want the footer title to be removed, and despite iOS properly calling the titleForFooterInSection method and it returning nil, it doesn't remove the title unless we call reloadData
        tableView.reloadData()
    }
}
