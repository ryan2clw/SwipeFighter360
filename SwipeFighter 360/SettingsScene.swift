//
//  SettingsScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/16/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.
//

import SpriteKit
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SettingsScene: GameScene {
    
    var timeOfLastUpdateForGameReset:CFTimeInterval = 0
    var resetSwitch:UISwitch!
    
    func addExitButton(){
        let exitButton = UIButton(frame: CGRect(x: self.size.width - 90, y: 0, width: 90, height: 90))
        exitButton.backgroundColor = UIColor.clear
        exitButton.setTitle("EXIT", for: UIControlState())
        exitButton.setTitleColor(UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0), for: UIControlState())
        exitButton.addTarget(self, action: #selector(SettingsScene.exitAction(_:)), for: UIControlEvents.touchDown)
        self.view!.addSubview(exitButton)
    }
    func addSwitch(_ selector: Selector, x: Double, y: Double, on: Bool){
        let selectorSwitch = UISwitch(frame: CGRect(x: x, y: y, width: 120, height: 120))
        if on{
            selectorSwitch.isOn = true
        }else{
            selectorSwitch.isOn = false
        }
        selectorSwitch.backgroundColor = UIColor.clear
        selectorSwitch.addTarget(self, action: selector, for: UIControlEvents.valueChanged)
        if selector == #selector(SettingsScene.resetAction(_:)){
            resetSwitch = selectorSwitch
            self.view!.addSubview(selectorSwitch)
            //RESET SWITCH HAS TO BE LAST
            return
        }
        self.view!.addSubview(selectorSwitch)
    }
    
    func addSwitches(){
    //RESET SWITCH HAS TO BE LAST
        var y = Double(self.frame.height)/12.0
        let selectors:[Selector]=[#selector(SettingsScene.musicOffAction(_:)), #selector(SettingsScene.lazerOffAction(_:)), #selector(SettingsScene.explosionOffAction(_:)), #selector(SettingsScene.resetAction(_:))]
        var switchStates:[Bool]=[!self.musicOff, !self.lazerOff, !self.explosionOff, false]
        for i in 0 ... 3{
            addSwitch(selectors[i], x: Double(self.frame.width)/15.0, y: y, on: switchStates[i])
            y += Double(self.frame.height/7)
        }
    }
    
    func addNewLabel(_ title: String, x: Double, y: Double, font: CGFloat, color: UIColor, alignment:SKLabelHorizontalAlignmentMode ){
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.horizontalAlignmentMode = alignment  //.Left
        myLabel.text = title
        myLabel.fontSize = font
        myLabel.fontColor = color
        myLabel.position = CGPoint(x:x, y: y)
        myLabel.name = title
        self.addChild(myLabel)
    }
    func addLabels() {
        var y = Double(self.frame.height*0.84)
        for i in 0 ... 3 {
            let names:[String]=["Music", "Lazers", "Explosions", "Start Over"]
            addNewLabel(names[i], x: Double(self.frame.width) / 5.2, y: y, font: 35, color: UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0), alignment: .left)
            y -= Double(self.frame.height/7)
        }
    }
    
    override func createContent() {
        if super.contentCreated{
            return
        }
        super.loadBoundary()
        addExitButton()
        addSwitches()
        addSwitch(#selector(SettingsScene.swipeMode(_:)), x: Double(self.frame.width) * 0.6, y: Double(self.frame.height)*0.25, on: self.swipeMode)
        addNewLabel("Swipe Mode", x: Double(self.frame.width) * 0.69, y: Double(self.frame.height)*0.68, font: 30, color: UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0), alignment: .left)
        addLabels()
        displayHighestLevel()
        super.contentCreated = true
    }

    func exitAction(_ sender: UIButton!){
        self.thisDelegate?.gameSceneDidFinish(self, command: "close")
    }
    func swipeMode(_ sender: UIButton!){
        if swipeMode == false{
            swipeMode = true
        }else{
            swipeMode = false
        }
        self.thisDelegate?.updateTransitionLevvel(self)
    }
    func musicOffAction(_ sender: UIButton!){
        if musicOff == false{
            musicOff = true
        }else{
            musicOff = false
        }
        self.thisDelegate?.updateTransitionLevvel(self)
    }
    func lazerOffAction(_ sender: UIButton!){
        if lazerOff == false{
            lazerOff = true
        }else{
            lazerOff = false
        }
        self.thisDelegate?.updateTransitionLevvel(self)
    }
    func explosionOffAction(_ sender: UIButton!){
        if explosionOff == false{
            explosionOff = true
        }else{
            explosionOff = false
        }
        self.thisDelegate?.updateTransitionLevvel(self)
    }
    func resetAction(_ sender: UIButton!){
        level = 1
        self.highScore! = HighScore(name: "Player 1", lives: 1, accuracy: 0.0, level: 0)!
        //self.bestScore! = HighScore(name: "Player 1", lives: 1, accuracy: 0.0, level: 0)!
        self.thisDelegate?.updateTransitionLevvel(self)
    }
    func updateResetHiddenStatus(){
        if resetSwitch != nil{
            if level == 1{
                if let label = childNode(withName: "Start Over") as? SKLabelNode{
                    label.text = "Level One"
                }
                resetSwitch.isHidden = true
            }else{
                resetSwitch.isHidden = false
            }
        }
    }
    override func update(_ currentTime: TimeInterval) {
        if currentTime - timeOfLastUpdateForGameReset > 0.5{
            if self.level != 12{
                updateResetHiddenStatus()
            }
            timeOfLastUpdateForGameReset = currentTime
        }
    }

    func displayHighestLevel(){
        var x = Double(self.frame.width*0.54)
        var y = Double(self.frame.height*0.30)
        var names:[String]=[]
        for i in 1 ... 2{
            for j in 0...2{
                if i == 1{
                    var bestLevelString:String!
                    var bestAccuracyString:String!
                    if bestScore!.level == 1{
                        bestAccuracyString = "---"
                    }else{
                        bestAccuracyString = String(format: "Accuracy: %.1f%%", bestScore!.accuracy * 100.0 / Double(bestScore!.level - 1))
                    }
                    if bestScore!.level != 11{
                        bestLevelString = "Level:     \(bestScore!.level)"
                    }else{
                        bestAccuracyString = String(format: "Accuracy: %.1f%%", bestScore!.accuracy * 100.0 / Double(bestScore!.level - 2))
                        bestLevelString = "Completed"
                    }
                    names = ["Best Game", bestLevelString, "Lives:     \(bestScore!.lives)",
                        bestAccuracyString]
                }else{
                    var accuracyString:String!
                    if highScore?.level > 1{
                        accuracyString = String(format: "Accuracy: %.1f%%", highScore!.accuracy * 100.0 / Double(highScore!.level - 1))
                    }else{
                        accuracyString = "---"
                    }
                    names = ["Current Game",  "Level:     \(highScore!.level)", "Lives:     \(highScore!.lives)", accuracyString]
                }
                if j > 0 {
                    addNewLabel(names[j], x: x, y: y, font: 25, color: UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0), alignment: .left)
                }else{
                    addNewLabel(names[j], x: x, y: y, font: 30, color: UIColor.white, alignment: .left)
                    x += Double(self.frame.width)*0.05
                }
                y -= Double(self.frame.height*0.08)
                // decrement y
            }
            y += Double(self.frame.height*0.32)
            x -= Double(self.frame.width*0.5)
            // decrement x
        }
    }
}




