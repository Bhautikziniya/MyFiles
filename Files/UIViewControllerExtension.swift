//
//  UIViewControllerExtension.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 9/14/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit

extension UIViewController {
    class func loadController() -> Self
    {
        return instantiateViewControllerFromMainStoryBoard()
    }
    
    private class func instantiateViewControllerFromMainStoryBoard<T>() -> T
    {
        let controller = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: String(describing: self)) as! T
        return controller
    }
    
    func reloadViewFromNib() {
        let parent = view.superview
        view.removeFromSuperview()
        view = nil
        parent?.addSubview(view) // This line causes the view to be reloaded
    }
}
