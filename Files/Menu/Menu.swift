//
//  Menu.swift
//  FlowMenu
//
//  Created by Bhautik Ziniya on 9/26/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit

/**
     // How to Use.
 
    var menu: Menu!
    menu = Menu.instanceFromNib()

    let items = [
        Item(name: "Item1"),
        Item(name: "Item2"),
        Item(name: "Item3"),
        Item(name: "Item4"),
        Item(name: "Item5"),
        Item(name: "Item6", image: UIImage)
    ]

    menu.show(inView: self.view, sender: sender, items: items)
    menu.itemTapBlock = { (item,idx) in
        print(item.name)
        print(idx)
        self.menu.hide()
    }
 **/

class Menu: UIView {

    @IBOutlet weak private var itemsTableView: PopUpMenuTableView!
    
    static var shared: Menu = Menu.instanceFromNib()
    
    private var flowWindow: UIWindow!
    var isVisible: Bool = false
    var itemTapBlock: ((_ item: Item, _ idx: Int) -> Void)!
    var items : [Item] = []
    
    private var menuDidHide: (() -> Void)?
    private var menuDidDisplayed: (() -> Void)?
    
    convenience init(items: [Item]) {
        self.init()
        self.items = items
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTable()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        OperationQueue.main.addOperation {
            self.layoutIfNeeded()
            self.setupShadow()
        }
    }
    
    class func instanceFromNib() -> Menu {
        let view = UINib(nibName: String(describing: Menu.self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! Menu
        globalMenu = view
        return view
    }
    
    private func setupTable() {
        self.itemsTableView.items = self.items
        self.itemsTableView.itemTapBlock = {(item,row)in
            if let validBlock = self.itemTapBlock{
                validBlock(item, row)
            }
            self.hide()
        } 
    }
    
    private func setupShadow() {
        self.layer.masksToBounds = false
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 1.0, height: -1.0)
//        self.layer.shadowOpacity = 0.6
        
//        let shadowPath = UIBezierPath(rect: self.bounds)
//        self.layer.shadowPath = shadowPath.cgPath
//        self.theme_backgroundColor = GlobalPickerClass.shared.backgroundColor
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 6)
        self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.24).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 10
    }
    
     func show(inView: UIView, sender: UIButton, items: [Item], tableViewHeader: Bool = false) {
        
        self.items = items
        self.itemsTableView.items = self.items
        
        var maximalWidth:CGFloat = 40.0 // 20 - 20 Spacing from left and right in tableviewcell.
        var maximalHeight:CGFloat = self.itemsTableView.contentInset.top + self.itemsTableView.contentInset.bottom
        
        // Required Width Calculation
        var requiredWidth:CGFloat = 0
        
        for objItem in self.items{
            
            let attributedText:NSAttributedString = objItem.name.getAttributedString(generalAttributes: AITextAttribute.init(WithText: "", Color: UIColor.black, Font: UIFont.appFont_Medium(fontSize: CGFloat(16).proportionalFontSize()), Underline: false), SubStringDetails: [])
            
            let requiredSize = attributedText.width(withConstrainedHeight: self.itemsTableView.tableView(self.itemsTableView, heightForRowAt: IndexPath.init(row: 0, section: 0)))
            
            if requiredWidth < requiredSize{
                requiredWidth = requiredSize
            }
        }
        maximalWidth += requiredWidth
        
        if maximalWidth > SCREEN_WIDTH{
            maximalWidth = SCREEN_WIDTH
        }
        
        // Required Height Calculation
        for index in 0..<self.itemsTableView.tableView(self.itemsTableView, numberOfRowsInSection: 0){
            maximalHeight += self.itemsTableView.tableView(self.itemsTableView, heightForRowAt: IndexPath.init(row: index, section: 0))
        }
        
        for v in inView.subviews {
            if v.isKind(of: Menu.self) {
                v.removeFromSuperview()
            }
        }
        
        for window in UIApplication.shared.windows {
            for subview in window.subviews {
                if subview.isKind(of: Menu.self) {
                    subview.removeFromSuperview()
                    self.flowWindow = nil
                }
            }
        }
        
        let point = sender.convert(sender.frame.origin, to: inView)
        
        let xPadding:CGFloat = sender.frame.size.width * 0.45
        let yPadding:CGFloat = sender.frame.size.height * 0.1
        
        if tableViewHeader {
            self.frame = CGRect(x: (sender.frame.origin.x) + (sender.frame.size.width * 0.5), y: point.y, width: maximalWidth, height: maximalHeight)
//            if Devices.deviceType == .iPhoneX && Devices.isLandscape {
//                self.frame = CGRect(x: (((sender.frame.origin.x + sender.frame.size.width) - maximalWidth) - xPadding) - (44 * 2) , y: point.y, width: maximalWidth, height: maximalHeight)
//            } else {
//                self.frame = CGRect(x: ((sender.frame.origin.x + sender.frame.size.width) - maximalWidth) - xPadding , y: point.y, width: maximalWidth, height: maximalHeight)
//            }
        } else {
            self.frame = CGRect(x: ((sender.frame.origin.x + sender.frame.size.width) - maximalWidth) - xPadding, y: (sender.frame.origin.y + sender.frame.size.height) - 20, width: maximalWidth, height: maximalHeight)
        }
        inView.addSubview(self)
        
        if ((UIScreen.main.bounds.origin.x > self.frame.origin.x) && (self.frame.origin.y + self.frame.size.height) > UIScreen.main.bounds.size.height) {
            // Bottom Left
            
            if tableViewHeader {
                self.frame = CGRect(x: ((sender.frame.origin.x + sender.frame.size.width) - maximalWidth) + xPadding , y: (point.y - maximalHeight), width: maximalWidth, height: maximalHeight)
            } else {
                self.frame = CGRect(x: ((sender.frame.origin.x + sender.frame.size.width) - maximalWidth) + xPadding , y: (sender.frame.origin.y - maximalHeight), width: maximalWidth, height: maximalHeight)
            }
            
            self.layer.anchorPoint = CGPoint(x: 0.0, y: 1.0)
            if tableViewHeader {
                self.layer.position = CGPoint(x: sender.frame.origin.x, y: point.y)
            } else {
                self.layer.position = CGPoint(x: sender.frame.origin.x, y: (sender.frame.origin.y + sender.frame.size.height))
            }
            
        } else if ((self.frame.origin.y + self.frame.size.height) > UIScreen.main.bounds.size.height) || ((self.frame.origin.y + self.frame.size.height) > inView.frame.size.height) {
            // Bottom Right
            if tableViewHeader {
                self.frame = CGRect(x: ((sender.frame.origin.x + sender.frame.size.width) - maximalWidth) - xPadding , y: (point.y - yPadding), width: maximalWidth, height: maximalHeight)
            } else {
                
                self.frame = CGRect(x: ((sender.frame.origin.x + sender.frame.size.width) - maximalWidth) - 10, y: (sender.frame.origin.y) - 20, width: maximalWidth, height: maximalHeight)
            }
            
            self.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
            if tableViewHeader {
                self.layer.position = CGPoint(x: (sender.frame.origin.x + sender.frame.size.width) - xPadding, y: ((point.y + sender.frame.size.height) - yPadding))
            } else {
                self.layer.position = CGPoint(x: ((sender.frame.origin.x + sender.frame.size.width)) - 10, y: (sender.frame.origin.y) - 20)
            }
        } else if (UIScreen.main.bounds.origin.x > self.frame.origin.x) {
            // Top Left
            if tableViewHeader {
                self.frame = CGRect(x: (sender.frame.origin.x) + xPadding, y: point.y, width: maximalWidth, height: maximalHeight)
            } else {
                self.frame = CGRect(x: (sender.frame.origin.x) + xPadding, y: sender.frame.origin.y, width: maximalWidth, height: maximalHeight)
            }
            
            self.layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            if tableViewHeader {
                self.layer.position = CGPoint(x: sender.frame.origin.x, y: point.y)
            } else {
                self.layer.position = CGPoint(x: sender.frame.origin.x, y: sender.frame.origin.y)
            }
        } else {
            // Top Right
            print(self.frame)
            self.layer.anchorPoint = CGPoint(x: 1.0, y: 0.0)
            if tableViewHeader {
                self.layer.position = CGPoint(x: (sender.frame.origin.x + sender.frame.size.width) - xPadding, y: point.y)
            } else {
                self.layer.position = CGPoint(x: (sender.frame.origin.x + sender.frame.size.width) - xPadding, y: (sender.frame.origin.y + sender.frame.size.height) - 20)
            }
        }
        
        self.alpha = 0.0
        let scale = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.transform = scale.concatenating(scale)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .beginFromCurrentState, animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
                self.isVisible = true
            })
        }, completion:{ (finished) in
            if let validHandler = self.menuDidDisplayed {
                validHandler()
            }
        })
    }
    
    /// Show quick option menu
    ///
    /// - Parameters:
    ///   - inView: Sdd menu to particular view. or the view which holds the menu view.
    ///   - sender: Sender from which menu to be shown.
    ///   - items: Items to display in menu.
    func show(inView: UIView, sender: UIButton, items: [Item]) {
        
        self.items = items
        self.itemsTableView.items = self.items
        
        var maximalWidth:CGFloat = 40.0 // 20 - 20 Spacing from left and right in tableviewcell.
        var maximalHeight:CGFloat = self.itemsTableView.contentInset.top + self.itemsTableView.contentInset.bottom
        
        // Required Width Calculation
        var requiredWidth:CGFloat = 0
        
        for objItem in self.items{
            
            let attributedText:NSAttributedString = objItem.name.getAttributedString(generalAttributes: AITextAttribute.init(WithText: "", Color: UIColor.black, Font: UIFont.appFont_Medium(fontSize: CGFloat(16).proportionalFontSize()), Underline: false), SubStringDetails: [])
            
            let requiredSize = attributedText.width(withConstrainedHeight: self.itemsTableView.tableView(self.itemsTableView, heightForRowAt: IndexPath.init(row: 0, section: 0)))
            
            if requiredWidth < requiredSize{
                requiredWidth = requiredSize
            }
        }
        maximalWidth += requiredWidth
        
        if maximalWidth > SCREEN_WIDTH{
            maximalWidth = SCREEN_WIDTH
        }
        
        // Required Height Calculation
        for index in 0..<self.itemsTableView.tableView(self.itemsTableView, numberOfRowsInSection: 0){
            maximalHeight += self.itemsTableView.tableView(self.itemsTableView, heightForRowAt: IndexPath.init(row: index, section: 0))
        }
        
        for v in inView.subviews {
            if v.isKind(of: Menu.self) {
                v.removeFromSuperview()
            }
        }
        
        for window in UIApplication.shared.windows {
            for subview in window.subviews {
                if subview.isKind(of: Menu.self) {
                    subview.removeFromSuperview()
                    self.flowWindow = nil
                }
            }
        }
        
        // MARK: Dont Delete the comments.
//        print(sender.convert(sender.frame.origin, to: inView))

        let point = sender.convert(sender.frame.origin, to: inView)
        
//        self.frame = CGRect(x: (sender.frame.origin.x + sender.frame.size.width) - maximalWidth , y: point.y, width: maximalWidth, height: CGFloat(maximalHeight * self.items.count))
        self.frame = CGRect(x: (sender.frame.origin.x + sender.frame.size.width) - maximalWidth , y: (sender.frame.origin.y + sender.frame.size.height) - 20, width: maximalWidth, height: CGFloat(maximalHeight * CGFloat(self.items.count)))
        inView.addSubview(self)
        
        if ((UIScreen.main.bounds.origin.x > self.frame.origin.x) && (self.frame.origin.y + self.frame.size.height) > UIScreen.main.bounds.size.height) {
//            self.frame = CGRect(x: (sender.frame.origin.x + sender.frame.size.width) - maximalWidth , y: (point.y - CGFloat(maximalHeight * self.items.count)), width: maximalWidth, height: CGFloat(maximalHeight * self.items.count))
            self.frame = CGRect(x: (sender.frame.origin.x + sender.frame.size.width) - maximalWidth , y: (sender.frame.origin.y - CGFloat(maximalHeight * CGFloat(self.items.count))), width: maximalWidth, height: CGFloat(maximalHeight * CGFloat(self.items.count)))
            
            self.layer.anchorPoint = CGPoint(x: 0.0, y: 1.0)
//            self.layer.position = CGPoint(x: sender.frame.origin.x, y: point.y)
            self.layer.position = CGPoint(x: sender.frame.origin.x, y: (sender.frame.origin.y + sender.frame.size.height))
            
        } else if (self.frame.origin.y + self.frame.size.height) > UIScreen.main.bounds.size.height {
            self.frame = CGRect(x: (sender.frame.origin.x + sender.frame.size.width) - maximalWidth , y: (sender.frame.origin.y - CGFloat(maximalHeight * CGFloat(self.items.count))), width: maximalWidth, height: CGFloat(maximalHeight * CGFloat(self.items.count)))
//            self.frame = CGRect(x: (sender.frame.origin.x + sender.frame.size.width) - maximalWidth , y: (point.y - CGFloat(maximalHeight * self.items.count)), width: maximalWidth, height: CGFloat(maximalHeight * self.items.count))
            
            self.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
            self.layer.position = CGPoint(x: (sender.frame.origin.x + sender.frame.size.width), y: (sender.frame.origin.y + sender.frame.size.height))
//            self.layer.position = CGPoint(x: (sender.frame.origin.x + sender.frame.size.width), y: point.y)
            
        } else if (UIScreen.main.bounds.origin.x > self.frame.origin.x) {
            self.frame = CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y, width: maximalWidth, height: CGFloat(maximalHeight * CGFloat(self.items.count)))
//            self.frame = CGRect(x: sender.frame.origin.x, y: point.y, width: maximalWidth, height: CGFloat(maximalHeight * self.items.count))
            
            self.layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            self.layer.position = CGPoint(x: sender.frame.origin.x, y: sender.frame.origin.y)
//            self.layer.position = CGPoint(x: sender.frame.origin.x, y: point.y)
        } else {
            self.layer.anchorPoint = CGPoint(x: 1.0, y: 0.0)
            self.layer.position = CGPoint(x: (sender.frame.origin.x + sender.frame.size.width), y: (sender.frame.origin.y + sender.frame.size.height) - 20)
//            self.layer.position = CGPoint(x: (sender.frame.origin.x + sender.frame.size.width), y: point.y)
        }
        
        self.alpha = 0.0
        let scale = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.transform = scale.concatenating(scale)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .beginFromCurrentState, animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
                self.isVisible = true
            })
        }, completion: { (finished) in
            if let validHandler = self.menuDidDisplayed {
                validHandler()
            }
        })
    }
    
    /// Method to display menu on navigation bar button item.
    ///
    /// - Parameters:
    ///   - inView: Add menu to particular view. or the view which holds the menu view.
    ///   - sender: Sender from which menu to be shown.
    ///   - items: Items to display in menu.
    func show(inView: UIView, sender: UIBarButtonItem, items: [Item]) {
        
        self.items = items
        self.itemsTableView.items = self.items
        
        var maximalWidth:CGFloat = 40.0 // 20 - 20 Spacing from left and right in tableviewcell.
        var maximalHeight:CGFloat = 0
        
        // Required Width Calculation
        var requiredWidth:CGFloat = 0
        
        for objItem in self.items{
            
            let attributedText:NSAttributedString = objItem.name.getAttributedString(generalAttributes: AITextAttribute.init(WithText: "", Color: UIColor.black, Font: UIFont.appFont_Medium(fontSize: CGFloat(16).proportionalFontSize()), Underline: false), SubStringDetails: [])
            
            let requiredSize = attributedText.width(withConstrainedHeight: self.itemsTableView.tableView(self.itemsTableView, heightForRowAt: IndexPath.init(row: 0, section: 0)))
            
            if requiredWidth < requiredSize{
                requiredWidth = requiredSize
            }
        }
        maximalWidth += requiredWidth
        
        if maximalWidth > SCREEN_WIDTH{
            maximalWidth = SCREEN_WIDTH
        }
        
        // Required Height Calculation
        for index in 0..<self.itemsTableView.tableView(self.itemsTableView, numberOfRowsInSection: 0){
            maximalHeight += self.itemsTableView.tableView(self.itemsTableView, heightForRowAt: IndexPath.init(row: index, section: 0))
        }
        
        for v in inView.subviews {
            if v.isKind(of: Menu.self) {
                v.removeFromSuperview()
            }
        }
        
        for window in UIApplication.shared.windows {
            for subview in window.subviews {
                if subview.isKind(of: Menu.self) {
                    subview.removeFromSuperview()
                    self.flowWindow = nil
                }
            }
        }
        
        flowWindow = UIApplication.shared.windows.first
        flowWindow!.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        
        var yPosition : CGFloat = 30.0
        var xPadding : CGFloat = 20.0
        if #available(iOS 11.0, *) {
            print(flowWindow.safeAreaInsets)
            if Devices.deviceType == .iPhoneX {
                yPosition = flowWindow.safeAreaInsets.top
                
                if Devices.isLandscape {
                    xPadding = flowWindow.safeAreaInsets.left
                    xPadding += flowWindow.safeAreaInsets.right
                }
                
            } else {
                if Devices.isLandscape {
                    yPosition = flowWindow.safeAreaInsets.top
                } else {
                    yPosition += flowWindow.safeAreaInsets.top
                }
            }
        }

        if Devices.isPortrait {
            self.frame = CGRect(x: ((flowWindow!.frame.origin.x + flowWindow!.frame.size.width) - (maximalWidth) - 25) , y: yPosition, width: maximalWidth, height: maximalHeight)
        } else {
            self.frame = CGRect(x: ((flowWindow!.frame.origin.x + (flowWindow!.frame.size.width - xPadding)) - (maximalWidth)) , y: yPosition, width: maximalWidth, height: maximalHeight)
        }
        flowWindow!.addSubview(self)
        
        let scale = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.transform = scale.concatenating(scale)
        self.layer.anchorPoint = CGPoint(x: 1.0, y: 0.0)
        if Devices.isPortrait {
            self.layer.position = CGPoint(x: (flowWindow!.frame.origin.x + flowWindow!.frame.size.width) - 25, y: yPosition)
        } else {
            self.layer.position = CGPoint(x: ((flowWindow!.frame.origin.x + (flowWindow!.frame.size.width - xPadding))), y: yPosition)
        }
        self.alpha = 0.0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .beginFromCurrentState, animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
                self.isVisible = true
            })
        }, completion: { (finished) in
            if let validHandler = self.menuDidDisplayed {
                validHandler()
            }
        })
    }
    
    /// Method to hide the quick menu.
    func hide() { 
        self.transform = CGAffineTransform.identity
        self.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        self.layer.position = CGPoint(x: 200, y: 200 - 20)
        self.alpha = 1.0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .beginFromCurrentState, animations: {
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }, completion: { (finished) in
            if finished {
                self.flowWindow = nil
                self.removeFromSuperview()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
                    self.isVisible = false
                })
                
                if let validHandler = self.menuDidHide {
                    validHandler()
                }
            }
        })
    } 
}

class Item: NSObject {
    
    /// The Overflow item's name.
    var name: String!
    
    /// The overflow item's image. (Option)
    var image: UIImage!
    
    //
    var shouldShowSeperator:Bool = false
    
    /// A Convenience constructor to create FlowItem
    ///
    /// - Parameter withName: the overflow item's name.
    /// - Returns: an instance of FlowItem
    
    convenience init(name withName: String) {
        self.init()
        self.name = withName
    }
    
    /// A convenience constructor to create FlowItem
    ///
    /// - Parameters:
    ///   - withName: the overflow item's name
    ///   - image: the overflow item's image (Optional)
    /// - Returns: an instance of FlowItem
    
    convenience init(name withName: String, image: UIImage?) {
        self.init()
        self.name = withName
        self.image = image
    }
    
    class func getItemsArray(FromStrings aryItems:[String]) -> [Item]{
        var aryItemsToReturn:[Item] = []
        for index in 0..<aryItems.count{
            if aryItems[index] == "separator" && index > 0{
                aryItemsToReturn[index-1].shouldShowSeperator = true
            }else{
                aryItemsToReturn.append(Item(name: aryItems[index]))
            }
        }
        return aryItemsToReturn
    }
    
    class func getItemsArray(FromStrings aryItems:[Item]) -> [Item]{
        var aryItemsToReturn:[Item] = []
        for index in 0..<aryItems.count {
            if aryItems[index].name == "separator" && index > 0{
                aryItemsToReturn[index-1].shouldShowSeperator = true
            }else{
                aryItemsToReturn.append(aryItems[index])
            }
        }
        return aryItemsToReturn
    }
}
