//
//  LevelNineIntro.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/29/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.
//

import SpriteKit

class LevelNineIntro: GameScene {
    var timerLevelThree:Double = 0.0
    
    override func displayAccuracy() {
        return
    }
    
    func exitAction(sender: UIButton!){
        self.level = 9
        self.highScore?.level = 9
        self.thisDelegate?.updateTransitionLevvel(self)
        self.thisDelegate?.changeScene(self, command: "close")
    }
    
    func addExitButton(){
        let fireButton = UIButton(frame: CGRect(x: self.size.width - 90, y: 0, width: 90, height: 90))
        fireButton.backgroundColor = UIColor.clearColor()
        fireButton.setTitle("EXIT", forState: UIControlState.Normal)
        fireButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
        fireButton.addTarget(self, action: #selector(LevelNineIntro.exitAction(_:)), forControlEvents: UIControlEvents.TouchDown)
        self.view!.addSubview(fireButton)
    }
    override func addFireButton() {
        return
    }
    override func addSlowButton() {
        return
    }
   // override func addStopButton() {
    //    return
   // }
    func addEarth(){
        let earth = SKSpriteNode(imageNamed: "Earth")
        earth.xScale = 0.15
        earth.yScale = 0.15
        earth.position = CGPoint(x: self.frame.width*0.02, y: self.frame.height)
        earth.name = "earth"
        self.addChild(earth)
    }
    
    func loadAsteroid(){
        let rock = SKSpriteNode(imageNamed: "brownRock")
        rock.xScale = 1.5
        rock.yScale = 1.5
        rock.position = CGPoint(x: self.frame.width*0.25, y: self.frame.height/2.0)
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
        rock.physicsBody!.velocity = CGVectorMake(50,-30)
    }
    
    override func createContent() {
        self.userInteractionEnabled = false
        super.createContent()
        timeOfLastUpdateForInvaderAttack = 0.0
        addExitButton()
        if let ship = childNodeWithName("ship"){
            ship.position = CGPoint(x: self.frame.width*0.02, y: 0)
            ship.runAction(SKAction.rotateByAngle(CGFloat(-M_PI/2.0), duration: 0.017))
        }
        addEarth()
        loadAsteroid()
    }
    override func update(currentTime: CFTimeInterval) {
        invaderAttack(currentTime)
        initializeTimer(currentTime)
        processContactsForUpdate(currentTime)
        super.updateBulletDelay(currentTime)
        if gameEnded(currentTime){
            scene?.paused = true
        }
    }
    func invaderAttack(currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForInvaderAttack > 2.0) {
            addMonster()
            if (currentTime - timeOfLastUpdateForInvaderAttack > 6.0){
                addDestroyer()
            }
            timeOfLastUpdateForInvaderAttack = currentTime
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
    func moveShip(){
        if let ship = childNodeWithName("ship") as? SKSpriteNode{
            let moveAction = SKAction.moveToY(self.size.height*0.8, duration: 0.4)
            let waitAction = SKAction.waitForDuration(0.2)
            let returnAction = SKAction.moveToY(self.size.height/2.0, duration: 0.4)
            let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI*0.66), duration: 0.4)
            let fireAction = SKAction.runBlock({self.shipAngle += M_PI*0.66;self.fireBullets()})
            let sequence:[SKAction]=[waitAction, moveAction,rotateAction,fireAction,returnAction, moveAction]
            ship.runAction(SKAction.sequence(sequence))
        }
    }
    func addMonster() {
        let monster = SKSpriteNode(imageNamed: "fighter2")
        monster.name = "invader"
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.frame.width/3.0)
        monster.physicsBody?.allowsRotation = false
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.categoryBitMask = invaderCategory
        monster.physicsBody?.contactTestBitMask = bulletCategory | shipCategory
        monster.physicsBody?.collisionBitMask = 0x00000000
        monster.physicsBody?.linearDamping = 0
        monster.physicsBody?.usesPreciseCollisionDetection = true
        let minInt = Int(self.size.height*0.2)
        let maxInt = Int(self.size.height*0.69)
        let actualY = CGFloat(arc4random_uniform(UInt32(maxInt-minInt))) + self.size.height * 0.2
        monster.position = CGPoint(x: self.size.width + monster.size.width/2, y: CGFloat(actualY))
        monster.name = "invader"
        self.addChild(monster)
        let randomSpeed = drand48()*3+3
        let actionMove = SKAction.applyImpulse(CGVector(dx: -randomSpeed, dy:0) ,duration: 0.1)
        let waitAction = SKAction.waitForDuration(10.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = [actionMove,waitAction,removeAction]
        monster.runAction(SKAction.sequence(sequence))
    }
    func addDestroyer() {
        let monster = SKSpriteNode(imageNamed: "destroyer")
        monster.name = "invader"
        monster.xScale = 0.3
        monster.yScale = 0.3
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.frame.width/3.0)
        monster.physicsBody?.allowsRotation = false
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.categoryBitMask = invaderCategory
        monster.physicsBody?.contactTestBitMask = bulletCategory | shipCategory
        monster.physicsBody?.collisionBitMask = 0x00000000
        monster.physicsBody?.linearDamping = 0
        monster.physicsBody?.usesPreciseCollisionDetection = true
        monster.position = CGPoint(x: self.size.width*0.78, y: CGFloat(self.size.height))
        self.addChild(monster)
        let actionMove = SKAction.applyImpulse(CGVector(dx: 0, dy:-9) ,duration: 3.0)
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
        if ((nodeNames as NSArray).containsObject("rock") && (nodeNames as NSArray).containsObject("bullet")){
            points += 10
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            if super.explosionOff{
                return
            }
            self.runAction(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
        }
        if ((nodeNames as NSArray).containsObject("boundary") && (nodeNames as NSArray).containsObject("bullet")){
            if(contact.bodyA.node!.name == "bullet"){
                contact.bodyA.node!.removeFromParent()
            }else{
                contact.bodyB.node!.removeFromParent()
            }
        }
        if ((nodeNames as NSArray).containsObject("invader") && (nodeNames as NSArray).containsObject("bullet")){
            // explosion sounds, bullet and invader removed
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            points += 10
            if super.explosionOff{
                return
            }
            self.runAction(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
        }
    }
    func displayObjective(){
        let myLevel = SKLabelNode(fontNamed: "Chalkduster")
        myLevel.text = "Level 1"
        myLevel.position = CGPoint(x: self.frame.width/7, y:self.frame.height*0.6)
        myLevel.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.name = "objective"
        myLabel.horizontalAlignmentMode = .Left
        let myLabel2 = SKLabelNode(fontNamed: "Chalkduster")
        myLabel2.name = "objective"
        myLabel2.horizontalAlignmentMode = .Left
        let myLabel3 = SKLabelNode(fontNamed: "Chalkduster")
        myLabel3.name = "objective"
        myLabel3.horizontalAlignmentMode = .Left
        let myLabel4 = SKLabelNode(fontNamed: "Chalkduster")
        myLabel4.name = "objective"
        myLabel4.horizontalAlignmentMode = .Left
        myLabel.text = "The destroyer can't be shielded while"
        myLabel2.text = "launching fighter jets. Clear this last"
        myLabel3.text = "asteroid and take him out."
        myLabel4.text = "One last bad guy to kill, on it."
        myLabel.position = CGPoint(x: self.frame.width/9.5, y:self.frame.height*0.9)
        myLabel2.position = CGPoint(x: self.frame.width/9.5, y:self.frame.height*0.82)
        myLabel3.position = CGPoint(x: self.frame.width/9.5, y:self.frame.height*0.74)
        myLabel4.position = CGPoint(x: self.frame.width/9.0, y:self.frame.height*0.06)
        myLabel.fontSize = 23
        myLabel.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel2.fontSize = 23
        myLabel2.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel3.fontSize = 25
        myLabel3.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel4.fontSize = 23
        myLabel4.fontColor = UIColor.whiteColor()  //.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        self.addChild(myLabel)
        self.addChild(myLabel2)
        self.addChild(myLabel3)
        self.addChild(myLabel4)
    }
    
    override func gameEnded(currentTime: CFTimeInterval)->Bool{
        timerLevelThree = currentTime - timeOfLastUpdateForLevel
        if timerLevelThree > 7.0{
            super.level = 9
            highScore?.level = 9
            cleanupStrongReferences()
            displayObjective()
            self.thisDelegate?.updateTransitionLevvel(self)
            return true
        }
        return false
    }
}