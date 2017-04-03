//
//  GameScene.swift
//  Basketball
//
//  Created by Reid Ellis on 2017-03-15.
//  Copyright © 2017 Ronnie Ellis. All rights reserved.
//

import SpriteKit

let kSceneTransitionDelay = 0.6

class GameScene : SKScene {
	var backLabel: SKLabelNode!
	var scoreLabel: SKLabelNode!
	var basketballNet: SKSpriteNode!
	var basketball: SKSpriteNode!
	var startTouchPos = CGPoint(x: 0, y: 0)
	var startTouchTime: TimeInterval = 0
	var lastTouchPos = CGPoint(x: 0, y: 0)
	var lastTouchTime: TimeInterval = 0
	let yBasketballStart = -500.0
	let basketballScale = CGFloat(0.75)
	let basketballHoopHeight = 200.0
	var shotCount = 0
	var isShooting = false
	var recordedDrags = [CGPoint]()
	let basketballCategory : UInt32 = 1
	let hoopCategory : UInt32 = 2
	let basketballYImpulse = CGFloat(1500.0)
	let inFrontZ = CGFloat(6.0)
	let droppingZ = CGFloat(4.0)

	override func didMove(to view: SKView) {
		backLabel = childNode(withName: "//backLabel") as? SKLabelNode
		scoreLabel = childNode(withName: "//scoreLabel") as? SKLabelNode
		basketballNet = childNode(withName: "//net-front") as? SKSpriteNode
		basketball = childNode(withName: "//basketball") as? SKSpriteNode
		resetBasketBall()
	}

	// put the basketball at the bottom of the screen, perhaps in a random x location, and scaled up
	func resetBasketBall() {
		var rndX = 0.0
		// the first shot is alsway at x=0
		if shotCount > 0 {
			// x varies between -300 and +300
			rndX = -300.0 + Double(arc4random_uniform(600))
			// rnadomness increases over first 3 shots
			if shotCount < 4 {
				rndX = rndX / (4.0 - Double(shotCount))
			}
		}
		basketball.position = CGPoint(x: rndX, y: yBasketballStart)
		basketball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
		basketball.physicsBody?.affectedByGravity = false
		basketball.physicsBody?.isDynamic = false
		// make baskeball bigger
		basketball.xScale = 1.5 * basketballScale
		basketball.yScale = 1.5 * basketballScale
		// put it in front of the net
		basketball.zPosition = inFrontZ
		// don't collide with anything for now
		basketball.physicsBody?.collisionBitMask = 0
		// not recording touch events yet
		isShooting = false
		// nuke any leftover recorded drag points
		recordedDrags = [CGPoint]()
	}

	func touchDown(atPoint pos: CGPoint, atTime t: TimeInterval) {
		// have to start inside the basketball
		guard basketball.contains(pos) else {
			return
		}
		isShooting = true

		startTouchPos = pos
		lastTouchPos = pos
		startTouchTime = t
		lastTouchTime = t
		addDrag(point: pos)
	}

	func addDrag(point: CGPoint) {
		recordedDrags.append(point)
	}

	func touchMoved(atPoint pos: CGPoint, atTime t: TimeInterval) {
		guard isShooting else {
			return
		}
		lastTouchPos = pos
		lastTouchTime = t
		addDrag(point: pos)
	}

	// what to do when the user taps the "<Back" label
	func goBack() {
		self.backLabel.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
		// Load the TitleScene
		if let view = self.view, let scene = MenuScene(fileNamed: "MenuScene") {
			// Set the scale mode to scale to fit the window
			scene.scaleMode = .aspectFill
			let reveal = SKTransition.moveIn(with: .left, duration: kSceneTransitionDelay)
			// Present the scene
			view.presentScene(scene, transition:reveal)
		}
	}

	func touchUp(atPoint pos : CGPoint, atTime t: TimeInterval) {
		// check for touching the "< Back" label
		if touchWasHandledByLabel(atPoint: pos,
		                          withDict: [ backLabel : { self.goBack() } ]) {
			return
		}

		// nothing else to do unless we are shooting
		guard isShooting else {
			return
		}

		// add the new point tothe list of drag points
		addDrag(point: pos)

		// need to move your finger to move the ball
		guard recordedDrags.count > 1 else {
			resetBasketBall()
			return
		}

		// calculate the dx / dy vector for the ball
		var dx = CGFloat(0.0)
		var dy = dx
		// average the last few drags to get a vector
		for i in 1..<recordedDrags.count {
			// CGFloat.native is a Double
			dx += recordedDrags[i].x - recordedDrags[i-1].x
			dy += recordedDrags[i].y - recordedDrags[i-1].y
		}
		// average them
		dx /= CGFloat(recordedDrags.count)
		dy /= CGFloat(recordedDrags.count)

		// we always want dy to be at basketballYImpulse, so find out what the appropriate dx value is
		let yFactor = basketballYImpulse / dy
		dx *= yFactor

		// launch the basketball
		launch(x: dx, y: basketballYImpulse)
	}
	
	func launch(x: CGFloat, y: CGFloat) {
		basketball.physicsBody?.affectedByGravity = true
		basketball.physicsBody?.isDynamic = true
		// give the basketball a kick in the right direction
		basketball.physicsBody?.velocity = CGVector(dx: x, dy: y)
		// shrink the basketball down to size soon after it's launched
		basketball.run(SKAction.scale(to: basketballScale, duration: 0.33))
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { touchDown(atPoint: t.location(in: self), atTime: t.timestamp) }
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { touchMoved(atPoint: t.location(in: self), atTime: t.timestamp) }
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { touchUp(atPoint: t.location(in: self), atTime: t.timestamp) }
	}

	override func update(_ currentTime: TimeInterval) {
		let ballClearHeight = basketball.position.y - basketball.size.height/2.0
		if ballClearHeight.native > basketballHoopHeight {
			// allow colliding with the hoop
			basketball.physicsBody?.collisionBitMask = hoopCategory
			// put it behind the net
			basketball.zPosition = droppingZ
		}
		// basketball has dropped out of the frame
		if basketball.position.y + basketball.size.height/2.0 < self.frame.minY {
			shotCount += 1
			resetBasketBall()
		}
	}
}
