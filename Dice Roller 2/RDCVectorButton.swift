//
//  RDCVectorButton.swift
//  CALayer Animation Test 1
//
//  Created by David Rak on 08/01/16.
//  Copyright © 2016 David Rak. All rights reserved.
//

import UIKit

class RDCVectorButton: UIControl {
	
	private var renderer = RDCVectorButtonRenderer()
	var delegate: RDCVectorButtonDelegate?
	
	var buttonColor = UIColor.blackColor().CGColor {
		didSet { renderer.updateLayers() } }
	var symbolColor = UIColor.blackColor().CGColor {
		didSet { renderer.updateLayers() } }
	var outerCircle: CGFloat = 0.7
	var innerCircle: CGFloat = 0.62
	var outerCircleHighlighted: CGFloat = 1.0
	var innerCircleHighlighted: CGFloat = 0.92
	var disabledAlpha = 0.4
	
	// if false, button act just like button
	// if true, button switches from selected to deselected and vice versa
	// default is false
	var switchable = false
	var canBeSwitched = true
	
	private var lastSelected = false
	private var internalSelected = false
	override var selected: Bool {
		get {
			return internalSelected
		}
		set {
			internalSelected = newValue
			//			if lastSelected != selected { renderer.updateShapes() }
			renderer.updateShapes()
			lastSelected = newValue
		}
	}
	
	private var lastHighlighted = false
	private var internalHighlighted = false
	override var highlighted: Bool {
		get { return internalHighlighted }
		set {
			internalHighlighted = newValue
			if lastHighlighted != highlighted { renderer.updateShapes() }
			lastHighlighted = newValue
		}
	}
	
	private var internalEnabled = true
	override var enabled: Bool {
		get { return internalEnabled }
		set {
			internalEnabled = newValue
			if newValue {
				renderer.updateShapes()
			} else {
				renderer.updateShapes()
			}
		}
	}
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		renderer.button = self
		
		self.selected = false
		self.highlighted = false
		
		createSublayers()
	}
	
	
	
	private func createSublayers() {
		renderer.updateLayers()
		renderer.updateShapes()
		
		layer.addSublayer(renderer.buttonLayer)
	}
	
	
	func update() {
		renderer.updateShapes()
	}
	
	
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if internalEnabled {
			lastHighlighted = internalHighlighted
			internalHighlighted = true
			renderer.updateShapes()
		}
	}
	
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if internalEnabled {
			if CGRectContainsPoint(self.bounds, touches.first!.locationInView(self)) {
				highlighted = true
			} else {
				highlighted = false
			}
		}
	}
	
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if internalEnabled {
			if CGRectContainsPoint(self.bounds, touches.first!.locationInView(self)) {
				if switchable {
					if canBeSwitched {
						lastSelected = internalSelected
						internalSelected = !internalSelected
						sendActionsForControlEvents(UIControlEvents.ValueChanged)
						delegate?.buttonSwitched(self)
					}
				} else {
					sendActionsForControlEvents(UIControlEvents.TouchUpInside)
				}
			}
			internalHighlighted = false
			renderer.updateShapes()
		}
	}
	
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		super.touchesCancelled(touches, withEvent: event)
		print("touch CANCELED")
	}
	
	
	
	
	
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}




//-------------------------------



private class RDCVectorButtonRenderer {
	weak var button: RDCVectorButton!
	
	var shapeSelected = UIBezierPath()
	var shapeDeselected = UIBezierPath()
	var shapeHighlightedSelected = UIBezierPath()
	var shapeHighlightedDeselected = UIBezierPath()
	
	var buttonLayer = CAShapeLayer()
	var symbolLayer = CAShapeLayer()
	
	let animationDuration = CFTimeInterval(0.07)
	
	
	
	func updateLayers() {
		buttonLayer.fillRule = kCAFillRuleEvenOdd
		symbolLayer.fillRule = kCAFillRuleEvenOdd
		
		buttonLayer.fillColor = button.buttonColor
		symbolLayer.fillColor = button.symbolColor
	}
	
	
	
	func updateShapes() {
//		if !button.enabled { return }
		
		if buttonLayer.path == nil {
			let path = UIBezierPath(
				arcCenter: CGPoint(x: button.bounds.width / 2, y:	button.bounds.height / 2),
				radius: 0.0,
				startAngle: 0.0,
				endAngle: CGFloat(2 * M_PI),
				clockwise: true)
			path.closePath()
			buttonLayer.path = path.CGPath
		}
		
		if button.enabled {
			button.layer.opacity = 1.0
		} else {
			button.layer.opacity = Float(button.disabledAlpha)
		}

		switch button.state {
			// Disabled
//		case UIControlState.Disabled:
//			print("updateShape switch: .Disabled")
			
		// Highlighted Selected
		case [UIControlState.Selected, UIControlState.Highlighted], [UIControlState.Selected, UIControlState.Highlighted, UIControlState.Disabled]:
			drawShapeHighlightedSelected()
			let animation = CABasicAnimation(keyPath: "path")
			// start animation with current graphic if another animation is running
			// or start from graphic of last state
			animation.fromValue =
				(buttonLayer.presentationLayer() as? CAShapeLayer)?.path ?? lastShape()
			
			animation.toValue = shapeHighlightedSelected.CGPath
			animation.duration = animationDuration
			animation.removedOnCompletion = false
			animation.fillMode = kCAFillModeBoth
			buttonLayer.removeAllAnimations()
			buttonLayer.addAnimation(animation, forKey: animation.keyPath)
			
		// Highlighted
		case UIControlState.Highlighted, [UIControlState.Highlighted, UIControlState.Disabled]:
			drawShapeHighlighted()
			let animation = CABasicAnimation(keyPath: "path")
			// start animation with current graphic if another animation is running
			// or start from graphic of last state
			animation.fromValue =
				(buttonLayer.presentationLayer() as? CAShapeLayer)?.path ?? lastShape()
			animation.toValue = shapeHighlightedDeselected.CGPath
			animation.duration = animationDuration
			animation.removedOnCompletion = false
			animation.fillMode = kCAFillModeBoth
			buttonLayer.removeAllAnimations()
			buttonLayer.addAnimation(animation, forKey: animation.keyPath)
			
		// Selected
		case UIControlState.Selected, [UIControlState.Selected, UIControlState.Disabled]:
			drawShapeSelected()
			let animation = CABasicAnimation(keyPath: "path")
			// start animation with current graphic if another animation is running
			// or start from graphic of last state
			animation.fromValue =
				(buttonLayer.presentationLayer() as? CAShapeLayer)?.path ?? lastShape()
			animation.toValue = shapeSelected.CGPath
			animation.duration = animationDuration
			animation.removedOnCompletion = false
			animation.fillMode = kCAFillModeBoth
			buttonLayer.removeAllAnimations()
			buttonLayer.addAnimation(animation, forKey: animation.keyPath)
			
		// Normal (deselected)
		case UIControlState.Normal, [UIControlState.Normal, UIControlState.Disabled]:
			drawShapeDeselected()
			let animation = CABasicAnimation(keyPath: "path")
			// start animation with current graphic if another animation is running
			// or start from graphic of last state
			animation.fromValue =
				(buttonLayer.presentationLayer() as? CAShapeLayer)?.path ?? lastShape()
			animation.toValue = shapeDeselected.CGPath
			animation.duration = animationDuration
			animation.removedOnCompletion = false
			animation.fillMode = kCAFillModeBoth
			buttonLayer.removeAllAnimations()
			buttonLayer.addAnimation(animation, forKey: animation.keyPath)
			
		default:
			print("updateShape switch: something else")
		}
		
	}
	
	
	
	func lastShape() -> CGPath {
		switch (button.lastSelected, button.lastHighlighted) {
		case (false, false):
			return shapeDeselected.CGPath
		case (true, false):
			return shapeSelected.CGPath
		case (false, true):
			return shapeHighlightedDeselected.CGPath
		case (true, true):
			return shapeHighlightedSelected.CGPath
		}
		
	}
		
	
	func drawShapeSelected() {
		shapeSelected = UIBezierPath()
		shapeSelected.addArcWithCenter(
			CGPoint(x: button.bounds.width / 2, y: button.bounds.height / 2),
			radius: min(button.bounds.width / 2 * button.outerCircle, button.bounds.height / 2 * button.outerCircle),
			startAngle: 0.0,
			endAngle: CGFloat(2.0 * M_PI),
			clockwise: true)
		shapeSelected.addArcWithCenter(
			CGPoint(x: button.bounds.width / 2, y: button.bounds.height / 2),
			radius: 0.1,
			startAngle: 0.0,
			endAngle: CGFloat(2.0 * M_PI),
			clockwise: true)
		shapeSelected.closePath()
	}
	
	
	func drawShapeDeselected() {
		shapeDeselected = UIBezierPath()
		shapeDeselected.addArcWithCenter(CGPoint(x: button.bounds.width / 2, y:	button.bounds.height / 2),
			radius: min(button.bounds.width / 2 * button.outerCircle, button.bounds.height / 2 * button.outerCircle),
			startAngle: 0.0,
			endAngle: CGFloat(2 * M_PI),
			clockwise: true)
		shapeDeselected.addArcWithCenter(CGPoint(x: button.bounds.width / 2, y: button.bounds.height / 2),
			radius: min(button.bounds.width / 2 * button.innerCircle, button.bounds.height / 2 * button.outerCircle),
			startAngle: 0.0,
			endAngle: CGFloat(2 * M_PI),
			clockwise: true)
		shapeDeselected.closePath()
	}
	
	
	func drawShapeHighlighted() {
		shapeHighlightedDeselected = UIBezierPath()
		shapeHighlightedDeselected.addArcWithCenter(
			CGPoint(x: button.bounds.width / 2, y: button.bounds.height / 2),
			radius: min(button.bounds.width / 2 * button.outerCircleHighlighted, button.bounds.height / 2 * button.outerCircleHighlighted),
			startAngle: 0.0,
			endAngle: CGFloat(2.0 * M_PI),
			clockwise: true)
		shapeHighlightedDeselected.addArcWithCenter(
			//			touchPoint ??
			CGPoint(x: button.bounds.width / 2, y: button.bounds.height / 2),
			radius: min(button.bounds.width / 2 * button.innerCircleHighlighted, button.bounds.height / 2 * button.innerCircleHighlighted),
			startAngle: 0.0,
			endAngle: CGFloat(2.0 * M_PI),
			clockwise: true)
		shapeHighlightedDeselected.closePath()
	}
	
	
	func drawShapeHighlightedSelected() {
		shapeHighlightedSelected = UIBezierPath()
		shapeHighlightedSelected.addArcWithCenter(
			CGPoint(x: button.bounds.width / 2, y: button.bounds.height / 2),
			radius: min(button.bounds.width / 2 * button.outerCircleHighlighted, button.bounds.height / 2 * button.outerCircleHighlighted),
			startAngle: 0.0,
			endAngle: CGFloat(2.0 * M_PI),
			clockwise: true)
				shapeHighlightedSelected.addArcWithCenter(
					CGPoint(x: button.bounds.width / 2, y: button.bounds.height / 2),
					radius: 0.0,
					startAngle: 0.0,
					endAngle: CGFloat(2.0 * M_PI),
					clockwise: true)
		shapeHighlightedSelected.closePath()
	}
	
}

