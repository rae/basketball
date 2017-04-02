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

	override func didMove(to view: SKView) {
		self.backLabel = self.childNode(withName: "//backLabel") as? SKLabelNode
		self.scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode
		self.basketballNet = self.childNode(withName: "//basketballNet") as? SKSpriteNode
		self.basketball = self.childNode(withName: "//basketball") as? SKSpriteNode
//		createBoundsPhysics()
	}

	func createBoundsPhysics() {
		// add a physics border around the screen for the ball to bounce against
		self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
		self.physicsBody?.isDynamic = false
		self.physicsBody?.restitution = 0.9
		self.physicsBody?.friction = 0.4
		self.physicsBody?.linearDamping = 0
		self.physicsBody?.angularDamping = 0
		self.physicsBody?.allowsRotation = false
		self.physicsBody?.affectedByGravity = false
	}

	func touchUp(atPoint pos : CGPoint, atTime t: TimeInterval) {
		if touchWasHandledByLabel(atPoint: pos, withDict: [
			self.backLabel : {
				self.backLabel.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
				// Load the TitleScene
				if let view = self.view, let scene = MenuScene(fileNamed: "MenuScene") {
					// Set the scale mode to scale to fit the window
					scene.scaleMode = .aspectFill
					let reveal = SKTransition.moveIn(with: .left, duration: kSceneTransitionDelay)
					// Present the scene
					view.presentScene(scene, transition:reveal)
				}
			}]) {
			return
		}

		// code to handle touch not on labels
		self.basketball.position = pos
		self.basketball.physicsBody?.affectedByGravity = true
		let delta = t - self.lastTouchTime
		var dx = (pos.x.native - lastTouchPos.x.native)*5.0/delta
//		if dx < 3 {
			dx = (pos.x.native - startTouchPos.x.native)*2.0 / (t - startTouchTime)
			print("using start")
//		} else {
//			print("using delta")
//		}

		self.basketball.physicsBody?.velocity = CGVector(dx: dx, dy: 1200)
		print("deltax = \(dx)")
	}

	func touchDown(atPoint pos: CGPoint, atTime t: TimeInterval) {
		self.basketball.position = pos
		self.basketball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
		self.basketball.physicsBody?.affectedByGravity = false

		startTouchPos = pos
		lastTouchPos = pos
		startTouchTime = t
		lastTouchTime = t
	}

	func touchMoved(atPoint pos: CGPoint, atTime t: TimeInterval) {
		self.basketball.position = pos
		lastTouchPos = pos
		lastTouchTime = t
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchDown(atPoint: t.location(in: self), atTime: t.timestamp) }
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchMoved(atPoint: t.location(in: self), atTime: t.timestamp) }
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self), atTime: t.timestamp) }
	}
}
