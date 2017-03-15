//
//  GameScene.swift
//  Basketball
//
//  Created by Reid Ellis on 2017-03-15.
//  Copyright © 2017 Ronnie Ellis. All rights reserved.
//

import SpriteKit

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
					let reveal = SKTransition.moveIn(with: .left, duration: 1)
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
