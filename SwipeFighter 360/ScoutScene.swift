//
//  NewScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/6/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.
//
import AVFoundation
import SpriteKit
import CoreMotion

class ScoutScene: GameScene{
    
    var monsterAngle:Double = 0.0
    var timeOfLastUpdateForInvaderEntrance: CFTimeInterval = 0
    let rightFieldCategory:UInt32 = 0x00100000
    let upFieldCategory:UInt32 = 0x00200000
    let leftFieldCategory:UInt32 = 0x00400000
    let downFieldCategory:UInt32 = 0x00800000
    var timerLevelTwo = 0.0
   // var backgroundAudio:AVAudioPlayer!// = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("dannyDopeBeat4", ofType: "mp3")!))
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
        asteroidField(currentTime)
        invaderEnters(currentTime)
        invaderAttack(currentTime)
        initializeTimer(currentTime)
        processContactsForUpdate(currentTime)
        gameEnds = gameEnded(currentTime)
        if gameEnds == true{
            if let _ = childNodeWithName("timer"){
                let timerLabel = childNodeWithName("timer") as! SKLabelNode
                timerLabel.text = "DONE"
            }
            motionManager.stopAccelerometerUpdates()
            var allScouts: [SKSpriteNode] = []
            // put nodes in array
            self.enumerateChildNodesWithName("monster"){// <--FIND ROCKS HERE
                node, stop in allScouts.append(node as! SKSpriteNode)}
            for scout in allScouts{
                // Strong Reference eliminated from runBlock
                scout.removeAllActions()
            }
            if backgroundAudio != nil{
                backgroundAudio.stop()
            }
            if !arcadeMode{
                self.thisDelegate?.gameSceneDidFinish(self, command: "close")
            }else{
                if super.level == 501{
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
    }
    func initializeTimer(currentTime: CFTimeInterval){
        if timeOfLastUpdateForLevel < 0.1{
            timeOfLastUpdateForLevel = currentTime
            timeOfLastUpdateForInvaderEntrance = currentTime
            timeOfLastUpdateForInvaderAttack = currentTime
        }
    }
    func invaderEnters(currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForInvaderEntrance > 10.0) {
            addMonster()
            timeOfLastUpdateForInvaderEntrance = currentTime
        }
    }
    func invaderAttack(currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForInvaderAttack > 0.6) {
            monsterFire(monsterAim())
            timeOfLastUpdateForInvaderAttack = currentTime
        }
    }

    func monsterAim()->(CGVector, CGFloat){
// rotate monster to face ship
        if let ship = childNodeWithName("ship"){
            if let monster = childNodeWithName("monster"){
// if the ship is right of the monster, ie quadrants I and IV, add 90 to the angle
                let dx = ship.position.x - monster.position.x
                let dy = ship.position.y - monster.position.y
                let magnitude = sqrt(dx*dx+dy*dy)
                let bulletVelocity = CGVector(dx: dx/magnitude, dy: dy/magnitude)
                let angle = atan(dy/dx)
                if ship.position.x > monster.position.x{
                    monsterAngle += M_PI / 2.0
                }
                monsterAngle = Double(angle)
                return (bulletVelocity, angle)
            }
        }
    return (CGVector(dx: 0, dy: 0),0)
    }

    func monsterFire(trigTuple: (CGVector, CGFloat)){

        if let monster = self.childNodeWithName("monster"){
            if monster.position.x < self.frame.width / 2.5 {
                let bullet = SKSpriteNode(color: UIColor.magentaColor(), size: CGSize(width: 3, height: 9))
                bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: bullet.frame.width, height: bullet.frame.height))
                let bulletVelocity = CGVector(dx: trigTuple.0.dx * 300.0, dy: trigTuple.0.dy * 300.0)
                let bulletPosition = CGPoint(x:monster.position.x ,y: monster.position.y)
                monster.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                if let ship = childNodeWithName("ship"){
                    if ship.position.x > monster.position.x{
                        if ship.position.y > monster.position.y{
                            monsterAngle -= M_PI
                        }else{
                            monsterAngle += M_PI
                        }
                    }
                }
                monster.runAction(SKAction.rotateByAngle(CGFloat(monsterAngle), duration: 0.20))
                bullet.position = bulletPosition
                bullet.runAction(SKAction.rotateByAngle(CGFloat(monsterAngle+M_PI/2), duration: 0.01))
                bullet.name = "monsterBullet"
                bullet.physicsBody?.affectedByGravity = false
                bullet.physicsBody?.dynamic = true
                bullet.physicsBody?.mass = 0.01
                bullet.physicsBody?.linearDamping = 0
                bullet.physicsBody?.categoryBitMask = bulletCategory
                bullet.physicsBody?.contactTestBitMask = shipCategory | edgeCategory
                bullet.physicsBody?.usesPreciseCollisionDetection = true
                bullet.physicsBody?.collisionBitMask = 0x00000000
                bullet.physicsBody?.fieldBitMask = 0x00000000
                bullet.runAction(SKAction.playSoundFileNamed("shipBullet.mp3", waitForCompletion: false))
                bullet.physicsBody?.velocity = bulletVelocity
                self.addChild(bullet)
                monster.name = "monsterSpent"
            }
        }
    }
    func asteroidField(currentTime: CFTimeInterval){
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
            let waitAction = SKAction.waitForDuration(10.0)
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
            rock.runAction(SKAction.sequence(sequence))
            timeOfLastUpdateForAsteroidField = currentTime
        }
    }
    
    func createGravityField(strength: vector_float3){
        let gravityNode = SKFieldNode.linearGravityFieldWithVector(strength)
        
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
    override func gameEnded(currentTime: CFTimeInterval)->Bool{
        // super checks for ship, other endings are specific to level
        if super.gameEnded(currentTime){
            return true
        }
        timerLevelTwo = currentTime - timeOfLastUpdateForLevel
        let timer = childNodeWithName("timer") as! SKLabelNode
        timer.text = "Timer: \(Int(timerLevelTwo))"
        if timerLevelTwo > 60.0{
            super.level = 501
            highScore?.level = 501
            return true
        }
        return false
    }    
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
        backgroundAudio = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("dannyDopeBeat4", ofType: "mp3")!))
        backgroundAudio.currentTime = 10.0
        backgroundAudio.numberOfLoops = -1
        backgroundAudio.volume = 0.3
        backgroundAudio.play()
    }
    func addMonster() {
        let monster = SKSpriteNode(imageNamed: "fighter")
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.frame.width/3)
        monster.physicsBody?.allowsRotation = false
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.categoryBitMask = invaderCategory
        monster.physicsBody?.contactTestBitMask = bulletCategory | shipCategory
        monster.physicsBody?.collisionBitMask = 0x00000000
        monster.physicsBody?.linearDamping = 0
        monster.physicsBody?.usesPreciseCollisionDetection = true
        let minInt = Int(monster.size.height/2)
        let maxInt = Int(self.size.height-monster.size.height/2)
        let actualY = arc4random_uniform(UInt32(maxInt-minInt))
        monster.position = CGPoint(x: self.size.width + monster.size.width/2, y: CGFloat(actualY))
        monster.name = "monster"
        self.addChild(monster)
        let randomSpeed = drand48()+2
        func monsterLeave()->(){
            monster.physicsBody!.velocity = CGVectorMake(CGFloat(cos(monsterAngle+M_PI) * 300.0), CGFloat(sin(monsterAngle+M_PI) * 300.0))
        }
        let moveAction = SKAction.applyImpulse(CGVector(dx: -randomSpeed, dy:0) ,duration: 0.1)
        let waitAction = SKAction.waitForDuration(5.0)
        let removeAction = SKAction.removeFromParent()
        let exitAction = SKAction.runBlock(monsterLeave)
        let sequence = [moveAction, waitAction, exitAction, waitAction, removeAction]
        monster.runAction(SKAction.sequence(sequence), withKey: "strongReference")
    }
    override func handleContact(contact: SKPhysicsContact) {
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil){
            return
        }
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        if ((nodeNames as NSArray).containsObject("monster") && (nodeNames as NSArray).containsObject("bullet")){
            var explosion:SKSpriteNode!
            if(contact.bodyA.node!.name == "monster"){
                explosion = contact.bodyA.node! as! SKSpriteNode
                explosion.removeActionForKey("strongReference")
                explosion.name = "monsterSpent"
                contact.bodyB.node!.removeFromParent()
            } else{
                explosion = contact.bodyB.node! as! SKSpriteNode
                explosion.removeActionForKey("strongReference")
                explosion.name = "monsterSpent"
                contact.bodyA.node!.removeFromParent()
            }
            if super.explosionOff{
                setupExplosion(explosion, soundFX: false, file: "shipExplodes.mp3")
            }else{
                setupExplosion(explosion, soundFX: true, file: "shipExplodes.mp3")
            }
            monstersHit += 1
        }
        if ((nodeNames as NSArray).containsObject("brownRock") && (nodeNames as NSArray).containsObject("bullet")){
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

        if ((nodeNames as NSArray).containsObject("monsterSpent") && (nodeNames as NSArray).containsObject("bullet")){
            monstersHit += 1
            var explosion:SKSpriteNode!
            if(contact.bodyA.node!.name == "monsterSpent"){
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
}