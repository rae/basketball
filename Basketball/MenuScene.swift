//
//  MenuScene.swift
//  Basketball
//
//  Created by Ronnie Ellis on 2017-03-09.
//  Copyright © 2017 Ronnie Ellis. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
	private var playLabel : SKLabelNode!
	private var instructionsLabel : SKLabelNode!
	private var scoreLabel : SKLabelNode!

    override func didMove(to view: SKView) {
		self.playLabel = self.childNode(withName: "//playLabel") as? SKLabelNode
		self.instructionsLabel = self.childNode(withName: "//instructionsLabel") as? SKLabelNode
		self.scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
		print("touchDown at \(pos)")
    }
    
    func touchMoved(toPoint pos : CGPoint) {
		print("touchMoved to \(pos)")
    }
    
    func touchUp(atPoint pos : CGPoint) {
		if touchWasHandledByLabel(atPoint: pos, withDict: [
			self.playLabel: {
				self.playLabel.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
				// Load the GameScene
				if let view = self.view, let scene = GameScene(fileNamed: "GameScene") {
					// Set the scale mode to scale to fit the window
					scene.scaleMode = .aspectFill
					let reveal = SKTransition.reveal(with: .left, duration: kSceneTransitionDelay)
					// Present the scene
					view.presentScene(scene, transition:reveal)
				}
			},
			self.instructionsLabel : {
				self.instructionsLabel.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
				// Load the InstructionsScene
//				if let view = self.view, let scene = InstructionsScene(fileNamed: "InstructionsScene") {
				if let view = self.view, let scene = InstructionsScene(fileNamed: "Test") {
					// Set the scale mode to scale to fit the window
					scene.scaleMode = .aspectFill
					let reveal = SKTransition.reveal(with: .left, duration: kSceneTransitionDelay)
					// Present the scene
					view.presentScene(scene, transition:reveal)
				}
			},
			self.scoreLabel: {
				self.scoreLabel.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
				// Load the HighScoresScene
				if let view = self.view, let scene = HighScoresScene(fileNamed: "HighScoresScene") {
					// Set the scale mode to scale to fit the window
					scene.scaleMode = .aspectFill
					let reveal = SKTransition.reveal(with: .left, duration: kSceneTransitionDelay)
					// Present the scene
					view.presentScene(scene, transition:reveal)
				}
			}]) {
			return
		}
		// code to handle touch not on labels
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
