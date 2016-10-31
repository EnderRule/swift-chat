//
//  VideoPlayerViewController.swift
//  SMedia
//
//  Created by sagesse on 28/10/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

class VideoPlayerViewController: UIViewController, SMVideoPlayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let url = URL(string: "http://sagesse.me:1080/a.mp4") else {
            return
        }
//        guard let url = URL(string: "http://192.168.90.254/a.mp4") else {
//            return
//        }
        
        player = SMVideoPlayer(contentsOf: url)
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
    
    func player(shouldPreparing player: SMPlayerProtocol) -> Bool {
        print(#function)
        return true
    }
    func player(didPreparing player: SMPlayerProtocol) {
        print(#function)
        
        playProgressView.maximumValue = Float(player.duration)
        playProgressView.value = Float(player.currentTime)
        
        loadProgressView.progress = Float(player.loadedTime) / max(playProgressView.maximumValue, 0)
    }
    
    func player(shouldPlaying player: SMPlayerProtocol) -> Bool {
        print(#function)
        return true
    }
    func player(didPlaying player: SMPlayerProtocol) {
        print(#function)
    }
    
    func player(didPause player: SMPlayerProtocol) {
        print(#function)
    }
    
    func player(didStop player: SMPlayerProtocol) {
        print(#function)
    }
    func player(didInterruption player: SMPlayerProtocol) {
        print(#function)
    }
    func player(didStalled player: SMPlayerProtocol) {
        print(#function)
    }
    
    func player(shouldRestorePlaying player: SMPlayerProtocol) -> Bool {
        print(#function)
        return true
    }
    func player(didRestorePlaying player: SMPlayerProtocol) {
        print(#function)
    }
    
    func player(didChange player: SMPlayerProtocol, currentTime time: TimeInterval) {
        playProgressView.setValue(Float(time), animated: true)
    }
    
    func player(didChange player: SMPlayerProtocol, loadedTime time: TimeInterval) {
        let progress = Float(time) / max(playProgressView.maximumValue, 0)
        
        loadProgressView.setProgress(progress, animated: true)
    }
    
    func player(didFinishPlaying player: SMPlayerProtocol, successfully flag: Bool) {
        print(#function)
    }
    
    func player(didOccur player: SMPlayerProtocol, error: Error?) {
        print(#function)
    }
    

    var player: SMVideoPlayer?
    
    @IBOutlet weak var playView: SMVideoPlayerView!

    @IBOutlet weak var playProgressView: UISlider!
    @IBOutlet weak var loadProgressView: UIProgressView!
}
