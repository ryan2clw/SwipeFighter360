//
//  HighScore.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/16/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.
//

import UIKit

class HighScore: NSObject, NSCoding {
    // MARK: Properties
    
    var name: String
    var lives: Int
    var accuracy: Double
    var level: Int
    

    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let livesKey = "lives"
        static let accuracyKey = "accuracy"
        static let levelKey = "level"
    }
    // MARK: Archiving Paths
    
    static let DocumentsDirectory:NSURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL:NSURL = DocumentsDirectory.URLByAppendingPathComponent("HighScore")
    static let ArchiveURL2:NSURL = DocumentsDirectory.URLByAppendingPathComponent("BestScore")
    
    // MARK: Initialization
    
    init?(name: String, lives: Int, accuracy: Double, level: Int) {
        // Initialize stored properties.
        self.name = name
        self.lives = lives
        self.accuracy = accuracy
        self.level = level
        
        super.init()
        
        // Initialization should fail if there is no name or if the lives are negative
        if name.isEmpty || lives < 1 {
            return nil
        }
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeInteger(lives, forKey: PropertyKey.livesKey)
        aCoder.encodeDouble(accuracy, forKey: PropertyKey.accuracyKey)
        aCoder.encodeInteger(level, forKey: PropertyKey.levelKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        let lives = aDecoder.decodeIntegerForKey(PropertyKey.livesKey)
        
        let accuracy = aDecoder.decodeDoubleForKey(PropertyKey.accuracyKey)
        
        let level = aDecoder.decodeIntegerForKey(PropertyKey.levelKey)
        // Must call designated initializer.
        self.init(name: name, lives: lives, accuracy: accuracy, level: level)
    }
}