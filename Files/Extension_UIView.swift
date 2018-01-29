//
//  Extension_UIView.swift
//  Vachnamrut
//
//  Created by Dhaval Nena on 22/06/17.
//  Copyright © 2017 Agile. All rights reserved.
//

import Foundation
import UIKit


//MARK:- AIEdge
enum AIEdge:Int {
	case
	Top,
	Left,
	Bottom,
	Right,
	Top_Left,
	Top_Right,
	Bottom_Left,
	Bottom_Right,
	All,
	None
}

private extension UIView {
    
    @discardableResult func _round(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        return mask
    }
    
    func addBorder(mask: CAShapeLayer, borderColor: UIColor, borderWidth: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
    
}



extension UIView {
    
    /**
     Rounds the given set of corners to the specified radius
     
     - parameter corners: Corners to round
     - parameter radius:  Radius to round to
     */
    func round(corners: UIRectCorner, radius: CGFloat) {
        _ = _round(corners: corners, radius: radius)
    }
    
    /**
     Rounds the given set of corners to the specified radius with a border
     
     - parameter corners:     Corners to round
     - parameter radius:      Radius to round to
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func round(corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let mask = _round(corners: corners, radius: radius)
        addBorder(mask: mask, borderColor: borderColor, borderWidth: borderWidth)
    }
    
    /**
     Fully rounds an autolayout view (e.g. one with no known frame) with the given diameter and border
     
     - parameter diameter:    The view's diameter
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func fullyRound(diameter: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = diameter / 2
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor;
    }
    
    func pushTransition(_ duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromTop
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionPush)
    }
	
	//MARK:- HEIGHT / WIDTH
	
	var width:CGFloat {
		return self.frame.size.width
	}
	var height:CGFloat {
		return self.frame.size.height
	}
	var xPos:CGFloat {
		return self.frame.origin.x
	}
	var yPos:CGFloat {
		return self.frame.origin.y
	}
	
	//MARK:- DASHED BORDER
	func drawDashedBorderAroundView() {
		let cornerRadius: CGFloat = self.frame.size.width / 2
		let borderWidth: CGFloat = 0.5
		let dashPattern1: Int = 4
		let dashPattern2: Int = 2
		let lineColor = UIColor.red
		
		//drawing
		let frame: CGRect = self.bounds
		let shapeLayer = CAShapeLayer()
		//creating a path
		let path: CGMutablePath = CGMutablePath()
		
		//drawing a border around a view
		path.move(to: CGPoint(x: CGFloat(0), y: CGFloat(frame.size.height - cornerRadius)), transform: .identity)
		path.addLine(to: CGPoint(x: CGFloat(0), y: CGFloat(cornerRadius)), transform: .identity)
		path.addArc(center: CGPoint(x: CGFloat(cornerRadius), y: CGFloat(cornerRadius)), radius: CGFloat(cornerRadius), startAngle: CGFloat(Double.pi), endAngle: CGFloat(-Double.pi / 2), clockwise: false, transform: .identity)
		path.addLine(to: CGPoint(x: CGFloat(frame.size.width - cornerRadius), y: CGFloat(0)), transform: .identity)
		path.addArc(center: CGPoint(x: CGFloat(frame.size.width - cornerRadius), y: CGFloat(cornerRadius)), radius: CGFloat(cornerRadius), startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(0), clockwise: false, transform: .identity)
		path.addLine(to: CGPoint(x: CGFloat(frame.size.width), y: CGFloat(frame.size.height - cornerRadius)), transform: .identity)
		path.addArc(center: CGPoint(x: CGFloat(frame.size.width - cornerRadius), y: CGFloat(frame.size.height - cornerRadius)), radius: CGFloat(cornerRadius), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi / 2), clockwise: false, transform: .identity)
		path.addLine(to: CGPoint(x: CGFloat(cornerRadius), y: CGFloat(frame.size.height)), transform: .identity)
		path.addArc(center: CGPoint(x: CGFloat(cornerRadius), y: CGFloat(frame.size.height - cornerRadius)), radius: CGFloat(cornerRadius), startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: false, transform: .identity)
		
		//path is set as the _shapeLayer object's path
		
		shapeLayer.path = path
		shapeLayer.backgroundColor = UIColor.clear.cgColor
		shapeLayer.frame = frame
		shapeLayer.masksToBounds = false
		shapeLayer.setValue(NSNumber(value: false), forKey: "isCircle")
		shapeLayer.fillColor = UIColor.clear.cgColor
		shapeLayer.strokeColor = lineColor.cgColor
		shapeLayer.lineWidth = borderWidth
		shapeLayer.lineDashPattern = [NSNumber(integerLiteral: dashPattern1),NSNumber(integerLiteral: dashPattern2)]
		shapeLayer.lineCap = kCALineCapRound
		
		self.layer.addSublayer(shapeLayer)
	}
	
	
	//MARK:- ROTATE
	func rotate(angle: CGFloat) {
		let radians = angle / 180.0 * CGFloat(Double.pi)
		self.transform = self.transform.rotated(by: radians);
	}
	
	
	
	//MARK:- BORDER
	func applyBorderDefault() {
		self.applyBorder(color: UIColor.red, width: 1.0)
	}
	func applyBorderDefault1() {
		self.applyBorder(color: UIColor.green, width: 1.0)
	}
	func applyBorderDefault2() {
		self.applyBorder(color: UIColor.blue, width: 1.0)
	}
	func applyBorder(color:UIColor, width:CGFloat) {
		DispatchQueue.main.async {
			self.layer.borderColor = color.cgColor
			self.layer.borderWidth = width
		}
	}
    
    func removeBorder() {
        DispatchQueue.main.async {
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 0.0
        }
    }
	
    // MARK: - ADD Blur View
    
    func applyBlurEffect(withStyle: UIBlurEffectStyle) {
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: withStyle)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            self.backgroundColor = UIColor.black
        }
    }
	
	//MARK:- CIRCLE
	func applyCircle() {
        self.layoutIfNeeded()
		self.applyCornerRadius(radius: min(self.frame.size.height, self.frame.size.width) * 0.5)
	}
	
	//MARK:- CORNER RADIUS
	func applyCornerRadius(radius:CGFloat) {
        DispatchQueue.main.async {
            if self.isKind(of: DesignableView.self) || self.isKind(of: DesignableButton.self) || self.isKind(of: DesignableLabel.self) {
                self.cornerRadius = radius
            } else {
                self.layer.cornerRadius = radius
                self.layer.masksToBounds = true
            }
        }
	}
	
	
	//MARK:- SHADOW

	func applyShadowWithColor(color:UIColor, opacity:Float, radius: CGFloat, edge:AIEdge, shadowSpace:CGFloat)	{
		
		var sizeOffset:CGSize = CGSize.zero
		switch edge {
		case .Top:
			sizeOffset = CGSize(width: 0, height: -shadowSpace) //CGSizeMake(0, -shadowSpace)
		case .Left:
			sizeOffset = CGSize(width: -shadowSpace, height: 0) //CGSizeMake(-shadowSpace, 0)
		case .Bottom:
			sizeOffset = CGSize(width: 0, height: shadowSpace) //CGSizeMake(0, shadowSpace)
		case .Right:
			sizeOffset = CGSize(width: shadowSpace, height: 0) //CGSizeMake(shadowSpace, 0)
			
			
		case .Top_Left:
			sizeOffset = CGSize(width: -shadowSpace, height: -shadowSpace) //CGSizeMake(-shadowSpace, -shadowSpace )
		case .Top_Right:
			sizeOffset = CGSize(width: shadowSpace, height: -shadowSpace) //CGSizeMake(shadowSpace, -shadowSpace)
		case .Bottom_Left:
			sizeOffset = CGSize(width: -shadowSpace, height: shadowSpace) //CGSizeMake(-shadowSpace, shadowSpace)
		case .Bottom_Right:
			sizeOffset = CGSize(width: shadowSpace, height: shadowSpace) //CGSizeMake(shadowSpace, shadowSpace)
			
			
		case .All:
			sizeOffset = CGSize(width: 0, height: 0) //CGSizeMake(0, 0)
		case .None:
			sizeOffset = CGSize.zero
		}
		
		self.layer.shadowColor = color.cgColor
		self.layer.shadowOpacity = opacity
		self.layer.shadowOffset = sizeOffset
		self.layer.shadowRadius = radius
//		self.clipsToBounds = false
		self.layer.masksToBounds = false
	}
	
	
    func addBorderWithColor(color:UIColor, edge:AIEdge, thicknessOfBorder:CGFloat, withWidth: CGFloat? = nil)	{

		DispatchQueue.main.async {
			
			var rect:CGRect = CGRect.zero
			
			switch edge {
			case .Top:
                rect = CGRect(x: 0, y: 0, width: withWidth == nil ? self.width : withWidth!, height: thicknessOfBorder) //CGRectMake(0, 0, self.width, thicknessOfBorder);
			case .Left:
				rect = CGRect(x: 0, y: 0, width: thicknessOfBorder, height: self.width ) //CGRectMake(0, 0, thicknessOfBorder, self.height);
			case .Bottom:
				rect = CGRect(x: 0, y: self.height - thicknessOfBorder, width: withWidth == nil ? self.width : withWidth!, height: thicknessOfBorder) //CGRectMake(0, self.height - thicknessOfBorder, self.width, thicknessOfBorder);
			case .Right:
				rect = CGRect(x: self.width-thicknessOfBorder, y: 0, width: thicknessOfBorder, height: self.height) //CGRectMake(self.width-thicknessOfBorder, 0,thicknessOfBorder, self.height);
			default:
				break
			}
            //print("Border Added")
			let layerBorder = CALayer()
			layerBorder.frame = rect
            layerBorder.backgroundColor = color.cgColor
			self.layer.addSublayer(layerBorder)
		}
	}
    
    func removeBorderLayer(color: UIColor) {
        
        for layer in self.layer.sublayers! {
            if layer.backgroundColor == color.cgColor {
                layer.removeFromSuperlayer()
            }
        }
    }
	
	//MARK:- ANIMATE VIBRATE
	func animateVibrate() {
		
		let duration = 0.05
		
		UIView.animate(withDuration: duration ,
		                           animations: {
									self.transform = self.transform.translatedBy(x: 5, y: 0)
		},
		                           completion: { finish in
									
									UIView.animate(withDuration: duration ,
									                           animations: {
																self.transform = self.transform.translatedBy(x: -10, y: 0)
									},
									                           completion: { finish in
																
																
																UIView.animate(withDuration: duration ,
																                           animations: {
																							self.transform = self.transform.translatedBy(x: 10, y: 0)
																},
																                           completion: { finish in
																							
																							
																							UIView.animate(withDuration: duration ,
																							                           animations: {
																														self.transform = self.transform.translatedBy(x: -10, y: 0)
																							},
																							                           completion: { finish in
																														
																														UIView.animate(withDuration: duration){
																															self.transform = CGAffineTransform.identity
																														}
																							})
																})
									})
		})
	}
    
    // Load From Nib
    
    class func loadFromNib() -> Self {
        return fromNib()
    }
    
    private class func fromNib<T>() -> T {
        let view = UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: nil, options: nil).first as! T
        return view
    }
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UIScrollView {
    
    // Bonus: Scroll to top
    func scrollToTop(animated: Bool) {
        self.layoutIfNeeded()
        scrollRectToVisible(CGRect.init(x: 0, y: 0, width: 1, height: 1), animated: animated)
    }
}

extension UITableView {
    func scrollToBottom(){
        let scrollPoint = CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height)
        self.setContentOffset(scrollPoint, animated: true)
    }
}
