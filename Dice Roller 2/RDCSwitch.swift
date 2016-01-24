//
//  RDCSwitch.swift
//  RDCVectorButton
//
//  Created by David Rak on 18/01/16.
//  Copyright © 2016 David Rak. All rights reserved.
//

import UIKit


class RDCSwitch: NSObject, RDCVectorButtonDelegate {
	var buttons: [RDCVectorButton]
	var selectedButton: Int = 0
	var delegate: RDCSwitchDelegate?
	
	
	init(buttons: [RDCVectorButton]) {
		self.buttons = buttons
		super.init()
		
		for button in buttons {
			button.switchable = true
			button.canBeSwitched = true
			button.selected = false
			button.delegate = self
		}
		buttons[0].selected = true
		buttons[0].canBeSwitched = false
	}
	
	
	
	func buttonSwitched(sender: RDCVectorButton) {
		var x = 1
		for button in buttons {
			if button !== sender {
				button.canBeSwitched = true
				button.selected = false
				x++
			} else {
				button.canBeSwitched = false
				selectedButton = x
				
			}
		}
		delegate?.switchValueChanged(selectedButton)
	}
	
	
}
