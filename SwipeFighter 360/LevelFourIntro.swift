//
//  LevelFourIntro.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/29/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.
//

import SpriteKit

class LevelFourIntro: GameScene {
    
    var timerLevelThree:Double = 0.0
    var direction:Int = 0
    var scoutPosition:CGFloat = 0.9
    
    override func displayAccuracy() {
        return
    }
    
    func exitAction(_ sender: UIButton!){
        self.level = 4
        self.highScore?.level = 4
        self.thisDelegate?.updateTransitionLevvel(self)
        self.thisDelegate?.changeScene(self, command: "close")
    }
    
    func addExitButton(){
        let fireButton = UIButton(frame: CGRect(x: self.size.width - 90, y: 0, width: 90, height: 90))
        fireButton.backgroundColor = UIColor.clear
        fireButton.setTitle("EXIT", for: UIControlState())
        fireButton.setTitleColor(UIColor.green, for: UIControlState())
        fireButton.addTarget(self, action: #selector(LevelFourIntro.exitAction(_:)), for: UIControlEvents.touchDown)
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
    //}
    func addEarth(){
        let earth = SKSpriteNode(imageNamed: "Earth")
        earth.xScale = 0.15
        earth.yScale = 0.15
        earth.position = CGPoint(x: self.frame.width*0.02, y: self.frame.height)
        earth.name = "earth"
        self.addChild(earth)
    }
    
    func loadAsteroid(_ direction: Int){
        let rock = SKSpriteNode(imageNamed: "brownRock")
        rock.xScale = 1.5
        rock.yScale = 1.5
        rock.name = "rock"
        rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.size.width/2)
        rock.physicsBody!.affectedByGravity = false
        rock.physicsBody!.linearDamping = 0
        rock.physicsBody!.restitution = 1
        rock.physicsBody!.friction = 0
        rock.physicsBody!.categoryBitMask = rockCategory
        rock.physicsBody!.contactTestBitMask = bulletCategory
        rock.physicsBody!.collisionBitMask = edgeCategory | rockCategory
        if direction == 0 {
            rock.position = CGPoint(x: self.frame.width, y: self.frame.height/2.0)
            rock.physicsBody!.velocity = CGVector(dx: -110,dy: 0)
        }
        if direction == 2 {
            rock.position = CGPoint(x: 0, y: self.frame.height/2.0)
            rock.physicsBody!.velocity = CGVector(dx: 110,dy: 0)
        }
        if direction == 1 {
            rock.position = CGPoint(x: self.frame.width/2.0, y: self.frame.height)
            rock.physicsBody!.velocity = CGVector(dx: 0,dy: -110)
        }
        if direction == 3 {
            rock.position = CGPoint(x: self.frame.width/2.0, y: 0)
            rock.physicsBody!.velocity = CGVector(dx: 0,dy: 110)
        }
        self.addChild(rock)
    }
    
    override func createContent() {
        self.isUserInteractionEnabled = false
        super.createContent()
        timeOfLastUpdateForInvaderAttack = 0.0
        addExitButton()
        if let ship = childNode(withName: "ship"){
            //ship.position = CGPoint(x: self.frame.width*0.02, y: 0)
            ship.run(SKAction.rotate(byAngle: CGFloat(-M_PI/2.0), duration: 0.017))
            ship.run(SKAction.move(to: CGPoint(x: self.frame.width*0.85, y: self.frame.height * 0.15), duration: 1.8))
            ship.run(SKAction.rotate(byAngle: CGFloat(M_PI*0.8), duration: 0.8))
        }
        addEarth()
    }
    override func update(_ currentTime: TimeInterval) {
        invaderAttack(currentTime)
        initializeTimer(currentTime)
        processContactsForUpdate(currentTime)
        super.updateBulletDelay(currentTime)
        if gameEnded(currentTime){
            scene?.isPaused = true
        }
    }
    func invaderAttack(_ currentTime: CFTimeInterval){
        if (currentTime - timeOfLastUpdateForInvaderAttack > 3.0) {
            loadAsteroid(direction)
            addMonster(scoutPosition)
            scoutPosition -= 0.25
            direction += 1
            timeOfLastUpdateForInvaderAttack = currentTime
        }
    }
    func initializeTimer(_ currentTime: CFTimeInterval){
        if timeOfLastUpdateForLevel < 0.1{
            timeOfLastUpdateForLevel = currentTime
            timeOfLastUpdateForInvaderAttack = currentTime
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
    func moveShip(){
        if let ship = childNode(withName: "ship") as? SKSpriteNode{
            let moveAction = SKAction.moveTo(y: self.size.height*0.8, duration: 0.4)
            let waitAction = SKAction.wait(forDuration: 0.2)
            let returnAction = SKAction.moveTo(y: self.size.height/2.0, duration: 0.4)
            let rotateAction = SKAction.rotate(byAngle: CGFloat(M_PI*0.66), duration: 0.4)
            let fireAction = SKAction.run({self.shipAngle += M_PI*0.66;self.fireBullets()})
            let sequence:[SKAction]=[waitAction, moveAction,rotateAction,fireAction,returnAction, moveAction]
            ship.run(SKAction.sequence(sequence))
        }
    }
    func addMonster(_ location: CGFloat) {
        let monster = SKSpriteNode(imageNamed: "fighter")
        monster.name = "invader"
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.frame.width/3.0)
        monster.physicsBody?.allowsRotation = false
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.categoryBitMask = invaderCategory
        monster.physicsBody?.contactTestBitMask = bulletCategory | shipCategory
        monster.physicsBody?.collisionBitMask = 0x00000000
        monster.physicsBody?.linearDamping = 0
        monster.physicsBody?.usesPreciseCollisionDetection = true
        monster.position = CGPoint(x: self.size.width + monster.size.width/2, y: CGFloat(self.size.height * location))
        self.addChild(monster)
        let actionMove = SKAction.applyImpulse(CGVector(dx: -5, dy:0) ,duration: 0.1)
        let pauseAction = SKAction.wait(forDuration: 3.0)
        let waitAction = SKAction.wait(forDuration: 7.0)
        let removeAction = SKAction.removeFromParent()
        let rotateAction = SKAction.rotate(byAngle: -0.707, duration: 0.3)
        let moveAction = SKAction.applyImpulse(CGVector(dx: 5, dy: -5), duration: 0.1)
        let sequence = [actionMove, pauseAction, rotateAction, moveAction, waitAction,removeAction]
        monster.run(SKAction.sequence(sequence))
    }
    override func handleContact(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil){
            return
        }
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        if ((nodeNames as NSArray).contains("rock") && (nodeNames as NSArray).contains("bullet")){
            points += 10
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            if super.explosionOff{
                return
            }
            self.run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
        }
        if ((nodeNames as NSArray).contains("boundary") && (nodeNames as NSArray).contains("bullet")){
            if(contact.bodyA.node!.name == "bullet"){
                contact.bodyA.node!.removeFromParent()
            }else{
                contact.bodyB.node!.removeFromParent()
            }
        }
        if ((nodeNames as NSArray).contains("invader") && (nodeNames as NSArray).contains("bullet")){
            // explosion sounds, bullet and invader removed
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            points += 10
            if super.explosionOff{
                return
            }
            self.run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
        }
    }
    func displayObjective(){
        let myLevel = SKLabelNode(fontNamed: "Chalkduster")
        myLevel.text = "Level 1"
        myLevel.position = CGPoint(x: self.frame.width/7, y:self.frame.height*0.6)
        myLevel.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.name = "objective"
        myLabel.horizontalAlignmentMode = .left
        let myLabel2 = SKLabelNode(fontNamed: "Chalkduster")
        myLabel2.name = "objective"
        myLabel2.horizontalAlignmentMode = .left
        let myLabel3 = SKLabelNode(fontNamed: "Chalkduster")
        myLabel3.name = "objective"
        myLabel3.horizontalAlignmentMode = .left
        let myLabel4 = SKLabelNode(fontNamed: "Chalkduster")
        myLabel4.name = "objective"
        myLabel4.horizontalAlignmentMode = .left
        myLabel.text = "Come back to earth until we"
        myLabel2.text = "figure out what's going on."
        myLabel3.text = "Looks like we've got scout"
        myLabel4.text = "droids in the area."
        myLabel.position = CGPoint(x: self.frame.width/9.5, y:self.frame.height*0.9)
        myLabel2.position = CGPoint(x: self.frame.width/9.5, y:self.frame.height*0.82)
        myLabel3.position = CGPoint(x: self.frame.width/3.0, y:self.frame.height*0.26)
        myLabel4.position = CGPoint(x: self.frame.width/2.4, y:self.frame.height*0.18)
        myLabel.fontSize = 23
        myLabel.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel2.fontSize = 23
        myLabel2.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel3.fontSize = 25
        myLabel3.fontColor = UIColor.white//.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel4.fontSize = 23
        myLabel4.fontColor = UIColor.white  //.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        self.addChild(myLabel)
        self.addChild(myLabel2)
        self.addChild(myLabel3)
        self.addChild(myLabel4)
    }
    
    func removeRocks(){
        var allRocks:[SKNode] = []
        enumerateChildNodes(withName: "rock", using: {node, stop in allRocks.append(node)})
        for rock in allRocks{
            rock.removeFromParent()
        }
    }
    
    override func gameEnded(_ currentTime: CFTimeInterval)->Bool{
        timerLevelThree = currentTime - timeOfLastUpdateForLevel
        if timerLevelThree > 6.0{
            if timerLevelThree > 7.0{
                super.level = 4
                highScore?.level = 4
                cleanupStrongReferences()
                removeRocks()
                displayObjective()
                self.thisDelegate?.updateTransitionLevvel(self)
                return true
            }
            shipAngle = 0.707
            fireBullets()
        }
        return false
    }
}

