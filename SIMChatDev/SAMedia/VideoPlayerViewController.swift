//
//  VideoPlayerViewController.swift
//  SAMedia
//
//  Created by sagesse on 28/10/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

class VideoPlayerViewController: UIViewController, SAMVideoPlayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let url = URL(string: "http://sagesse.me:1080/a.mp4") else {
            return
        }
//        guard let url = URL(string: "http://192.168.90.254/a.mp4") else {
//            return
//        }
        
        player = SAMVideoPlayer(contentsOf: url)
        player?.delegate = self
        
        playView.player = player
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func play() {
        
        player?.play()
    }
    @IBAction func pause() {
        
        player?.pause()
    }
    @IBAction func stop() {
        
        player?.stop()
    }
    
    @IBAction func progressDidChange(_ sender: AnyObject) {
        
        print(playProgressView.value)
        
//        if player?.status.isPlayed ?? false {
//            player?.play(at: TimeInterval(playProgressView.value))
//        } else {
            player?.seek(to: TimeInterval(playProgressView.value))
//        }
    }
    
    func player(shouldPreparing player: SAMVideoPlayerProtocol) -> Bool {
        print(#function)
        return true
    }
    func player(didPreparing player: SAMVideoPlayerProtocol) {
        print(#function)
        
        playProgressView.maximumValue = Float(player.duration)
        playProgressView.value = Float(player.currentTime)
        
        loadProgressView.progress = Float(player.loadedTime) / max(playProgressView.maximumValue, 0)
    }
    
    func player(shouldPlaying player: SAMVideoPlayerProtocol) -> Bool {
        print(#function)
        return true
    }
    func player(didPlaying player: SAMVideoPlayerProtocol) {
        print(#function)
    }
    
    func player(didPause player: SAMVideoPlayerProtocol) {
        print(#function)
    }
    
    func player(didStop player: SAMVideoPlayerProtocol) {
        print(#function)
    }
    func player(didInterruption player: SAMVideoPlayerProtocol) {
        print(#function)
    }
    func player(didStalled player: SAMVideoPlayerProtocol) {
        print(#function)
    }
    
    func player(shouldRestorePlaying player: SAMVideoPlayerProtocol) -> Bool {
        print(#function)
        return true
    }
    func player(didRestorePlaying player: SAMVideoPlayerProtocol) {
        print(#function)
    }
    
    func player(didChange player: SAMVideoPlayerProtocol, currentTime time: TimeInterval) {
        playProgressView.setValue(Float(time), animated: true)
    }
    
    func player(didChange player: SAMVideoPlayerProtocol, loadedTime time: TimeInterval) {
        let progress = Float(time) / max(playProgressView.maximumValue, 0)
        
        loadProgressView.setProgress(progress, animated: true)
    }
    
    func player(didFinishPlaying player: SAMVideoPlayerProtocol, successfully flag: Bool) {
        print(#function)
    }
    
    func player(didOccur player: SAMVideoPlayerProtocol, error: Error?) {
        print(#function)
    }
    

    var player: SAMVideoPlayer?
    
    @IBOutlet weak var playView: SAMVideoPlayerView!

    @IBOutlet weak var playProgressView: UISlider!
    @IBOutlet weak var loadProgressView: UIProgressView!
}
