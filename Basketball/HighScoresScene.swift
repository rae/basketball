//
//  HighScoresScene.swift
//  Basketball
//
//  Created by Ronnie Ellis on 2017-03-15.
//  Copyright © 2017 Ronnie Ellis. All rights reserved.
//

import SpriteKit

class HighScoresScene : SKScene {
	// label to return to the menu
	var menuLabel : SKLabelNode!

	override func didMove(to view: SKView) {
		self.menuLabel = self.childNode(withName: "//menuLabel") as? SKLabelNode
		guard let scores = self.childNode(withName: "//scores") else {
			return
		}
		for i in 0...9 {
			guard let label = scores.childNode(withName: "score_\(i)") as? SKLabelNode else {
				continue
			}
			if MenuScene.scores.list.count > i {
				label.text = "\(i+1).        \(MenuScene.scores.list[i])"

			} else {
				label.text = "\(i+1).        —"
			}
		}
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
