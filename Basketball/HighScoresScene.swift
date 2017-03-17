//
//  HighScoresScene.swift
//  Basketball
//
//  Created by Ronnie Ellis on 2017-03-15.
//  Copyright © 2017 Ronnie Ellis. All rights reserved.
//

import SpriteKit

class HighScoresScene : SKScene {
	var menuLabel : SKLabelNode!

	override func didMove(to view: SKView) {
		self.menuLabel = self.childNode(withName: "//menuLabel") as? SKLabelNode
	}

	func touchUp(atPoint pos : CGPoint) {
		if touchWasHandledByLabel(atPoint: pos, withDict: [
			self.menuLabel : {
				self.menuLabel.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
				// Load the MenuScene
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
