//
//  SAAudioTalkbackView.swift
//  SIMChat
//
//  Created by sagesse on 9/16/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import AVFoundation

internal class SAAudioTalkbackView: SAAudioView {
    
    func updateStatus(_ status: SAAudioStatus) {
        _logger.trace(status)
        
        _status = status
        _statusView.status = status
        
        switch status {
        case .none, // 默认状态
             .error(_): // 错误状态
            
            _clearResources()
            
            // 先重置状态
            _recordToolbar.leftView.isHighlighted = false
            _recordToolbar.leftBackgroundView.isHighlighted = false
            _recordToolbar.leftBackgroundView.layer.transform = CATransform3DIdentity
            _recordToolbar.rightView.isHighlighted = false
            _recordToolbar.rightBackgroundView.isHighlighted = false
            _recordToolbar.rightBackgroundView.layer.transform = CATransform3DIdentity
            
            // 显示录音按钮
            _showRecordMode()
            
            _recordButton.isUserInteractionEnabled = true
            _recordToolbar.isHidden = true
            
        case .waiting: // 等待状态
            
            _playButton.isUserInteractionEnabled = false
            _recordButton.isUserInteractionEnabled = false
            
        case .processing: // 处理状态
            
            _playButton.isUserInteractionEnabled = false
            _recordButton.isUserInteractionEnabled = false
            _recordToolbar.isHidden = true
            
        case .recording: // 录音状态
            
            _recordToolbar.isHidden = false
            _recordToolbar.alpha = 0
            
            _updateTime()
            
            _recordButton.isUserInteractionEnabled = true
            
            _recordToolbar.transform = CGAffineTransform(scaleX: 0.5, y: 1)
            _recordToolbar.center = CGPoint(x: self.bounds.width / 2, y: _recordToolbar.center.y)
            
            UIView.animate(withDuration: 0.25) { [_recordToolbar] in
                _recordToolbar.alpha = 1
                _recordToolbar.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
        case .playing: // 播放状态
            
            _playButton.isSelected = true
            _playButton.isUserInteractionEnabled = true
            
        case .processed: // 试听状态
            
            // 显示时间
            let t = Int(_recorder?.currentTime ?? 0)
            _statusView.text = String(format: "%0d:%02d", t / 60, t % 60)
            
            _playButton.progress = 0
            _playButton.isSelected = false
            _playButton.isUserInteractionEnabled = true
            
            _showPlayMode()
        }
    }
    
    func _showPlayMode() {
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
            self._recordToolbar.alpha = 0
        }, completion: { f in 
            self._recordButton.alpha = 1
            self._recordToolbar.alpha = 1
            self._recordButton.isHidden = true
            self._recordToolbar.isHidden = true
        })
    }
    func _showRecordMode() {
        guard _recordButton.isHidden else {
            return
        }
        
        _recordButton.alpha = 0
        _recordToolbar.alpha = 0
        _recordButton.isHidden = false
        //_recordToolbar.isHidden = true
        
        UIView.animate(withDuration: 0.25, animations: {
            self._playButton.alpha = 0
            self._playToolbar.transform = CGAffineTransform(translationX: 0, y: self._playToolbar.frame.height)
            self._recordButton.alpha = 1
            self._recordToolbar.alpha = 1
        }, completion: { f in 
            self._playButton.alpha = 1
            self._playButton.isHidden = true
            self._playButton.isSelected = false
            self._playToolbar.transform = .identity
            self._playToolbar.isHidden = true
        })
    }
    
    func _clearResources() {
        _recorder?.delegate = nil
        _recorder?.stop() 
        _recorder = nil
        _player?.delegate = nil
        _player?.stop()
        _player = nil
    }
    
    
    func _updateTime() {
        if _status.isRecording {
            if _recordToolbar.leftView.isHighlighted {
                _statusView.text = "松手试听"
                _statusView.spectrumView.isHidden = true
            } else if _recordToolbar.rightView.isHighlighted {
                _statusView.text = "松手取消发送"
                _statusView.spectrumView.isHidden = true
            } else {
                let t = Int(_recorder?.currentTime ?? 0)
                _statusView.text = String(format: "%0d:%02d", t / 60, t % 60)
                _statusView.spectrumView.isHidden = false
            }
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
        
        _statusView.text = "按住说话"
        _statusView.delegate = self
        _statusView.translatesAutoresizingMaskIntoConstraints = false
        
        _recordToolbar.isHidden = true
        _recordToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let backgroundImage = UIImage(named: "aio_play_background")
        
        _playButton.isHidden = true
        _playButton.progressColor = hcolor
        _playButton.progressLineWidth = 2
        _playButton.translatesAutoresizingMaskIntoConstraints = false
        _playButton.setBackgroundImage(backgroundImage, for: .normal)
        _playButton.setBackgroundImage(backgroundImage, for: .highlighted)
        _playButton.setBackgroundImage(backgroundImage, for: [.selected, .normal])
        _playButton.setBackgroundImage(backgroundImage, for: [.selected, .highlighted])
        _playButton.setImage(UIImage(named: "aio_play_start_nor"), for: .normal)
        _playButton.setImage(UIImage(named: "aio_play_start_press"), for: .highlighted)
        _playButton.setImage(UIImage(named: "aio_play_stop_nor"), for: [.selected, .normal])
        _playButton.setImage(UIImage(named: "aio_play_stop_press"), for: [.selected, .highlighted])
        _playButton.addTarget(self, action: #selector(onPlayAndStop(_:)), for: .touchUpInside)
        
       
        _playToolbar.isHidden = true
        _playToolbar.translatesAutoresizingMaskIntoConstraints = false
        _playToolbar.cancelButton.setTitleColor(hcolor, for: .normal)
        _playToolbar.confirmButton.setTitleColor(hcolor, for: .normal)
        _playToolbar.cancelButton.addTarget(self, action: #selector(onCancel(_:)), for: .touchUpInside)
        _playToolbar.confirmButton.addTarget(self, action: #selector(onConfirm(_:)), for: .touchUpInside)
        
        _recordButton.setImage(UIImage(named: "aio_record_icon"), for: .normal)
        _recordButton.setBackgroundImage(UIImage(named: "aio_record_nor"), for: .normal)
        _recordButton.setBackgroundImage(UIImage(named: "aio_record_pres"), for: .normal)
        _recordButton.translatesAutoresizingMaskIntoConstraints = false
        _recordButton.addTarget(self, action: #selector(onTouchStart(_:)), for: .touchDown)
        _recordButton.addTarget(self, action: #selector(onTouchDrag(_:withEvent:)), for: .touchDragInside)
        _recordButton.addTarget(self, action: #selector(onTouchDrag(_:withEvent:)), for: .touchDragOutside)
        _recordButton.addTarget(self, action: #selector(onTouchStop(_:)), for: .touchUpInside)
        _recordButton.addTarget(self, action: #selector(onTouchStop(_:)), for: .touchUpOutside)
        _recordButton.addTarget(self, action: #selector(onTouchInterrupt(_:)), for: .touchCancel)
        
        // add subview
        addSubview(_recordToolbar)
        addSubview(_recordButton)
        addSubview(_playButton)
        addSubview(_playToolbar)
        addSubview(_statusView)
        
        addConstraint(_SALayoutConstraintMake(_playButton, .centerX, .equal, _recordButton, .centerX))
        addConstraint(_SALayoutConstraintMake(_playButton, .centerY, .equal, _recordButton, .centerY))
        
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerX, .equal, self, .centerX))
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerY, .equal, self, .centerY, -8))
        
        addConstraint(_SALayoutConstraintMake(_playToolbar, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_playToolbar, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_playToolbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_recordToolbar, .top, .equal, _recordButton, .top, -9))
        addConstraint(_SALayoutConstraintMake(_recordToolbar, .left, .equal, self, .left, 20))
        addConstraint(_SALayoutConstraintMake(_recordToolbar, .right, .equal, self, .right, -20))
        
        addConstraint(_SALayoutConstraintMake(_statusView, .top, .equal, self, .top, 8))
        addConstraint(_SALayoutConstraintMake(_statusView, .bottom, .equal, _recordButton, .top, -8))
        addConstraint(_SALayoutConstraintMake(_statusView, .centerX, .equal, self, .centerX))
    }
    
    fileprivate lazy var _playButton: SAAudioPlayButton = SAAudioPlayButton()
    fileprivate lazy var _playToolbar: SAAudioPlayToolbar = SAAudioPlayToolbar()
    
    fileprivate lazy var _recordButton: SAAudioRecordButton = SAAudioRecordButton()
    fileprivate lazy var _recordToolbar: SAAudioRecordToolbar = SAAudioRecordToolbar() 
    
    fileprivate lazy var _status: SAAudioStatus = .none
    fileprivate lazy var _statusView: SAAudioStatusView = SAAudioStatusView()
    
    fileprivate lazy var _recordFileAtURL: URL = URL(fileURLWithPath: NSTemporaryDirectory().appending("sa-audio-record.m3a"))
    
    fileprivate var _recorder: SAAudioRecorder?
    fileprivate var _player: SAAudioPlayer?
    fileprivate var _lastPoint: CGPoint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - Touch Events

extension SAAudioTalkbackView {
    
    @objc func onCancel(_ sender: Any) {
        _logger.trace()
        
        let duration = _recorder?.currentTime ?? 0
        let url = _recordFileAtURL
        
        updateStatus(.none)
        
        delegate?.audioView(self, didFailure: url, duration: duration)
    }
    @objc func onConfirm(_ sender: Any) {
        _logger.trace()
        
        let duration = _recorder?.currentTime ?? 0
        let url = _recordFileAtURL
        
        updateStatus(.none)
        
        delegate?.audioView(self, didComplete: url, duration: duration)
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
    
    @objc func onTouchStart(_ sender: Any) {
        guard _status.isNone || _status.isError else {
            return
        }
        _lastPoint = nil
        _recorder = _makeRecorder(_recordFileAtURL)
        _recorder?.prepareToRecord()
        
        let ani = CAKeyframeAnimation(keyPath: "transform.scale")
        ani.values = [1, 1.2, 1]
        ani.duration = 0.15
        _recordButton.layer.add(ani, forKey: "click")
    }
    @objc func onTouchStop(_ sender: Any) {
        guard _status.isRecording else {
            return
        }
        _recorder?.stop()
    }
    @objc func onTouchInterrupt(_ sender: Any) {
        guard _status.isRecording else {
            return
        }
        // 如果中断了, 认为他是选择了试听
        _recordToolbar.leftView.isHighlighted = true
        _recordToolbar.leftBackgroundView.isHighlighted = true
        _recordToolbar.leftBackgroundView.layer.transform = CATransform3DIdentity
        _recordToolbar.rightView.isHighlighted = false
        _recordToolbar.rightBackgroundView.isHighlighted = false
        _recordToolbar.rightBackgroundView.layer.transform = CATransform3DIdentity
        // 走正常结束流程
        onTouchStop(sender)
    }
    @objc func onTouchDrag(_ sender: UIButton, withEvent event: UIEvent) {
        sender.isHighlighted = true
        
        guard let touch = event.allTouches?.first, _status.isRecording else {
            return
        }
        //_logger.trace(touch.location(in: self))
        
        var hl = false
        var hr = false
        var sl = CGFloat(1.0)
        var sr = CGFloat(1.0)
        let pt = touch.location(in: _recordButton)
        
        // 检查阀值避免提交大量动画
        if let lpt = _lastPoint, fabs(sqrt(lpt.x * lpt.x + lpt.y * lpt.y) - sqrt(pt.x * pt.x + pt.y * pt.y)) < 1 {
            return
        }
        _lastPoint = pt
        if pt.x < 0 {
            // 左边
            var pt2 = touch.location(in: _recordToolbar.leftBackgroundView)
            pt2.x -= _recordToolbar.leftBackgroundView.bounds.width / 2
            pt2.y -= _recordToolbar.leftBackgroundView.bounds.height / 2
            let r = max(sqrt(pt2.x * pt2.x + pt2.y * pt2.y), 0)
            // 是否高亮
            hl = r < _recordToolbar.leftBackgroundView.bounds.width / 2
            // 计算出左边的缩放
            sl = 1.0 + min(max((100 - r) / 80, 0), 1) * 0.75
        } else if pt.x > _recordButton.bounds.width {
            // 右边
            var pt2 = touch.location(in: _recordToolbar.rightBackgroundView)
            pt2.x -= _recordToolbar.rightBackgroundView.bounds.width / 2
            pt2.y -= _recordToolbar.rightBackgroundView.bounds.height / 2
            let r = max(sqrt(pt2.x * pt2.x + pt2.y * pt2.y), 0)
            // 是否高亮
            hr = r < _recordToolbar.rightBackgroundView.bounds.width / 2
            // 计算出右边的缩放
            sr = 1.0 + min(max((100 - r) / 80, 0), 1) * 0.75
        }
        //_logger.debug("\(sl)|\(hl) => \(sr)|\(hr)")
        
        if _recordToolbar.leftView.isHighlighted != hl || _recordToolbar.rightView.isHighlighted != hr {
            _updateTime()
        }
        
        UIView.animate(withDuration: 0.25) { [_recordToolbar] in
            _recordToolbar.leftView.isHighlighted = hl
            _recordToolbar.leftBackgroundView.isHighlighted = hl
            _recordToolbar.leftBackgroundView.layer.transform = CATransform3DMakeScale(sl, sl, 1)
            _recordToolbar.rightView.isHighlighted = hr
            _recordToolbar.rightBackgroundView.isHighlighted = hr
            _recordToolbar.rightBackgroundView.layer.transform = CATransform3DMakeScale(sr, sr, 1)
        }
    }
    
}

// MARK: - SAAudioPlayerDelegate

extension SAAudioTalkbackView: SAAudioPlayerDelegate {
    
    public func player(shouldPrepareToPlay player: SAAudioPlayer) -> Bool {
        _logger.trace()
        updateStatus(.waiting)
        return true
    }
    public func player(didPrepareToPlay player: SAAudioPlayer){ 
        _logger.trace()
    }
    
    public func player(shouldStartPlay player: SAAudioPlayer) -> Bool {
        _logger.trace()
        return true
    }
    public func player(didStartPlay player: SAAudioPlayer) {
        _logger.trace()
        updateStatus(.playing)
    }
    
    public func player(didStopPlay player: SAAudioPlayer) {
        _logger.trace()
        updateStatus(.processed)
    }
    
    public func player(didFinishPlay player: SAAudioPlayer) {
        _logger.trace()
        updateStatus(.processed)
    }
    public func player(didInterruptionPlay player: SAAudioPlayer) {
        _logger.trace()
        updateStatus(.processed)
    }
    public func player(didErrorOccur player: SAAudioPlayer, error: NSError){
        _logger.trace(error)
        updateStatus(.error(error.localizedFailureReason ?? "Unknow error"))
    }
}

// MARK: - SAAudioRecorderDelegate

extension SAAudioTalkbackView: SAAudioRecorderDelegate {
    
    public func recorder(shouldPrepareToRecord recorder: SAAudioRecorder) -> Bool {
        _logger.trace()
        
        guard delegate?.audioView(self, shouldStartRecord: recorder.url) ?? true else {
            return false
        }
        updateStatus(.waiting)
        return true
    }
    public func recorder(didPrepareToRecord recorder: SAAudioRecorder) {
        _logger.trace()
        // 异步一下让系统消息有机会处理
        DispatchQueue.main.async {
            guard self._recordButton.isHighlighted else {
                return self.onCancel(recorder)
            }
            self._recorder?.record()
        }
    }
    
    public func recorder(shouldStartRecord recorder: SAAudioRecorder) -> Bool {
        _logger.trace()
        return true
    }
    public func recorder(didStartRecord recorder: SAAudioRecorder) {
        _logger.trace()
        
        delegate?.audioView(self, didStartRecord: recorder.url)
        updateStatus(.recording)
    }
    
    public func recorder(didStopRecord recorder: SAAudioRecorder) {
        _logger.trace()
        updateStatus(.processing)
    }
    public func recorder(didInterruptionRecord recorder: SAAudioRecorder) {
        _logger.trace()
        updateStatus(.processed)
    }
    public func recorder(didFinishRecord recorder: SAAudioRecorder) {
        let isplay = _recordToolbar.leftView.isHighlighted
        let iscancel = _recordToolbar.rightView.isHighlighted
        
        _logger.trace("play: \(isplay), cancel: \(iscancel)")
        
        if isplay {
            updateStatus(.processed)
        } else if iscancel {
            onCancel(recorder)
        } else {
            onConfirm(recorder)
        }
    }
    public func recorder(didErrorOccur recorder: SAAudioRecorder, error: NSError) {
        _logger.trace(error)
        updateStatus(.error(error.localizedFailureReason ?? "Unknow error"))
    }
}

// MARK: - SAAudioStatusViewDelegate

extension SAAudioTalkbackView: SAAudioStatusViewDelegate {
    
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

