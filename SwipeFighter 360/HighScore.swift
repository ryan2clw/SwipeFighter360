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
    
    static let DocumentsDirectory:URL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL:URL = DocumentsDirectory.appendingPathComponent("HighScore")
    static let ArchiveURL2:URL = DocumentsDirectory.appendingPathComponent("BestScore")
    
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(lives, forKey: PropertyKey.livesKey)
        aCoder.encode(accuracy, forKey: PropertyKey.accuracyKey)
        aCoder.encode(level, forKey: PropertyKey.levelKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        
        let lives = aDecoder.decodeInteger(forKey: PropertyKey.livesKey)
        
        let accuracy = aDecoder.decodeDouble(forKey: PropertyKey.accuracyKey)
        
        let level = aDecoder.decodeInteger(forKey: PropertyKey.levelKey)
        // Must call designated initializer.
        self.init(name: name, lives: lives, accuracy: accuracy, level: level)
    }
}
