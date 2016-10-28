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


internal class SAPhotoVideoView: SAMVideoPlayerView {
    
    var thumbnailImage: UIImage? {
        set { return _thumbnailView.image = newValue }
        get { return _thumbnailView.image }
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
