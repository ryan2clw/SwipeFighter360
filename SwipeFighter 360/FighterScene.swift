//
//  LevelFiveScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 12/22/15.
//  Copyright © 2015 DimeZee Software. All rights reserved.
//

import AVFoundation
import CoreMotion
import SpriteKit

class FighterScene: GameScene{
    
    //let rightFieldCategory:UInt32 = 0x00100000
    //let upFieldCategory:UInt32 = 0x00200000
    //let leftFieldCategory:UInt32 = 0x00400000
    //let downFieldCategory:UInt32 = 0x00800000
    var timeOfLastUpdateForGameEnding = 0.0
    var timerLevelTwo = 0.0
   // var backgroundAudio:AVAudioPlayer!// = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gangstaTheme8", ofType: "mp3")!))
    var fighters:[FighterNode] = []
    var timeOfLastUpdateForEnemeyFire:CFTimeInterval = 0
    
    override func createContent() {
        super.level = 8
        super.createContent()
        displayTimer(Int(timerLevelTwo))
        if super.musicOff{
            return
        }
        backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "gangstaTheme8", ofType: "mp3")!))
        super.playTheme(backgroundAudio, volume: 0.4)
    }
    func asteroidField(_ currentTime: CFTimeInterval){
        // replaced asteroids with fighters, pardon the misnomers
        if currentTime - timeOfLastUpdateForAsteroidField > 6.0 {
            var allRocks:[SKSpriteNode]=[]
            self.enumerateChildNodes(withName: "rock"){// <--FIND ROCKS HERE
                node, stop in allRocks.append(node as! SKSpriteNode)}
            self.enumerateChildNodes(withName: "brownRock"){// <--FIND ROCKS HERE
                node, stop in allRocks.append(node as! SKSpriteNode)}
            if allRocks.count < 4{
                let rock:FighterNode = FighterNode(imageNamed: "fighter2")
                rock.name = "monster"
                rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.frame.width/2.2)
                rock.physicsBody?.affectedByGravity = false
                rock.physicsBody?.categoryBitMask = rockCategory
                rock.physicsBody?.contactTestBitMask = bulletCategory | shipCategory
                rock.physicsBody?.collisionBitMask = 0x00000000
                rock.physicsBody?.usesPreciseCollisionDetection = true
                rock.physicsBody?.allowsRotation = false
                rock.physicsBody?.mass = 0.1
                rock.physicsBody?.linearDamping = 0
                rock.physicsBody?.restitution = 1.0
                //   let waitAction = SKAction.waitForDuration(10.0)
                // let removeAction = SKAction.removeFromParent()
                // pick random side and pass in position and velocity
                let randomSide = arc4random_uniform(4)
                // Determine where to spawn the monster along the Y axis
                var minInt = Int(rock.size.height/1.4)
                var maxInt = Int(self.size.height-rock.size.height/2)
                let actualY = arc4random_uniform(UInt32(maxInt-minInt))
                let randomSpeed = drand48()+2
                var moveAction = SKAction.applyImpulse(CGVector(dx: 0, dy: 0), duration: 0.1)
                var rotateAction = SKAction.rotate(byAngle: 0, duration: 0.1)
                // Rocks curve toward center, field category depends on entry location
                // asteroid from left
                if randomSide == 0 {
                    rock.position = CGPoint(x: self.size.width + rock.size.width/2, y: CGFloat(actualY))
                    moveAction = SKAction.applyImpulse(CGVector(dx: -2.0 * randomSpeed, dy:0) ,duration: 0.1)
                    
                }
                // asteroid from right
                if randomSide == 1 {
                    rock.position = CGPoint(x: -rock.size.width/2, y: CGFloat(actualY))
                    moveAction = SKAction.applyImpulse(CGVector(dx: 2.0 * randomSpeed, dy:0) ,duration: 0.1)
                    rotateAction = SKAction.rotate(byAngle: CGFloat(M_PI), duration: 0.1)
                    rock.angle = 0
                }
                // asteroid from above
                minInt = Int(rock.size.height/1.4)
                maxInt = Int(self.size.width-rock.size.width/2)
                let actualX = arc4random_uniform(UInt32(maxInt-minInt))
                if randomSide == 2{
                    rotateAction = SKAction.rotate(byAngle: CGFloat(M_PI/2.0), duration: 0.1)
                    rock.angle = CGFloat(-M_PI/2.0)
                    rock.position = CGPoint(x: CGFloat(actualX), y: self.size.height+rock.size.height/2)
                    moveAction = SKAction.applyImpulse(CGVector(dx: 0, dy: -2.0 * randomSpeed) ,duration: 0.1)
                    
                }
                // asteroid from below
                if randomSide == 3{
                    rock.position = CGPoint(x: CGFloat(actualX), y: -rock.size.width/2)
                    rotateAction = SKAction.rotate(byAngle: CGFloat(-M_PI/2.0), duration: 0.1)
                    rock.angle = CGFloat(M_PI/2.0)
                    moveAction = SKAction.applyImpulse(CGVector(dx: 0, dy:3.0 * randomSpeed) ,duration: 0.1)
                }
                // Position the monster slightly off-screen along the right edge, randomly
                let sequence = [rotateAction, moveAction]
                // add rocks and let er rip
                self.addChild(rock)
                rock.run(SKAction.sequence(sequence))
                timeOfLastUpdateForAsteroidField = currentTime
            }
        }
    }


    func initializeTimer(_ currentTime: CFTimeInterval){
        if timeOfLastUpdateForLevel < 0.1{
            timeOfLastUpdateForLevel = currentTime
        }
    }
    override func handleContact(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil){
            return
        }
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
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
        if ((nodeNames as NSArray).contains("monster") && (nodeNames as NSArray).contains("bullet")){
            monstersHit += 1
            var explosion:SKSpriteNode!
            if(contact.bodyA.node!.name == "monster"){
                explosion = contact.bodyA.node! as! SKSpriteNode
                explosion.name = "monsterSpent"
                contact.bodyB.node!.removeFromParent()
            } else{
                explosion = contact.bodyB.node! as! SKSpriteNode
                explosion.name = "monsterSpent"
                contact.bodyA.node!.removeFromParent()
            }
            if super.explosionOff{
                setupExplosion(explosion, soundFX: false, file: "shipExplodes.mp3")
            }else{
                setupExplosion(explosion, soundFX: true, file: "shipExplodes.mp3")
            }
        }/*
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
        }*/
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
        if currentTime - timeOfLastUpdateForGameEnding > 0.3{
            // super checks for ship, other endings are specific to level
            if super.gameEnded(currentTime){
                return true
            }
            timerLevelTwo = currentTime - timeOfLastUpdateForLevel
            let timer = childNode(withName: "timer") as! SKLabelNode
            timer.text = "Timer: \(Int(timerLevelTwo))"
            if timerLevelTwo > 60.0{
                super.level = 901
                highScore?.level = 901
                return true
            }
        timeOfLastUpdateForGameEnding = currentTime
        }
    return false
    }
    
    override func update(_ currentTime: TimeInterval) {
        initializeTimer(currentTime)
        super.update(currentTime)
        gameEnds = gameEnded(currentTime)
        if gameEnds == true{
            if let timerLabel = childNode(withName: "timer") as? SKLabelNode{
                timerLabel.text = "DONE"
            }
            motionManager.stopAccelerometerUpdates()
            if backgroundAudio != nil{
                backgroundAudio.stop()
            }
            shipAngle = 0.0
            if !arcadeMode{
                self.thisDelegate?.gameSceneDidFinish(self, command: "close")
            }else{
                if super.level == 901{
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
        processContactsForUpdate(currentTime)
        asteroidField(currentTime)
        updateAimMoveFighter(currentTime)
        updateEnemyFire(currentTime)
    }

    func updateAimMoveFighter(_ currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForInvaderAttack > 0.2) {
            aimFighters()
            timeOfLastUpdateForInvaderAttack = currentTime
        }
    }
    func gatherFighters(){
        self.enumerateChildNodes(withName: "monster"){
            node, stop in self.fighters.append(node as! FighterNode)}

    }
    func updateEnemyFire(_ currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForEnemeyFire > 1.0) {
            gatherFighters()
            if let ship = childNode(withName: "ship"){
                for fighter in fighters{
                    let dx = fighter.position.x - ship.position.x
                    let dy = fighter.position.y - ship.position.y
                    let distance = sqrt(dx*dx+dy*dy)
                    if distance < 160.0{
                        enemyFire(fighter as SKSpriteNode, angle: fighter.angle)
                    }
                }
                timeOfLastUpdateForEnemeyFire = currentTime
            }
            self.fighters = []
        }
    }
    
    func aimFighters()->(){
        gatherFighters()
        // Finds absolute heading from fighter to ship
            if let ship = childNode(withName: "ship"){
            for fighter in fighters{
                let dx = ship.position.x - fighter.position.x
                let dy = ship.position.y - fighter.position.y
                var angle = atan(dy/dx)
                if ship.position.x < fighter.position.x{
                    if ship.position.y > fighter.position.y{
                        angle += CGFloat(M_PI)
                    }else{
                        angle -= CGFloat(M_PI)
                    }
                }
                // subclassed SpriteNode handles its angle internally, while function makes turning less awkward
                var difference = fighter.addDifferenceBetweenAngles(angle)
                while difference > CGFloat(M_PI){
                    difference -= CGFloat(2.0*M_PI)
                }
                while difference < CGFloat(-M_PI){
                    difference += CGFloat(2.0*M_PI)
                }
                fighter.run(SKAction.rotate(byAngle: difference, duration: 0.2))
                let magnitude:CGFloat = 1.0
                let vector = CGVector(dx: magnitude*cos(fighter.angle), dy: magnitude*sin(fighter.angle))
                fighter.run(SKAction.applyImpulse(vector, duration: 0.1))
            }
        self.fighters = []
        }
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
}
