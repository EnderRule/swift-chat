//
//  SAAudioTalkbackView.swift
//  SIMChat
//
//  Created by sagesse on 9/16/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import AVFoundation



internal enum SAAudioTalkbackStatus: CustomStringConvertible {
    
    case none
    case waiting
    case recording(SAAudioRecorder)
    case processing(URL)
    case processed(URL)
    case playing(AVAudioPlayer)
    case error(String)
    
    
    var isNone: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
    var isWaiting: Bool {
        switch self {
        case .waiting: return true
        default: return false
        }
    }
    var isRecording: Bool {
        switch self {
        case .recording(_): return true
        default: return false
        }
    }
    var isProcessing: Bool {
        switch self {
        case .processing(_): return true
        default: return false
        }
    }
    var isProcessed: Bool {
        switch self {
        case .processed(_): return true
        default: return false
        }
    }
    var isPlaying: Bool {
        switch self {
        case .playing(_): return true
        default: return false
        }
    }
    var isError: Bool {
        switch self {
        case .error(_): return true
        default: return false
        }
    }
    
    var description: String {
        switch self {
        case .none: return "None"
        case .waiting: return "Waiting"
        case .recording(_): return "Recording"
        case .processing(_): return "Processing"
        case .processed(_): return "Processed"
        case .playing(_): return "Playing"
        case .error(let e): return "Error(\(e))"
        }
    }
}

internal class SAAudioTalkbackView: SAAudioView {
    
    private func _init() {
        _logger.trace()
        
        _recordToolbar.isHidden = true
        _recordToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        _tipsLabel.text = "按住说话"
        _tipsLabel.font = UIFont.systemFont(ofSize: 16)
        _tipsLabel.textColor = .gray
        _tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        _activityView.isHidden = true
        _activityView.hidesWhenStopped = true
        _activityView.translatesAutoresizingMaskIntoConstraints = false
        
        _spectrumView.isHidden = true
        _spectrumView.dataSource = self
        _spectrumView.translatesAutoresizingMaskIntoConstraints = false
        
        _playButton.isHidden = true
        _playButton.translatesAutoresizingMaskIntoConstraints = false
        _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_nor"), for: .normal)
        _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_press"), for: .highlighted)
        _playButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_background"), for: .normal)
        _playButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_background"), for: .highlighted)
        
        _playButton.addTarget(self, action: #selector(onPlayAndStop(_:)), for: .touchUpInside)
        
        let nbounds = CGRect(origin: .zero, size: _playButton.intrinsicContentSize)
        
        _playProgress.lineWidth = 3.5
        _playProgress.fillColor = nil
        _playProgress.strokeColor = UIColor.blue.cgColor
        _playProgress.strokeStart = 0
        _playProgress.strokeEnd = 1
        _playProgress.frame = nbounds
        _playProgress.path = UIBezierPath(ovalIn: nbounds).cgPath
        _playProgress.transform = CATransform3DMakeRotation((-90 / 180) * CGFloat(M_PI), 0, 0, 1)
        _playButton.layer.addSublayer(_playProgress)
        
        _playToolbar.isHidden = true
        _playToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        _playToolbar.cancelButton.addTarget(self, action: #selector(onCancel(_:)), for: .touchUpInside)
        _playToolbar.confirmButton.addTarget(self, action: #selector(onConfirm(_:)), for: .touchUpInside)
        
        _recordButton.setImage(UIImage(named: "simchat_keyboard_voice_icon_record"), for: .normal)
        _recordButton.setImage(UIImage(named: "simchat_keyboard_voice_icon_record"), for: .highlighted)
        _recordButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_button_nor"), for: .normal)
        _recordButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_button_press"), for: .highlighted)
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
        addSubview(_tipsLabel)
        addSubview(_activityView)
        addSubview(_spectrumView)
        
        addConstraint(_SALayoutConstraintMake(_playButton, .centerX, .equal, _recordButton, .centerX))
        addConstraint(_SALayoutConstraintMake(_playButton, .centerY, .equal, _recordButton, .centerY))
        
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerX, .equal, self, .centerX))
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerY, .equal, self, .centerY, -12))
        
        addConstraint(_SALayoutConstraintMake(_playToolbar, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_playToolbar, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_playToolbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_recordToolbar, .top, .equal, _recordButton, .top, -9))
        addConstraint(_SALayoutConstraintMake(_recordToolbar, .left, .equal, self, .left, 20))
        addConstraint(_SALayoutConstraintMake(_recordToolbar, .right, .equal, self, .right, -20))
        
        addConstraint(_SALayoutConstraintMake(_tipsLabel, .top, .equal, self, .top, 8))
        addConstraint(_SALayoutConstraintMake(_tipsLabel, .bottom, .equal, _recordButton, .top, -8))
        addConstraint(_SALayoutConstraintMake(_tipsLabel, .centerX, .equal, self, .centerX))
        
        addConstraint(_SALayoutConstraintMake(_activityView, .left, .equal, _tipsLabel, .left))
        addConstraint(_SALayoutConstraintMake(_activityView, .centerY, .equal, _tipsLabel, .centerY))
        addConstraint(_SALayoutConstraintMake(_spectrumView, .centerX, .equal, _tipsLabel, .centerX))
        addConstraint(_SALayoutConstraintMake(_spectrumView, .centerY, .equal, _tipsLabel, .centerY))
    }
    
    fileprivate lazy var _recordButton: UIButton = UIButton()
    fileprivate lazy var _recordToolbar: SAAudioRecordToolbar = SAAudioRecordToolbar() 
    
    fileprivate lazy var _playButton: UIButton = UIButton()
    fileprivate lazy var _playToolbar: SAAudioPlayToolbar = SAAudioPlayToolbar()
    fileprivate lazy var _playProgress: CAShapeLayer = CAShapeLayer()
    
    fileprivate lazy var _tipsLabel: UILabel = UILabel()
    fileprivate lazy var _spectrumView: SAAudioSpectrumView = SAAudioSpectrumView()
    fileprivate lazy var _activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    fileprivate var _recorder: SAAudioRecorder?
    fileprivate var _status: SAAudioTalkbackStatus = .none
    
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
    
    @objc func onCancel(_ sender: UIButton) {
        updateStatus(.none)
    }
    @objc func onConfirm(_ sender: UIButton) {
        updateStatus(.none)
    }
    @objc func onPlayAndStop(_ sender: UIButton) {
        _logger.trace()
    }
    
    @objc func onTouchStart(_ sender: UIButton) {
        guard _status.isNone || _status.isError else {
            return
        }
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory().appending("/sa-audio-record.m3a"))
        let recorder = SAAudioRecorder(url: url)
        
        recorder.delegate = self
        recorder.prepareToRecord()
        
        _recorder = recorder
    }
    @objc func onTouchStop(_ sender: UIButton) {
        guard _status.isRecording else {
            return
        }
        let isPlay = _recordToolbar.leftView.isHighlighted
        let isCancel = _recordToolbar.rightView.isHighlighted
        
        _logger.trace("isPlay: \(isPlay), isCancel: \(isCancel)")
        
        if isCancel {
            // 取消的话直接重置就好了
            updateStatus(.none)
            return
        }
        guard let url = _recorder?.url else {
            // 出错了
            updateStatus(.error("文件丢失"))
            return
        }
        // 记住用记的选择
        updateStatus(.processing(url))
    }
    @objc func onTouchInterrupt(_ sender: UIButton) {
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
        
        guard let touch = event.allTouches?.first else {
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
    
    func updateStatus(_ status: SAAudioTalkbackStatus) {
        _logger.trace(status)
        
        _status = status
        
        if let scrollView = superview as? UIScrollView {
            scrollView.isScrollEnabled = status.isNone || status.isError
        }
        
        switch status {
        case .none:
            // 进入默认状态
            
            _lastPoint = nil
            _recorder?.delegate = nil
            _recorder?.stop() 
            _recorder = nil
            
            _recordToolbar.isHidden = true
            _tipsLabel.text = "按住说话"
            _activityView.isHidden = true
            _activityView.stopAnimating()
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _recordButton.isUserInteractionEnabled = true
            
            _showRecordMode()
            
        case .waiting:
            // 进入等待状态
            
            _recordToolbar.isHidden = true
            _tipsLabel.attributedText = _makeTips("准备中", _activityView.bounds)
            _spectrumView.isHidden = true
            _activityView.isHidden = false
            _activityView.startAnimating()
            
            _recordButton.isUserInteractionEnabled = false
            
            break
        case .recording(let recorder):
            // 进入录音状态
            
            _recorder = recorder
            _recorder?.isMeteringEnabled = true
            _recorder?.record()
            
            _recordToolbar.isHidden = false
            _recordToolbar.alpha = 0
            
            _tipsLabel.text = "00:00"
            _activityView.isHidden = true
            _spectrumView.isHidden = false
            _spectrumView.startAnimating()
            
            _updateTime()
            _recordButton.isUserInteractionEnabled = true
            
            // 先重置状态
            _recordToolbar.leftView.isHighlighted = false
            _recordToolbar.leftBackgroundView.isHighlighted = false
            _recordToolbar.leftBackgroundView.layer.transform = CATransform3DIdentity
            _recordToolbar.rightView.isHighlighted = false
            _recordToolbar.rightBackgroundView.isHighlighted = false
            _recordToolbar.rightBackgroundView.layer.transform = CATransform3DIdentity
            
            UIView.animate(withDuration: 0.25) { [_recordToolbar] in
                _recordToolbar.alpha = 1
            }
            
        case .processing(_):
            // 进入处理状态
            
            _recorder?.stop()
            
            _recordToolbar.isHidden = true
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _tipsLabel.attributedText = _makeTips("处理中", _activityView.bounds)
            _activityView.isHidden = false
            _activityView.startAnimating()
            
            _recordButton.isUserInteractionEnabled = false
            
        case .processed(_):
            // 处理完成
            
            let t = Int(_recorder?.currentTime ?? 0)
            _tipsLabel.text = String(format: "%0d:%02d", t / 60, t % 60)
            _activityView.isHidden = true
            _spectrumView.isHidden = false
            
            _showPlayMode()
            
        case .playing(_):
            // 播放中
            
            _recordButton.isHidden = true
            _recordToolbar.isHidden = true
            _playButton.isHidden = false
            _playToolbar.isHidden = false
            
        case .error(let err):
            // 进入错误状态
            
            _recorder?.delegate = nil
            _recorder?.stop() 
            _recorder = nil
            
            _recordToolbar.isHidden = true
            _tipsLabel.text = err
            _tipsLabel.isHidden = false
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            _activityView.isHidden = true
            _activityView.stopAnimating()
            
            _showRecordMode()
            _recordButton.isUserInteractionEnabled = true
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
            self._playToolbar.transform = .identity
            self._playToolbar.isHidden = true
        })
    }
    
    fileprivate func _updateTime() {
        guard _status.isRecording else {
            return
        }
        
        if _recordToolbar.leftView.isHighlighted {
            _tipsLabel.text = "松手试听"
            _spectrumView.isHidden = true
        } else if _recordToolbar.rightView.isHighlighted {
            _tipsLabel.text = "松手取消发送"
            _spectrumView.isHidden = true
        } else {
            let t = Int(_recorder?.currentTime ?? 0)
            _tipsLabel.text = String(format: "%0d:%02d", t / 60, t % 60)
            _spectrumView.isHidden = false
        }
    }
    fileprivate func _makeTips(_ str: String, _ bounds: CGRect? = nil) -> NSAttributedString {
        let mas = NSMutableAttributedString(string: str)
        if let bounds = bounds {
            let at = NSTextAttachment()
            at.bounds = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 0, bounds.height, -8))
            mas.insert(NSAttributedString(attachment: at), at: 0)
        }
        return mas
    }
}

// MARK: - SAAudioRecorderDelegate

extension SAAudioTalkbackView: SAAudioRecorderDelegate {
    
    public func recorder(shouldPrepareToRecord recorder: SAAudioRecorder) -> Bool {
        updateStatus(.waiting)
        return true
    }
    public func recorder(didPrepareToRecord recorder: SAAudioRecorder) {
        guard _recordButton.isHighlighted else {
            return updateStatus(.none)
        }
        updateStatus(.recording(recorder))
    }
    
    public func recorder(shouldStartRecord recorder: SAAudioRecorder) -> Bool {
        // not thing
        return true
    }
    public func recorder(didStartRecord recorder: SAAudioRecorder) {
        // not thing
        _logger.trace()
    }
    
    public func recorder(didStopRecord recorder: SAAudioRecorder) {
        _logger.trace()
        // not thing
    }
    public func recorder(didFinish recorder: SAAudioRecorder) {
        _logger.trace()
        //updateStatus(.none)
        
        updateStatus(.processed(recorder.url))
    }
    public func recorder(didErrorOccur recorder: SAAudioRecorder, error: NSError) {
        _logger.trace(error)
        
        updateStatus(.error(error.localizedFailureReason ?? "Unknow error"))
    }
}

// MARK: - SAAudioSpectrumViewDataSource

extension SAAudioTalkbackView: SAAudioSpectrumViewDataSource {
    
    func spectrumView(willUpdateMeters spectrumView: SAAudioSpectrumView) {
        _recorder?.updateMeters()
        _updateTime()
    }
    func spectrumView(_ spectrumView: SAAudioSpectrumView, peakPowerFor channel: Int) -> Float {
        return _recorder?.peakPower(forChannel: 0) ?? -160
    }
    func spectrumView(_ spectrumView: SAAudioSpectrumView, averagePowerFor channel: Int) -> Float {
        return _recorder?.averagePower(forChannel: 0) ?? -160
    }
}

