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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol GameSceneDelegate {
    func gameSceneDidFinish(_ myScene:GameScene, command: String)
    func updateTransitionLevvel(_ myScene:GameScene)
    func changeScene(_ myScene:GameScene, command: String)
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
        enumerateChildNodes(withName: "//*", using: {
                node, stop in nodes.append(node)
            })
        print("Node Count: \(nodes.count)")
        for node in nodes{
            node.removeAllActions()
        }
    }
    func updateRocksForRemoval(_ currentTime: CFTimeInterval){
        if currentTime - timeOfLastUpdateForRockRemoval > 1.0{
            var badRockCount:Int = 0
            var allRocks: [SKNode] = []
            self.enumerateChildNodes(withName: "rock"){
                node, stop in allRocks.append(node)}
            self.enumerateChildNodes(withName: "brownRock"){
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
    
    
    override func didMove(to view: SKView) {
        isUserInteractionEnabled = true
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
        ship.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
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
    func degree2radian(_ a:CGFloat)->CGFloat {
        let b = CGFloat(M_PI) * a/180
        return b
    }
    func polygonPointArray(_ sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,offset:CGFloat)->[CGPoint] {
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

    func polygonPath(_ x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, offset: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let points = polygonPointArray(sides,x: x,y: y,radius: radius, offset: offset)
        let cpg = points[0]
        path.move(to: CGPoint(x: cpg.x, y: cpg.y), transform: CGAffineTransform())
        for p in points {
            path.addLine(to: CGPoint(x: p.x, y: p.y))
        }
        path.closeSubpath()
        return path
    }
    
    func assymetricalPolygonPath(_ points:[CGPoint])->CGPath{
        let path = CGMutablePath()
        let cpg = points[0]
        path.move(to: CGPoint(x: cpg.x, y: cpg.y), transform: CGAffineTransform())
        for p in points {
            path.addLine(to: CGPoint(x: p.x, y: p.y))
        }
        path.closeSubpath()
        return path
    }
    
    func loadBoundary(){
        let boundary = SKSpriteNode(imageNamed: "space")
        boundary.position = CGPoint(x: frame.width/2, y: frame.height/2)
        boundary.name = "boundary"
        boundary.xScale = 1.04
        boundary.yScale = 1.04
        self.addChild(boundary)
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -frame.width/2, y: -frame.height/2, width: frame.width, height: frame.height))
        boundary.physicsBody!.affectedByGravity = false
        boundary.physicsBody!.isDynamic = false
        boundary.physicsBody!.categoryBitMask = edgeCategory
        boundary.physicsBody!.contactTestBitMask = bulletCategory
        boundary.physicsBody!.collisionBitMask = 0xFFFFFFFF
    }
    
    func playTheme(_ backgroundAudio: AVAudioPlayer, volume: Float){
        backgroundAudio.volume = volume
        backgroundAudio.currentTime = 0
        backgroundAudio.play()
        backgroundAudio.numberOfLoops = -1
    }
    func addFireButton(){
        let fireButton = UIButton(frame: CGRect(x: 0, y: scene!.size.height-90, width: 90, height: 90))
        fireButton.backgroundColor = UIColor.clear
        fireButton.setTitle("FIRE", for: UIControlState())
        fireButton.setTitleColor(UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0), for: UIControlState())
        fireButton.addTarget(self, action: #selector(GameScene.fireAction(_:)), for: UIControlEvents.touchDown)
        self.view!.addSubview(fireButton)
    }

    func addSlowButton(){
        slowButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        slowButton.backgroundColor = UIColor.clear
        slowButton.setTitle("FAST", for: UIControlState())
        slowButton.setTitleColor(UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0), for: UIControlState())
        slowButton.addTarget(self, action: #selector(GameScene.adjustTurnAction(_:)), for: UIControlEvents.touchDown)
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
    
    func fireAction(_ sender: UIButton!){
        fireBullets()
    }

    func adjustTurnAction(_ sender: UIButton!){
        if fast == true{
            slowButton.setTitle("SLOW", for: UIControlState())
            fast = false
        }else{
            slowButton.setTitle("FAST", for: UIControlState())
            fast = true
        }
    }
    func processUserMotionForUpdate(_ currentTime: CFTimeInterval){
        
        if (currentTime - timeOfLastUpdateForUserMotion > 0.1) {
            
            if let ship = self.childNode(withName: "ship") as! SKSpriteNode!{
                
                if let data = motionManager.accelerometerData {
                    ship.run(SKAction.rotate(byAngle: -CGFloat(data.acceleration.y * attenuationSteeringFactor), duration:0.1))
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
            if let ship = self.childNode(withName: "ship"){
                let bullet = SKSpriteNode(color: UIColor.green, size: CGSize(width: 3, height: 9))
                bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bullet.frame.width, height: bullet.frame.height))
                let unitVelocity = bulletTrajectory()
                let bulletVelocity = CGVector(dx: unitVelocity.dx * 350.0, dy: unitVelocity.dy * 350.0)
                let bulletDisplacementX = unitVelocity.dx * 10.0
                let bulletDisplacementY = unitVelocity.dy * 10.0
                let bulletPosition = CGPoint(x: ship.position.x + bulletDisplacementX,y: ship.position.y + bulletDisplacementY)
                bullet.position = bulletPosition
                bullet.run(SKAction.rotate(byAngle: CGFloat(shipAngle), duration: 0.01))
                bullet.name = "bullet"
                bullet.physicsBody?.affectedByGravity = false
                bullet.physicsBody?.isDynamic = true
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
                bullet.run(soundAction, withKey: "bulletSound")
                //bullet.runAction(SKAction.playSoundFileNamed("shipBullet.mp3", waitForCompletion: true))
                // update function toggles bulletDelay to false per bulletTimer in updateBulletDelay
            }
        }
    }
    
// MARK: CONTACT SECTION
    
    func didBegin(_ contact: SKPhysicsContact){ // adds contacts from contactDelegate into an array
        if contact as SKPhysicsContact? != nil {
            self.contactArray.append(contact)
        }
    }
    func handleContact(_ contact: SKPhysicsContact) { // helper function: main guts of update
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil){
            return
        }
// subclasses handle specific instances of contact
    }
    func processContactsForUpdate(_ currentTime: CFTimeInterval){
        for contact in self.contactArray {
            self.handleContact(contact)
            if let index = (self.contactArray as NSArray).index(of: contact) as Int? {
                self.contactArray.remove(at: index)
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swipeMode{
            for touch in touches {
                if let ship = childNode(withName: "ship"){
                    //let x = touch.locationInNode(self).x
                    //let y = touch.locationInNode(self).y
                    //let dx = x - ship.position.x
                    //let dy = y - ship.position.y
                    //let shipVelocity = CGVector(dx: 1.5*dx, dy: 1.5*dy)
                    //ship.runAction(SKAction.applyForce(shipVelocity, duration: 0.05))
                    let scalingFactor:CGFloat = 11.0
                    let dx = touch.location(in: self).x - ship.position.x
                    let dy = touch.location(in: self).y - ship.position.y
                    let shipVelocity = CGVector(dx: scalingFactor*dx, dy: scalingFactor*dy)
                    // while function acts like high pass filter
                    /*while abs(shipVelocity.dx) > CGFloat(650) || abs(shipVelocity.dy) > CGFloat(650){
                        shipVelocity = CGVector(dx: shipVelocity.dx * CGFloat(0.5), dy: shipVelocity.dy * CGFloat(0.5))
                    }*/
                    let waitAction = SKAction.wait(forDuration: 0.15)
                    let moveAction = SKAction.applyForce(shipVelocity, duration: 0.04)
                    let stopAction = (SKAction.run({
                        ship.physicsBody?.velocity = CGVector(dx: 0, dy: 0)}))
                    let actionSequence:[SKAction] = [moveAction, waitAction, stopAction]
                    ship.run(SKAction.sequence(actionSequence))
                }
            }
        }

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if swipeMode{
            for touch in touches {
                if let ship = childNode(withName: "ship"){
                    let scalingFactor:CGFloat = 11.0
                    let dx = touch.location(in: self).x - ship.position.x
                    let dy = touch.location(in: self).y - ship.position.y
                    var shipVelocity = CGVector(dx: scalingFactor*dx, dy: scalingFactor*dy)
                    // while function acts like high pass filter
                    while abs(shipVelocity.dx) > CGFloat(650) || abs(shipVelocity.dy) > CGFloat(650){
                        shipVelocity = CGVector(dx: shipVelocity.dx * CGFloat(0.5), dy: shipVelocity.dy * CGFloat(0.5))
                    }
                    let waitAction = SKAction.wait(forDuration: 0.15)
                    let moveAction = SKAction.applyForce(shipVelocity, duration: 0.04)
                    let stopAction = (SKAction.run({
                        ship.physicsBody?.velocity = CGVector(dx: 0, dy: 0)}))
                    let actionSequence:[SKAction] = [moveAction, waitAction, stopAction]
                    ship.run(SKAction.sequence(actionSequence))
                }
            }
        }
    }

// LEVEL AND GAME ENDING SECTION
    
    func gameEnded(_ currentTime: CFTimeInterval)->Bool{
// subclasses of GameScene call gameEnded because the ship always has to exist
        var allShips: [SKNode] = []
        // put nodes in array
        self.enumerateChildNodes(withName: "ship"){//<--FIND SHIPS HERE
            node, stop in allShips.append(node)}
        if(allShips.count == 0){
            return true
        }
        return false
    }


    func updateDisplayAccuracy(_ currentTime:CFTimeInterval){
        if currentTime - timeOfLastUpdateForAccuracy > 0.3{
            if let acc = childNode(withName: "accuracy") as? SKLabelNode{
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
    
    override func update(_ currentTime: TimeInterval) {
        processUserMotionForUpdate(currentTime)
        updateBulletDelay(currentTime)
        updateRateOfTurning(currentTime)
        updateDisplayAccuracy(currentTime)
    }
    func updateBulletDelay(_ currentTime: CFTimeInterval){
        if currentTime - bulletTimer > 0.4{
            bulletDelay = false
            bulletTimer = currentTime
        }
    }
    func updateRateOfTurning(_ currentTime: CFTimeInterval){
        if currentTime - timeOfLastUpdateForRateOfTurn > 0.5{
            if !fast{
                attenuationSteeringFactor = 0.4
                
            }else{
                attenuationSteeringFactor = 1.0
            }
            timeOfLastUpdateForRateOfTurn = currentTime
        }
    }
    func setupExplosion(_ node: SKSpriteNode, soundFX: Bool, file: String){
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
        shipExplodes = SKAction.animate(with: explosionFrames, timePerFrame: 0.03)
        let waitAction = SKAction.wait(forDuration: 1.2)
        let removeAction = SKAction.removeFromParent()
        let group:[SKAction] = [soundAction, shipExplodes]
        let sequence:[SKAction] = [waitAction,removeAction]
        if !soundFX{
            node.run(shipExplodes)
        }else{
            node.run(SKAction.group(group))
        }
        node.run(SKAction.sequence(sequence))
    }
    func removeBulletSounds(){
        var bullets:[SKNode]=[]
        enumerateChildNodes(withName: "bullet", using: {node, stop in bullets.append(node)})
        for bullet in bullets{
            bullet.removeAction(forKey: "soundAction")
        }
    }
}
