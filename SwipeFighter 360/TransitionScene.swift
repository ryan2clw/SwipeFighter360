//
//  ReplayScene.swift
//  RockBlaster
//
//  Created by Ryan Dines on 11/10/15.
//  Copyright © 2015 DimeZee Software. All rights reserved.
//

import SpriteKit

class TransitionScene:SKScene, GameSceneDelegate{

    var totalPoints:Int = 0
    var gameView: SKView?
    var currentGameScene:GameScene?
    var updatedOnce:Bool = false
    var timeOfLastUpdate:Double = 0
    var accuracy:Double = 0
    var highScore:HighScore?
    var bestScore:HighScore?
    var explosionOff:Bool = false
    var lazerOff:Bool = false
    var musicOff:Bool = false
    var arcadeMode:Bool = false
    var swipeMode:Bool = true
    var buttons:[UIButton] = []
    
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
    
    func loadBoundary(){
        let boundary = SKSpriteNode(imageNamed: "background2")
        boundary.position = CGPoint(x: frame.width/2, y: frame.height/2)
        boundary.name = "boundary"
        boundary.xScale = 1.04
        boundary.yScale = 1.04
        self.addChild(boundary)
    }
    override func didMoveToView(view: SKView) {
        self.removeAllChildren()
        loadBoundary()
        createLotsaButtons(view)
        createHelpButton(view, x: self.frame.width*0.1, y: self.frame.height/10.0, title: "Help")
        createHelpButton(view, x: self.frame.width*0.4, y: self.frame.height/10.0, title: "Play")
        createHelpButton(view, x: self.frame.width*0.7, y: self.frame.height/10.0, title: "Settings")
        createTitle()
        createShip()
        createAsteroid()
    }

    func createPlayButton(view: SKView, x: CGFloat, y: CGFloat, title: String, level: Int, hidden: Bool){
        let playAgainButton = UIButton(frame: CGRectMake(x, y, self.frame.width/7.0, self.frame.height/5.0))
        playAgainButton.backgroundColor = UIColor.blackColor()
        playAgainButton.alpha = 0.6
        playAgainButton.layer.cornerRadius = 11.0
        playAgainButton.layer.borderWidth = 1.0
        playAgainButton.layer.borderColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0).CGColor
        if let titleFont = UIFont(name: "Chalkduster", size: 20.0)  {
            let color = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
            let attributes = [NSFontAttributeName : titleFont, NSForegroundColorAttributeName : color]
            playAgainButton.setAttributedTitle(NSAttributedString(string: title, attributes: attributes),forState: UIControlState.Normal)
            if level == 10{
                playAgainButton.setAttributedTitle(NSAttributedString(string: "Practice", attributes: attributes), forState: UIControlState.Normal)
            }
        }
        playAgainButton.setTitle("\(level)", forState: UIControlState.Normal)
        playAgainButton.addTarget(self, action: #selector(TransitionScene.buttonAction(_:)), forControlEvents: UIControlEvents.TouchDown)
        playAgainButton.hidden = hidden
        playAgainButton.titleLabel?.adjustsFontSizeToFitWidth = true
        buttons.append(playAgainButton)
        self.view!.addSubview(playAgainButton)
    }
    func createHelpButton(view: SKView, x: CGFloat, y: CGFloat, title: String){
        let helpButton = UIButton(frame: CGRectMake(x, y, self.frame.width/4.0, self.frame.height/5.0))
        helpButton.backgroundColor = UIColor.blackColor()
        helpButton.alpha = 0.6
        helpButton.layer.cornerRadius = 11.0
        helpButton.layer.borderWidth = 1.0
        helpButton.layer.borderColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0).CGColor
        if let titleFont = UIFont(name: "Chalkduster", size: 30.0)  {
            let color = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
            let attributes = [NSFontAttributeName : titleFont,
                NSForegroundColorAttributeName : color]
            helpButton.setAttributedTitle(NSAttributedString(string: title, attributes: attributes),forState: UIControlState.Normal)
        }
        if title == "Help"{
            helpButton.addTarget(self, action: #selector(TransitionScene.helpAction(_:)), forControlEvents: UIControlEvents.TouchDown)
        }
        if title == "Play"{
            helpButton.addTarget(self, action: #selector(TransitionScene.playAction(_:)), forControlEvents: UIControlEvents.TouchDown)
        }
        if title == "Settings"{
            helpButton.addTarget(self, action: #selector(TransitionScene.settingsAction(_:)), forControlEvents: UIControlEvents.TouchDown)
        }
        self.view!.addSubview(helpButton)
    }
    func createLotsaButtons(view: SKView){
        var x:CGFloat = self.frame.width/12.0
        var y:CGFloat = self.frame.height*0.55
        if let highestLevel = bestScore?.level{
            for i in 1 ..< 6 {
                if i <= highestLevel{
                    createPlayButton(view, x: x, y: y, title: "Level \(i)", level: i, hidden: false)
                }else{
                    createPlayButton(view, x: x, y: y, title: "Level \(i)", level: i, hidden: true)
                }
                x += self.frame.width/6.0
            }
            y += self.frame.height/4.3
            x = self.frame.width/12.0
            for i in 6 ..< 11 {
                if i <= highestLevel || i == 10{
                    createPlayButton(view, x: x, y: y, title: "Level \(i)", level: i, hidden: false)
                }else{
                    createPlayButton(view, x: x, y: y, title: "Level \(i)", level: i, hidden: true)
                }
                x += self.frame.width/6.0
            }
        }
    }
    func buttonAction(sender: UIButton!){
// get level by interpreting the title of the button
        let level = Int(sender!.currentTitle!)!
            self.gameView = SKView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
// initGameScene sets currentScene according to level, buttons do not include storyline, hence arcadeMode is false
            self.arcadeMode = false
            initGameScene(level)
            //updatedOnce = false
            currentGameScene?.arcadeMode = false
            currentGameScene?.swipeMode = self.swipeMode
            self.gameView!.presentScene(currentGameScene)
            currentGameScene?.explosionOff = self.explosionOff
            currentGameScene?.lazerOff = self.lazerOff
            currentGameScene?.musicOff = self.musicOff
            currentGameScene?.thisDelegate = self
            self.view?.addSubview(gameView!)
        //}
    }
    func helpAction(sender: UIButton!){
        self.arcadeMode = false
        self.gameView = SKView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        // set to practice scene or an even more involved tutorial
        //level = 10
        initGameScene(13)
        self.gameView!.presentScene(currentGameScene)
        currentGameScene?.explosionOff = self.explosionOff
        currentGameScene?.lazerOff = self.lazerOff
        currentGameScene?.musicOff = self.musicOff
        currentGameScene?.thisDelegate = self
        self.view?.addSubview(gameView!)
        //}
    }
    func playAction(sender: UIButton!){
        arcadeMode = true
        self.gameView = SKView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        // initGameScene sets currentScene according to levvel
        if let playa = highScore{
            initGameScene(playa.level)
        }else{
            initGameScene(0)
            print("highScore instance of HighScore failed to load")
        }
        //updatedOnce = false
        self.gameView!.presentScene(currentGameScene)
        currentGameScene?.highScore = self.highScore
        currentGameScene?.explosionOff = self.explosionOff
        currentGameScene?.lazerOff = self.lazerOff
        currentGameScene?.musicOff = self.musicOff
        currentGameScene?.thisDelegate = self
        self.view?.addSubview(gameView!)
        //scene?.paused = true
    }
    func settingsAction(sender: UIButton!){
        self.arcadeMode = false
        self.gameView = SKView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        initGameScene(12)
        self.gameView!.presentScene(currentGameScene)
        currentGameScene?.thisDelegate = self
        self.view?.addSubview(gameView!)
    }

    func initGameScene(level: Int){
        switch level{
        case 0:
            currentGameScene = LevelOneIntro(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 201:
            currentGameScene = LevelTwoIntro(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 301:
            currentGameScene = LevelThreeIntro(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 401:
            currentGameScene = LevelFourIntro(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 501:
            currentGameScene = LevelFiveIntro(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 601:
            currentGameScene = LevelSixIntro(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 701:
            currentGameScene = LevelSevenIntro(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 801:
            currentGameScene = LevelEightIntro(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 901:
            currentGameScene = LevelNineIntro(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 1:
            currentGameScene = TwoBrownRockScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 2:
            currentGameScene = AsteroidFieldScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 3:
            currentGameScene = FourRockScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 4:
            currentGameScene = ScoutScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 5:
            currentGameScene = DestroyerScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 6:
            currentGameScene = DefendEarthScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 7:
            currentGameScene = AlienInvasionScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 8:
            currentGameScene = FighterScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 9:
            currentGameScene = BossScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 10:
            currentGameScene = PracticeScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 11:
            currentGameScene = EndScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 12:
            currentGameScene = SettingsScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        case 13:
            currentGameScene = HelpScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        default:
            currentGameScene = TwoBrownRockScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height))
        }
        currentGameScene!.name = "currentScene"
        currentGameScene!.musicOff = self.musicOff
        currentGameScene!.lazerOff = self.lazerOff
        currentGameScene!.explosionOff = self.explosionOff
        currentGameScene!.highScore = self.highScore
        currentGameScene!.arcadeMode = self.arcadeMode
        currentGameScene!.bestScore = self.bestScore
        currentGameScene!.swipeMode = self.swipeMode
    }
    func createTitle(){
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "SwipeFighter 360"
        myLabel.fontSize = 49
        myLabel.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y: self.frame.height*0.55)
        self.addChild(myLabel)
    }

    func createShip(){
        let sprite = SKSpriteNode(imageNamed:"newShip")
        let location = CGPoint(x:self.frame.width*1.1, y: self.frame.height*0.58)
        let rotateAction = SKAction.rotateByAngle(CGFloat(2.0*M_PI), duration:6.5)
        let moveAction = SKAction.moveByX(-self.frame.width/4.0, y: 0, duration: 2.0)
        let waitAction = SKAction.waitForDuration(2.5)
        let returnAction = SKAction.moveByX(self.frame.width/4.0, y: 0, duration: 2.0)
        let actionSequence = SKAction.sequence([moveAction, waitAction, returnAction])
        let groupSequence = [rotateAction, actionSequence]
        sprite.position = location
        self.addChild(sprite)
        sprite.runAction(SKAction.repeatActionForever(SKAction.group(groupSequence)))
    }
    func createAsteroid(){
        let sprite = SKSpriteNode(imageNamed:"brownRock")
        let location = CGPoint(x:-self.frame.width*0.1, y: self.frame.height*0.58)
        let rotateAction = SKAction.rotateByAngle(CGFloat(2.0*M_PI), duration:6.5)
        let moveAction = SKAction.moveByX(self.frame.width/4.0, y: 0, duration: 2.0)
        let waitAction = SKAction.waitForDuration(2.5)
        let returnAction = SKAction.moveByX(-self.frame.width/4.0, y: 0, duration: 2.0)
        let actionSequence = SKAction.sequence([moveAction, waitAction, returnAction])
        let groupSequence = [rotateAction, actionSequence]
        sprite.position = location
        self.addChild(sprite)
        sprite.runAction(SKAction.repeatActionForever(SKAction.group(groupSequence)))
    }

    func gameSceneDidFinish(myScene: GameScene,command: String) {
        myScene.removeBulletSounds()
        myScene.cleanupStrongReferences()
       // self.cleanupStrongReferences()
        myScene.removeAllChildren()
        myScene.view!.removeFromSuperview()
        myScene.contactArray = []
        myScene.explosion = nil
        myScene.shipExplodes = nil
        if myScene.slowButton != nil{
            myScene.slowButton.removeFromSuperview()
        }
        if (command == "close"){
            if myScene.backgroundAudio != nil{
                myScene.backgroundAudio.stop()
                myScene.backgroundAudio = nil
            }
            //myScene.backgroundAudio = nil
            myScene.removeFromParent()
            currentGameScene = nil
            self.gameView = nil
        }
    }
    func saveHighScore(mainFile:AppDelegate, command: String){
        if (command == "save"){
            mainFile.savePlayaData()
        }
    }
    
    func changeScene(myScene: GameScene,command: String){
        myScene.removeBulletSounds()
        myScene.cleanupStrongReferences()
        //self.cleanupStrongReferences()
        myScene.removeAllChildren()
        myScene.view!.removeFromSuperview()
        myScene.contactArray = []
        myScene.explosion = nil
        myScene.shipExplodes = nil
        if myScene.slowButton != nil{
            myScene.slowButton.removeFromSuperview()
        }
        if (command == "close"){
            myScene.removeFromParent()
            if myScene.backgroundAudio != nil{
                myScene.backgroundAudio.stop()
                myScene.backgroundAudio = nil
            }
            //myScene.backgroundAudio = nil
            self.gameView = nil
            currentGameScene = nil
            self.gameView = SKView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            // initGameScene sets currentScene according to highScore.level
            if let playa = highScore{
                initGameScene(playa.level)
            }else{
                initGameScene(0)
            }
            //updatedOnce = false
            self.gameView!.presentScene(currentGameScene)
            currentGameScene?.explosionOff = self.explosionOff
            currentGameScene?.lazerOff = self.lazerOff
            currentGameScene?.musicOff = self.musicOff
            currentGameScene?.thisDelegate = self
            self.view?.addSubview(gameView!)
        }
    }
    
    func updateTransitionLevvel(myScene:GameScene){
        // THIS FUNCTION TRANSFERS HIGH SCORE AND BESTSCORE FROM GAMESCENE
        self.swipeMode = myScene.swipeMode
        self.musicOff = myScene.musicOff
        self.lazerOff = myScene.lazerOff
        self.explosionOff = myScene.explosionOff
        self.bestScore = myScene.bestScore
        self.highScore = myScene.highScore
    }
    override func update(currentTime: NSTimeInterval) {
        if currentTime - timeOfLastUpdate > 0.5{
            for button in buttons{
                if let _ = button.titleLabel?.text{
                    let character:Character = button.titleLabel!.text!.characters.last!
                    let intString = "\(character)"
                    if let int = Int(intString){
                        if let best = self.bestScore?.level{
                            if int <= best{
                                button.hidden = false
                            }else{
                                button.hidden = true
                            }
                        }
                    }
                }
            }
        timeOfLastUpdate = currentTime
        }
    }
}