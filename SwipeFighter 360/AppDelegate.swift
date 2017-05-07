


//  MeteorMike
//
//  AppDelegate.swift
//  MeteorMike
//
//  Created by Ryan Dines on 12/1/15.
//  Copyright © 2015 DimeZee Software. All rights reserved.
//

import UIKit
import SpriteKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    var gameViewController:GameViewController!
    //var transitionScene:SKScene!
    func savePlayaData(){
        // push data up from scene
        if let scene = gameViewController.scene{
            gameViewController.playaData = scene.highScore
            gameViewController.bestHighScore = scene.bestScore
        }
        // don't save during intro scenes
        if gameViewController.playaData.level > 99 || gameViewController.bestHighScore.level > 99{
            return
        }
        if gameViewController.bestHighScore.level < gameViewController.playaData.level{
            gameViewController.bestHighScore = gameViewController.playaData
        }
        if gameViewController.bestHighScore.level == gameViewController.playaData.level{
            if gameViewController.bestHighScore.lives > gameViewController.playaData.lives{
                gameViewController.bestHighScore = gameViewController.playaData
            }
            if gameViewController.bestHighScore.lives == gameViewController.playaData.lives{
                if gameViewController.bestHighScore.accuracy < gameViewController.playaData.accuracy{
                    gameViewController.bestHighScore = gameViewController.playaData
                }
            }
        }
        gameViewController.saveBestScores()
        gameViewController.saveHighScores()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        gameViewController = window!.rootViewController as! GameViewController
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        print("app resigns active")
        savePlayaData()
        gameViewController.scene?.paused = true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        print("app entered background")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        gameViewController.scene?.paused = false
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        print("app terminating")
        savePlayaData()
    }
}