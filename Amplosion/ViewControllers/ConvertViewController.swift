//
//  ConvertViewController.swift
//  ConvertViewController
//
//  Created by Christian Selig on 2021-09-03.
//

import UIKit

class ConvertViewController: UIViewController {
    let totalAmplosions: Int
    
    let label = UILabel()
    let conversionRateButton: UIButton
    
    let labelToButtonSpacing = 100.0
    
    init(totalAmplosions: Int) {
        self.totalAmplosions = totalAmplosions
        
        var buttonConfig = UIButton.Configuration.tinted()
        buttonConfig.title = "Change Conversion Rate"
        
        buttonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attribute in
            var newAttribute = attribute
            newAttribute.font = attribute.font?.rounded(withWeight: .medium)
            return newAttribute
        }
                
        buttonConfig.image = Locale.current.currencySFSymbol(filled: true)
        buttonConfig.imagePlacement = .leading
        buttonConfig.buttonSize = .large
        buttonConfig.imagePadding = 10.0
        
        self.conversionRateButton = UIButton(configuration: buttonConfig)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemTapped(sender:)))
        view.backgroundColor = .systemBackground
        
        setLabelAttributedText()
        label.numberOfLines = 0
        view.addSubview(label)
        
        conversionRateButton.addTarget(self, action: #selector(changeConversionRateButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(conversionRateButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        let labelMinimumSideSpacing = 30.0
        let labelMaxWidth = 500.0
        let labelWidth = min(labelMaxWidth, view.bounds.width - labelMinimumSideSpacing * 2.0)
        let labelHeight = label.sizeThatFits(CGSize(width: labelWidth, height: 0.0)).height
        
        let buttonSize = conversionRateButton.sizeThatFits(.zero)
        
        let totalAreaHeight = labelHeight + labelToButtonSpacing + buttonSize.height
        let labelY = (view.bounds.height - totalAreaHeight) / 2.0
        
        let labelX = (view.bounds.width - labelWidth) / 2.0
        
        label.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        
        conversionRateButton.frame = CGRect(x: (view.bounds.width - buttonSize.width) / 2.0, y: label.frame.maxY + labelToButtonSpacing, width: buttonSize.width, height: buttonSize.height)
    }
    
    private func setLabelAttributedText() {
        let mainAttributedString = NSMutableAttributedString()
                
        // Title
        let conversionRatio = UserDefaults.groupSuite.swearJarConversionRate()
        let amountSaved = Double(totalAmplosions) * conversionRatio
        let formattedString = formatAmountAsLocalCurrency(amount: amountSaved)
        
        let titleAttributedString = NSAttributedString(string: "\(formattedString) Saved! 💰\n", attributes: [.font: UIFont.preferredFont(forTextStyle: .title1).rounded(withWeight: .semibold), .foregroundColor: UIColor.label])
        mainAttributedString.append(titleAttributedString)
        
        // Body
        let costPerViolation = formatAmountAsLocalCurrency(amount: UserDefaults.groupSuite.swearJarConversionRate())
        let totalSavings = formatAmountAsLocalCurrency(amount: UserDefaults.groupSuite.swearJarConversionRate() * Double(totalAmplosions))
        
        let bodyAttributedString = NSAttributedString(string: "If you keep a Swear Jar, and each violation is \(costPerViolation), Amplosion has prevented \(totalAmplosions) AMP links and therefore \(totalSavings) in Swear Jar savings! Nice!\n\n", attributes: [.font: UIFont.preferredFont(forTextStyle: .body).rounded(), .foregroundColor: UIColor.label])
        mainAttributedString.append(bodyAttributedString)
        
        // Roy Kent
        let royKentAttributedString = NSAttributedString(string: "(Though Roy Kent would be sad)", attributes: [.font: UIFont.preferredFont(forTextStyle: .body).rounded(), .foregroundColor: UIColor.secondaryLabel])
        mainAttributedString.append(royKentAttributedString)
        
        let firstParagraphParagraphStyle = NSMutableParagraphStyle()
        firstParagraphParagraphStyle.alignment = .center
        firstParagraphParagraphStyle.paragraphSpacing = 20.0
        mainAttributedString.addAttribute(.paragraphStyle, value: firstParagraphParagraphStyle, range: NSRange(location: 0, length: titleAttributedString.length))
        
        let secondParagraphParagraphStyle = NSMutableParagraphStyle()
        secondParagraphParagraphStyle.alignment = .center
        mainAttributedString.addAttribute(.paragraphStyle, value: secondParagraphParagraphStyle, range: NSRange(location: titleAttributedString.length, length: mainAttributedString.length - titleAttributedString.length))
        
        label.attributedText = mainAttributedString
    }
    
    @objc private func doneBarButtonItemTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func changeConversionRateButtonTapped(sender: UIButton) {
        let currencyName: String = {
            let base = "dollars"
            guard let currencyCode = Locale.current.currencyCode else { return base }
            return Locale.current.localizedString(forCurrencyCode: currencyCode) ?? base
        }()
        
        let defaultCostOf3Swears = Double(Locale.current.chocolateBarCostForCurrency()) * 3.0
        let defaultCostFormattedString = formatAmountAsLocalCurrency(amount: defaultCostOf3Swears)
        
        let alertController = UIAlertController(title: "Conversion Rate", message: "What is your preferred conversion rate for Swear Jar violations to \(currencyName)? By default it is \(Locale.current.chocolateBarCostForCurrency()), meaning 3 swears would cost \(defaultCostFormattedString).", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Conversion Rate"
            textField.keyboardType = .decimalPad
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let changeAction = UIAlertAction(title: "Change", style: .default) { [weak self] action in
            let textFieldText = alertController.textFields?.first?.text
            
            guard let textAsDouble: Double = {
                guard let textFieldText = textFieldText, !textFieldText.isEmpty else { return nil }
                
                // This is really simple but should suffice for this use case and prevent users from typing in something silly and causing an issue for themselves
                let conversionRateRegex = #"^\d{1,9}(?:\.\d{1,9})?$"#
                let isValidInput = textFieldText.range(of: conversionRateRegex, options: .regularExpression) != nil
                
                guard isValidInput else { return nil }
                
                let formatter = NumberFormatter()
                formatter.locale = Locale.current
                formatter.numberStyle = .decimal
                let doubleValue = formatter.number(from: textFieldText)?.doubleValue
                
                if let doubleValue = doubleValue, doubleValue > 0.0 {
                    return doubleValue
                } else {
                    return nil
                }
            }() else {
                let alertController = UIAlertController(title: "Invalid Text Entered", message: "The entered text doesn’t appear to resemble a valid conversion rate. Please try again! No funny business like trying to make me divide by 0!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            
            UserDefaults.groupSuite.setSwearJarConversionRate(textAsDouble)
            self?.setLabelAttributedText()
        }
        
        alertController.addAction(changeAction)
        alertController.preferredAction = changeAction
        
        present(alertController, animated: true, completion: nil)
    }
    
    func formatAmountAsLocalCurrency(amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        let amountIsInteger = amount.remainder(dividingBy: 1.0) == 0.0
        
        // Hide cents if there are none to keep it clean
        formatter.maximumFractionDigits = amountIsInteger ? 0 : 2
        
        let formattedString = formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
        return formattedString
    }
}
