//
//  AboutViewController.swift
//  AboutViewController
//
//  Created by Christian Selig on 2021-08-26.
//

import UIKit
import WebKit

class AboutViewController: IndentedTitleViewController, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    let webView = WKWebView()
    
    let aboutOptions: [AboutOption] = [.twitter, .subreddit, .contact, .openSource, .privacyPolicy, .shortStory]
    
    lazy var dataSource: UITableViewDiffableDataSource<Int, AboutOption> = {
        let dataSource = UITableViewDiffableDataSource<Int, AboutOption>(tableView: tableView) { tableView, indexPath, aboutOption in
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutOptionCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = aboutOption.title
            content.secondaryText = aboutOption.subtitle
            content.textProperties.font = UIFont.rounded(ofSize: content.textProperties.font.pointSize, weight: aboutOption == .apollo ? .medium : .regular)
            content.secondaryTextProperties.color = UIColor.secondaryLabel
            content.image = aboutOption.icon
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "About"
        
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AboutOptionCell")
        tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.cellLayoutMarginsFollowReadableWidth = true
        view.addSubview(tableView)
        
        addAboutOptions()
        
        let html = try! String(contentsOf: Bundle.main.url(forResource: "adventures-waffles-rascal", withExtension: "html")!)
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    private func addAboutOptions() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AboutOption>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(aboutOptions, toSection: 0)
        
        snapshot.appendSections([1])
        snapshot.appendItems([AboutOption.apollo, AboutOption.achoo], toSection: 1)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let aboutOption = dataSource.itemIdentifier(for: indexPath) else { return }
            
        switch aboutOption {
        case .twitter:
            UIApplication.shared.open(URL(string: "https://twitter.com/christianselig")!, options: [:], completionHandler: nil)
        case .subreddit:
            UIApplication.shared.open(URL(string: "https://reddit.com/r/AmplosionApp")!, options: [:], completionHandler: nil)
        case .contact:
            UIApplication.shared.open(URL(string: "mailto://contact@amplosion.app")!, options: [:], completionHandler: nil)
        case .openSource:
            UIApplication.shared.open(URL(string: "https://github.com/christianselig/Amplosion")!, options: [:], completionHandler: nil)
        case .privacyPolicy:
            UIApplication.shared.open(URL(string: "https://amplosion.app/privacy-policy")!, options: [:], completionHandler: nil)
        case .shortStory:
            navigationController?.pushViewController(ShortStoryViewController(webView: webView), animated: true)
        case .apollo:
            UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/id979274575")!, options: [:], completionHandler: nil)
        case .achoo:
            UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/id1585833321")!, options: [:], completionHandler: nil)
        }
    }
}
