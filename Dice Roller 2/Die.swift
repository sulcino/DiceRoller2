//
//  Die.swift
//  Dice Roller 2
//
//  Created by David Rak on 15/01/16.
//  Copyright © 2016 David Rak. All rights reserved.
//

import Foundation

struct Die {
	let sides: Int
	var value: Int
	

	init(sides: Int, maxAddsValue: Bool) {
		self.sides = sides
		if maxAddsValue {
			var newValue = 0
			value = 0
			repeat {
				newValue = Int(arc4random_uniform(UInt32(sides))) + 1
				value += newValue
			} while newValue == sides
		} else {
			value = Int(arc4random_uniform(UInt32(sides))) + 1
		}
		
	}
}
