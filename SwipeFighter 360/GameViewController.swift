//
//  GameViewController.swift
//  MeteorMike
//
//  Created by Ryan Dines on 12/1/15.
//  Copyright (c) 2015 DimeZee Software. All rights reserved.
//


import UIKit
import SpriteKit


class GameViewController: UIViewController, UIGestureRecognizerDelegate{
    
    var scene:TransitionScene?
    //var thisDelegate: GameViewControllerDelegate?

    var playaData:HighScore!
    var bestHighScore:HighScore!
    
    func saveHighScores(){
        print("Inside GVC.saveHighScores")
        print("saving: playaData.level = \(playaData.level)")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(playaData, toFile: HighScore.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save scores")
        }
    }
    func saveBestScores(){
        print("Saving best score")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bestHighScore, toFile: BestScore.ArchiveURL2.path)
        if !isSuccessfulSave {
            print("Failed to save scores")
        }
    }

    func loadHighScores() -> HighScore? {
        print("Inside GVC.loadHighScores()")
        return (NSKeyedUnarchiver.unarchiveObject(withFile: HighScore.ArchiveURL.path) as? HighScore)      //(HighScore.ArchiveURL.path!) as? [HighScore]
    }
    func loadBestScores()->HighScore?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: BestScore.ArchiveURL2.path) as? HighScore
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = self.view as! SKView
        skView.tag = 1
        if let savedScore = loadHighScores(){
              print("Successful finding of scores from loadHighScores")
              playaData = savedScore
            
        }else {
            // Load default data
            let newPlaya = HighScore(name: "Player 1", lives: 1, accuracy: 0.0, level: 1)
            print("No scores found")
            //universalHighScores.append(newPlaya!)
            playaData = newPlaya
        }
        if let savedBestScore = loadBestScores(){
            bestHighScore = savedBestScore
        }else{
            let newBest = HighScore(name: "Player 1", lives: 1, accuracy: 0.0, level: 1)
            print("No Best Score Found")
            bestHighScore = newBest
        }
        skView.ignoresSiblingOrder = false
        scene = TransitionScene(size:view.frame.size)
        scene!.scaleMode = .aspectFill
        scene!.highScore = playaData    //universalHighScores[0]
        print("bestHighScore: \(bestHighScore.level)")
        scene!.bestScore = bestHighScore
        skView.presentScene(scene)
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
