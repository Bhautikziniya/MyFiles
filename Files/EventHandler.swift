//
//  EventHandler.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 10/12/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit

class EventHandler: UIApplication {

    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
  
        
        if let menu = globalMenu, menu.isVisible {
            if let touchEvent = event.allTouches, let firstTouch = touchEvent.first {
                let touch = firstTouch.location(in: menu)
                if touch.x > 0 && touch.y > 0 {
                    if touch.x < menu.frame.size.width && touch.y < menu.frame.size.height {
                    } else {
                        menu.hide()
                        globalMenu = nil
                    }
                } else {
                    menu.hide()
                    globalMenu = nil
                }
            } 
        } else if let menu = globalLanguageMenu, menu.isVisible {
            let touch = event.allTouches!.first!.location(in: menu)
            if touch.x > 0 && touch.y > 0 {
                if touch.x < menu.frame.size.width && touch.y < menu.frame.size.height {
                } else {
                    menu.hide()
                    globalLanguageMenu = nil
                }
            } else {
                menu.hide()
                globalLanguageMenu = nil
            }
            
        }
    }
}

