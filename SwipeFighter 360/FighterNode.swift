//
//  FighterNode.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/13/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.
//

import SpriteKit

class FighterNode: SKSpriteNode {
    
    var angle:CGFloat = CGFloat(M_PI)
    
    func addDifferenceBetweenAngles(_ destinationAngle: CGFloat)->CGFloat{
        var difference: CGFloat = destinationAngle - angle
        
        let increment = CGFloat(2.0*M_PI)
        while difference > increment{
            difference -= increment
        }
        while difference < -increment{
            difference += increment
        }
        angle += difference
        return difference
    }
}

