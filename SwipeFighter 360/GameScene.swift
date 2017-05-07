//
//  GameScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 12/1/15.
//  Copyright (c) 2015 DimeZee Software. All rights reserved.
//
     //( disable : 382:74070)

import SpriteKit
import CoreMotion
import AVFoundation

protocol GameSceneDelegate {
    func gameSceneDidFinish(myScene:GameScene, command: String)
    func updateTransitionLevvel(myScene:GameScene)
    func changeScene(myScene:GameScene, command: String)
}

class GameScene: SKScene,SKPhysicsContactDelegate{
 
    var backgroundAudio:AVAudioPlayer!
    var timeOfLastUpdateForRockRemoval:CFTimeInterval = 0
    var swipeMode:Bool = true
    var thisDelegate:GameSceneDelegate?
    var contactArray:[SKPhysicsContact]=[]
    let shipCategory:UInt32 = 0x00000001
    let rockCategory:UInt32 = 0x00000010
    let edgeCategory:UInt32 = 0x00000100
    let bulletCategory:UInt32 = 0x00001000
    let invaderCategory:UInt32 = 0x00010000
    let motionManager: CMMotionManager = CMMotionManager()
    var shipAngle = 0.0
    var timeOfLastUpdateForUserMotion:CFTimeInterval = 0
    var timeOfLastUpdateForInvaderAttack:CFTimeInterval = 0
    var timeOfLastUpdateForAsteroidField:CFTimeInterval = 0
    var timeOfLastUpdateForLevel:CFTimeInterval = 0
    var timeOfLastUpdateForRateOfTurn:CFTimeInterval = 0
    var timeOfLastUpdateForGameOver:CFTimeInterval = 0
    var timeOfLastUpdateForAccuracy:CFTimeInterval = 0
    var bulletTimer:CFTimeInterval = 0
    var contentCreated:Bool = false
    var points:Int = 0
    var gameEnds:Bool = false
    var level:Int = 0
    var bulletDelay = false
    var fast:Bool = true
    var attenuationSteeringFactor:Double = 1.0
    //var fireButton:UIButton!
    var slowButton:UIButton!
    var highScore:HighScore?
    var bestScore:HighScore?
    var accuracy:Double = 0.0
    var bulletsFired:Int = 0
    var monstersHit:Int = 0
    var explosionOff:Bool = false
    var lazerOff:Bool = false
    var musicOff:Bool = false
    var arcadeMode:Bool = false
    var explosion: SKSpriteNode!
    var shipExplodes: SKAction!
    
    func updateBestScore(){
        if highScore != nil {
            if bestScore != nil{
                if highScore!.level > bestScore!.level{
                    print("highScore.level is greater than bestScore.level")
                    // higher level is better
                    if highScore!.level < 99{
                        print("not a storyboard scene")
                        bestScore! = highScore!
                    }
                }
                if highScore!.level == bestScore!.level{
                    if bestScore!.lives > highScore!.lives{
                        print("level is equal, highScore.lives is less than the bestScore.lives")
                        // less lives is better
                        bestScore! = highScore!
                    }
                    if bestScore!.lives == highScore!.lives{
                        if bestScore!.accuracy < highScore!.accuracy{
                            print("level and lives equal, accuracy is greater at object highScore")
                            // more accuracy is better
                            bestScore! = highScore!
                        }
                    }
                }
                
            }else{
                print("bestScore not found, initializing to highScore")
                bestScore! = highScore!
            }
        }else{
            print("highScore not found in Scene")
        }
    }
    func updateAccuracy(){
        if highScore != nil{
            highScore?.accuracy += self.accuracy
        }
    }

    func displayAccuracy(){
        let myLabel = SKLabelNode(fontNamed: "Arial")
        myLabel.name = "accuracy"
        myLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.9)
        myLabel.text = String(format: "Accuracy: %.1f%%", 100.0)
        myLabel.fontSize = 25
        myLabel.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel.alpha = 0.9
        self.addChild(myLabel)
    }
    
    func cleanupStrongReferences(){
        var nodes:[SKNode] = []
        enumerateChildNodesWithName("//*", usingBlock: {
                node, stop in nodes.append(node)
            })
        print("Node Count: \(nodes.count)")
        for node in nodes{
            node.removeAllActions()
        }
    }
    func updateRocksForRemoval(currentTime: CFTimeInterval){
        if currentTime - timeOfLastUpdateForRockRemoval > 1.0{
            var badRockCount:Int = 0
            var allRocks: [SKNode] = []
            self.enumerateChildNodesWithName("rock"){
                node, stop in allRocks.append(node)}
            self.enumerateChildNodesWithName("brownRock"){
                node, stop in allRocks.append(node)}
            for rock in allRocks{
                if rock.position.x > self.frame.width{
                    badRockCount += 1
                    rock.removeFromParent()
                }
                if rock.position.y > self.frame.height{
                    badRockCount += 1
                    rock.removeFromParent()
                }
                if rock.position.x < 0 || rock.position.y < 0{
                    badRockCount += 1
                    rock.removeFromParent()
                }
            }
            timeOfLastUpdateForRockRemoval = currentTime
        }
    }
    
    
    override func didMoveToView(view: SKView) {
        userInteractionEnabled = true
        physicsWorld.contactDelegate = self
        motionManager.startAccelerometerUpdates()
        motionManager.startMagnetometerUpdates()
        if !self.contentCreated{
            self.createContent()
        }
    }
    
// MARK: MAIN CONTENT
    
    func randomSpeed()->CGFloat{
        var velocity = CGFloat(0.0)
        let positive = arc4random_uniform(2)
        let strength = CGFloat(arc4random_uniform(5))
        if(positive == 1){
            velocity = strength * CGFloat(15.0)
            return velocity
        } else {
            velocity = strength * CGFloat(-15.0)
            return velocity
        }
    }
    func addShip(){

        let ship = SKSpriteNode(imageNamed:"newShip")
        ship.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.addChild(ship)
        ship.name = "ship"
        ship.physicsBody = SKPhysicsBody(circleOfRadius: ship.size.width/2)
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.allowsRotation = false
// Ship bounces off edge, killed by rocks
        ship.physicsBody!.categoryBitMask = shipCategory
        ship.physicsBody!.contactTestBitMask = rockCategory
        ship.physicsBody!.collisionBitMask = edgeCategory
        ship.physicsBody!.fieldBitMask = 0x00000000
    }
    func degree2radian(a:CGFloat)->CGFloat {
        let b = CGFloat(M_PI) * a/180
        return b
    }
    func polygonPointArray(sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,offset:CGFloat)->[CGPoint] {
        let angle = degree2radian(360/CGFloat(sides))
        let cx = x // x origin
        let cy = y // y origin
        let r  = radius // radius of circle
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            let xpo = cx + r * cos(angle * CGFloat(i) - offset)
            let ypo = cy + r * sin(angle * CGFloat(i) - offset)
            // need to shift x and y by a few degrees so that a triangle lines up with a ship
            points.append(CGPoint(x: xpo, y: ypo))
            i += 1
        }
        return points
    }

    func polygonPath(x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, offset: CGFloat) -> CGPathRef {
        let path = CGPathCreateMutable()
        let points = polygonPointArray(sides,x: x,y: y,radius: radius, offset: offset)
        let cpg = points[0]
        CGPathMoveToPoint(path, nil, cpg.x, cpg.y)
        for p in points {
            CGPathAddLineToPoint(path, nil, p.x, p.y)
        }
        CGPathCloseSubpath(path)
        return path
    }
    
    func assymetricalPolygonPath(points:[CGPoint])->CGPathRef{
        let path = CGPathCreateMutable()
        let cpg = points[0]
        CGPathMoveToPoint(path, nil, cpg.x, cpg.y)
        for p in points {
            CGPathAddLineToPoint(path, nil, p.x, p.y)
        }
        CGPathCloseSubpath(path)
        return path
    }
    
    func loadBoundary(){
        let boundary = SKSpriteNode(imageNamed: "space")
        boundary.position = CGPoint(x: frame.width/2, y: frame.height/2)
        boundary.name = "boundary"
        boundary.xScale = 1.04
        boundary.yScale = 1.04
        self.addChild(boundary)
        boundary.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(-frame.width/2, -frame.height/2, frame.width, frame.height))
        boundary.physicsBody!.affectedByGravity = false
        boundary.physicsBody!.dynamic = false
        boundary.physicsBody!.categoryBitMask = edgeCategory
        boundary.physicsBody!.contactTestBitMask = bulletCategory
        boundary.physicsBody!.collisionBitMask = 0xFFFFFFFF
    }
    
    func playTheme(backgroundAudio: AVAudioPlayer, volume: Float){
        backgroundAudio.volume = volume
        backgroundAudio.currentTime = 0
        backgroundAudio.play()
        backgroundAudio.numberOfLoops = -1
    }
    func addFireButton(){
        let fireButton = UIButton(frame: CGRect(x: 0, y: scene!.size.height-90, width: 90, height: 90))
        fireButton.backgroundColor = UIColor.clearColor()
        fireButton.setTitle("FIRE", forState: UIControlState.Normal)
        fireButton.setTitleColor(UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0), forState: UIControlState.Normal)
        fireButton.addTarget(self, action: #selector(GameScene.fireAction(_:)), forControlEvents: UIControlEvents.TouchDown)
        self.view!.addSubview(fireButton)
    }

    func addSlowButton(){
        slowButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        slowButton.backgroundColor = UIColor.clearColor()
        slowButton.setTitle("FAST", forState: UIControlState.Normal)
        slowButton.setTitleColor(UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0), forState: UIControlState.Normal)
        slowButton.addTarget(self, action: #selector(GameScene.adjustTurnAction(_:)), forControlEvents: UIControlEvents.TouchDown)
        self.view!.addSubview(slowButton)
    }

    func createContent(){
        loadBoundary()
        addShip()
        addFireButton()
        addSlowButton()
        displayAccuracy()
        contentCreated = true
    }
// MARK: USER CONTROLS SECTION
    
    func fireAction(sender: UIButton!){
        fireBullets()
    }

    func adjustTurnAction(sender: UIButton!){
        if fast == true{
            slowButton.setTitle("SLOW", forState: UIControlState.Normal)
            fast = false
        }else{
            slowButton.setTitle("FAST", forState: UIControlState.Normal)
            fast = true
        }
    }
    func processUserMotionForUpdate(currentTime: CFTimeInterval){
        
        if (currentTime - timeOfLastUpdateForUserMotion > 0.1) {
            
            if let ship = self.childNodeWithName("ship") as! SKSpriteNode!{
                
                if let data = motionManager.accelerometerData {
                    ship.runAction(SKAction.rotateByAngle(-CGFloat(data.acceleration.y * attenuationSteeringFactor), duration:0.1))
                    shipAngle -= data.acceleration.y * attenuationSteeringFactor
                    timeOfLastUpdateForUserMotion = currentTime
                }
            }
        }
    }
    
    func bulletTrajectory()->CGVector{
        //converts boundless rotations(shipAngle) into bounded trig argument and returns vector for bullet
        var angleInDegrees:Int = Int(shipAngle * (180.0/M_PI) + 90.0)
        var angleInRadians:Double = shipAngle + M_PI/2.0
        var x: Double = 0.0
        var y: Double = 0.0
        var bulletVector = CGVector(dx: 0.0, dy: 0.0)
        while (angleInDegrees > 180){
            // decrement angle until its below 180")
            angleInDegrees -= 360
            angleInRadians -= 2.0 * M_PI
        }
        while (angleInDegrees < -180){
            // increment angle until its above -180")
            angleInDegrees += 360
            angleInRadians += 2.0*M_PI
        }
        if ((angleInDegrees <= 180)&&(angleInDegrees >= -180)){
            x = cos(angleInRadians)
            y = sin(angleInRadians)
            bulletVector = CGVector(dx: x , dy: y )
            // Ship is pointed at angleInDegrees, bulletVector is a unit vector pointed in the direction of the ship)
        }
        return bulletVector
    }
    func fireBullets(){
        if bulletDelay == false{
            if let ship = self.childNodeWithName("ship"){
                let bullet = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: 3, height: 9))
                bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: bullet.frame.width, height: bullet.frame.height))
                let unitVelocity = bulletTrajectory()
                let bulletVelocity = CGVector(dx: unitVelocity.dx * 350.0, dy: unitVelocity.dy * 350.0)
                let bulletDisplacementX = unitVelocity.dx * 10.0
                let bulletDisplacementY = unitVelocity.dy * 10.0
                let bulletPosition = CGPoint(x: ship.position.x + bulletDisplacementX,y: ship.position.y + bulletDisplacementY)
                bullet.position = bulletPosition
                bullet.runAction(SKAction.rotateByAngle(CGFloat(shipAngle), duration: 0.01))
                bullet.name = "bullet"
                bullet.physicsBody?.affectedByGravity = false
                bullet.physicsBody?.dynamic = true
                bullet.physicsBody?.mass = 0.01
                bullet.physicsBody?.categoryBitMask = bulletCategory
                bullet.physicsBody?.contactTestBitMask = rockCategory | edgeCategory
                bullet.physicsBody?.collisionBitMask = 0x00000000
                bullet.physicsBody?.fieldBitMask = 0x00000000
                bullet.physicsBody?.usesPreciseCollisionDetection = true
                bullet.physicsBody?.velocity = bulletVelocity
                self.addChild(bullet)
                bulletDelay = true
                bulletsFired += 1
                if self.lazerOff{
                    return
                }
                let soundAction = SKAction.playSoundFileNamed("shipBullet.mp3", waitForCompletion: true)
                bullet.runAction(soundAction, withKey: "bulletSound")
                //bullet.runAction(SKAction.playSoundFileNamed("shipBullet.mp3", waitForCompletion: true))
                // update function toggles bulletDelay to false per bulletTimer in updateBulletDelay
            }
        }
    }
    
// MARK: CONTACT SECTION
    
    func didBeginContact(contact: SKPhysicsContact){ // adds contacts from contactDelegate into an array
        if contact as SKPhysicsContact? != nil {
            self.contactArray.append(contact)
        }
    }
    func handleContact(contact: SKPhysicsContact) { // helper function: main guts of update
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil){
            return
        }
// subclasses handle specific instances of contact
    }
    func processContactsForUpdate(currentTime: CFTimeInterval){
        for contact in self.contactArray {
            self.handleContact(contact)
            if let index = (self.contactArray as NSArray).indexOfObject(contact) as Int? {
                self.contactArray.removeAtIndex(index)
            }
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swipeMode{
            for touch in touches {
                if let ship = childNodeWithName("ship"){
                    //let x = touch.locationInNode(self).x
                    //let y = touch.locationInNode(self).y
                    //let dx = x - ship.position.x
                    //let dy = y - ship.position.y
                    //let shipVelocity = CGVector(dx: 1.5*dx, dy: 1.5*dy)
                    //ship.runAction(SKAction.applyForce(shipVelocity, duration: 0.05))
                    let scalingFactor:CGFloat = 11.0
                    let dx = touch.locationInNode(self).x - ship.position.x
                    let dy = touch.locationInNode(self).y - ship.position.y
                    let shipVelocity = CGVector(dx: scalingFactor*dx, dy: scalingFactor*dy)
                    // while function acts like high pass filter
                    /*while abs(shipVelocity.dx) > CGFloat(650) || abs(shipVelocity.dy) > CGFloat(650){
                        shipVelocity = CGVector(dx: shipVelocity.dx * CGFloat(0.5), dy: shipVelocity.dy * CGFloat(0.5))
                    }*/
                    let waitAction = SKAction.waitForDuration(0.15)
                    let moveAction = SKAction.applyForce(shipVelocity, duration: 0.04)
                    let stopAction = (SKAction.runBlock({
                        ship.physicsBody?.velocity = CGVector(dx: 0, dy: 0)}))
                    let actionSequence:[SKAction] = [moveAction, waitAction, stopAction]
                    ship.runAction(SKAction.sequence(actionSequence))
                }
            }
        }

    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if swipeMode{
            for touch in touches {
                if let ship = childNodeWithName("ship"){
                    let scalingFactor:CGFloat = 11.0
                    let dx = touch.locationInNode(self).x - ship.position.x
                    let dy = touch.locationInNode(self).y - ship.position.y
                    var shipVelocity = CGVector(dx: scalingFactor*dx, dy: scalingFactor*dy)
                    // while function acts like high pass filter
                    while abs(shipVelocity.dx) > CGFloat(650) || abs(shipVelocity.dy) > CGFloat(650){
                        shipVelocity = CGVector(dx: shipVelocity.dx * CGFloat(0.5), dy: shipVelocity.dy * CGFloat(0.5))
                    }
                    let waitAction = SKAction.waitForDuration(0.15)
                    let moveAction = SKAction.applyForce(shipVelocity, duration: 0.04)
                    let stopAction = (SKAction.runBlock({
                        ship.physicsBody?.velocity = CGVector(dx: 0, dy: 0)}))
                    let actionSequence:[SKAction] = [moveAction, waitAction, stopAction]
                    ship.runAction(SKAction.sequence(actionSequence))
                }
            }
        }
    }

// LEVEL AND GAME ENDING SECTION
    
    func gameEnded(currentTime: CFTimeInterval)->Bool{
// subclasses of GameScene call gameEnded because the ship always has to exist
        var allShips: [SKNode] = []
        // put nodes in array
        self.enumerateChildNodesWithName("ship"){//<--FIND SHIPS HERE
            node, stop in allShips.append(node)}
        if(allShips.count == 0){
            return true
        }
        return false
    }


    func updateDisplayAccuracy(currentTime:CFTimeInterval){
        if currentTime - timeOfLastUpdateForAccuracy > 0.3{
            if let acc = childNodeWithName("accuracy") as? SKLabelNode{
                if self.highScore?.level < 99{
                    if bulletsFired != 0 {
                        accuracy = Double(monstersHit) / Double(bulletsFired)
                        acc.text = String(format: "Accuracy: %.1f%%", accuracy * 100)
                    }else{
                        acc.text = "---"
                    }
                }else{
                    acc.removeFromParent()
                    if let button =  slowButton{
                        button.alpha = 0
                    }
                }
            }
            timeOfLastUpdateForAccuracy = currentTime
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        processUserMotionForUpdate(currentTime)
        updateBulletDelay(currentTime)
        updateRateOfTurning(currentTime)
        updateDisplayAccuracy(currentTime)
    }
    func updateBulletDelay(currentTime: CFTimeInterval){
        if currentTime - bulletTimer > 0.4{
            bulletDelay = false
            bulletTimer = currentTime
        }
    }
    func updateRateOfTurning(currentTime: CFTimeInterval){
        if currentTime - timeOfLastUpdateForRateOfTurn > 0.5{
            if !fast{
                attenuationSteeringFactor = 0.4
                
            }else{
                attenuationSteeringFactor = 1.0
            }
            timeOfLastUpdateForRateOfTurn = currentTime
        }
    }
    func setupExplosion(node: SKSpriteNode, soundFX: Bool, file: String){
        node.physicsBody?.velocity = CGVector(dx: (node.physicsBody?.velocity.dx)! * 0.5, dy: (node.physicsBody?.velocity.dy)! * 0.5)
        node.physicsBody?.categoryBitMask = 0x00000000
        node.physicsBody?.collisionBitMask = 0x00000000
        node.physicsBody?.contactTestBitMask = 0x00000000
        node.physicsBody?.affectedByGravity = false
        let atlas = SKTextureAtlas(named: "explosion")
        var explosionFrames = [SKTexture]()
        let numImages = atlas.textureNames.count
        for i in 1...numImages{
            var explosionTextureName: String!
            if i < 10{
                explosionTextureName = String(format: "explosion_0%i.png", i)
            }else{
                explosionTextureName = String(format: "explosion_%2i.png", i)
            }
            explosionFrames.append(atlas.textureNamed(explosionTextureName))
        }
        let soundAction = SKAction.playSoundFileNamed(file, waitForCompletion: true)
        shipExplodes = SKAction.animateWithTextures(explosionFrames, timePerFrame: 0.03)
        let waitAction = SKAction.waitForDuration(1.2)
        let removeAction = SKAction.removeFromParent()
        let group:[SKAction] = [soundAction, shipExplodes]
        let sequence:[SKAction] = [waitAction,removeAction]
        if !soundFX{
            node.runAction(shipExplodes)
        }else{
            node.runAction(SKAction.group(group))
        }
        node.runAction(SKAction.sequence(sequence))
    }
    func removeBulletSounds(){
        var bullets:[SKNode]=[]
        enumerateChildNodesWithName("bullet", usingBlock: {node, stop in bullets.append(node)})
        for bullet in bullets{
            bullet.removeActionForKey("soundAction")
        }
    }
}
