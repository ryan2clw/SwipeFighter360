//
//  LevelTwoScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 12/10/15.
//  Copyright © 2015 DimeZee Software. All rights reserved.
//

import AVFoundation
import SpriteKit
import CoreMotion

class AsteroidFieldScene: GameScene{
    
    let rightFieldCategory:UInt32 = 0x00100000
    let upFieldCategory:UInt32 = 0x00200000
    let leftFieldCategory:UInt32 = 0x00400000
    let downFieldCategory:UInt32 = 0x00800000
    var timerLevelTwo = 0.0
   // var backgroundAudio:AVAudioPlayer!
    
    override func createContent() {
        super.createContent()

        createGravityField(vector_float3(0,0.3,0))
        createGravityField(vector_float3(0,-0.3,0))
        createGravityField(vector_float3(0.3,0,0))
        createGravityField(vector_float3(-0.3,0,0))
        displayTimer(Int(timerLevelTwo))
        if super.musicOff{
            return
        }
        backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "dopeTheme2", ofType: "mp3")!))
        super.playTheme(backgroundAudio, volume: 0.3)
    }
    func asteroidField(_ currentTime: CFTimeInterval){
        if currentTime - timeOfLastUpdateForAsteroidField > 2.0 {
            let rock = SKSpriteNode(imageNamed: "brownRock")
            rock.name = "brownRock"
            let randomSize = 1.8 * drand48()+0.4
            rock.xScale = CGFloat(randomSize)
            rock.yScale = CGFloat(randomSize)
            rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.frame.width/2.2)
            rock.physicsBody?.affectedByGravity = false
            rock.physicsBody?.categoryBitMask = rockCategory
            rock.physicsBody?.contactTestBitMask = bulletCategory | shipCategory
            rock.physicsBody?.collisionBitMask = rockCategory
            rock.physicsBody?.usesPreciseCollisionDetection = true
            rock.physicsBody?.mass = 0.1
            rock.physicsBody?.linearDamping = 0
            rock.physicsBody?.restitution = 1.0 
            let waitAction = SKAction.wait(forDuration: 10.0)
            let removeAction = SKAction.removeFromParent()
            // pick random side and pass in position and velocity
            let randomSide = arc4random_uniform(4)
            // Determine where to spawn the monster along the Y axis
            var minInt = Int(rock.size.height/1.4)
            var maxInt = Int(self.size.height-rock.size.height/2)
            let actualY = arc4random_uniform(UInt32(maxInt-minInt))
            let randomSpeed = drand48()+3
            var actionMove = SKAction.applyImpulse(CGVector(dx: 0, dy: 0), duration: 0.1)
            // Rocks curve toward center, field category depends on entry location
            // asteroid from left
            if randomSide == 0 {
                rock.position = CGPoint(x: self.size.width + rock.size.width/2, y: CGFloat(actualY))
                actionMove = SKAction.applyImpulse(CGVector(dx: -3.0 * randomSpeed, dy:0) ,duration: 0.1)
                if rock.position.y < self.size.height/2{
                    rock.physicsBody?.fieldBitMask = upFieldCategory
                } else{
                    rock.physicsBody?.fieldBitMask = downFieldCategory
                }
            }
            // asteroid from right
            if randomSide == 1 {
                rock.position = CGPoint(x: -rock.size.width/2, y: CGFloat(actualY))
                actionMove = SKAction.applyImpulse(CGVector(dx: 3.0 * randomSpeed, dy:0) ,duration: 0.1)
                if rock.position.y < self.size.height/2{
                    rock.physicsBody?.fieldBitMask = upFieldCategory
                } else{
                    rock.physicsBody?.fieldBitMask = downFieldCategory
                }
            }
            // asteroid from above
            minInt = Int(rock.size.height/1.4)
            maxInt = Int(self.size.width-rock.size.width/2)
            let actualX = arc4random_uniform(UInt32(maxInt-minInt))
            if randomSide == 2{
                rock.position = CGPoint(x: CGFloat(actualX), y: self.size.height+rock.size.height/2)
                actionMove = SKAction.applyImpulse(CGVector(dx: 0, dy: -3.0 * randomSpeed) ,duration: 0.1)
                if rock.position.x < self.size.width/2{
                    rock.physicsBody?.fieldBitMask = rightFieldCategory
                } else{
                    rock.physicsBody?.fieldBitMask = leftFieldCategory
                }
            }
            // asteroid from below
            if randomSide == 3{
                rock.position = CGPoint(x: CGFloat(actualX), y: -rock.size.width/2)
                actionMove = SKAction.applyImpulse(CGVector(dx: 0, dy:3.0 * randomSpeed) ,duration: 0.1)
                if rock.position.x < self.size.width/2{
                    rock.physicsBody?.fieldBitMask = rightFieldCategory
                } else{
                    rock.physicsBody?.fieldBitMask = leftFieldCategory
                }
            }
            // Position the monster slightly off-screen along the right edge, randomly
            let sequence = [actionMove,waitAction,removeAction]
            // add rocks and let er rip
            self.addChild(rock)
            rock.run(SKAction.sequence(sequence))
            timeOfLastUpdateForAsteroidField = currentTime
        }
    }

    func createGravityField(_ strength: vector_float3){
        let gravityNode = SKFieldNode.linearGravityField(withVector: strength)
        
        if strength.x > 0{
            gravityNode.categoryBitMask = rightFieldCategory
        }
        if strength.x < 0{
            gravityNode.categoryBitMask = leftFieldCategory
        }
        if strength.y > 0{
            gravityNode.categoryBitMask = upFieldCategory
        }
        if strength.y < 0{
            gravityNode.categoryBitMask = downFieldCategory
        }
        self.addChild(gravityNode)
    }
    override func handleContact(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil){
            return
        }
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        if ((nodeNames as NSArray).contains("brownRock") && (nodeNames as NSArray).contains("bullet")){
            var explosion:SKSpriteNode!
            if(contact.bodyA.node!.name == "brownRock"){
                explosion = contact.bodyA.node! as! SKSpriteNode
                contact.bodyB.node!.removeFromParent()
            } else{
                explosion = contact.bodyB.node! as! SKSpriteNode
                contact.bodyA.node!.removeFromParent()
            }
            if super.explosionOff{
                setupExplosion(explosion, soundFX: false, file:"explosion.wav")
            }else{
                setupExplosion(explosion, soundFX: true, file:"explosion.wav")
            }
            monstersHit += 1
        }
        if ((nodeNames as NSArray).contains("boundary") && (nodeNames as NSArray).contains("bullet")){
            if(contact.bodyA.node!.name == "bullet"){
                contact.bodyA.node!.removeFromParent()
            } else{
                contact.bodyB.node!.removeFromParent()
            }
        }
        if ((nodeNames as NSArray).contains("ship")){
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
        if ((nodeNames as NSArray).contains("invader") && (nodeNames as NSArray).contains("bullet")){
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
    func displayTimer(_ timer: Int){
        let myLabel = SKLabelNode(fontNamed: "Arial")
        myLabel.name = "timer"
        myLabel.position = CGPoint(x: self.size.width * 0.9, y: self.size.height * 0.9)
        myLabel.text = "Timer: \(timer)"
        myLabel.fontSize = 25
        myLabel.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel.alpha = 0.9
        self.addChild(myLabel)
    }
    override func gameEnded(_ currentTime: CFTimeInterval)->Bool{
// super checks for ship, other endings are specific to level
        if super.gameEnded(currentTime){
            return true
        }
        timerLevelTwo = currentTime - timeOfLastUpdateForLevel
        let timer = childNode(withName: "timer") as! SKLabelNode
        timer.text = "Timer: \(Int(timerLevelTwo))"
        if timerLevelTwo > 60.0{
            super.level = 301
            highScore?.level = 301
            return true
        }
        return false
    }
    func initializeTimer(_ currentTime: CFTimeInterval){
        if timeOfLastUpdateForLevel < 0.1{
            timeOfLastUpdateForLevel = currentTime
        }
    }
    override func update(_ currentTime: TimeInterval) {
        initializeTimer(currentTime)
        super.update(currentTime)
        gameEnds = gameEnded(currentTime)
        if gameEnds == true{
            if let _ = childNode(withName: "timer"){
                let timerLabel = childNode(withName: "timer") as! SKLabelNode
                 timerLabel.text = "DONE"
            }
            motionManager.stopAccelerometerUpdates()
            if backgroundAudio != nil{
                backgroundAudio.stop()
            }
            if !arcadeMode{
                self.thisDelegate?.gameSceneDidFinish(self, command: "close")
            }else{
                if super.level == 301{
                    updateAccuracy()
                    updateBestScore()
                    self.thisDelegate?.updateTransitionLevvel(self)
                    self.isPaused = true
                    self.thisDelegate?.changeScene(self, command: "close")
                }else{
                    self.highScore?.lives += 1
                    self.thisDelegate?.updateTransitionLevvel(self)
                    scene?.isPaused = true
                    self.thisDelegate?.gameSceneDidFinish(self, command: "close")
                }
            }
        }
        processContactsForUpdate(currentTime)
        asteroidField(currentTime)
    }
}
