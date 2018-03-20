//
//  CreditScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 12/14/15.
//  Copyright © 2015 DimeZee Software. All rights reserved.
//

import SpriteKit
import AVFoundation

class EndScene:GameScene{
    
    var timeToEndScene:Double = 0
    var initCompleted:Bool = false
   // let backgroundAudio = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("applause", ofType: "mp3")!))
    
    func addWinLabel(){
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "!!! YOU WON !!!"
        myLabel.fontSize = 35
        myLabel.fontColor = UIColor.init(colorLiteralRed: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        myLabel.position = CGPoint(x:self.frame.midX, y:0.25 * (self.frame.height))
        self.addChild(myLabel)
    }
    override func didMove(to view: SKView) {
        super.addShip()
        addWinLabel()
        do{
            backgroundAudio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "applause", ofType: "mp3")!))
        }catch{
            print("AVAudioPlayer error")
        }
        if backgroundAudio != nil{
            backgroundAudio!.play()
        }
        if highScore != nil {
            if bestScore != nil{
                if highScore!.level > bestScore!.level{
                    // higher level is better
                    bestScore! = highScore!
                }
                if highScore!.level == bestScore!.level{
                    if bestScore!.lives > highScore!.lives{
                        // less lives is better
                        bestScore! = highScore!
                    }
                    if bestScore!.lives == highScore!.lives{
                        if bestScore!.accuracy < highScore!.accuracy{
                            // more accuracy is better
                            bestScore! = highScore!
                        }
                    }
                }
            }else{
                //bestScore not found
                bestScore! = highScore!
            }
        }else{
            print("highScore not found in Scene")
        }
        self.backgroundColor = UIColor.black
    }
    override func update(_ currentTime: TimeInterval) {
        if initCompleted == false{
            timeToEndScene = currentTime
            initCompleted = true
        }
        if currentTime - timeToEndScene > 6.0 {
            updateBestScore()
            self.highScore! = HighScore(name: "Player 1", lives: 1, accuracy: 0, level: 0)!
            self.thisDelegate?.updateTransitionLevvel(self)
            //score.level = 101
            scene?.isPaused = true
            self.thisDelegate?.gameSceneDidFinish(self, command: "close")
        }
    }
}
