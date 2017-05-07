//
//  LevelThreeScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 12/17/15.
//  Copyright © 2015 DimeZee Software. All rights reserved.
//

import AVFoundation
import SpriteKit
import CoreMotion

class AlienInvasionScene: GameScene{
    
   // var backgroundAudio:AVAudioPlayer!
    var timerLevelThree:Double = 0.0
    
    override func createContent() {
        super.createContent()
        timeOfLastUpdateForInvaderAttack = 0.0
        displayTimer(Int(timerLevelThree))
        if super.musicOff{
            return
        }
        backgroundAudio = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("fastTheme7", ofType: "mp3")!))
        super.playTheme(backgroundAudio, volume: 0.3)
    }
    override func update(currentTime: CFTimeInterval) {
        initializeTimer(currentTime)
        super.updateDisplayAccuracy(currentTime)
        super.processUserMotionForUpdate(currentTime)
        super.processContactsForUpdate(currentTime)
        super.updateBulletDelay(currentTime)
        super.updateRateOfTurning(currentTime)
        if gameEnded(currentTime){
            if backgroundAudio != nil{
                backgroundAudio.stop()
            }
            motionManager.stopAccelerometerUpdates()
    
            if !arcadeMode{
                self.thisDelegate?.gameSceneDidFinish(self, command: "close")
            }else{
                if super.level == 801{
                    // Arcade mode is designed to have scenes run continuously upon successful completion
                    updateAccuracy()
                    updateBestScore()
                    self.thisDelegate?.updateTransitionLevvel(self)
                    self.paused = true
                    self.thisDelegate?.changeScene(self, command: "close")
                }else{
                    self.highScore?.lives += 1
                    self.thisDelegate?.updateTransitionLevvel(self)
                    scene?.paused = true
                    self.thisDelegate?.gameSceneDidFinish(self, command: "close")
                }
            }
        }
        invaderAttack(currentTime)
    }
    func invaderAttack(currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForInvaderAttack > 0.50) {
            addMonster()
            timeOfLastUpdateForInvaderAttack = currentTime
            //super.processContactsForUpdate(currentTime)
        }
    }
    func initializeTimer(currentTime: CFTimeInterval){
        if timeOfLastUpdateForLevel < 0.1{
            timeOfLastUpdateForLevel = currentTime
            timeOfLastUpdateForInvaderAttack = currentTime
        }
    }
    func displayTimer(timer: Int){
        let myLabel = SKLabelNode(fontNamed: "Arial")
        myLabel.name = "timer"
        myLabel.position = CGPoint(x: self.size.width * 0.9, y: self.size.height * 0.9)
        myLabel.text = "Timer: \(timer)"
        myLabel.fontSize = 25
        myLabel.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel.alpha = 0.9
        self.addChild(myLabel)
    }
    func addMonster() {
        // Create sprite
        //monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        let monster = SKSpriteNode(imageNamed: "alien")
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.frame.width/3.0)
        monster.physicsBody?.allowsRotation = false
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.categoryBitMask = invaderCategory
        monster.physicsBody?.contactTestBitMask = bulletCategory | shipCategory
        monster.physicsBody?.collisionBitMask = 0x00000000
        monster.physicsBody?.linearDamping = 0
        monster.physicsBody?.usesPreciseCollisionDetection = true
        // Determine where to spawn the monster along the Y axis
        let minInt = Int(monster.size.height/2)
        let maxInt = Int(self.size.height-monster.size.height/2)
        let actualY = arc4random_uniform(UInt32(maxInt-minInt))
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: self.size.width + monster.size.width/2, y: CGFloat(actualY))
        monster.name = "invader"
        // Add the monster to the scene
        self.addChild(monster)
        // Determine speed of the monster
        let randomSpeed = drand48()*3+3
        // Create the actions
        let actionMove = SKAction.applyImpulse(CGVector(dx: -randomSpeed, dy:0) ,duration: 0.1)
        let waitAction = SKAction.waitForDuration(10.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = [actionMove,waitAction,removeAction]
        monster.runAction(SKAction.sequence(sequence))
    }
    override func handleContact(contact: SKPhysicsContact) {
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil){
            return
        }
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        if ((nodeNames as NSArray).containsObject("boundary") && (nodeNames as NSArray).containsObject("bullet")){
            if(contact.bodyA.node!.name == "bullet"){
                contact.bodyA.node!.removeFromParent()
            } else{
                contact.bodyB.node!.removeFromParent()
            }
        }
        if ((nodeNames as NSArray).containsObject("ship")){
            var explosion:SKSpriteNode!
            if(contact.bodyA.node!.name == "ship"){
                explosion = contact.bodyA.node! as! SKSpriteNode
                contact.bodyB.node!.removeFromParent()
            } else{
                explosion = contact.bodyB.node! as! SKSpriteNode
                contact.bodyA.node!.removeFromParent()
            }
            if super.explosionOff{
                setupExplosion(explosion, soundFX: false, file:"shipExplodes.mp3")
            }else{
                setupExplosion(explosion, soundFX: true, file:"shipExplodes.mp3")
            }
            
        }
        if ((nodeNames as NSArray).containsObject("invader") && (nodeNames as NSArray).containsObject("bullet")){
            monstersHit += 1
            var explosion:SKSpriteNode!
            if(contact.bodyA.node!.name == "invader"){
                explosion = contact.bodyA.node! as! SKSpriteNode
                contact.bodyB.node!.removeFromParent()
            } else{
                explosion = contact.bodyB.node! as! SKSpriteNode
                contact.bodyA.node!.removeFromParent()
            }
            if super.explosionOff{
                setupExplosion(explosion, soundFX: false, file: "shipExplodes.mp3")
            }else{
                setupExplosion(explosion, soundFX: true, file: "shipExplodes.mp3")
            }
        }
    }

    override func gameEnded(currentTime: CFTimeInterval)->Bool{
        // super checks for ship, other endings are specific to level
        if super.gameEnded(currentTime){
            return true
        }
        timerLevelThree = currentTime - timeOfLastUpdateForLevel
        let timer = childNodeWithName("timer") as! SKLabelNode
        timer.text = "Timer: \(Int(timerLevelThree))"
        if timerLevelThree > 60.0{
            super.level = 801
            highScore?.level = 801
            return true
        }
        return false
    }
}
