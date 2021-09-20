//
//  ShortStoryViewController.swift
//  ShortStoryViewController
//
//  Created by Christian Selig on 2021-09-12.
//

import UIKit
import WebKit

class ShortStoryViewController: IndentedTitleViewController {
    // Should be pre-initialized to prevent loading delay and to make it feel native
    weak var webView: WKWebView?
    
    init(webView: WKWebView) {
        self.webView = webView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Short Story"
        
        view.backgroundColor = .systemBackground
        webView?.backgroundColor = .systemBackground
        
        if let webView = webView {
            view.addSubview(webView)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(screenshotNotification(notification:)), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView?.frame = view.bounds
    }
    
    @objc private func screenshotNotification(notification: Notification) {
        let alertController = UIAlertController(title: "Did you take a screenshot?!", message: "You better not be taking this beloved children’s story and sharing it with a big time book publisher and reaping all the profits for yourself! Or printing it out and selling it on street corners! Lord Waffles and Rascal would chase after you!\n\n🐶🐢💨", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Eep!", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}
