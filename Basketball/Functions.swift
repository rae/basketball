//
//  Functions.swift
//  Basketball
//
//  Created by Ronnie Ellis on 2017-03-15.
//  Copyright © 2017 Ronnie Ellis. All rights reserved.
//

import SpriteKit

// map touches inside labels to blocks and execute the block in which the touch happened
func touchWasHandledByLabel(atPoint pos : CGPoint, withDict dict: [SKLabelNode : ()->()]) -> Bool {
	var labelWasTouched = false
	for (label, block) in dict {
		let debugRect = label.frame
		// make touch area bigger
		let touchRect = label.frame.insetBy(dx: -20, dy: -20)
		if touchRect.contains(pos) {
			labelWasTouched = true
			block()
			break
		}
	}
	return labelWasTouched
}

