//
//  HowToEnableViewController.swift
//  HowToEnableViewController
//
//  Created by Christian Selig on 2021-09-09.
//

import UIKit

class HowToEnableViewController: UIViewController {
    // Only has scrolling enabled if needed
    let scrollView = UIScrollView()
    
    let instructionViews: [EnableInstructionView] = EnableInstruction.allCases.map { EnableInstructionView(instruction: $0) }
    let videoExplainerView = VideoExplainerView()
    
    let videoSideSpacing = 20.0
    let instructionsSideSpacing = 30.0
    let videoBottomSpacing = 35.0
    let instructionIntraSpacing = 16.0
    let gotItButtonSideSpacing = 23.0
    let gotItButtonVerticalSpacing = 40.0
    let gotItButtonHeightPadding: CGFloat = 5.0
    
    let gotItButton: UIButton
    
    // Preload so it loads instantly and zippy
    private let whyAllWebsitesViewController = WhyAllWebsitesViewController()
    
    init() {
        self.gotItButton = UIButton(type: .system)
        
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.title = "How to Enable"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemTapped(sender:)))
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    @objc private func doneBarButtonItemTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(videoExplainerView)
        instructionViews.forEach {
            $0.delegate = self
            scrollView.addSubview($0)
        }

        gotItButton.setTitle("Got It", for: .normal)
        gotItButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3).rounded(withWeight: .semibold)
        gotItButton.titleLabel?.adjustsFontForContentSizeCategory = true
        gotItButton.layer.cornerRadius = 14.0
        gotItButton.layer.cornerCurve = .continuous
        gotItButton.tintColor = .white
        gotItButton.backgroundColor = UIColor(named: "got-it-button")
        gotItButton.addTarget(self, action: #selector(gotItButtonTapped(sender:)), for: .touchUpInside)
        scrollView.addSubview(gotItButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let scrollViewWidth = min(440.0, view.bounds.width)
        let scrollViewX = (view.bounds.width - scrollViewWidth) / 2.0
        let navigationBarHeight = navigationController?.navigationBar.bounds.height ?? 0.0
        scrollView.frame = CGRect(x: scrollViewX, y: navigationBarHeight, width: scrollViewWidth, height: view.bounds.height - navigationBarHeight - view.safeAreaInsets.bottom)
        
        let videoExplainerWidth = scrollView.bounds.width - 40.0
        let videoExplainerViewHeight = videoExplainerView.sizeThatFits(CGSize(width: videoExplainerWidth, height: 0.0)).height
        videoExplainerView.frame = CGRect(x: 20.0, y: 0.0, width: videoExplainerWidth, height: videoExplainerViewHeight)
        
        for (index, instructionView) in instructionViews.enumerated() {
            let instructionViewWidth = scrollView.bounds.width - instructionsSideSpacing * 2.0
            let instructionViewHeight = instructionView.sizeThatFits(CGSize(width: instructionViewWidth, height: 0.0)).height
            instructionView.frame.size = CGSize(width: instructionViewWidth, height: instructionViewHeight)
            
            if index == 0 {
                instructionView.frame.origin = CGPoint(x: instructionsSideSpacing, y: videoExplainerView.frame.maxY + videoBottomSpacing)
            } else {
                instructionView.frame.origin = CGPoint(x: instructionsSideSpacing, y: instructionViews[index - 1].frame.maxY + instructionIntraSpacing)
            }
        }
        
        let gotItButtonHeight = gotItButton.sizeThatFits(.zero).height + gotItButtonHeightPadding * 2.0
        
        let tentativeGotItButtonY = instructionViews.last!.frame.maxY + gotItButtonVerticalSpacing
        let tentativeContentHeight = tentativeGotItButtonY + gotItButtonHeight + gotItButtonVerticalSpacing
        
        let scrollShouldBeEnabled = view.bounds.height < tentativeContentHeight + scrollView.frame.origin.y
        scrollView.isScrollEnabled = scrollShouldBeEnabled
        
        if scrollShouldBeEnabled {
            gotItButton.frame = CGRect(x: gotItButtonSideSpacing, y: tentativeGotItButtonY, width: scrollView.bounds.width - gotItButtonSideSpacing * 2.0, height: gotItButtonHeight)
            scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: tentativeContentHeight)
        } else {
            // There's enough room that we don't need to scroll, position it closer to the bottom for aesthetic reasons
            let extraBottomSpacing: CGFloat = 10.0
            let gotItButtonY = view.bounds.height - view.safeAreaInsets.bottom - gotItButtonHeight - scrollView.frame.origin.y - extraBottomSpacing
            gotItButton.frame = CGRect(x: gotItButtonSideSpacing, y: gotItButtonY, width: scrollView.bounds.width - gotItButtonSideSpacing * 2.0, height: gotItButtonHeight)
            scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: gotItButton.frame.maxY)
        }
    }
    
    @objc private func gotItButtonTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension HowToEnableViewController: EnableInstructionViewDelegate {
    func moreInfoTapped() {
        let whyAllWebsitesNavigationController = UINavigationController(rootViewController: whyAllWebsitesViewController)
        present(whyAllWebsitesNavigationController, animated: true, completion: nil)
    }
}
