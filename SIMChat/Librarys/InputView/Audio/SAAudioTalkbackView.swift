//
//  SAAudioTalkbackView.swift
//  SIMChat
//
//  Created by sagesse on 9/16/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAAudioTalkbackView: SAAudioView {
    
    private func _init() {
        _logger.trace()
        
        _toolbar.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerX, .equal, self, .centerX))
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerY, .equal, self, .centerY, -12))
        
        addConstraint(_SALayoutConstraintMake(_toolbar, .top, .equal, _recordButton, .top, -9))
        addConstraint(_SALayoutConstraintMake(_toolbar, .left, .equal, self, .left, 20))
        addConstraint(_SALayoutConstraintMake(_toolbar, .right, .equal, self, .right, -20))
    }
    
    private lazy var _toolbar: SAAudioTalkbackToolbar = SAAudioTalkbackToolbar() 
    private lazy var _recordButton: UIButton = UIButton()
    
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
        _logger.trace()
        
//        guard let panel = panel , _state.isNone() || _state.isError() else {
//            return
//        }
//        // 请求一个录音器
//        guard let recorder = delegate?.inputPanelAudioRecorder(panel, resource: _temporaryAudioRecordResource()) else {
//            return
//        }
//        SIMLog.trace()
//        
//        // 进入等待状态
//        _recorder = recorder
//        _recorder?.delegate = self
//        _state = .waiting
//        _lastPoint = nil
//        
//        // 直接开始. 如果失败了, 通过回调知之
//        recorder.record()
    }
    @objc func onTouchStop(_ sender: UIButton) {
        _logger.trace()
        
//        guard let panel = panel, let recorder = _recorder , _state.isRecording() else {
//            return
//        }
//        SIMLog.trace()
//        
//        let isCancel = _rightView.isHighlighted
//        // 关掉操作响应
//        _recordButton.isUserInteractionEnabled = false
//        // 检查用户选择
//        if !isCancel && delegate?.inputPanelShouldSendAudio(panel, resource: recorder.resource, duration: recorder.currentTime) ?? true {
//            _confirm = !_leftView.isHighlighted
//            _recorder?.stop()
//        } else {
//            _recorder?.cancel()
//        }
    }
    @objc func onTouchDrag(_ sender: UIButton, withEvent event: UIEvent) {
        _logger.trace()
        
//        // 必须要一直维持高亮
//        sender.isHighlighted = true
//        
//        guard let touch = event?.allTouches?.first , _state.isRecording() else {
//            return
//        }
//        //SIMLog.trace(touch.locationInView(self))
//        var hl = false
//        var hr = false
//        var sl = CGFloat(1.0)
//        var sr = CGFloat(1.0)
//        let pt = touch.location(in: _recordButton)
//        
//        // 检查阀值避免提交大量动画
//        if let lpt = _lastPoint , fabs(sqrt(lpt.x * lpt.x + lpt.y * lpt.y) - sqrt(pt.x * pt.x + pt.y * pt.y)) < 1 {
//            return
//        }
//        _lastPoint = pt
//        if pt.x < 0 {
//            // 左边
//            var pt2 = touch.location(in: _leftBackgroundView)
//            pt2.x -= _leftBackgroundView.bounds.width / 2
//            pt2.y -= _leftBackgroundView.bounds.height / 2
//            let r = max(sqrt(pt2.x * pt2.x + pt2.y * pt2.y), 0)
//            // 是否高亮
//            hl = r < _leftBackgroundView.bounds.width / 2
//            // 计算出左边的缩放
//            sl = 1.0 + max((80 - r) / 80, 0) * 0.75
//        } else if pt.x > _recordButton.bounds.width {
//            // 右边
//            var pt2 = touch.location(in: _rightBackgroundView)
//            pt2.x -= _rightBackgroundView.bounds.width / 2
//            pt2.y -= _rightBackgroundView.bounds.height / 2
//            let r = max(sqrt(pt2.x * pt2.x + pt2.y * pt2.y), 0)
//            // 是否高亮
//            hr = r < _rightBackgroundView.bounds.width / 2
//            // 计算出右边的缩放
//            sr = 1.0 + max((80 - r) / 80, 0) * 0.75
//        }
//        UIView.animate(withDuration: 0.25) {
//            self._leftView.isHighlighted = hl
//            self._leftBackgroundView.isHighlighted = hl
//            self._leftBackgroundView.layer.transform = CATransform3DMakeScale(sl, sl, 1)
//            self._rightView.isHighlighted = hr
//            self._rightBackgroundView.isHighlighted = hr
//            self._rightBackgroundView.layer.transform = CATransform3DMakeScale(sr, sr, 1)
//            self._state = .recording
//        }
    }
    @objc func onTouchInterrupt(_ sender: UIButton) {
        _logger.trace()
        
//        guard _state.isRecording() else {
//            return
//        }
//        SIMLog.trace()
//        // 如果中断了, 认为他是选择了试听
//        _leftView.isHighlighted = true
//        _leftBackgroundView.isHighlighted = true
//        _leftBackgroundView.layer.transform = CATransform3DIdentity
//        _rightView.isHighlighted = false
//        _rightBackgroundView.isHighlighted = false
//        _rightBackgroundView.layer.transform = CATransform3DIdentity
//        // 走正常结束流程
//        onTouchStop(sender)
    }
}
