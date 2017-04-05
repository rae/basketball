//
//  InstructionsScene.swift
//  Basketball
//
//  Created by Ronnie Ellis on 2017-03-09.
//  Copyright © 2017 Ronnie Ellis. All rights reserved.
//

import SpriteKit

class InstructionsScene: SKScene {
	var menuLabel : SKLabelNode!

	override func didMove(to view: SKView) {
		self.menuLabel = self.childNode(withName: "//menuLabel") as? SKLabelNode
	}

	func touchUp(atPoint pos : CGPoint) {
		if touchWasHandledByLabel(atPoint: pos, withDict: [
			self.menuLabel : {
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
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
}
