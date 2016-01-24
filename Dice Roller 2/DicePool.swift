//
//  DicePool.swift
//  Dice Roller 2
//
//  Created by David Rak on 15/01/16.
//  Copyright © 2016 David Rak. All rights reserved.
//

import Foundation

class DicePool {
	var dice = [Die]()
	let maxAgain: Bool
	// when max value is rolled, add additional die to dice pool
	// rule used Shadowrun 4th & 5th ed. when player uses Endge
	let maxAddsDie: Bool
	// when max value is rolled, roll again and add value to roll
	// rule used Shadowrun 2th edition
	let maxAddsValue: Bool
	// rule used in World of Darkness
	var subtractOnes: Bool
	
	
	
	init(numberOfDice: Int, withSides sides: Int,
		maxAgain: Bool, maxAddsDie: Bool, maxAddsValue: Bool,
		subtractOnes: Bool) {
		self.maxAgain = maxAgain
		self.maxAddsDie = maxAddsDie
		self.maxAddsValue = maxAddsValue
		self.subtractOnes = subtractOnes
		for _ in 1...numberOfDice {
			if maxAddsDie && maxAgain {
				while addDie(sides, maxAddsValue: maxAddsValue) == sides { }
			} else {
				addDie(sides, maxAddsValue: maxAddsValue)
			}
		}
		
	}
	
	
	
	
	func addDie(sides: Int, maxAddsValue: Bool) -> Int {
		let die = Die(sides: sides, maxAddsValue: maxAddsValue)
		dice.append(die)
		return die.value
	}
	
	
	func removeDie() {
		
	}
	
	
	func removeDice(howMany: Int) {
		for _ in 1...howMany {
			removeDie()
		}
	}
}