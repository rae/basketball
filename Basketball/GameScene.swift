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

	override func didMove(to view: SKView) {
		self.backLabel = self.childNode(withName: "//backLabel") as? SKLabelNode
		self.scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode
		self.basketballNet = self.childNode(withName: "//basketballNet") as? SKSpriteNode
		self.basketball = self.childNode(withName: "//basketball") as? SKSpriteNode
//		createBoundsPhysics()
		// initially the ball does not fall
//		self.basketball.physicsBody?.affectedByGravity = false
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

	func touchUp(atPoint pos : CGPoint) {
		if touchWasHandledByLabel(atPoint: pos, withDict: [
			self.scoreLabel: {
				self.scoreLabel.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
			},
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
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
}
