//
//  BossScene.swift
//  MeteorMike
//
//  Created by Ryan Dines on 1/13/16.
//  Copyright © 2016 DimeZee Software. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation

class PracticeScene: GameScene {
    
    enum SongNumber:Int {
        case one = 1,two, three, four, five, six, seven, eight, nine
    }
   // var backgroundAudio:AVAudioPlayer!
    var songPlaying:Int = 9
    var songDesired:Int = 9
    var timeOfLastUpdateForPracticeSong:CFTimeInterval = 0
    
    func initMusic(_ song: SongNumber.RawValue){
        songPlaying = song
        songDesired = song
        switch song{
        case 1: backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "stonerTheme1", ofType: "mp3")!))
        case 2: backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "dopeTheme2", ofType: "mp3")!))
        case 3:backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "technoTheme3", ofType: "mp3")!))
        case 4: backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "dannyDopeBeat4", ofType: "mp3")!))
        case 5: backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "rapTheme5", ofType: "mp3")!))
        case 6: backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "happyTheme6", ofType: "mp3")!))
        case 7: backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "fastTheme7", ofType: "mp3")!))
        case 8: backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "gangstaTheme8", ofType: "mp3")!))
        case 9: backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "dopeTrapBeat9", ofType: "mp3")!))
        default: backgroundAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "stonerTheme1", ofType: "mp3")!))
        }
    }

    override func createContent() {
        super.createContent()
        initMusic(9)
        backgroundAudio.play()
        addExitButton()
    }
    
    func addExitButton(){
        let fireButton = UIButton(frame: CGRect(x: self.size.width - 90, y: 0, width: 90, height: 90))
        fireButton.backgroundColor = UIColor.clear
        fireButton.setTitle("EXIT", for: UIControlState())
        fireButton.setTitleColor(UIColor.red, for: UIControlState())
        fireButton.addTarget(self, action: #selector(PracticeScene.exitAction(_:)), for: UIControlEvents.touchDown)
        self.view!.addSubview(fireButton)
    }
    func endGame(){
        motionManager.stopAccelerometerUpdates()
        if backgroundAudio != nil{
            backgroundAudio!.stop()
        }
        self.thisDelegate?.gameSceneDidFinish(self, command: "close")
    }
    func exitAction(_ sender: UIButton!){
        endGame()
    }
    func updateSong(){
        self.thisDelegate?.updateTransitionLevvel(self)
        if songPlaying != songDesired{
            if backgroundAudio != nil{
                backgroundAudio.stop()
                initMusic(songDesired)
                if backgroundAudio != nil{
                    backgroundAudio.play()
                }
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let ship = childNode(withName: "ship"){
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
                // tapping ship changes song
                if (abs(dx) <= 6.0 && abs(dy) <= 6.0){
                    songDesired += 1
                    if songDesired > 9{
                        songDesired = 1
                    }
                }
            }
        }
    }
    func updateSongPlaying(_ currentTime: CFTimeInterval){
        if currentTime - timeOfLastUpdateForPracticeSong > 0.1{
            updateSong()
            timeOfLastUpdateForPracticeSong = currentTime
        }
    }
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        updateSongPlaying(currentTime)
    }
}
