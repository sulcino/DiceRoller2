//
//  RollerDataSource.swift
//  Dice Roller 2
//
//  Created by David Rak on 16/01/16.
//  Copyright © 2016 David Rak. All rights reserved.
//

import Foundation


protocol RollerDataSource {
	var numberOfDice: Int { get }
	var sides: Int { get }
	var targetNumber: Int { get }
	var maxAgain: Bool { get }
	var maxAddDie: Bool { get }
	var maxAddValue: Bool { get }
	var subtractOnes: Bool { get }
	
}