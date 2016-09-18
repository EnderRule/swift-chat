//
//  SAAudioRecorder.swift
//  SIMChat
//
//  Created by sagesse on 9/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import AVFoundation

@objc 
public protocol SAAudioRecorderDelegate: NSObjectProtocol {
    
    @objc optional func recorder(shouldPrepareToRecord recorder: SAAudioRecorder) -> Bool
    @objc optional func recorder(didPrepareToRecord recorder: SAAudioRecorder)
    
    @objc optional func recorder(shouldStartRecord recorder: SAAudioRecorder) -> Bool
    @objc optional func recorder(didStartRecord recorder: SAAudioRecorder)
    
    @objc optional func recorder(didStopRecord recorder: SAAudioRecorder)
    
    @objc optional func recorder(didFinishRecord recorder: SAAudioRecorder)
    @objc optional func recorder(didInterruptionRecord recorder: SAAudioRecorder)
    @objc optional func recorder(didErrorOccur recorder: SAAudioRecorder, error: NSError)
}


open class SAAudioRecorder: NSObject {

    open func prepareToRecord() {
        _prepareToRecord(false)
    }
    open func record() {
        _prepareToRecord(true)
        _startRecord()
    }
    open func stop() {
        _stopRecord()
    }
    
    open var url: URL {
        return _url
    }
    open var currentTime: TimeInterval {
        if let recorder = _recorder, recorder.isRecording {
            return recorder.currentTime
        }
        return _lastCurrentTime
    }
    
    open var isRecording: Bool {
        return _recorder?.isRecording ?? true
    }
    open var isMeteringEnabled: Bool = false {
        willSet {
            _recorder?.isMeteringEnabled = newValue
        }
    }
    
    open func updateMeters() {
        _recorder?.updateMeters()
    }
    open func peakPower(forChannel channelNumber: Int) -> Float {
        return _recorder?.peakPower(forChannel: channelNumber) ?? -160
    }
    open func averagePower(forChannel channelNumber: Int) -> Float {
        return _recorder?.averagePower(forChannel: channelNumber) ?? -160
    }
    
    open weak var delegate: SAAudioRecorderDelegate?
    
    fileprivate var _lastCurrentTime: TimeInterval = 0
    fileprivate var _isStarted: Bool = false
    
    fileprivate var _isPrepared: Bool { return _recorder != nil }
    fileprivate var _isPrepareing: Bool = false
    
    fileprivate var _url: URL
    fileprivate var _settings: [String: Any] 
    fileprivate var _recorder: AVAudioRecorder?
    
    public init(url: URL, settings: [String: Any]? = nil) {
        _url = url
        _settings = settings ?? [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),                   // 设置录音格式: kAudioFormatLinearPCM
            AVSampleRateKey: 44100,                                 // 设置录音采样率(Hz): 8000/44100/96000(影响音频的质量)
            AVNumberOfChannelsKey: 1,                               // 录音通道数: 1/2
            AVLinearPCMBitDepthKey: 16,                             // 线性采样位数: 8/16/24/32
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue  // 录音的质量
        ]
        super.init()
        
        let center = NotificationCenter.default
        
        center.addObserver(self,
                           selector: #selector(audioRecorderDidInterruption(_:)),
                           name: .AVAudioSessionInterruption,
                           object: nil)
        
    }
    deinit {
        _recorder?.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
}

fileprivate extension SAAudioRecorder {
    
    fileprivate func _clearResource() {
        
        _isStarted = false
        _recorder?.delegate = nil
        _recorder?.stop()
        _recorder = nil
    }
    
    fileprivate func _activate() throws {
        try SAAudioSession.setCategory(AVAudioSessionCategoryRecord)
        try SAAudioSession.setActive(true, context: self)
    }
    fileprivate func _deactivate() {
        _ = try? SAAudioSession.setActive(false, with: .notifyOthersOnDeactivation, context: self)
    }
    
    fileprivate func _prepareToRecord(_ autoStart: Bool) {
        guard !_isPrepared && !_isPrepareing else {
            return // 己经准备或正在准备
        }
        guard _shouldPrepareToRecord() else {
            return // 申请被拒绝
        }
        _isPrepareing = true
        // 首先请求录音权限
        AVAudioSession.sharedInstance().requestRecordPermission { hasPermission in
            DispatchQueue.main.async {
                if self._prepareToRecordV2(hasPermission) && autoStart {
                    DispatchQueue.main.async {
                        self._startRecord()
                    }
                }
            }
        }
    }
    fileprivate func _prepareToRecordV2(_ hasPermission: Bool) -> Bool {
        do {
            guard hasPermission else {
                throw NSError(domain: "SAAudioDoMain", code: 1, userInfo: [
                    NSLocalizedFailureReasonErrorKey: "没有录音权限"
                ])
            }
            let recorder = try _makeRecorder()
            _recorder = recorder
            _isPrepareing = false
            _didPrepareToRecord()
            return true
        } catch let error as NSError  {
            _isPrepareing = false
            _didErrorOccur(error)
            return false
        }
    }
    
    fileprivate func _startRecord() {
        guard !_isStarted && _isPrepared else {
            return // 并没有准备好
        }
        do {
            guard let recorder = _recorder else {
                return // 并没有准备好
            }
            guard _shouldStartRecord() else {
                _clearResource()
                return // 用户拒绝了该请求
            }
            try _activate()
            guard recorder.prepareToRecord() else  {
                throw NSError(domain: "SAAudioDoMain", code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: "准备录音失败"
                ])
            }
            guard recorder.record() else {
                throw NSError(domain: "SAAudioDoMain", code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: "录音失败"
                ])
            }
            _isStarted = true
            _didStartRecord()
        } catch let error as NSError {
            _didErrorOccur(error)
        }
    }
    
    fileprivate func _stopRecord() {
        guard _isStarted && _isPrepared else {
            return // 并没有启动
        }
        // 取消
        _isStarted = false
        _lastCurrentTime = currentTime
        _recorder?.stop()
        _didStopRecord()
        _deactivate()
    }
    fileprivate func _interruptionRecord() {
        guard _isStarted && _isPrepared else {
            return // 并没有启动
        }
        _lastCurrentTime = currentTime
        _isStarted = false
        _recorder?.delegate = nil
        _recorder?.stop()
        _recorder = nil
        _didInterruptionRecord()
        _deactivate()
        _clearResource()
    }
    
    private func _makeRecorder() throws -> AVAudioRecorder {
        _ = try? FileManager.default.removeItem(at: _url)
        let recorder = try AVAudioRecorder(url: _url, settings: _settings)
        recorder.delegate = self
        recorder.isMeteringEnabled = isMeteringEnabled
        return recorder
    }
}

fileprivate extension SAAudioRecorder {
    
    fileprivate func _shouldPrepareToRecord() -> Bool {
        guard delegate?.recorder?(shouldPrepareToRecord: self) ?? true else {
            return false
        }
        return true
    }
    fileprivate func _didPrepareToRecord() {
        delegate?.recorder?(didPrepareToRecord: self)
    }
    
    fileprivate func _shouldStartRecord() -> Bool {
        guard delegate?.recorder?(shouldStartRecord: self) ?? true else {
            return false
        }
        return true
    }
    fileprivate func _didStartRecord() {
        delegate?.recorder?(didStartRecord: self)
    }
    
    fileprivate func _didStopRecord() {
        delegate?.recorder?(didStopRecord: self)
    }
    
    fileprivate func _didInterruptionRecord() {
        delegate?.recorder?(didInterruptionRecord: self)
    }
    
    fileprivate func _didFinishRecord() {
        delegate?.recorder?(didFinishRecord: self)
    }
    fileprivate func _didErrorOccur(_ error: NSError) {
        delegate?.recorder?(didErrorOccur: self, error: error)
        // 释放资源
        _isStarted = false
        _clearResource()
    }
}

extension SAAudioRecorder: AVAudioRecorderDelegate { 
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        DispatchQueue.main.async {
            self._didFinishRecord()
            self._clearResource()
        }
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        let err = (error as? NSError) ?? NSError(domain: "SAAudioDoMain", code: 4, userInfo: [
            NSLocalizedFailureReasonErrorKey: "编码错误"
        ])
        _deactivate()
        _didErrorOccur(err)
    }
    
    public func audioRecorderDidInterruption(_ sender: Notification) {
        _interruptionRecord()
    }
}
