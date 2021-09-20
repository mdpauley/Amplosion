//
//  IndentedTitleViewController.swift
//  IndentedTitleViewController
//
//  Created by Christian Selig on 2021-08-31.
//

import UIKit

/// Simple class that just insets the navigation bar large title to be consistent with the indent of the table view caused by `cellLayoutMarginsFollowReadableWidth`.
class IndentedTitleViewController: UIViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Downside is that this causes a slightly weird, pseudo-bounce animation during view controller transitions. But we'll just say it's an intentional ✨feature✨
        let leftMargin = self.view.readableContentGuide.layoutFrame.minX
        self.navigationController?.navigationBar.layoutMargins.left = leftMargin
    }
}
