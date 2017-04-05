//
//  GameScene.swift
//  Basketball
//
//  Created by Reid Ellis on 2017-03-15.
//  Copyright © 2017 Ronnie Ellis. All rights reserved.
//

import SpriteKit

let kSceneTransitionDelay = 0.6

class GameScene : SKScene, SKPhysicsContactDelegate {
	var backLabel: SKLabelNode!
	var scoreLabel: SKLabelNode!
	// area where the ball scores a point
	var scoreZone: SKSpriteNode!
	// the current player score
	var score = 0
	// the basketball sprite
	var basketball: SKSpriteNode!
	// ball-shooting state to avoid taking action when user touches outside the ball / labels
	var isShooting = false
	// recording of the user's touch points in a throw
	var throwPoints = [CGPoint]()
	// the physics body category for the hoop
	let hoopCategory : UInt32 = 2
	// should we check for the ball entering the scoreZone?
	var shouldDetectScoreCollision = false
	// don't count collisions with the scoreZone more than once
	var collidedWithScoreZone = false
	// scene constants
	let yBasketballStart = -500.0
	let basketballScale = CGFloat(0.75)
	let basketballHoopHeight = 200.0
	let basketballYImpulse = CGFloat(3750.0)
	let inFrontZ = CGFloat(6.0)
	let droppingZ = CGFloat(4.0)

	override func didMove(to view: SKView) {
		backLabel = childNode(withName: "//backLabel") as? SKLabelNode
		scoreLabel = childNode(withName: "//scoreLabel") as? SKLabelNode
		basketball = childNode(withName: "//basketball") as? SKSpriteNode
		scoreZone = childNode(withName: "//scoreZone") as? SKSpriteNode
		// make sure we get notified of any collisions, including pass-through (for scoreZone)
		physicsWorld.contactDelegate = self
		resetBasketBall()
	}

	// put the basketball at the bottom of the screen, perhaps in a random x location, and scaled up
	func resetBasketBall() {
		// reset score state
		if !collidedWithScoreZone {
			recordScore()
			score = 0
			scoreLabel.text = "0"
		}
		collidedWithScoreZone = false
		shouldDetectScoreCollision = false

		// the first shot is always at x=0
		var randomX = 0.0
		if score > 0 {
			// x varies between -300 and +300
			randomX = -300.0 + Double(arc4random_uniform(600))
			// rnadomness increases over first 3 shots
			if score < 4 {
				randomX = randomX / (4.0 - Double(score))
			}
		}

		basketball.position = CGPoint(x: randomX, y: yBasketballStart)
		// not moving
		basketball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

		// ball isn't affected by the physics simulation at all
		basketball.physicsBody?.isDynamic = false

		// stop any running scale animation
		basketball.removeAction(forKey: "scale")

		// make basketball bigger
		basketball.xScale = 2 * basketballScale
		basketball.yScale = 2 * basketballScale

		// not recording touch events yet
		isShooting = false

		// nuke any leftover recorded drag points
		throwPoints = [CGPoint]()

		//
		// Things that will be changed after the ball moves above the net
		//

		// put ball's Z location it in front of the net
		basketball.zPosition = inFrontZ

		// don't collide with anything
		basketball.physicsBody?.collisionBitMask = 0
}

	func touchDown(atPoint pos: CGPoint, atTime t: TimeInterval) {
		// have to start inside the basketball
		guard basketball.contains(pos) else {
			return
		}
		isShooting = true

		addDrag(point: pos)
	}

	func addDrag(point: CGPoint) {
		throwPoints.append(point)
	}

	func recordScore() {
		if score > 0 {
			// add the score before wiping it out
			MenuScene.scores.add(score: score)
		}
	}

	// what to do when the user taps the "<Back" label
	func goBack() {
		// record the current score if it's non-zero
		recordScore()
		// Load the TitleScene
		if let view = self.view, let scene = MenuScene(fileNamed: "MenuScene") {
			// Set the scale mode to scale to fit the window
			scene.scaleMode = .aspectFill
			let reveal = SKTransition.moveIn(with: .left, duration: kSceneTransitionDelay)
			// Present the scene
			view.presentScene(scene, transition:reveal)
		}
	}
	
	func touchMoved(atPoint pos: CGPoint, atTime t: TimeInterval) {
		guard isShooting else {
			return
		}
		addDrag(point: pos)
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
		guard throwPoints.count > 1 else {
			resetBasketBall()
			return
		}

		// calculate the dx / dy vector for the ball
		var dx = CGFloat(0.0)
		var dy = dx
		// average the last few drags to get a vector
		for i in 1 ..< throwPoints.count {
			// CGFloat.native is a Double
			dx += throwPoints[i].x - throwPoints[i-1].x
			dy += throwPoints[i].y - throwPoints[i-1].y
		}
		// average them
		dx /= CGFloat(throwPoints.count)
		dy /= CGFloat(throwPoints.count)

		// we always want dy to be at basketballYImpulse, so find out what the appropriate dx value is
		let yFactor = basketballYImpulse / dy
		dx *= yFactor

		// launch the basketball
		launch(x: dx, y: basketballYImpulse)
	}
	
	func launch(x inX: CGFloat, y: CGFloat) {
		// make a 1200-magnitude vector that points just above the net
		var netVector = CGVector(dx: scoreZone.position.x - basketball.position.x,
		                         dy: scoreZone.position.y + 1200 - basketball.position.y)
		let netVectorYFactor = basketballYImpulse / netVector.dy
		netVector = netVector * netVectorYFactor

		// limit magnitude of x such that the max angle is 45º
		var x = inX
		if abs(x) > abs(y) {
			x = abs(y)*(x/abs(x))
			print("Updated x: \(inX) -> \(x)")
		}

		// allow the ball to be affected by the physics simulation
		basketball.physicsBody?.isDynamic = true

		// average out 2 x the user vector with 1 x the netVector to give the user a bit of a helping hand
		let userThrowVector = CGVector(dx: x, dy: y)
		// weight of helping hand is 1/3
		let ballVector = (userThrowVector*2 + netVector) * 0.333

		// give the basketball a kick in the given direction
		basketball.physicsBody?.velocity = ballVector

		// shrink the basketball down to size soon after it's launched - name this action
		// so that it can be cancelled if the ball flies offscreen
		basketball.run(SKAction.scale(to: basketballScale, duration: 0.66), withKey: "scale")
	}

	func didBegin(_ contact: SKPhysicsContact) {
		// check for the ball contacting the scoreZone
		guard let ballBody = basketball.physicsBody, let scoreBody = scoreZone.physicsBody else {
			return
		}
		// it doesn't matter who touches who, so just use array "contains" to handle both cases
		let bodies = [contact.bodyA, contact.bodyB]
		if bodies.contains(ballBody) && bodies.contains(scoreBody) && shouldDetectScoreCollision {
			addScore()
		}
	}

	func addScore() {
		score += 1
		scoreLabel.text = "\(score)"
		shouldDetectScoreCollision = false
		collidedWithScoreZone = true
	}

	// overridden touch methods to call our touch method for each touch
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { touchDown(atPoint: t.location(in: self), atTime: t.timestamp) }
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { touchMoved(atPoint: t.location(in: self), atTime: t.timestamp) }
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { touchUp(atPoint: t.location(in: self), atTime: t.timestamp) }
	}

	// called each tick
	override func update(_ currentTime: TimeInterval) {
		// check to see if the ball is past the net
		let halfBall = basketball.size.height/2.0
		let ballClearHeight = basketball.position.y - halfBall
		if !shouldDetectScoreCollision && ballClearHeight.native > basketballHoopHeight {
			// allow colliding with the hoop
			basketball.physicsBody?.collisionBitMask = hoopCategory
			// put the ball behind the net in Z
			basketball.zPosition = droppingZ
			shouldDetectScoreCollision = true
		}
		// check for basketball leaving screen in (almost) any direction
		if basketball.position.y + halfBall < self.frame.minY
		|| basketball.position.x + halfBall < self.frame.minX
		|| basketball.position.x - halfBall > self.frame.maxX {
			resetBasketBall()
		}
	}
}
