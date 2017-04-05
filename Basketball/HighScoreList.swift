//
//  HighScore.swift
//  Basketball
//
//  Created by Reid Ellis on 2017-04-04.
//  Copyright © 2017 Ronnie Ellis. All rights reserved.
//

import Foundation

struct HighScore {
	var list = [Int]()

	mutating func add(score: Int) {
		list.append(score)
		list.sort {
			$0 > $1
		}
	}
}
