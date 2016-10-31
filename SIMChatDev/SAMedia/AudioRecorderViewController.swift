//
//  AudioRecorderViewController.swift
//  SMedia
//
//  Created by sagesse on 27/10/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

class AudioRecorderViewController: UIViewController, SMAudioRecorderDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let url = URL(fileURLWithPath: NSTemporaryDirectory() + "a.m3a")
        
        recorder = try? SMAudioRecorder(contentsOf: url)
        recorder?.delegate = self
        
        player = try? SMAudioPlayer(contentsOf: url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func record(_ sender: AnyObject) {
        
        recorder?.record()
    }
    @IBAction func pause(_ sender: AnyObject) {
        recorder?.pause()
    }
    @IBAction func stop(_ sender: AnyObject) {
        recorder?.stop()
    }
    
    @IBAction func startPlay(_ sender: AnyObject) {
        player?.play()
    }
    @IBAction func stopPlay(_ sender: AnyObject) {
        player?.stop()
    }
    
    func audioRecorder(shouldPreparing audioRecorder: SMAudioRecorder) -> Bool {
        print(#function)
        return true
    }
    func audioRecorder(didPreparing audioRecorder: SMAudioRecorder) {
        print(#function)
    }
    
    func audioRecorder(shouldRecording audioRecorder: SMAudioRecorder) -> Bool {
        print(#function)
        return true
    }
    func audioRecorder(didRecording audioRecorder: SMAudioRecorder) {
        print(#function)
    }
    
    func audioRecorder(didPause audioRecorder: SMAudioRecorder) {
        print(#function)
    }
    
    func audioRecorder(didStop audioRecorder: SMAudioRecorder) {
        print(#function)
    }
    func audioRecorder(didInterruption audioRecorder: SMAudioRecorder) {
        print(#function)
    }
    
    func audioRecorder(didFinishRecording audioRecorder: SMAudioRecorder, successfully flag: Bool) {
        print(#function, flag)
    }
    
    func audioRecorder(didOccur audioRecorder: SMAudioRecorder, error: Error?) {
        print(#function, error as Any)
    }

    var recorder: SMAudioRecorder?
    var player: SMAudioPlayer?
}
