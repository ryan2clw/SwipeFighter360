//
//  BossScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/14/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.
//

import AVFoundation
import SpriteKit
import CoreMotion

class BossScene: GameScene{
    
   // var backgroundAudio:AVAudioPlayer!
    let destroyerCategory:UInt32 = 0x20000000
    var destroyerHealth:Double = 1.00
    var timeOfLastUpdateForHUD = 0.0
    var timeOfLastUpdateForGameEnding = 0.0
    var timeOfLastUpdateForDestroyerAttack = 0.0
    var timeOfLastUpdateForEnemyFire = 0.0
    var fighters:[FighterNode] = []
    
    func gatherFighters(){
        self.enumerateChildNodes(withName: "monster"){
            node, stop in self.fighters.append(node as! FighterNode)}
    }
    func updateEnemyFire(_ currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForEnemyFire > 1.0) {
            gatherFighters()
            if let ship = childNode(withName: "ship"){
                for fighter in fighters{
                    let dx = fighter.position.x - ship.position.x
                    let dy = fighter.position.y - ship.position.y
                    let distance = sqrt(dx*dx+dy*dy)
                    if distance < 144.0{
                        enemyFire(fighter as SKSpriteNode, angle: fighter.angle)
                    }
                }
                timeOfLastUpdateForEnemyFire = currentTime
            }
            self.fighters = []
        }
    }

    func setupHud() {
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        healthLabel.name = "health"
        healthLabel.fontSize = 25
        //5
        healthLabel.fontColor = SKColor.green
        healthLabel.text = String(format: "Boss: %.1f%%", destroyerHealth * 100.0)
        //6
        healthLabel.position = CGPoint(x: frame.size.width / 6, y: self.frame.height*0.92)
        healthLabel.alpha = 0
        addChild(healthLabel)
    }
    
    func loadAsteroids(){
        let location = CGPoint(x: 0.87 * self.frame.width, y: 0.298 * self.frame.height)
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
        //let moveAction = SKAction.applyImpulse(CGVector(dx: 0, dy: -3.0 * randomSpeed()), duration: 0.1)
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
    func invaderAttack(_ currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForInvaderAttack > 5.0) {
            addMonster()
            timeOfLastUpdateForInvaderAttack = currentTime
        }
    }
    
    override func createContent() {
        super.createContent()
        loadAsteroids()
        setupHud()
        super.level = 9
        if super.musicOff{
            return
        }
        backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "dopeTrapBeat9", ofType: "mp3")!))
        super.playTheme(backgroundAudio, volume: 1.0)
    }
    override func handleContact(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil){
            return
        }
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        if ((nodeNames as NSArray).contains("monster") && (nodeNames as NSArray).contains("bullet")){
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
        if ((nodeNames as NSArray).contains("destroyer") && (nodeNames as NSArray).contains("bullet")){
            if(contact.bodyA.node!.name == "bullet"){
                contact.bodyA.node!.removeFromParent()
            } else{
                contact.bodyB.node!.removeFromParent()
            }
            destroyerHealth -= 0.02
            points += 10
            monstersHit += 1
            if super.explosionOff{
                return
            }
            self.run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
        }
    }
    
    // GAME ENDING
    
    override func gameEnded(_ currentTime: CFTimeInterval)->Bool{
        if currentTime - timeOfLastUpdateForGameEnding > 0.3{
            let superEnded = super.gameEnded(currentTime)  // super checks for ship
            if(superEnded){
                return true
            }
            if destroyerHealth < 0.0{
                super.level = 11
                highScore?.level = 11
                return true
            }
            timeOfLastUpdateForGameEnding = currentTime
        }
        return false
    }
    
    override func update(_ currentTime: TimeInterval) {
        // super updates user controls
        initializeTimer(currentTime)
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
                if super.level == 11{
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
        invaderAttack(currentTime)
        updateDestroyer(currentTime)
        processContactsForUpdate(currentTime)
        updateHUD(currentTime)
        destroyerAttack(currentTime)
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
    func updateDestroyer(_ currentTime: CFTimeInterval){
        if currentTime - timeOfLastUpdateForLevel > 10.0{
            var allRocks: [SKNode] = []
            // put nodes in array
            self.enumerateChildNodes(withName: "rock"){// <--FIND ROCKS HERE
                node, stop in allRocks.append(node)}
            self.enumerateChildNodes(withName: "brownRock"){// <--FIND ROCKS HERE
                node, stop in allRocks.append(node)}
            if allRocks.count < 4{
                if let label = childNode(withName: "health"){
                    label.alpha = 1.0
                }
                addDestroyer()
                timeOfLastUpdateForLevel = currentTime
            }
        }
    }
    
    func updateHUD(_ currentTime: CFTimeInterval){
        if currentTime - timeOfLastUpdateForHUD > 0.2{
            if let healthLabel = childNode(withName: "health") as? SKLabelNode{
                healthLabel.text = String(format: "Boss: %.1f%%", destroyerHealth * 100.0)
                timeOfLastUpdateForHUD = currentTime
            }
        }
    }
    func initializeTimer(_ currentTime: CFTimeInterval){
        if timeOfLastUpdateForLevel < 0.1{
            timeOfLastUpdateForLevel = currentTime
            timeOfLastUpdateForInvaderAttack = currentTime
            timeOfLastUpdateForHUD = currentTime
            timeOfLastUpdateForGameEnding = currentTime
            timeOfLastUpdateForDestroyerAttack = currentTime
            timeOfLastUpdateForAsteroidField = currentTime
        }
    }
    func enemyFire(_ fighter: SKSpriteNode, angle: CGFloat){
        let bullet = SKSpriteNode(color: UIColor.magenta, size: CGSize(width: 3, height: 9))
        bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bullet.frame.width, height: bullet.frame.height))
        let bulletVelocity = CGVector(dx: cos(angle) * 330.0, dy: sin(angle) * 330.0)
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
    func destroyerAttack(_ currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForDestroyerAttack > 1.0) {
            if let ship = childNode(withName: "ship"){
                var fighters:[SKSpriteNode]=[]
                self.enumerateChildNodes(withName: "destroyer"){
                    node, stop in fighters.append(node as! SKSpriteNode)}
                for fighter in fighters{
                    let dx = fighter.position.x - ship.position.x
                    let dy = fighter.position.y - ship.position.y
                    let distance = sqrt(dx*dx+dy*dy)
                    var angle = atan(dy/dx)
                    if ship.position.x < fighter.position.x{
                        angle += CGFloat(M_PI)
                    }
                    if distance < self.frame.width/3.8{
                        enemyFire(fighter, angle: angle)
                        timeOfLastUpdateForDestroyerAttack = currentTime
                    }
                }
            }
        }
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
                let sequence = [rotateAction, moveAction]
                // add rocks and let er rip
                self.addChild(rock)
                rock.run(SKAction.sequence(sequence))
                timeOfLastUpdateForAsteroidField = currentTime
            }
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
}
