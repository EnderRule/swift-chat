//
//  AudioPlayerViewController.swift
//  SMedia
//
//  Created by sagesse on 27/10/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

class AudioPlayerViewController: UIViewController, SMAudioPlayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let mp3 = Bundle.main.url(forResource: "m1", withExtension: "m4a") else {
            return
        }
        playItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(play(_:)))
        pauseItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(pause(_:)))
        stopItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stop(_:)))
        
        player = try? SMAudioPlayer(contentsOf: mp3)
        player?.delegate = self
        //player?.prepareToPlay()
        
        navigationItem.rightBarButtonItems = [playItem]
    }
    
    var playItem: UIBarButtonItem!
    var pauseItem: UIBarButtonItem!
    var stopItem: UIBarButtonItem!
    
    func play(_ sender: AnyObject) {
        
        player?.play()
    }
    func pause(_ sender: AnyObject) {
        
        player?.pause()
    }
    func stop(_ sender: AnyObject) {
        
        player?.stop()
    }
    

    func audioPlayer(shouldPreparing audioPlayer: SMAudioPlayer) -> Bool {
        print(#function)
        return true
    }
    func audioPlayer(didPreparing audioPlayer: SMAudioPlayer) {
        print(#function)
    }
    
    func audioPlayer(shouldPlaying audioPlayer: SMAudioPlayer) -> Bool {
        print(#function)
        return true
    }
    func audioPlayer(didPlaying audioPlayer: SMAudioPlayer) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [pauseItem, stopItem]
    }
    
    func audioPlayer(didPause audioPlayer: SMAudioPlayer) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [playItem, stopItem]
    }
    
    func audioPlayer(didStop audioPlayer: SMAudioPlayer) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [playItem]
    }
    func audioPlayer(didInterruption audioPlayer: SMAudioPlayer) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [playItem, stopItem]
    }
    
    func audioPlayer(didFinishPlaying audioPlayer: SMAudioPlayer, successfully flag: Bool) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [playItem]
    }
    
    func audioPlayer(didOccur audioPlayer: SMAudioPlayer, error: Error?) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [playItem]
    }
    
    var player: SMAudioPlayer?
}
