//
//  ThreeRockScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/6/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.

import AVFoundation
import SpriteKit
import CoreMotion

class DestroyerScene: GameScene{
    
  //  var backgroundAudio:AVAudioPlayer!
    let destroyerCategory:UInt32 = 0x20000000
    
    func loadAsteroids(){
        let location3 = CGPoint(x: self.frame.width*0.216, y: self.frame.height * 0.773)//left top
        let location4 = CGPoint(x: 0.88 * self.frame.width, y: 0.76 * self.frame.height) //right top
        let location5 = CGPoint(x: 0.87 * self.frame.width, y: 0.3 * self.frame.height)//right bottom
        let locationArray:[CGPoint]=[location3, location4, location5]
        for i in 0...2{
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
            rock.physicsBody!.collisionBitMask = edgeCategory | rockCategory | destroyerCategory
            rock.physicsBody!.velocity = CGVector(dx: randomSpeed()*0.65,dy: randomSpeed()*0.65)
        }
    }
    func addDestroyer(){
        let destroyer = SKSpriteNode(imageNamed: "destroyer")
        destroyer.xScale = 0.6
        destroyer.yScale = 0.6
        let minInt = Int(destroyer.size.height/1.4)
        let maxInt = Int(self.size.width-destroyer.size.width/2)
        let actualX = arc4random_uniform(UInt32(maxInt-minInt))
        destroyer.position = CGPoint(x: CGFloat(actualX), y: self.size.height+destroyer.size.height/2)
        destroyer.name = "destroyer"
        let minX = -destroyer.frame.width / 2.0
        let minY = -destroyer.frame.height / 2.0
        let maxX = destroyer.frame.width / 2.0
        let maxY = destroyer.frame.height / 2.0
        let points = [CGPoint(x: minX, y: maxY / 5.0), CGPoint(x: 0, y: maxY),CGPoint(x: maxX, y: maxY/5.0), CGPoint(x: 0, y: minY),CGPoint(x: minX, y: maxY/5.0)]
        let destroyerShape:CGPath = assymetricalPolygonPath(points)
        destroyer.physicsBody = SKPhysicsBody(polygonFrom: destroyerShape)
        destroyer.physicsBody?.isDynamic = false
        destroyer.physicsBody?.allowsRotation = false
        destroyer.physicsBody?.affectedByGravity = false
        destroyer.physicsBody?.categoryBitMask = destroyerCategory
        destroyer.physicsBody?.contactTestBitMask = bulletCategory | shipCategory
        destroyer.physicsBody?.collisionBitMask = 0xFFFFFFFF
        destroyer.physicsBody?.linearDamping = 0
        destroyer.physicsBody?.friction = 0
        destroyer.physicsBody?.usesPreciseCollisionDetection = true
        let moveAction = SKAction.moveTo(y: -self.frame.height/2.0, duration: 9.0)
        let waitAction = SKAction.wait(forDuration: 15.0)
        let removeAction = SKAction.removeFromParent()
        let actionSequence = [moveAction, waitAction, removeAction]
        destroyer.run(SKAction.sequence(actionSequence))
        self.addChild(destroyer)
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
            sprite.physicsBody?.collisionBitMask = edgeCategory | rockCategory | destroyerCategory
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
        let monster = SKSpriteNode(imageNamed: "UFO")
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
        monster.name = "invader"
        self.addChild(monster)
        let randomSpeed = drand48()*3+3
        let actionMove = SKAction.applyImpulse(CGVector(dx: -randomSpeed, dy:0) ,duration: 0.1)
        let waitAction = SKAction.wait(forDuration: 10.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = [actionMove,waitAction,removeAction]
        monster.run(SKAction.sequence(sequence))
    }
    
    override func createContent() {
        super.createContent()
        loadAsteroids()
        super.level = 5
        if super.musicOff{
            return
        }
        do{
            backgroundAudio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "rapTheme5", ofType: "mp3")!))
            backgroundAudio.volume = 0.6
            backgroundAudio.numberOfLoops = -1
            backgroundAudio.currentTime = 2.0
            backgroundAudio.play()
            //super.playTheme(backgroundAudio, volume: 0.6)
        }catch{
            print("AVAudioPlayer Failure")
            return
        }
    }
    override func handleContact(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil){
            return
        }
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        if ((nodeNames as NSArray).contains("invader") && (nodeNames as NSArray).contains("bullet")){
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
            monstersHit += 1
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
        
        if ((nodeNames as NSArray).contains("destroyer") && (nodeNames as NSArray).contains("bullet")){
            monstersHit += 1
            //var explosion:SKSpriteNode!
            if(contact.bodyA.node!.name == "destroyer"){
                //explosion = contact.bodyA.node! as! SKSpriteNode
                contact.bodyB.node!.removeFromParent()
            } else{
                //explosion = contact.bodyB.node! as! SKSpriteNode
                contact.bodyA.node!.removeFromParent()
            }/*
            if super.explosionOff{
                setupExplosion(explosion, soundFX: false, file: "shipExplodes.mp3")
            }else{
                setupExplosion(explosion, soundFX: true, file: "shipExplodes.mp3")
            }*/
            self.run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
        }

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
    }
    
// GAME ENDING
    
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
                super.level = 601
                self.level = 601
                highScore?.level = 601
                return true
            }
        }
        // then the game over scenario
        if(superEnded){
            return true
        }
        return false
    }
    func enemyFire(_ fighter: SKSpriteNode, angle: CGFloat){
        let bullet = SKSpriteNode(color: UIColor.magenta, size: CGSize(width: 3, height: 9))
        bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bullet.frame.width, height: bullet.frame.height))
        let bulletVelocity = CGVector(dx: cos(angle) * 350.0, dy: sin(angle) * 350.0)
        let bulletPosition = CGPoint(x:fighter.position.x ,y: fighter.position.y)
        //fighter.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        //fighter.runAction(SKAction.rotateByAngle(CGFloat(angle), duration: 0.20))
        bullet.position = bulletPosition
        bullet.run(SKAction.rotate(byAngle: angle+(CGFloat(M_PI/2)), duration: 0.01))
        bullet.name = "monsterBullet"
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.mass = 0.01
        bullet.physicsBody?.linearDamping = 0
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = shipCategory | edgeCategory
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.collisionBitMask = 0x00000000
        bullet.physicsBody?.fieldBitMask = 0x00000000
        bullet.run(SKAction.playSoundFileNamed("shipBullet.mp3", waitForCompletion: false))
        bullet.physicsBody?.velocity = bulletVelocity
        self.addChild(bullet)
    }

    
    override func update(_ currentTime: TimeInterval) {
        initializeTimer(currentTime)
        // super updates user controls
        super.update(currentTime)
        // gameEnds accounts for super
        if currentTime - super.timeOfLastUpdateForGameOver > 0.2{
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
                    if self.level == 601{
                        // Arcade mode is designed to have scenes run continuously upon successful completion
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
            super.timeOfLastUpdateForGameOver = currentTime
        }
        invaderAttack(currentTime)
        updateDestroyer(currentTime)
        processContactsForUpdate(currentTime)
        updateRocksForRemoval(currentTime)
    }
    func updateDestroyer(_ currentTime: CFTimeInterval){
        if currentTime - timeOfLastUpdateForLevel > 10.0{
            addDestroyer()
            timeOfLastUpdateForLevel = currentTime
        }
    }
    func initializeTimer(_ currentTime: CFTimeInterval){
        if timeOfLastUpdateForLevel < 0.1{
            timeOfLastUpdateForLevel = currentTime
            timeOfLastUpdateForInvaderAttack = currentTime
            timeOfLastUpdateForRockRemoval = currentTime
        }
    }
}
