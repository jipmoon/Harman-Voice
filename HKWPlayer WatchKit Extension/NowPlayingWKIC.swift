//
//  NowPlayingWKIC.swift
//  HKWPlayer
//
//  Created by Seonman Kim on 5/7/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import WatchKit
import Foundation

var g_isPlaying = false

class NowPlayingWKIC: WKInterfaceController {
    @IBOutlet weak var titleWKLabel: WKInterfaceLabel!

    @IBOutlet weak var artistWKLabel: WKInterfaceLabel!
    
    @IBOutlet weak var playWKBtn: WKInterfaceButton!
    
    @IBOutlet weak var fastForwardWKBtn: WKInterfaceButton!
    
    @IBOutlet weak var rewindWKBtn: WKInterfaceButton!
    
    @IBOutlet var volumeSlide: WKInterfaceSlider!
    
    @IBOutlet var timeLabel: WKInterfaceLabel!
    
    var playItem: Playlist!
    
    var timeElapsed = 0
    var totalTimeStr: String!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        g_nowPlayingWKIC = self
        
        playItem = context as! Playlist
        
        configureUI(playItem)
        
        WKInterfaceController.openParentApplication(["getVolume": NSNumber(float: 25.0)], reply: {(reply, error) -> Void in
            if let retValue = reply["getVolume"] as? NSNumber {
                println("current Volume: \(retValue.floatValue)")
                self.volumeSlide.setValue(retValue.floatValue)
                
            }
        })
        
        WKInterfaceController.openParentApplication(["getElapsedTime": NSNumber(float: 0.0)], reply: {(reply, error) -> Void in
            if let retValue = reply["getElapsedTime"] as? NSNumber {
                println("getElapsedTime : \(retValue.intValue)")
                
                self.timeElapsed = Int(retValue.intValue)
                var min = self.timeElapsed / 60
                var sec = self.timeElapsed % 60
                var formatStr: String = String(format: "%d:%02d", min, sec)
                self.timeLabel.setText("\(formatStr)/\(self.totalTimeStr)")
                
            }
        })
        
        if !g_sameItem {
            playCurrentIndex()
        } else {
            self.playWKBtn.setBackgroundImage(UIImage(named: "pause_white"))
        }
    }

    func configureUI(item: Playlist) {
        titleWKLabel.setText(item.item_title)
        artistWKLabel.setText(item.item_artist)
        
        var totalTime = Int(item.item_duration)
        var min = totalTime / 60
        var sec = totalTime % 60
        totalTimeStr = String(format: "%d:%02d", min, sec)
    }
    
    func updateTimeElapsed(newTime: Int) {
        self.timeElapsed = newTime
        var min = self.timeElapsed / 60
        var sec = self.timeElapsed % 60
        var formatStr: String = String(format: "%d:%02d", min, sec)
        self.timeLabel.setText("\(formatStr)/\(self.totalTimeStr)")
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func playPressed() {
        println("Play pressed")
        println("persistenID: \(playItem.item_persistentID)")
        
        if !g_isPlaying {
            // start play
            WKInterfaceController.openParentApplication(["resumeItem": playItem.item_persistentID], reply: {(reply, error) -> Void in
                if let eventCreated = reply["resumeItem"] as? NSNumber {
                    if eventCreated.boolValue {
                        g_isPlaying = true
                        self.playWKBtn.setBackgroundImage(UIImage(named: "pause_white"))
                        
                    }
                }
            })
        } else {
            // pause
            WKInterfaceController.openParentApplication(["pauseItem": playItem.item_persistentID], reply: {(reply, error) -> Void in
                if let eventCreated = reply["pauseItem"] as? NSNumber {
                    if eventCreated.boolValue {
                        g_isPlaying = false
                        self.playWKBtn.setBackgroundImage(UIImage(named: "play_white"))
                    }
                }
            })
        }
    }
    

    @IBAction func fastForwardPressed() {
        println("FF pressed")

        timeElapsed = 0
        g_currentIndex++
        if g_currentIndex == g_playList.count {
            g_currentIndex = 0
        }

        
        playItem = g_playList[g_currentIndex]
        configureUI(playItem)

        playCurrentIndex()

    }
    
    @IBAction func rewindPressed() {
        println("RW pressed")
        if timeElapsed < 1 {
            timeElapsed = 0
            
            g_currentIndex--
            if g_currentIndex < 0 {
                g_currentIndex = g_playList.count - 1
            }
        }
        
        playItem = g_playList[g_currentIndex]
        configureUI(playItem)
        
        playCurrentIndex()

    }
    
    @IBAction func volumeChanged(value: Float) {
        println("volume: \(value)")
        WKInterfaceController.openParentApplication(["setVolume": NSNumber(float: value)], reply: {(reply, error) -> Void in
            if let eventCreated = reply["setVolume"] as? NSNumber {

            }
        })
    }
    
    func playCurrentIndex() {
        println("persistenID: \(playItem.item_persistentID)")
        WKInterfaceController.openParentApplication(["playItem": playItem.item_persistentID], reply: {(reply, error) -> Void in
            if let eventCreated = reply["playItem"] as? NSNumber {
                if eventCreated.boolValue {
                    g_isPlaying = true
                    self.playWKBtn.setBackgroundImage(UIImage(named: "pause_white"))
                    self.updateTimeElapsed(0);
                    
                }
            }
        })
    }

}