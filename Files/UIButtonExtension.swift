//
//  UIButtonExtension.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 11/9/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import Foundation

extension UIButton {
    
    func springAnimation() {
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .allowUserInteraction, animations: {
            self.transform = .identity
        }, completion: nil)
    }
    
    func addCharacterSpacing() {
        if let labelText = currentTitle, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedStringKey.kern, value: 2.15, range: NSRange(location: 0, length: attributedString.length - 1))
            setAttributedTitle(attributedString, for: .normal)
            //            attributedText = attributedString
        }
    }
}

extension UILabel {
    func addCharacterSpacing() {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedStringKey.kern, value: 2.15, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
