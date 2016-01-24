//
//  ViewController.swift
//  Dice Roller 2
//
//  Created by David Rak on 15/01/16.
//  Copyright © 2016 David Rak. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, RollerDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
	
	var numberOfDice: Int = 1
	var sides: Int = 6
	var targetNumber: Int = 5
	var maxAgain: Bool = false {
		didSet { maxAgainButton.selected = maxAgain } }
	var maxAddDie: Bool = true
	var maxAddValue: Bool = false
	var subtractOnes: Bool = false {
		didSet { subtractOnesButton.selected = subtractOnes } }
	var roller: Roller?
	
	@IBOutlet weak var successesLabel: UILabel!
	@IBOutlet weak var successesDisplay: UILabel!
	@IBOutlet weak var onesLabel: UILabel!
	@IBOutlet weak var onesDisplay: UILabel!
	@IBOutlet weak var dicePoolLabel: UILabel!
	@IBOutlet weak var dicePoolDisplay: UILabel!
	
	@IBOutlet weak var subtractOnesPlaceHolder: UIView!
	@IBOutlet weak var maxAgainPlaceHolder: UIView!
	@IBOutlet weak var addDiePlaceHolder: UIView!
	@IBOutlet weak var addValuePlaceHolder: UIView!
	
	@IBOutlet weak var rollPlaceHolder: UIView!
	@IBOutlet weak var plusPlaceHolder: UIView!
	@IBOutlet weak var minusPlaceHolder: UIView!
	
	@IBOutlet weak var pickerSides: UIPickerView!
	@IBOutlet weak var pickerHowMuchDice: UIPickerView!
	@IBOutlet weak var pickerTargetNumber: UIPickerView!
	
	var subtractOnesButton: RDCVectorButton!
	var maxAgainButton: RDCVectorButton!
	var addDieButton: RDCVectorButton!
	var addValueButton: RDCVectorButton!
	var addSwitch: RDCSwitch!
	
	var rollButton: RDCVectorButton!
	var plusButton: RDCVectorButton!
	var minusButton: RDCVectorButton!
	
	let defaults = NSUserDefaults.standardUserDefaults()
	var rollSound: AVAudioPlayer?
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()

		makeButtons()
		pickerSides.delegate = self
		pickerSides.dataSource = self
		pickerHowMuchDice.delegate = self
		pickerHowMuchDice.dataSource = self
		pickerTargetNumber.delegate = self
		pickerTargetNumber.dataSource = self
		
		loadDefaults()
		
		let soundURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("SecondBeep", ofType: "wav")!)
		do {
			try rollSound = AVAudioPlayer(contentsOfURL: soundURL)
		} catch {
			print("sound cannot be loaded")
		}
		rollSound?.prepareToPlay()
	}
	
	
	
	override func viewDidAppear(animated: Bool) {
		updateButtonsFrames()
		updateLabelsFontSizes()
	}
	

	override func viewDidLayoutSubviews() {

	}
	
	
	func maxAgainButtonSwitched() {
		maxAgain = maxAgainButton.selected
		addDieButton.enabled = maxAgainButton.selected
		addValueButton.enabled = maxAgainButton.selected
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	
	// vytvoření tlačítek
	func makeButtons() {
		subtractOnesButton = RDCVectorButton(frame: subtractOnesPlaceHolder.bounds)
		subtractOnesButton.buttonColor = UIColor.whiteColor().CGColor
		subtractOnesButton.selected = subtractOnes
		subtractOnesButton.switchable = true
		subtractOnesPlaceHolder.addSubview(subtractOnesButton)
		subtractOnesButton.addTarget(self, action: "subtractOnesSwitched", forControlEvents: UIControlEvents.ValueChanged)
		
		maxAgainButton = RDCVectorButton(frame: maxAgainPlaceHolder.bounds)
		maxAgainButton.buttonColor = UIColor.whiteColor().CGColor
		maxAgainButton.selected = maxAgain
		maxAgainButton.switchable = true
		maxAgainPlaceHolder.addSubview(maxAgainButton)
		maxAgainButton.addTarget(self, action: "maxAgainButtonSwitched",
			forControlEvents: UIControlEvents.ValueChanged)
		
		addDieButton = RDCVectorButton(frame: addDiePlaceHolder.bounds)
		addDieButton.buttonColor = UIColor.whiteColor().CGColor
		addDieButton.selected = false
		addDiePlaceHolder.addSubview(addDieButton)
		
		addValueButton = RDCVectorButton(frame: addValuePlaceHolder.bounds)
		addValueButton.buttonColor = UIColor.whiteColor().CGColor
		addValueButton.selected = false
		addValuePlaceHolder.addSubview(addValueButton)

		rollButton = RDCVectorButton(frame: rollPlaceHolder.bounds)
		rollButton.buttonColor = UIColor.whiteColor().CGColor
		rollButton.selected = false
		rollButton.outerCircle = 0.8
		rollButton.innerCircle = 0.74
		rollButton.outerCircleHighlighted = 0.9
		rollButton.innerCircleHighlighted = 0.84
		rollPlaceHolder.addSubview(rollButton)
		rollButton.addTarget(self, action: "rollButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
		
		plusButton = RDCVectorButton(frame: plusPlaceHolder.bounds)
		plusButton.buttonColor = UIColor.whiteColor().CGColor
		plusButton.selected = false
		plusPlaceHolder.addSubview(plusButton)
		
		minusButton = RDCVectorButton(frame: minusPlaceHolder.bounds)
		minusButton.buttonColor = UIColor.whiteColor().CGColor
		minusButton.selected = false
		minusPlaceHolder.addSubview(minusButton)
		
		addSwitch = RDCSwitch(buttons: [addDieButton, addValueButton])

		addDieButton.enabled = maxAgain
		addDieButton.selected = maxAddDie
		addValueButton.enabled = maxAgain
		addValueButton.selected = maxAddValue
}
	
	
	
	// aktualizování velikosti tlačítek podle aktuální velikosti views
	func updateButtonsFrames() {
		subtractOnesButton.frame = subtractOnesPlaceHolder.bounds
		subtractOnesButton.update()
		maxAgainButton.frame = maxAgainPlaceHolder.bounds
		maxAgainButton.update()
		addDieButton.frame = addDiePlaceHolder.bounds
		addDieButton.update()
		addValueButton.frame = addValuePlaceHolder.bounds
		addValueButton.update()
		
		rollButton.frame = rollPlaceHolder.bounds
		rollButton.update()
		plusButton.frame = plusPlaceHolder.bounds
		plusButton.update()
		minusButton.frame = minusPlaceHolder.bounds
		minusButton.update()
		
	}
	
	
	// nastavení velikosti písma podle velikosti view
	func updateLabelsFontSizes() {
		successesLabel.font = UIFont(
			name: successesLabel.font.fontName,
			size: CGFloat(successesLabel.bounds.height * 0.65))
		successesDisplay.font = UIFont(
			name: successesDisplay.font.fontName,
			size: CGFloat(successesDisplay.bounds.height * 0.9))
		onesLabel.font = UIFont(
			name: onesLabel.font.fontName,
			size: CGFloat(onesLabel.bounds.height * 0.65))
		onesDisplay.font = UIFont(
			name: onesDisplay.font.fontName,
			size: CGFloat(onesDisplay.bounds.height * 0.9))
		dicePoolLabel.font = UIFont(
			name: dicePoolLabel.font.fontName,
			size: CGFloat(dicePoolLabel.bounds.height * 0.65))
		dicePoolDisplay.font = UIFont(
			name: dicePoolDisplay.font.fontName,
			size: CGFloat(dicePoolDisplay.bounds.height * 0.9))
	}
	
	
	// picker view data source delegate funcs
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch pickerView {
		case pickerSides:
			return 100
		case pickerHowMuchDice:
			return 100
		case pickerTargetNumber:
			return pickerSides.selectedRowInComponent(0) + 1
		default:
			print("something's wrong in pickerView:numberOfRowsInComponent:")
			return 1
		}
	}

	
	// picker view delegate funcs
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch pickerView {
		case pickerSides:
			sides = pickerSides.selectedRowInComponent(0) + 1
			pickerTargetNumber.reloadAllComponents()
		case pickerHowMuchDice:
			numberOfDice = pickerHowMuchDice.selectedRowInComponent(0) + 1
		case pickerTargetNumber:
			targetNumber = pickerTargetNumber.selectedRowInComponent(0) + 1
		default:
			return
		}
	}
	
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch pickerView {
		case pickerSides:
			return "d\(row + 1)"
		case pickerHowMuchDice:
			return "\(row + 1)"
		case pickerTargetNumber:
			return "\(row + 1)"
		default: return "-"
		}
	}
	
	
	
	func rollButtonAction() {
		saveDefaults()
		numberOfDice = pickerHowMuchDice.selectedRowInComponent(0) + 1
		sides = pickerSides.selectedRowInComponent(0) + 1
		targetNumber = pickerTargetNumber.selectedRowInComponent(0) + 1
		maxAgain = maxAgainButton.selected
		maxAddDie = addDieButton.selected
		maxAddValue = addValueButton.selected
		subtractOnes = subtractOnesButton.selected
		
		if roller == nil {
			roller = Roller(dataSource: self)
		}
		
		roller?.newDicePool()

		updateResults()
		
		rollSound?.play()
	}
	
	
	func subtractOnesSwitched() {
		subtractOnes = subtractOnesButton.selected
		roller?.updateDicePool()
		updateResults()
	}
	
	
	func updateResults() {
		successesDisplay.text = "\(roller!.successes)"
		onesDisplay.text = "\(roller!.ones)"
		dicePoolDisplay.text = "\(roller!.numberOfDice)"
	}
	
	
	
	func loadDefaults() {
		numberOfDice = defaults.integerForKey("numberOfDice")
		pickerHowMuchDice.selectRow(numberOfDice - 1, inComponent: 0, animated: true)

		sides = defaults.integerForKey("sides")
		pickerSides.selectRow(sides - 1, inComponent: 0, animated: true)
		
		targetNumber = defaults.integerForKey("targetNumber")
		pickerTargetNumber.selectRow(targetNumber - 1, inComponent: 0, animated: true)
		
		maxAgainButton.selected = defaults.boolForKey("maxAgain")
		maxAgainButtonSwitched()
		addDieButton.selected = defaults.boolForKey("maxAddDie")
		addValueButton.selected = defaults.boolForKey("maxAddValue")
		subtractOnesButton.selected = defaults.boolForKey("subtractOnes")
		
	}
	
	
	func saveDefaults() {
		defaults.setInteger(numberOfDice, forKey: "numberOfDice")
		defaults.setInteger(sides, forKey: "sides")
		defaults.setInteger(targetNumber, forKey: "targetNumber")
		defaults.setBool(maxAgainButton.selected, forKey: "maxAgain")
		defaults.setBool(addDieButton.selected, forKey: "maxAddDie")
		defaults.setBool(addValueButton.selected, forKey: "maxAddValue")
		defaults.setBool(subtractOnesButton.selected, forKey: "subtractOnes")
	}
}


