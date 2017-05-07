//
//  HelpScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/16/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.
//

import SpriteKit

class HelpScene: GameScene {
    
    func addExitButton(){
        let exitButton = UIButton(frame: CGRect(x: self.size.width - 90, y: 0, width: 90, height: 90))
        exitButton.backgroundColor = UIColor.clearColor()
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: #selector(exitAction), forControlEvents: UIControlEvents.TouchDown)
        exitButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
        self.view!.addSubview(exitButton)
    }
    func exitAction(sender: UIButton!){
        self.thisDelegate?.gameSceneDidFinish(self, command: "close")
    }
    override func addFireButton() {
        return
    }
    override func addSlowButton() {
        return
    }
    override func displayAccuracy() {
        return
    }
    override func addShip() {
        return
    }
    override func createContent() {
        addExitButton()
        super.createContent()
        displayObjective()
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
        let myLabel5 = SKLabelNode(fontNamed: "Chalkduster")
        myLabel5.name = "objective"
        myLabel5.horizontalAlignmentMode = .Left
        myLabel.text = "I. You can practice levels that you"
        myLabel2.text = "unlocked by hitting the 'level' buttons"
        myLabel3.text = "II. 'Play' delivers the main content"
        myLabel4.text = "III. 'Settings' are for sound and high scores"
        myLabel5.text = "IV. Start by learning controls under 'Practice'"
        myLabel.position = CGPoint(x: self.frame.width/11.5, y:self.frame.height*0.73)
        myLabel2.position = CGPoint(x: self.frame.width/11.5, y:self.frame.height*0.65)
        myLabel3.position = CGPoint(x: self.frame.width/11.5, y:self.frame.height*0.49)
        myLabel4.position = CGPoint(x: self.frame.width/11.5, y:self.frame.height*0.33)
        myLabel5.position = CGPoint(x: self.frame.width/11.5, y:self.frame.height*0.17)
        myLabel.fontSize = 23
        myLabel.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel2.fontSize = 23
        myLabel2.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel3.fontSize = 25
        myLabel3.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel4.fontSize = 23
        myLabel4.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel5.fontSize = 23
        myLabel5.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        self.addChild(myLabel)
        self.addChild(myLabel2)
        self.addChild(myLabel3)
        self.addChild(myLabel4)
        self.addChild(myLabel5)
    }

}
