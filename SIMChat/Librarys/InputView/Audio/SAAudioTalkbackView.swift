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
    case recording(AVAudioRecorder)
    case processing(URL)
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
        case .error(let e): return "Error(\(e))"
        }
    }
}

internal class SAAudioTalkbackView: SAAudioView {
    
    private func _init() {
        _logger.trace()
        
        _toolbar.isHidden = true
        _toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        _tipsLabel.text = "按住说话"
        _tipsLabel.font = UIFont.systemFont(ofSize: 16)
        _tipsLabel.textColor = .gray
        _tipsLabel.isHidden = false
        _tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        _activityView.isHidden = true
        _activityView.hidesWhenStopped = true
        _activityView.translatesAutoresizingMaskIntoConstraints = false
        
        _spectrumView.isHidden = true
        _spectrumView.dataSource = self
        _spectrumView.translatesAutoresizingMaskIntoConstraints = false
        
        _recordButton.setImage(UIImage(named: "simchat_keyboard_voice_icon_record"), for: .normal)
        _recordButton.setImage(UIImage(named: "simchat_keyboard_voice_icon_record"), for: .highlighted)
        _recordButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_button_nor"), for: .normal)
        _recordButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_button_press"), for: .highlighted)
        _recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        // add events
        _recordButton.addTarget(self, action: #selector(onTouchStart(_:)), for: .touchDown)
        _recordButton.addTarget(self, action: #selector(onTouchDrag(_:withEvent:)), for: .touchDragInside)
        _recordButton.addTarget(self, action: #selector(onTouchDrag(_:withEvent:)), for: .touchDragOutside)
        _recordButton.addTarget(self, action: #selector(onTouchStop(_:)), for: .touchUpInside)
        _recordButton.addTarget(self, action: #selector(onTouchStop(_:)), for: .touchUpOutside)
        _recordButton.addTarget(self, action: #selector(onTouchInterrupt(_:)), for: .touchCancel)
        
        // add subview
        addSubview(_toolbar)
        addSubview(_recordButton)
        addSubview(_tipsLabel)
        addSubview(_activityView)
        addSubview(_spectrumView)
        
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerX, .equal, self, .centerX))
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerY, .equal, self, .centerY, -12))
        
        addConstraint(_SALayoutConstraintMake(_toolbar, .top, .equal, _recordButton, .top, -9))
        addConstraint(_SALayoutConstraintMake(_toolbar, .left, .equal, self, .left, 20))
        addConstraint(_SALayoutConstraintMake(_toolbar, .right, .equal, self, .right, -20))
        
        addConstraint(_SALayoutConstraintMake(_tipsLabel, .centerX, .equal, self, .centerX))
        addConstraint(_SALayoutConstraintMake(_tipsLabel, .bottom, .equal, _recordButton, .top, -20))
        addConstraint(_SALayoutConstraintMake(_activityView, .left, .equal, _tipsLabel, .left))
        addConstraint(_SALayoutConstraintMake(_activityView, .centerY, .equal, _tipsLabel, .centerY))
        addConstraint(_SALayoutConstraintMake(_spectrumView, .centerX, .equal, _tipsLabel, .centerX))
        addConstraint(_SALayoutConstraintMake(_spectrumView, .centerY, .equal, _tipsLabel, .centerY))
    }
    
    fileprivate lazy var _toolbar: SAAudioTalkbackToolbar = SAAudioTalkbackToolbar() 
    fileprivate lazy var _recordButton: UIButton = UIButton()
    
    
    fileprivate lazy var _tipsLabel: UILabel = UILabel()
    fileprivate lazy var _spectrumView: SAAudioSpectrumView = SAAudioSpectrumView()
    fileprivate lazy var _activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    fileprivate var _recorder: AVAudioRecorder?
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
    
    @objc func onTouchStart(_ sender: UIButton) {
        guard _status.isNone || _status.isError else {
            return
        }
        
        updateStatus(.waiting)
        audio?.requestRecordPermission { hasPermission in 
            guard hasPermission else {
                // 并没有权限
                return self.updateStatus(.error("没有权限"))
            }
            guard sender.isHighlighted else {
                // 用户取消操作
                return self.updateStatus(.none)
            }
            let path = NSTemporaryDirectory().appending("/sa-audio-record.m3a")
            guard let recorder = self.audio?.recorder(at: URL(fileURLWithPath: path)) else {
                // 创建失败
                return self.updateStatus(.error("创建失败"))
            }
            guard recorder.prepareToRecord() else {
                // 未准备就绪
                return self.updateStatus(.error("准备失败"))
            }
            self.updateStatus(.recording(recorder))
        }
    }
    @objc func onTouchStop(_ sender: UIButton) {
        guard _status.isRecording else {
            return
        }
        let isPlay = _toolbar.leftView.isHighlighted
        let isCancel = _toolbar.rightView.isHighlighted
        
        _logger.trace("isPlay: \(isPlay), isCancel: \(isCancel)")
        
        if let url = _recorder?.url {
            self.updateStatus(.processing(url))
            dispatch_after_at_now(1, .main) { 
                self.updateStatus(.none)
            }
        } else {
            updateStatus(.none)
        }
        
//        // 检查用户选择
//        if !isCancel && delegate?.inputPanelShouldSendAudio(panel, resource: recorder.resource, duration: recorder.currentTime) ?? true {
//            _confirm = !_leftView.isHighlighted
//            _recorder?.stop()
//        } else {
//            _recorder?.cancel()
//        }
    }
    @objc func onTouchInterrupt(_ sender: UIButton) {
        guard _status.isRecording else {
            return
        }
        // 如果中断了, 认为他是选择了试听
        _toolbar.leftView.isHighlighted = true
        _toolbar.leftBackgroundView.isHighlighted = true
        _toolbar.leftBackgroundView.layer.transform = CATransform3DIdentity
        _toolbar.rightView.isHighlighted = false
        _toolbar.rightBackgroundView.isHighlighted = false
        _toolbar.rightBackgroundView.layer.transform = CATransform3DIdentity
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
            var pt2 = touch.location(in: _toolbar.leftBackgroundView)
            pt2.x -= _toolbar.leftBackgroundView.bounds.width / 2
            pt2.y -= _toolbar.leftBackgroundView.bounds.height / 2
            let r = max(sqrt(pt2.x * pt2.x + pt2.y * pt2.y), 0)
            // 是否高亮
            hl = r < _toolbar.leftBackgroundView.bounds.width / 2
            // 计算出左边的缩放
            sl = 1.0 + max((80 - r) / 80, 0) * 0.75
        } else if pt.x > _recordButton.bounds.width {
            // 右边
            var pt2 = touch.location(in: _toolbar.rightBackgroundView)
            pt2.x -= _toolbar.rightBackgroundView.bounds.width / 2
            pt2.y -= _toolbar.rightBackgroundView.bounds.height / 2
            let r = max(sqrt(pt2.x * pt2.x + pt2.y * pt2.y), 0)
            // 是否高亮
            hr = r < _toolbar.rightBackgroundView.bounds.width / 2
            // 计算出右边的缩放
            sr = 1.0 + max((80 - r) / 80, 0) * 0.75
        }
        //_logger.debug("\(sl)|\(hl) => \(sr)|\(hr)")
        
        if _toolbar.leftView.isHighlighted != hl || _toolbar.rightView.isHighlighted != hr {
            _updateTime()
        }
        
        UIView.animate(withDuration: 0.25) { [_toolbar] in
            _toolbar.leftView.isHighlighted = hl
            _toolbar.leftBackgroundView.isHighlighted = hl
            _toolbar.leftBackgroundView.layer.transform = CATransform3DMakeScale(sl, sl, 1)
            _toolbar.rightView.isHighlighted = hr
            _toolbar.rightBackgroundView.isHighlighted = hr
            _toolbar.rightBackgroundView.layer.transform = CATransform3DMakeScale(sr, sr, 1)
        }
    }
    
    func updateStatus(_ status: SAAudioTalkbackStatus) {
        _logger.trace(status)
        
        _status = status
        
        switch status {
        case .none:
            // 进入默认状态
            
            _lastPoint = nil
            _recorder?.stop()
            _recorder = nil
            
            _toolbar.isHidden = true
            _tipsLabel.text = "按住说话"
            _tipsLabel.isHidden = false
            _activityView.isHidden = true
            _activityView.stopAnimating()
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _recordButton.isUserInteractionEnabled = true
            
            break
        case .waiting:
            // 进入等待状态
            
            _toolbar.isHidden = true
            _tipsLabel.attributedText = _makeTips("准备中", _activityView.bounds)
            _tipsLabel.isHidden = false
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
            
            _toolbar.isHidden = false
            _toolbar.alpha = 0
            _tipsLabel.text = "00:00"
            _tipsLabel.isHidden = false
            _activityView.isHidden = true
            _spectrumView.isHidden = false
            _spectrumView.startAnimating()
            
            _updateTime()
            _recordButton.isUserInteractionEnabled = true
            
            // 先重置状态
            _toolbar.leftView.isHighlighted = false
            _toolbar.leftBackgroundView.isHighlighted = false
            _toolbar.leftBackgroundView.layer.transform = CATransform3DIdentity
            _toolbar.rightView.isHighlighted = false
            _toolbar.rightBackgroundView.isHighlighted = false
            _toolbar.rightBackgroundView.layer.transform = CATransform3DIdentity
            
            UIView.animate(withDuration: 0.25, animations: { [_toolbar] in
                _toolbar.alpha = 1
            },
            completion: { _ in
                _toolbar.alpha = 1
                _toolbar.hidden = false
            })
            
        case .processing(_):
            // 进入处理状态
            
            _toolbar.isHidden = true
            _tipsLabel.attributedText = _makeTips("处理中", _activityView.bounds)
            _tipsLabel.isHidden = false
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            _activityView.isHidden = false
            _activityView.startAnimating()
            
            _recordButton.isUserInteractionEnabled = false
            
        case .error(let err):
            // 进入错误状态
            
            _toolbar.isHidden = true
            _tipsLabel.text = err
            _tipsLabel.isHidden = false
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            _activityView.isHidden = true
            _activityView.stopAnimating()
            
            _recordButton.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func _updateTime() {
        guard _status.isRecording else {
            return
        }
        
        if _toolbar.leftView.isHighlighted {
            _tipsLabel.text = "松手试听"
            _spectrumView.isHidden = true
        } else if _toolbar.rightView.isHighlighted {
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
            at.bounds = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 0, 0, -8))
            mas.insert(NSAttributedString(attachment: at), at: 0)
        }
        return mas
    }
}

// MARK: - AVAudioRecorderDelegate

extension SAAudioTalkbackView: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        _logger.trace(flag)
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        _logger.trace(error)
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

