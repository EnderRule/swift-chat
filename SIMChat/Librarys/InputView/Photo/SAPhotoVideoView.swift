//
//  SAPhotoVideoView.swift
//  SIMChat
//
//  Created by sagesse on 27/10/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import MediaPlayer

//open class SAMAudioPlayer {
//}
//open class SAMAudioRecorder {
//}

//open class SAMVideoPlayer {
//}
//open class SAMVideoPlayerView {
//}
//open class SAMVideoProgressView {
//}


internal class SAPhotoVideoView: UIView {
    
    var thumbnailImage: UIImage? {
        set { return _thumbnailView.image = newValue }
        get { return _thumbnailView.image }
    }
    
    //open var isPlaying: Bool { get } /* is it playing or not? */
    
//    /*  If the sound is playing, currentTime is the offset into the sound of the current playback position.  
//    If the sound is not playing, currentTime is the offset into the sound where playing would start. */
//    open var currentTime: TimeInterval
//
//    
//    /* returns the current time associated with the output device */
//    @available(iOS 4.0, *)
//    open var deviceCurrentTime: TimeInterval { get }
    
    //open var duration: TimeInterval { get } /* the duration of the sound. */
    
    //open var pan: Float /* set panning. -1.0 is left, 0.0 is center, 1.0 is right. */
    //open var volume: Float /* The volume for the sound. The nominal range is from 0.0 to 1.0. */
    
//    @available(iOS 10.0, *)
//    open func setVolume(_ volume: Float, fadeDuration duration: TimeInterval) /* fade to a new volume over a duration */
//
//    
//    @available(iOS 5.0, *)
//    open var enableRate: Bool /* You must set enableRate to YES for the rate property to take effect. You must set this before calling prepareToPlay. */
//
//    @available(iOS 5.0, *)
//    open var rate: Float /* See enableRate. The playback rate for the sound. 1.0 is normal, 0.5 is half speed, 2.0 is double speed. */
    
//    /* "numberOfLoops" is the number of times that the sound will return to the beginning upon reaching the end. 
//    A value of zero means to play the sound just once.
//    A value of one will result in playing the sound twice, and so on..
//    Any negative number will loop indefinitely until stopped.
//    */
//    open var numberOfLoops: Int
    
    //isPlaying
    
    func load(_ item: AVPlayerItem) {
        _logger.trace()
        
//        // 监听缓冲进度改变
//        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.New, context: nil)
//        // 监听状态改变
//        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    func stop() {
        _logger.trace()
        
    }
    func play() {
        _logger.trace()
    }
    func play(at time: TimeInterval) {
        _logger.trace()
    }
    func seek(at time: TimeInterval) {
    }
    
    func pause() {
        _logger.trace()
        
    }
    
    private func _init() {
        
        backgroundColor = .random
        
        _thumbnailView.frame = bounds
        _thumbnailView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(_thumbnailView)
    }
    
    private var _player: AVPlayer?
    private var _playerLayer: AVPlayerLayer?
    
    private lazy var _thumbnailView: UIImageView = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
