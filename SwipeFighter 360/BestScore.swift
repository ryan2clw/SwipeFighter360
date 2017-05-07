//
//  BestScore.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/31/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.
//

import SpriteKit

class BestScore: HighScore {
    override init?(name: String, lives: Int, accuracy: Double, level: Int) {
        super.init(name: name, lives: lives, accuracy: accuracy, level: level)
    }
}