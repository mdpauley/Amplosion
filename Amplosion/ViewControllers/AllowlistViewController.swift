//
//  AllowlistViewController.swift
//  AllowlistViewController
//
//  Created by Christian Selig on 2021-08-31.
//

import UIKit

class AllowlistViewController: IndentedTitleViewController, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    var allowlistItems: [String] {
        return UserDefaults.groupSuite.allowlistItems()
    }
    
    lazy var dataSource: AllowlistDataSource = {
        let dataSource = AllowlistDataSource(tableView: tableView) { tableView, indexPath, allowlistItem in
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllowlistItemCell", for: indexPath)
            var contentConfig = cell.defaultContentConfiguration()
            contentConfig.text = allowlistItem
            contentConfig.image = UIImage(systemName: "globe")
            contentConfig.imageProperties.tintColor = UIColor.tertiaryLabel
            contentConfig.textProperties.font = contentConfig.textProperties.font.rounded()
            cell.contentConfiguration = contentConfig
            cell.selectionStyle = .none
            return cell
        }
        
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Allowlist"
        setRightBarButtonItems(animated: false)
        
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AllowlistItemCell")
        tableView.cellLayoutMarginsFollowReadableWidth = true
        view.addSubview(tableView)
        
        refreshAllowlistItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    private func refreshAllowlistItems() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(allowlistItems, toSection: 0)
        
        if allowlistItems.isEmpty {
            tableView.backgroundView = AllowlistViewController.createEmptyLabel()
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
        
        let mainAttributedString = NSMutableAttributedString(string: "It’s quiet in here…\n", attributes: [.font: UIFont.preferredFont(forTextStyle: .headline).rounded(), .foregroundColor: UIColor.label])
        mainAttributedString.append(NSAttributedString(string: "By default Amplosion automatically works on every AMP link, but if you want to allow certain websites to load AMP, you can add them here (or from the extension in Safari directly).", attributes: [.font: UIFont.preferredFont(forTextStyle: .callout).rounded(), .foregroundColor: UIColor.secondaryLabel]))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.paragraphSpacing = 5.0
        
        mainAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mainAttributedString.length))
        
        label.attributedText = mainAttributedString
        
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }
    
    @objc private func addBarButtonItemTapped(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Domain", message: "If added, Amplosion won’t activate for this domain.", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Domain"
            textField.keyboardType = .URL
        }

        let addAction = UIAlertAction(title: "Add", style: .default, handler: { [weak self] action in
            let textFieldText = alertController.textFields?.first?.text
            
            let textIsValid: Bool = {
                guard let textFieldText = textFieldText, !textFieldText.isEmpty else { return false }

                // This is really simple but should suffice for this use case and prevent users from typing in something silly and causing an issue for themselves
                let hostnameRegex = #"^[\w\-]+\.[\w\-]+(?:\.\w+)*$"#
                return textFieldText.range(of: hostnameRegex, options: .regularExpression) != nil
            }()

            guard textIsValid else {
                let alertController = UIAlertController(title: "Invalid Text Entered", message: "The text you entered doesn’t seem to match a website format (remember: just the domain, not the full URL, so example.com, not https://example.com/full/path/).\n\nIf you think this is in error, send a message through the contact option.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            
            var currentItems = UserDefaults.groupSuite.allowlistItems()
            
            guard !currentItems.contains(textFieldText!) else {
                let alertController = UIAlertController(title: "Already Added", message: "This domain is already added to the Allowlist, no need to add it twice, it’s not like it’ll unblock AMP twice as much!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            
            currentItems.append(textFieldText!)
            UserDefaults.groupSuite.set(currentItems, forKey: DefaultsKey.allowlistItems)
            self?.refreshAllowlistItems()
            self?.setEditing(false, animated: true)
        })

        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alertController.preferredAction = addAction

        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func clearAllBarButtonItemTapped(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to clear all items? This cannot be undone.", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Clear All", style: .destructive, handler: { [weak self] action in
            UserDefaults.groupSuite.removeObject(forKey: DefaultsKey.allowlistItems)
            self?.refreshAllowlistItems()
            self?.setEditing(false, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func setRightBarButtonItems(animated: Bool) {
        let barButtonItems: [UIBarButtonItem] = {
            if isEditing {
                return [
                    editButtonItem,
                    UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonItemTapped(sender:))),
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
}

class AllowlistDataSource: UITableViewDiffableDataSource<Int, String> {
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let totalItems = (UserDefaults.groupSuite.stringArray(forKey: DefaultsKey.allowlistItems) ?? []).count
        return totalItems == 0 ? nil : "Amplosion will allow sites from this list to load their AMP links"
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var currentItems = UserDefaults.groupSuite.allowlistItems()
        guard !currentItems.isEmpty else { return }
        currentItems.remove(at: indexPath.row)
        UserDefaults.groupSuite.set(currentItems, forKey: DefaultsKey.allowlistItems)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(currentItems, toSection: 0)
        
        if currentItems.isEmpty {
            tableView.backgroundView = AllowlistViewController.createEmptyLabel()
        } else {
            tableView.backgroundView = nil
        }
        
        apply(snapshot, animatingDifferences: false)
        
        // iOSBUG: If we delete the last cell we want the footer title to be removed, and despite iOS properly calling the titleForFooterInSection method and it returning nil, it doesn't remove the title unless we call reloadData
        tableView.reloadData()
    }
}
