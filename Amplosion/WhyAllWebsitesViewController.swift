//
//  WhyAllWebsitesViewController.swift
//  WhyAllWebsitesViewController
//
//  Created by Christian Selig on 2021-09-12.
//

import UIKit
import WebKit
import SafariServices

class WhyAllWebsitesViewController: UIViewController, WKNavigationDelegate {
    let webView = WKWebView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "All Websites"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemTapped(sender:)))
        
        let html = try! String(contentsOf: Bundle.main.url(forResource: "all-websites", withExtension: "html")!)
        webView.loadHTMLString(html, baseURL: nil)
        view.addSubview(webView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.frame = view.bounds
    }
    
    @objc private func doneBarButtonItemTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard navigationAction.navigationType == .linkActivated else { decisionHandler(.allow); return }
        
        let safariViewController = SFSafariViewController(url: URL(string: "https://github.com/christianselig/Amplosion")!)
        present(safariViewController, animated: true, completion: nil)
        
        decisionHandler(.cancel)
    }
}
