//
//  SAAudioPlayer.swift
//  SIMChat
//
//  Created by sagesse on 9/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import AVFoundation

@objc 
public protocol SAAudioPlayerDelegate: NSObjectProtocol {
    
    @objc optional func player(shouldPrepareToPlay player: SAAudioPlayer) -> Bool
    @objc optional func player(didPrepareToPlay player: SAAudioPlayer)
    
    @objc optional func player(shouldStartPlay player: SAAudioPlayer) -> Bool
    @objc optional func player(didStartPlay player: SAAudioPlayer)
    
    @objc optional func player(didStopPlay player: SAAudioPlayer)
    
    @objc optional func player(didFinishPlay player: SAAudioPlayer)
    @objc optional func player(didInterruptionPlay player: SAAudioPlayer)
    @objc optional func player(didErrorOccur player: SAAudioPlayer, error: NSError)
}


open class SAAudioPlayer: NSObject {
    
    open func prepareToPlay() {
        _prepareToPlay(false)
    }
    open func play() {
        _prepareToPlay(true)
        _startPlay()
    }
    open func stop() {
        _stopPlay()
    }
    
    open weak var delegate: SAAudioPlayerDelegate?
    
    open var url: URL {
        return _url
    }
    open var duration: TimeInterval { 
        return _player?.duration ?? 0 
    }
    open var currentTime: TimeInterval {
        set {
            _player?.currentTime = newValue
        }
        get {
            return _player?.currentTime ?? 0 
        }
    }
    
    open var isPlaying: Bool {
        return _player?.isPlaying ?? false
    }
    open var isMeteringEnabled: Bool = false {
        willSet {
            _player?.isMeteringEnabled = newValue
        }
    }
    
    open func updateMeters() {
        _player?.updateMeters()
    }
    open func peakPower(forChannel channelNumber: Int) -> Float {
        return _player?.peakPower(forChannel: channelNumber) ?? -160
    }
    open func averagePower(forChannel channelNumber: Int) -> Float {
        return _player?.averagePower(forChannel: channelNumber) ?? -160
    }
    
    fileprivate var _isStarted: Bool = false
    
    fileprivate var _isPrepared: Bool { return _player != nil }
    fileprivate var _isPrepareing: Bool = false
    
    fileprivate var _url: URL
    fileprivate var _player: AVAudioPlayer?
    
    public init(url: URL) {
        _url = url
        super.init()
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(audioPlayDidInterruption(_:)),
                           name: .AVAudioSessionInterruption,
                           object: nil)
    }
    deinit {
        _player?.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
}

fileprivate extension SAAudioPlayer {
    
    fileprivate func _clearResource() {
        
        _isStarted = false
        _player?.delegate = nil
        _player?.stop() 
        _player = nil
    }
    
    fileprivate func _activate() throws {
        try SAAudioSession.setCategory(AVAudioSessionCategoryPlayback)
        try SAAudioSession.setActive(true, context: self)
        
//        objc_sync_enter(SAAudioPlayer.self)
//        defer {
//            objc_sync_exit(SAAudioPlayer.self) 
//        }
//        guard SAAudioPlayer._activatedPlayer !== self else {
//            return
//        }
//        logger.debug("activate session for \(self)")
//        
//        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//        try AVAudioSession.sharedInstance().setActive(true)
//        
//        SAAudioPlayer._activatedPlayer = self
    }
    fileprivate func _deactivate() {
        _ = try? SAAudioSession.setActive(false, with: .notifyOthersOnDeactivation, context: self)
        
//        let st = DispatchTimeInterval.seconds(3)
//        let task = time(nil)
//        let session = AVAudioSession.sharedInstance()
//        let category = session.category
//        
//        objc_sync_enter(SAAudioPlayer.self)
//        SAAudioPlayer._activateTaskId = task
//        objc_sync_exit(SAAudioPlayer.self)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + st) {  [logger] in
//            objc_sync_enter(SAAudioPlayer.self)
//            autoreleasepool {
//                guard session.category == category else {
//                    return // 别人使用了
//                }
//                guard SAAudioPlayer._activateTaskId == task else {
//                    logger.debug("can't deactivate session for \(self), task is expire")
//                    return // 任务过期
//                }
//                let activatedPlayer = SAAudioPlayer._activatedPlayer
//                guard activatedPlayer === self else {
//                    logger.debug("can't deactivate session for \(self), activated player is \(activatedPlayer)")
//                    return 
//                }
//                guard !self._isStarted else {
//                    logger.debug("can't deactivate session for \(self), player is stated")
//                    return 
//                }
//                logger.debug("dactivate session for \(self)")
//                _ = try? session.setActive(false, with: .notifyOthersOnDeactivation)
//                SAAudioPlayer._activatedPlayer = nil
//            }
//            objc_sync_exit(SAAudioPlayer.self) 
//        }
    }
    
    fileprivate func _prepareToPlay(_ autoStart: Bool) {
        guard !_isPrepared && !_isPrepareing else {
            return // 己经准备或正在准备
        }
        guard _shouldPrepareToPlay() else {
            return // 申请被拒绝
        }
        _isPrepareing = true
//        if self._prepareToPlayV2() && autoStart {
//            self._startPlay()
//        }
        dispatch_after_at_now(1, .main) {
            if self._prepareToPlayV2() && autoStart {
                self._startPlay()
            }
        }
    }
    fileprivate func _prepareToPlayV2() -> Bool {
        do {
            let player = try AVAudioPlayer(contentsOf: _url)
            player.delegate = self
            player.isMeteringEnabled = isMeteringEnabled
            _player = player
            _isPrepareing = false
            _didPrepareToPlay()
            return true
        } catch let error as NSError  {
            _isPrepareing = false
            _didErrorOccur(error)
            return false
        }
    }
    
    fileprivate func _startPlay() {
        guard !_isStarted && _isPrepared else {
            return // 并没有准备好
        }
        do {
            guard let player = _player else {
                return // 并没有准备好
            }
            guard _shouldStartPlay() else {
                _clearResource()
                return // 用户拒绝了该请求
            }
            try _activate()
            guard player.prepareToPlay() else  {
                throw NSError(domain: "SAAudioDoMain", code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: "准备播放失败"
                ])
            }
            guard player.play() else {
                throw NSError(domain: "SAAudioDoMain", code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: "播放失败"
                ])
            }
            _isStarted = true
            _didStartPlay()
        } catch let error as NSError {
            _didErrorOccur(error)
        }
    }
    
    fileprivate func _stopPlay() {
        guard _isStarted && _isPrepared else {
            return // 并没有启动
        }
        // 取消
        _isStarted = false
        _player?.delegate = nil
        _player?.stop()
        _player = nil
        _didStopPlay()
        _deactivate()
        _clearResource()
    }
    fileprivate func _interruptionPlay() {
        guard _isStarted && _isPrepared else {
            return // 并没有启动
        }
        _isStarted = false
        _isStarted = false
        _player?.delegate = nil
        _player?.stop()
        _player = nil
        _didInterruptionPlay()
        _deactivate()
        _clearResource()
    }
}

fileprivate extension SAAudioPlayer {
    
    fileprivate func _shouldPrepareToPlay() -> Bool {
        guard delegate?.player?(shouldPrepareToPlay: self) ?? true else {
            return false
        }
        return true
    }
    fileprivate func _didPrepareToPlay() {
        delegate?.player?(didPrepareToPlay: self)
    }
    
    fileprivate func _shouldStartPlay() -> Bool {
        guard delegate?.player?(shouldStartPlay: self) ?? true else {
            return false
        }
        return true
    }
    fileprivate func _didStartPlay() {
        delegate?.player?(didStartPlay: self)
    }
    
    fileprivate func _didStopPlay() {
        delegate?.player?(didStopPlay: self)
    }
    
    fileprivate func _didInterruptionPlay() {
        delegate?.player?(didInterruptionPlay: self)
    }
    
    fileprivate func _didFinishPlay() {
        delegate?.player?(didFinishPlay: self)
    }
    fileprivate func _didErrorOccur(_ error: NSError) {
        delegate?.player?(didErrorOccur: self, error: error)
        // 释放资源
        _isStarted = false
        _clearResource()
    }
}

// MARK: - AVAudioPlayerDelegate

extension SAAudioPlayer: AVAudioPlayerDelegate {
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        _didFinishPlay()
        _deactivate()
        _clearResource()
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        let err = (error as? NSError) ?? NSError(domain: "SAAudioDoMain", code: 4, userInfo: [
            NSLocalizedFailureReasonErrorKey: "编码错误"
        ])
        _deactivate()
        _didErrorOccur(err)
    }
    
    public func audioPlayDidInterruption(_ sender: Notification) {
        _interruptionPlay()
    }
}
