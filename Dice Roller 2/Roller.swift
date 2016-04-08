//
//  Roller.swift
//  Dice Roller 2
//
//  Created by David Rak on 16/01/16.
//  Copyright © 2016 David Rak. All rights reserved.
//

import Foundation


class Roller {
	var dicePool: DicePool?
	var dataSource: RollerDataSource
	
	var successes: Int {
		var x = 0
		for die in dicePool!.dice {
			if die.value >= dataSource.targetNumber {
				x += 1
			}
		}
		if dicePool!.subtractOnes {
			x -= ones
		}
		return max(x, 0)
	}
	
	var ones: Int {
		var x = 0
		for die in dicePool!.dice {
			if die.value == 1 {
				x += 1
			}
		}
		return x
	}
	
	var numberOfDice: Int {
		return dicePool!.dice.count
	}
	
	
	
	init(dataSource: RollerDataSource) {
		self.dataSource = dataSource
		newDicePool()
	}
	
	
	func newDicePool() {
		dicePool = nil
		dicePool = DicePool(
			numberOfDice: dataSource.numberOfDice,
			withSides: dataSource.sides,
			maxAgain: dataSource.maxAgain,
			maxAddsDie: dataSource.maxAddDie,
			maxAddsValue: dataSource.maxAddValue,
			subtractOnes: dataSource.subtractOnes)
	}
	
	
	func updateDicePool() {
		dicePool?.subtractOnes = dataSource.subtractOnes
	}
	
	
	func addDice(howMany: Int) {
		dicePool?.addDice(howMany)
	}
	
	
	func subtractDice(howMany: Int) {
		dicePool?.removeDice(howMany)
	}
	
}
