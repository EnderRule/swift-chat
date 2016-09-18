//
//  SAAudioRecordView.swift
//  SIMChat
//
//  Created by sagesse on 9/16/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAAudioRecordView: SAAudioView {
    
    func updateStatus(_ status: SAAudioStatus) {
        _logger.trace(status)
        
        _status = status
        _statusView.status = status
        
        switch status {
        case .none,
             .error(_): // 错误状态
            
            _clearResources()
            _showRecordMode()
            
            _recordButton.isSelected = false
            _recordButton.isUserInteractionEnabled = true
            
        case .waiting: // 等待状态
            
            _playButton.isUserInteractionEnabled = false
            _recordButton.isUserInteractionEnabled = false
            
        case .processing: // 处理状态
            
            _playButton.isUserInteractionEnabled = false
            _recordButton.isUserInteractionEnabled = false
            
        case .recording: // 录音状态
            
            _recordButton.isSelected = true
            _recordButton.isUserInteractionEnabled = true
            
        case .playing: // 播放状态
            
            _playButton.isSelected = true
            _playButton.isUserInteractionEnabled = true
            
        case .processed: // 试听状态
            
            let t = Int(_recorder?.currentTime ?? 0)
            _statusView.text = String(format: "%0d:%02d", t / 60, t % 60)
            
            _playButton.progress = 0
            _playButton.isSelected = false
            _playButton.isUserInteractionEnabled = true
            
            _showPlayMode()

            _clearResources()
            _showRecordMode()
            
            _recordButton.isSelected = false
            _recordButton.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func _showPlayMode() {
        guard _playButton.isHidden else {
            return
        }
        _playButton.isHidden = false
        _playButton.alpha = 0
        _playToolbar.isHidden = false
        _playToolbar.transform = CGAffineTransform(translationX: 0, y: _playToolbar.frame.height)
        
        UIView.animate(withDuration: 0.25, animations: {
            self._playButton.alpha = 1
            self._playToolbar.transform = .identity
            self._recordButton.alpha = 0
        }, completion: { f in
            self._recordButton.alpha = 1
            self._recordButton.isHidden = true
        })
    }
    fileprivate func _showRecordMode() {
        guard _recordButton.isHidden else {
            return
        }
        
        _recordButton.alpha = 0
        _recordButton.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self._playButton.alpha = 0
            self._playToolbar.transform = CGAffineTransform(translationX: 0, y: self._playToolbar.frame.height)
            self._recordButton.alpha = 1
        }, completion: { f in
            self._playButton.alpha = 1
            self._playButton.isHidden = true
            self._playButton.isSelected = false
            self._playToolbar.transform = .identity
            self._playToolbar.isHidden = true
        })
    }
    
    fileprivate func _clearResources() {
        _recorder?.delegate = nil
        _recorder?.stop() 
        _recorder = nil
        _player?.delegate = nil
        _player?.stop()
        _player = nil
    }
    
    
    fileprivate func _updateTime() {
        if _status.isRecording {
            let t = Int(_recorder?.currentTime ?? 0)
            _statusView.text = String(format: "%0d:%02d", t / 60, t % 60)
            _statusView.spectrumView.isHidden = false
            return
        }
        if _status.isPlaying {
            let d = TimeInterval(_recorder?.currentTime ?? 0)
            let ct = TimeInterval(_player?.currentTime ?? 0)
            
            _playButton.setProgress(CGFloat(ct + 0.2) / CGFloat(d), animated: true)
            
            _statusView.text = String(format: "%0d:%02d", Int(ct) / 60, Int(ct) % 60)
            _statusView.spectrumView.isHidden = false
            return
        }
    }
    
    
    fileprivate func _makePlayer(_ url: URL) -> SAAudioPlayer {
        let player = SAAudioPlayer(url: _recordFileAtURL)
        player.delegate = self
        player.isMeteringEnabled = true
        return player
    }
    fileprivate func _makeRecorder(_ url: URL) -> SAAudioRecorder {
        let recorder = SAAudioRecorder(url: _recordFileAtURL)
        recorder.delegate = self
        recorder.isMeteringEnabled = true
        return recorder
    }
    
    private func _init() {
        _logger.trace()
        
        let hcolor = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
        
        _statusView.text = "点击录音"
        _statusView.delegate = self
        _statusView.translatesAutoresizingMaskIntoConstraints = false
        
        let backgroundImage = UIImage(named: "simchat_keyboard_voice_background")
        
        _playButton.isHidden = true
        _playButton.progressColor = hcolor
        _playButton.progressLineWidth = 2
        _playButton.translatesAutoresizingMaskIntoConstraints = false
        _playButton.setBackgroundImage(backgroundImage, for: .normal)
        _playButton.setBackgroundImage(backgroundImage, for: .highlighted)
        _playButton.setBackgroundImage(backgroundImage, for: [.selected, .normal])
        _playButton.setBackgroundImage(backgroundImage, for: [.selected, .highlighted])
        _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_nor"), for: .normal)
        _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_press"), for: .highlighted)
        _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_nor"), for: [.selected, .normal])
        _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_press"), for: [.selected, .highlighted])
        _playButton.addTarget(self, action: #selector(onPlayAndStop(_:)), for: .touchUpInside)
        
        _playToolbar.isHidden = true
        _playToolbar.translatesAutoresizingMaskIntoConstraints = false
        _playToolbar.cancelButton.setTitleColor(hcolor, for: .normal)
        _playToolbar.confirmButton.setTitleColor(hcolor, for: .normal)
        _playToolbar.cancelButton.addTarget(self, action: #selector(onCancel(_:)), for: .touchUpInside)
        _playToolbar.confirmButton.addTarget(self, action: #selector(onConfirm(_:)), for: .touchUpInside)
        
        _recordButton.translatesAutoresizingMaskIntoConstraints = false
        _recordButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_nor"), for: .normal)
        _recordButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_press"), for: .highlighted)
        _recordButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_nor"), for: [.selected, .normal])
        _recordButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_press"), for: [.selected, .highlighted])
        _recordButton.setBackgroundImage(backgroundImage, for: .normal)
        _recordButton.setBackgroundImage(backgroundImage, for: .highlighted)
        _recordButton.setBackgroundImage(backgroundImage, for: [.selected, .normal])
        _recordButton.setBackgroundImage(backgroundImage, for: [.selected, .highlighted])
        _recordButton.addTarget(self, action: #selector(onRecordAndStop(_:)), for: .touchUpInside)
        
        // add subview
        addSubview(_recordButton)
        addSubview(_playButton)
        addSubview(_playToolbar)
        addSubview(_statusView)
        
        addConstraint(_SALayoutConstraintMake(_playButton, .centerX, .equal, _recordButton, .centerX))
        addConstraint(_SALayoutConstraintMake(_playButton, .centerY, .equal, _recordButton, .centerY))
        
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerX, .equal, self, .centerX))
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerY, .equal, self, .centerY, -12))
        
        addConstraint(_SALayoutConstraintMake(_playToolbar, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_playToolbar, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_playToolbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_statusView, .top, .equal, self, .top, 8))
        addConstraint(_SALayoutConstraintMake(_statusView, .bottom, .equal, _recordButton, .top, -8))
        addConstraint(_SALayoutConstraintMake(_statusView, .centerX, .equal, self, .centerX))
    }
    
    fileprivate lazy var _playButton: SAAudioPlayButton = SAAudioPlayButton()
    fileprivate lazy var _playToolbar: SAAudioPlayToolbar = SAAudioPlayToolbar()
    
    fileprivate lazy var _recordButton: SAAudioRecordButton = SAAudioRecordButton()
    
    fileprivate lazy var _status: SAAudioStatus = .none
    fileprivate lazy var _statusView: SAAudioStatusView = SAAudioStatusView()
    
    fileprivate lazy var _recordFileAtURL: URL = URL(fileURLWithPath: NSTemporaryDirectory().appending("/sa-audio-record.m3a"))
    
    fileprivate var _recorder: SAAudioRecorder?
    fileprivate var _player: SAAudioPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - Toucn Events

extension SAAudioRecordView {
    
    @objc func onCancel(_ sender: Any) {
        _logger.trace()
        // TODO: 取消
        //updateStatus(.none)
    }
    @objc func onConfirm(_ sender: Any) {
        _logger.trace()
        // TODO: 发送
        //updateStatus(.none)
    }
    @objc func onRecordAndStop(_ sender: Any) {
        _logger.trace()
        
        if let recorder = _recorder {
            recorder.stop()
        } else {
            _recorder = _makeRecorder(_recordFileAtURL)
            _recorder?.record()
        }
    }
    @objc func onPlayAndStop(_ sender: Any) {
        _logger.trace()
        
        if _player?.isPlaying ?? false {
            _player?.stop()
        } else {
            _player = _player ?? _makePlayer(_recordFileAtURL)
            _player?.currentTime = 0
            _player?.play()
        }
    }
}

// MARK: - SAAudioPlayerDelegate

extension SAAudioRecordView: SAAudioPlayerDelegate {
    
    public func player(shouldPrepareToPlay player: SAAudioPlayer) -> Bool {
        updateStatus(.waiting)
        return true
    }
    public func player(didPrepareToPlay player: SAAudioPlayer){ 
    }
    
    public func player(shouldStartPlay player: SAAudioPlayer) -> Bool {
        return true
    }
    public func player(didStartPlay player: SAAudioPlayer) {
        updateStatus(.playing)
    }
    
    public func player(didStopPlay player: SAAudioPlayer) {
        updateStatus(.processed)
    }
    
    public func player(didFinishPlay player: SAAudioPlayer) {
        updateStatus(.processed)
    }
    public func player(didInterruptionPlay player: SAAudioPlayer) {
        updateStatus(.processed)
    }
    public func player(didErrorOccur player: SAAudioPlayer, error: NSError){
        updateStatus(.error(error.localizedFailureReason ?? "Unknow error"))
    }
}

// MARK: - SAAudioRecorderDelegate

extension SAAudioRecordView: SAAudioRecorderDelegate {
    
    public func recorder(shouldPrepareToRecord recorder: SAAudioRecorder) -> Bool {
        updateStatus(.waiting)
        return true
    }
    public func recorder(didPrepareToRecord recorder: SAAudioRecorder) {
    }
    
    public func recorder(shouldStartRecord recorder: SAAudioRecorder) -> Bool {
        return true
    }
    public func recorder(didStartRecord recorder: SAAudioRecorder) {
        updateStatus(.recording)
    }
    
    public func recorder(didStopRecord recorder: SAAudioRecorder) {
        updateStatus(.processing)
    }
    public func recorder(didInterruptionRecord recorder: SAAudioRecorder) {
        updateStatus(.processed)
    }
    public func recorder(didFinishRecord recorder: SAAudioRecorder) {
        updateStatus(.processed)
    }
    public func recorder(didErrorOccur recorder: SAAudioRecorder, error: NSError) {
        _logger.trace(error)
        updateStatus(.error(error.localizedFailureReason ?? "Unknow error"))
    }
}

// MARK: - SAAudioStatusViewDelegate

extension SAAudioRecordView: SAAudioStatusViewDelegate {
    
    func statusView(_ statusView: SAAudioStatusView, spectrumViewWillUpdateMeters: SAAudioSpectrumView) {
        _updateTime()
        if _status.isPlaying {
            _player?.updateMeters()
        } else {
            _recorder?.updateMeters()
        }
    }
    
    func statusView(_ statusView: SAAudioStatusView, spectrumView: SAAudioSpectrumView, peakPowerFor channel: Int) -> Float {
        if _status.isPlaying {
            return _player?.peakPower(forChannel: 0) ?? -160
        } else {
            return _recorder?.peakPower(forChannel: 0) ?? -160
        }
    }
    func statusView(_ statusView: SAAudioStatusView, spectrumView: SAAudioSpectrumView, averagePowerFor channel: Int) -> Float {
        if _status.isPlaying {
            return _player?.averagePower(forChannel: 0) ?? -160
        } else {
            return _recorder?.averagePower(forChannel: 0) ?? -160
        }
    }
}
