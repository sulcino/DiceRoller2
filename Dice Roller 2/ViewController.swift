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
	var maxAgain: Bool {
		get { return maxAgainButton.selected }
		set { maxAgainButton.selected = newValue }
	}
	var maxAddDie: Bool {
		get { return addDieButton.selected }
		set {
			addDieButton.selected = newValue
		}
	}
	var maxAddValue: Bool {
		get { return addValueButton.selected }
		set {
			addValueButton.selected = newValue
		}
	}
	var subtractOnes: Bool {
		get { return subtractOnesButton.selected }
		set { subtractOnesButton.selected = newValue }
	}
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
	@IBOutlet weak var lockPlaceHolder: UIView!
	
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
	var lockPickersButton: RDCVectorButton!
	
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
		updateLabelsFont()
	}
	

	override func viewDidLayoutSubviews() {
		updateButtonsFrames()
		updateLabelsFont()
	}
	
	
	func maxAgainButtonSwitched() {
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
		subtractOnesButton.addTarget(self, action: #selector(ViewController.subtractOnesSwitched), forControlEvents: UIControlEvents.ValueChanged)
		
		maxAgainButton = RDCVectorButton(frame: maxAgainPlaceHolder.bounds)
		maxAgainButton.buttonColor = UIColor.whiteColor().CGColor
		maxAgainButton.selected = maxAgain
		maxAgainButton.switchable = true
		maxAgainPlaceHolder.addSubview(maxAgainButton)
		maxAgainButton.addTarget(self, action: #selector(ViewController.maxAgainButtonSwitched),
			forControlEvents: UIControlEvents.ValueChanged)
		
		addDieButton = RDCVectorButton(frame: addDiePlaceHolder.bounds)
		addDieButton.buttonColor = UIColor.whiteColor().CGColor
		addDieButton.selected = true
		addDieButton.switchable = true
		addDiePlaceHolder.addSubview(addDieButton)
		
		addValueButton = RDCVectorButton(frame: addValuePlaceHolder.bounds)
		addValueButton.buttonColor = UIColor.whiteColor().CGColor
		addValueButton.switchable = true
		addValueButton.selected = false
		addValuePlaceHolder.addSubview(addValueButton)
		
		lockPickersButton = RDCVectorButton(frame: lockPlaceHolder.bounds)
		lockPickersButton.buttonColor = UIColor.whiteColor().CGColor
		lockPickersButton.switchable = true
		lockPickersButton.selected = false
		lockPickersButton.addTarget(self, action: #selector(ViewController.lockPickersButtonAction), forControlEvents: UIControlEvents.ValueChanged)
		lockPlaceHolder.addSubview(lockPickersButton)

		rollButton = RDCVectorButton(frame: rollPlaceHolder.bounds)
		rollButton.buttonColor = UIColor.whiteColor().CGColor
		rollButton.selected = false
		rollButton.outerCircle = 0.8
		rollButton.innerCircle = 0.74
		rollButton.outerCircleHighlighted = 0.9
		rollButton.innerCircleHighlighted = 0.84
		rollPlaceHolder.addSubview(rollButton)
		rollButton.addTarget(self, action: #selector(ViewController.rollButtonAction), forControlEvents: UIControlEvents.TouchUpInside)
		
		plusButton = RDCVectorButton(frame: plusPlaceHolder.bounds)
		plusButton.buttonColor = UIColor.whiteColor().CGColor
		plusButton.symbolColor = UIColor.whiteColor().CGColor
		plusButton.selected = false
		plusButton.buttonSymbolDrawer = {(width: CGFloat, height: CGFloat) -> UIBezierPath in
			let path = UIBezierPath()
			path.moveToPoint(CGPoint(x: width * 0.26, y: height * 0.46))
			path.addLineToPoint(CGPoint(x: width * 0.46, y: height * 0.46))
			path.addLineToPoint(CGPoint(x: width * 0.46, y: height * 0.26))
			path.addLineToPoint(CGPoint(x: width * 0.54, y: height * 0.26))
			path.addLineToPoint(CGPoint(x: width * 0.54, y: height * 0.46))
			path.addLineToPoint(CGPoint(x: width * 0.74, y: height * 0.46))
			path.addLineToPoint(CGPoint(x: width * 0.74, y: height * 0.54))
			path.addLineToPoint(CGPoint(x: width * 0.54, y: height * 0.54))
			path.addLineToPoint(CGPoint(x: width * 0.54, y: height * 0.74))
			path.addLineToPoint(CGPoint(x: width * 0.46, y: height * 0.74))
			path.addLineToPoint(CGPoint(x: width * 0.46, y: height * 0.54))
			path.addLineToPoint(CGPoint(x: width * 0.26, y: height * 0.54))
			path.closePath()
			return path
		}
		plusPlaceHolder.addSubview(plusButton)
		plusButton.addTarget(self, action: #selector(ViewController.plusButtonAction), forControlEvents: .TouchUpInside)
		
		minusButton = RDCVectorButton(frame: minusPlaceHolder.bounds)
		minusButton.buttonColor = UIColor.whiteColor().CGColor
		minusButton.symbolColor = UIColor.whiteColor().CGColor
		minusButton.selected = false
		minusButton.buttonSymbolDrawer = {(width: CGFloat, height: CGFloat) -> UIBezierPath in
			let path = UIBezierPath()
			path.moveToPoint(CGPoint(x: width * 0.26, y: height * 0.46))
			path.addLineToPoint(CGPoint(x: width * 0.74, y: height * 0.46))
			path.addLineToPoint(CGPoint(x: width * 0.74, y: height * 0.54))
			path.addLineToPoint(CGPoint(x: width * 0.26, y: height * 0.54))
			path.closePath()
			return path
		}
		minusPlaceHolder.addSubview(minusButton)
		minusButton.addTarget(self, action: #selector(ViewController.minusButtonAction), forControlEvents: .TouchUpInside)
		
		// setup switch and it's buttons
		addDieButton.selected = maxAddDie
		addValueButton.selected = maxAddValue
		addDieButton.enabled = maxAgain
		addValueButton.enabled = maxAgain
		
		addSwitch = RDCSwitch(buttons: [addDieButton, addValueButton])
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
		lockPickersButton.frame = lockPlaceHolder.bounds
		lockPickersButton.update()
		
		rollButton.frame = rollPlaceHolder.bounds
		rollButton.update()
		plusButton.frame = plusPlaceHolder.bounds
		plusButton.update()
		minusButton.frame = minusPlaceHolder.bounds
		minusButton.update()
		
	}
	
	
	// nastavení velikosti písma podle velikosti view
	func updateLabelsFont() {
		let currentTraitCollection = view.traitCollection
		switch (currentTraitCollection.horizontalSizeClass, currentTraitCollection.verticalSizeClass) {
		case (.Compact, .Regular):
			successesLabel.textAlignment = .Right
		case (_, .Compact):
			successesLabel.textAlignment = .Center
		default:
			print("updateLabelsFont - uncaught combination of size classes")
		}
	}
	
	
	// picker view data source delegate funcs
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch pickerView {
		case pickerSides:
			return 99
		case pickerHowMuchDice:
			return 100
		case pickerTargetNumber:
			return pickerSides.selectedRowInComponent(0) + 2
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
			return "d\(row + 2)"
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
		sides = pickerSides.selectedRowInComponent(0) + 2
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
	
	
	func plusButtonAction() {
		if roller == nil { return }
		roller?.addDice(pickerHowMuchDice.selectedRowInComponent(0) + 1)
		updateResults()
	}
	
	
	func minusButtonAction() {
		if roller == nil { return }
		roller?.subtractDice(pickerHowMuchDice.selectedRowInComponent(0) + 1)
		updateResults()
	}
	
	
	func lockPickersButtonAction() {
		if lockPickersButton.selected {
			pickerSides.userInteractionEnabled = false
			pickerSides.alpha = 0.3
			pickerTargetNumber.userInteractionEnabled = false
			pickerTargetNumber.alpha = 0.3
		} else {
			pickerSides.userInteractionEnabled = true
			pickerSides.alpha = 1.0
			pickerTargetNumber.userInteractionEnabled = true
			pickerTargetNumber.alpha = 1.0
		}
	}
	
	
	func subtractOnesSwitched() {
		if roller != nil {
			subtractOnes = subtractOnesButton.selected
			roller?.updateDicePool()
			updateResults()
		}
	}
	
	
	func updateResults() {
		successesDisplay.text = "\(roller!.successes)"
		onesDisplay.text = "\(roller!.ones)"
		dicePoolDisplay.text = "\(roller!.numberOfDice)"
	}
	
	
	
	func loadDefaults() {
		if defaults.boolForKey("defaultsSaved") {
			numberOfDice = defaults.integerForKey("numberOfDice")
			sides = defaults.integerForKey("sides")
			targetNumber = defaults.integerForKey("targetNumber")
			maxAgainButton.selected = defaults.boolForKey("maxAgain")
			addDieButton.selected = defaults.boolForKey("maxAddDie")
			addDieButton.canBeSwitched = !addDieButton.selected
			addValueButton.selected = defaults.boolForKey("maxAddValue")
			addValueButton.canBeSwitched = !addValueButton.selected
			subtractOnesButton.selected = defaults.boolForKey("subtractOnes")
			lockPickersButton.selected = defaults.boolForKey("pickersLocked")
			lockPickersButtonAction()
		}
		pickerHowMuchDice.selectRow(numberOfDice - 1, inComponent: 0, animated: true)
		pickerSides.selectRow(sides - 2, inComponent: 0, animated: true)
		pickerTargetNumber.selectRow(targetNumber - 1, inComponent: 0, animated: true)
		maxAgainButtonSwitched()
	}
	
	
	func saveDefaults() {
		defaults.setBool(true, forKey: "defaultsSaved")
		defaults.setInteger(numberOfDice, forKey: "numberOfDice")
		defaults.setInteger(sides, forKey: "sides")
		defaults.setInteger(targetNumber, forKey: "targetNumber")
		defaults.setBool(maxAgainButton.selected, forKey: "maxAgain")
		defaults.setBool(addDieButton.selected, forKey: "maxAddDie")
		defaults.setBool(addValueButton.selected, forKey: "maxAddValue")
		defaults.setBool(subtractOnesButton.selected, forKey: "subtractOnes")
		defaults.setBool(lockPickersButton.selected, forKey: "pickersLocked")
	}
	
	
	@IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
		
	}
}


