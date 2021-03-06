//
//  DestroyerScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/6/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.

import AVFoundation
import SpriteKit
import CoreMotion

class FourRockScene: GameScene{
    
  //  var backgroundAudio:AVAudioPlayer!// = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("majLazerTheme3", ofType: "mp3")!))
    
    func loadAsteroids(){
        let location1 = CGPoint(x: self.frame.width*0.225, y: self.frame.height * 0.22) //left bottom
        let location3 = CGPoint(x: self.frame.width*0.216, y: self.frame.height * 0.773)//left top
        let location4 = CGPoint(x: 0.88 * self.frame.width, y: 0.76 * self.frame.height) //right top
        let location5 = CGPoint(x: 0.87 * self.frame.width, y: 0.3 * self.frame.height)//right bottom
        let locationArray:[CGPoint]=[location1, location3, location4, location5]
        for i in 0 ... 3{
            let location = locationArray[i]
            let rock = SKSpriteNode(imageNamed: "brownRock")
            rock.xScale = 2.0
            rock.yScale = 2.0
            rock.position = CGPoint(x: location.x, y: location.y)
            rock.name = "rock"
            self.addChild(rock)
            rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.size.width/2)
            rock.physicsBody!.affectedByGravity = false
            rock.physicsBody!.linearDamping = 0
            rock.physicsBody!.restitution = 1
            rock.physicsBody!.friction = 0
            rock.physicsBody!.categoryBitMask = rockCategory
            rock.physicsBody!.contactTestBitMask = bulletCategory
            rock.physicsBody!.collisionBitMask = edgeCategory | rockCategory
            rock.physicsBody!.velocity = CGVector(dx: randomSpeed()*0.8,dy: randomSpeed()*0.8)
        }
    }
    
    func newAsteroidPieces(_ location: CGPoint)->(){
        let offset = sqrt(2.0)
        let locationRight = CGPoint(x: location.x+30,y: location.y)
        let locationLeft = CGPoint(x: location.x-30,y: location.y)
        let locationDown = CGPoint(x: location.x,y: location.y-30)
        let locationUp = CGPoint(x: location.x,y: location.y+30)
        let locationNE = CGPoint(x: location.x + CGFloat(30.0/offset),y: location.y+CGFloat(30.0/offset))
        let locationSE = CGPoint(x: location.x + CGFloat(30.0/offset),y: location.y-CGFloat(30.0/offset))
        let locationSW = CGPoint(x: location.x - CGFloat(30.0/offset),y: location.y+CGFloat(30.0/offset))
        let locationNW = CGPoint(x: location.x - CGFloat(30.0/offset),y: location.y-CGFloat(30.0/offset))
        let locationMiddle = CGPoint(x: location.x,y: location.y)
        let locationArray = [locationRight,locationLeft,locationDown, locationUp, locationNE, locationNW, locationSE, locationSW, locationMiddle]
        for location in locationArray{
            let sprite = SKSpriteNode(imageNamed: "brownRock")
            sprite.position = location
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2.2)
            sprite.name = "brownRock"
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody!.linearDamping = 0
            sprite.physicsBody!.restitution = 1
            sprite.physicsBody!.friction = 0
            sprite.physicsBody?.categoryBitMask = rockCategory
            sprite.physicsBody?.contactTestBitMask = 0x00000000
            sprite.physicsBody?.collisionBitMask = edgeCategory | rockCategory
            sprite.physicsBody?.velocity = CGVector(dx: randomSpeed(),dy: randomSpeed())
            self.addChild(sprite)
        }
    }
    
    func invaderAttack(_ currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForInvaderAttack > 15.0) {
            addMonster()
            timeOfLastUpdateForInvaderAttack = currentTime
        }
    }
    func addMonster() {
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "UFO")
        //monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.frame.width/3)
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
        let waitAction = SKAction.wait(forDuration: 10.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = [actionMove,waitAction,removeAction]
        monster.run(SKAction.sequence(sequence))
    }
    
    override func createContent() {
        super.createContent()
        loadAsteroids()
        level = 3
        if super.musicOff{
            return
        }
        do{
            backgroundAudio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "technoTheme3", ofType: "mp3")!))
            backgroundAudio.currentTime = 30.0
            backgroundAudio.numberOfLoops = -1
            backgroundAudio.volume = 0.6
            backgroundAudio.play()
        }catch{
            print("AudioPlayer Failure")
        }
    }
    override func handleContact(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil){
            return
        }
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        var location = CGPoint(x: 0, y: 0)
        if ((nodeNames as NSArray).contains("rock") && (nodeNames as NSArray).contains("bullet")){
            var explosion:SKSpriteNode!
            if(contact.bodyA.node!.name == "rock"){
                location = contact.bodyA.node!.position
                explosion = contact.bodyA.node! as! SKSpriteNode
                contact.bodyB.node!.removeFromParent()
            } else{
                location = contact.bodyB.node!.position
                explosion = contact.bodyB.node! as! SKSpriteNode
                contact.bodyA.node!.removeFromParent()
            }
            if super.explosionOff{
                setupExplosion(explosion, soundFX: false, file: "shipExplodes.mp3")
            }else{
                setupExplosion(explosion, soundFX: true, file: "shipExplodes.mp3")
            }
            monstersHit += 1
            newAsteroidPieces(location)
        }
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

    override func gameEnded(_ currentTime: CFTimeInterval)->Bool{
        let superEnded = super.gameEnded(currentTime)  // super checks for ship
        var allRocks: [SKNode] = []
        // put nodes in array
        self.enumerateChildNodes(withName: "rock"){// <--FIND ROCKS HERE
            node, stop in allRocks.append(node)}
        self.enumerateChildNodes(withName: "red"){// <--FIND ROCKS HERE
            node, stop in allRocks.append(node)}
        self.enumerateChildNodes(withName: "brownRock"){// <--FIND ROCKS HERE
            node, stop in allRocks.append(node)}
        // Check for the level up scenario
        if let _ = childNode(withName: "ship"){
            if(allRocks.count == 0){
                super.level = 401
                highScore?.level = 401
                return true
            }
        }
        // then the game over scenario
        if(superEnded){
            return true
        }
        return false
    }
    
    override func update(_ currentTime: TimeInterval) {
        // super updates user controls
        super.update(currentTime)
        // gameEnds accounts for super
        gameEnds = gameEnded(currentTime)
        if gameEnds == true {
            motionManager.stopAccelerometerUpdates()
            timeOfLastUpdateForInvaderAttack = currentTime
            if backgroundAudio != nil{
                backgroundAudio.stop()
            }
            shipAngle = 0.0
            if !arcadeMode{
                self.thisDelegate?.gameSceneDidFinish(self, command: "close")
            }else{
                if super.level == 401{
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
        invaderAttack(currentTime)
        processContactsForUpdate(currentTime)
        updateRocksForRemoval(currentTime)
    }
}
