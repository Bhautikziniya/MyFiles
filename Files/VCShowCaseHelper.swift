//
//  VCShowCaseHelper.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 12/24/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit
import MaterialShowcase
import Themes
import iShowcase

class VCShowCaseHelper: NSObject, iShowcaseDelegate {

    static let shared : VCShowCaseHelper = VCShowCaseHelper()

    private var iShowcaseShown: ((iShowcase) -> Void)?
    private var iShowcaseDismissed: ((iShowcase) -> Void)?
    
//    private var showcaseWillDismiss: ((MaterialShowcase) -> Void)?
//    private var showcaseDidDismiss: ((MaterialShowcase) -> Void)?
    
    var showcase: iShowcase!
    var isDisplayed: Bool = false
    
    
    func showcase(forView view: UIView, type: iShowcase.TYPE = .rectangle, titleLabel: String, detailLabel: String, centerText: Bool = true) {
        showcase = iShowcase()
        showcase.delegate = self
        showcase.type = type
        showcase.highlightColor = (ThemeManager.currentTheme as! MyTheme).FloatingButtonBackgroundColor
        showcase.titleLabel.text = titleLabel
        showcase.detailsLabel.text = detailLabel
        showcase.titleLabel.font = UIFont.appFont_Medium(fontSize: CGFloat(24).proportionalFontSize())
        showcase.detailsLabel.font = UIFont.appFont_Regular(fontSize: CGFloat(20).proportionalFontSize())
        showcase.centerText = centerText
        showcase.setupShowcaseForView(view)
        showcase.show()
    }
    
    func showcase(forLocation rect: CGRect, type: iShowcase.TYPE = .rectangle, titleLabel: String, detailLabel: String) {
        showcase = iShowcase()
        showcase.delegate = self
        showcase.type = type
        showcase.highlightColor = (ThemeManager.currentTheme as! MyTheme).FloatingButtonBackgroundColor
        showcase.titleLabel.text = titleLabel
        showcase.detailsLabel.text = detailLabel
        showcase.titleLabel.font = UIFont.appFont_Medium(fontSize: CGFloat(24).proportionalFontSize())
        showcase.detailsLabel.font = UIFont.appFont_Regular(fontSize: CGFloat(20).proportionalFontSize())
        showcase.radius = 40
        showcase.setupShowcaseForLocation(rect)
        showcase.show()
    }
    
    func iShowcaseShownHandler(_ handler: @escaping (iShowcase) -> Void) {
        isDisplayed = true
        self.iShowcaseShown = handler
    }
    
    func iShowcaseDismissedHandler(_ handler: @escaping (iShowcase) -> Void) {
        isDisplayed = false
        self.iShowcaseDismissed = handler
    }
    
    // MAKR: iShowcase delegate
    
    internal func iShowcaseShown(_ showcase: iShowcase) {
        if let validHandler = self.iShowcaseShown {
            validHandler(showcase)
        }
    }
    
    internal func iShowcaseDismissed(_ showcase: iShowcase) {
        if let validHandler = self.iShowcaseDismissed {
            validHandler(showcase)
        }
        self.showcase = nil
    }
    
    /*
    // Any UIView
    func show(forView view: UIView, primaryText: String, secondaryText: String) {
        let showcase = MaterialShowcase()
        showcase.setTargetView(view: view) // always required to set targetView
        showcase.primaryText = primaryText
        showcase.secondaryText = secondaryText
        
        // Background
        showcase.backgroundPromptColor = (ThemeManager.currentTheme as! MyTheme).PrimaryColor
        showcase.backgroundPromptColorAlpha = 0.96
        // Target
        showcase.targetTintColor = (ThemeManager.currentTheme as! MyTheme).PrimaryColor
        showcase.targetHolderRadius = 44
        showcase.targetHolderColor = UIColor.white
        // Text
        showcase.primaryTextColor = UIColor.white
        showcase.secondaryTextColor = UIColor.white
        showcase.primaryTextSize = 20
        showcase.secondaryTextSize = 15
        showcase.primaryTextFont = UIFont.boldSystemFont(ofSize: showcase.primaryTextSize)
        showcase.secondaryTextFont = UIFont.systemFont(ofSize: showcase.secondaryTextSize)
        // Animation
        showcase.aniComeInDuration = 0.5 // unit: second
        showcase.aniGoOutDuration = 0.5 // unit: second
        showcase.aniRippleScale = 1.5
        showcase.aniRippleColor = UIColor.white
        showcase.aniRippleAlpha = 0.2
        
        // When dismissing, delegate should be declared.
        showcase.delegate = self
        showcase.show {
            // You can save showcase state here
            // Later you can check and do not show it again
        }
    }
    
    // UIBarButtonItem
    func show(forBarButtonItem barButtonItem: UIBarButtonItem) {
        let showcase = MaterialShowcase()
        showcase.setTargetView(barButtonItem: barButtonItem) // always required to set targetView
        showcase.primaryText = "Action 1"
        showcase.secondaryText = "Click here to go into details"
        // When dismissing, delegate should be declared.
        showcase.delegate = self
        showcase.show {
            // You can save showcase state here
            // Later you can check and do not show it again
        }
    }
    
    // UITabBar item
    func show(forTabBar tabBar: UITabBar, index: Int) {
        let showcase = MaterialShowcase()
        showcase.setTargetView(tabBar: tabBar, itemIndex: index) // always required to set targetView
        showcase.primaryText = "Action 1"
        showcase.secondaryText = "Click here to go into details"
        // When dismissing, delegate should be declared.
        showcase.delegate = self
        showcase.show {
            // You can save showcase state here
            // Later you can check and do not show it again
        }
    }
    
    // UItableViewCell
    func show(forTableViewCell tableView: UITableView, section: Int, row: Int) {
        let showcase = MaterialShowcase()
        showcase.setTargetView(tableView: tableView, section: section, row: row) // always required to set targetView
        showcase.primaryText = "Action 1"
        showcase.secondaryText = "Click here to go into details"
        // When dismissing, delegate should be declared.
        showcase.delegate = self
        showcase.show {
            // You can save showcase state here
            // Later you can check and do not show it again
        }
    }
    
    // MARK: showcase helper class handlers
    
    func showcaseWillDismissHandler(_ handler: @escaping (MaterialShowcase) -> Void) {
        self.showcaseWillDismiss = handler
    }
    
    func showcaseDidDismissHandler(_ handler: @escaping (MaterialShowcase) -> Void) {
        self.showcaseDidDismiss = handler
    }
    
    // Material Showcase delegate methods
    
    internal func showCaseWillDismiss(showcase: MaterialShowcase) {
       // print("Showcase \(showcase.primaryText) will dismiss.")
        if let validHandler = self.showcaseWillDismiss {
            validHandler(showcase)
        }
    }
    
    internal func showCaseDidDismiss(showcase: MaterialShowcase) {
       // print("Showcase \(showcase.primaryText) dismissed.")
        if let validHandler = self.showcaseDidDismiss {
            validHandler(showcase)
        }
    }
     */
}
