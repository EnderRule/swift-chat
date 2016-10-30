//
//  SAMVideoPlayerProtocol.swift
//  SAMedia
//
//  Created by sagesse on 28/10/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

@objc public enum SAMVideoPlayerStatus: Int {
    
    // 准备状态
    case preparing
    case prepared
    
    // 播放状态
    case playing
    
    // 停止状态
    case stop
    case error
    
    // 中断状态
    case loading
    case pauseing
    case interruptioning
    
    
    var isPrepared: Bool {
        switch self {
        case .preparing, .prepared,
             .pauseing, .loading, .interruptioning:
            return true
            
        default:
            return false
        }
    }
    var isInterruptioned: Bool {
        switch self {
        case .loading, .pauseing, .interruptioning:
            return true
            
        default:
            return false
        }
    }
    var isPlayed: Bool {
        switch self {
        case .playing:
            return true
            
        default:
            return false
        }
    }
    var isStoped: Bool {
        switch self {
        case .stop, .error:
            return true
            
        default:
            return false
        }
    }
}


@objc public protocol SAMVideoPlayerProtocol: NSObjectProtocol {
    
    // the player status
    var status: SAMVideoPlayerStatus { get }
    
    // the duration of the media.
    var duration: TimeInterval { get }
    
    // If the media is playing, currentTime is the offset into the media of the current playback position.
    // If the media is not playing, currentTime is the offset into the media where playing would start.
    var currentTime: TimeInterval { get }
   
    // This property provides a collection of time ranges for which the download task has media data already downloaded and playable.
    var loadedTime: TimeInterval { get }
    
    // This property provides a collection of time ranges for which the download task has media data already downloaded and playable.
    // The ranges provided might be discontinuous.
    var loadedTimeRanges: Array<NSValue>? { get }
    
    // an delegate
    weak var delegate: SAMVideoPlayerDelegate? { set get }
    
    
    // MARK: - Transport Control
    
    
    // prepare media the resources needed and active audio session
    // methods that return BOOL return YES on success and NO on failure.
    @discardableResult func prepare() -> Bool
    
    // play a media, if it is not ready to complete, will be ready to complete the automatic playback.
    @discardableResult func play() -> Bool
    @discardableResult func play(at time: TimeInterval) -> Bool
    
    @discardableResult func seek(to time: TimeInterval) -> Bool
    
    // pause play
    func pause()
    
    func stop()
}


@objc public protocol SAMVideoPlayerDelegate {

    
    @objc optional func player(shouldPreparing player: SAMVideoPlayerProtocol) -> Bool
    @objc optional func player(didPreparing player: SAMVideoPlayerProtocol)
    
    @objc optional func player(shouldPlaying player: SAMVideoPlayerProtocol) -> Bool
    @objc optional func player(didPlaying player: SAMVideoPlayerProtocol)
    
    @objc optional func player(didPause player: SAMVideoPlayerProtocol)
    @objc optional func player(didStalled player: SAMVideoPlayerProtocol )
    @objc optional func player(didInterruption player: SAMVideoPlayerProtocol)
    
    @objc optional func player(shouldRestorePlaying player: SAMVideoPlayerProtocol) -> Bool
    @objc optional func player(didRestorePlaying player: SAMVideoPlayerProtocol)
    
    @objc optional func player(didStop player: SAMVideoPlayerProtocol)
    
    // playerDidFinishPlaying:successfully: is called when a video has finished playing. This method is NOT called if the player is stopped due to an interruption.
    @objc optional func player(didFinishPlaying player: SAMVideoPlayerProtocol, successfully flag: Bool)
    
    // if an error occurs will be reported to the delegate.
    @objc optional func player(didOccur player: SAMVideoPlayerProtocol, error: Error?)
    
    
    @objc optional func player(didChange player: SAMVideoPlayerProtocol, currentTime time: TimeInterval)
    
    @objc optional func player(didChange player: SAMVideoPlayerProtocol, loadedTime time: TimeInterval)
    @objc optional func player(didChange player: SAMVideoPlayerProtocol, loadedTimeRanges ranges: Array<NSValue>)
}
