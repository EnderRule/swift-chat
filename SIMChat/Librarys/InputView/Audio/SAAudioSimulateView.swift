//
//  SAAudioSimulateView.swift
//  SIMChat
//
//  Created by sagesse on 9/16/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAAudioSimulateView: SAAudioView {
    
    func updateStatus(_ status: SAAudioStatus) {
        _logger.trace(status)
        
        _status = status
        _statusView.status = status
        
        switch status {
        case .none,
             .error(_): // 错误状态
            
            if !_status.isError {
                _statusView.text = "按住变声"
            }
            
            _clearResources()
            _showRecordMode()
            
            _statusView.isHidden = false
            _recordButton.isUserInteractionEnabled = true
            
        case .waiting: // 等待状态
            
            _recordButton.isUserInteractionEnabled = false
            
        case .processing: // 处理状态
            
            _recordButton.isUserInteractionEnabled = false
            
        case .recording: // 录音状态
            
            _recordButton.isUserInteractionEnabled = true
            
        case .playing: // 播放状态
            
            break
            
        case .processed: // 试听状态
            
            _statusView.isHidden = true
//            let t = Int(_recorder?.currentTime ?? 0)
//            _statusView.text = String(format: "%0d:%02d", t / 60, t % 60)
//            
//            _playButton.progress = 0
//            _playButton.isSelected = false
//            _playButton.isUserInteractionEnabled = true
            
            _showPlayMode()
        }
    }
    
    fileprivate func _showPlayMode() {
        guard _simulateView.isHidden else {
            return
        }
        _logger.trace()
        
        
        _simulateView.isHidden = false
        _simulateView.alpha = 0
        _playToolbar.isHidden = false
        _playToolbar.transform = CGAffineTransform(translationX: 0, y: _playToolbar.frame.height)
        
        UIView.animate(withDuration: 0.25, animations: {
            self._simulateView.alpha = 1
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
        _logger.trace()
        
        _recordButton.alpha = 0
        _recordButton.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self._simulateView.alpha = 0
            self._playToolbar.transform = CGAffineTransform(translationX: 0, y: self._playToolbar.frame.height)
            self._recordButton.alpha = 1
        }, completion: { f in
            self._simulateView.alpha = 1
            self._simulateView.isHidden = true
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
//        if _status.isPlaying {
//            let d = TimeInterval(_recorder?.currentTime ?? 0)
//            let ct = TimeInterval(_player?.currentTime ?? 0)
//            
//            //_playButton.setProgress(CGFloat(ct + 0.2) / CGFloat(d), animated: true)
//            
//            _statusView.text = String(format: "%0d:%02d", Int(ct) / 60, Int(ct) % 60)
//            _statusView.spectrumView.isHidden = false
//            return
//        }
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
        
        _statusView.text = "按住变声"
        _statusView.delegate = self
        _statusView.translatesAutoresizingMaskIntoConstraints = false
        
        _simulateViewLayout.itemSize = CGSize(width: 80, height: 80)
        _simulateViewLayout.minimumLineSpacing = 12
        _simulateViewLayout.minimumInteritemSpacing = 12
        
        _simulateView.isHidden = true
        _simulateView.backgroundColor = .clear
        _simulateView.translatesAutoresizingMaskIntoConstraints = false
        _simulateView.delegate = self
        _simulateView.dataSource = self
        _simulateView.allowsSelection = false
        _simulateView.allowsMultipleSelection = false
        _simulateView.register(SAAudioEffectView.self, forCellWithReuseIdentifier: "Item")
        _simulateView.showsVerticalScrollIndicator = false
        _simulateView.showsHorizontalScrollIndicator = false
        _simulateView.contentInset = UIEdgeInsetsMake(18, 10, 18 + 44, 10)
        
        _playToolbar.isHidden = true
        _playToolbar.translatesAutoresizingMaskIntoConstraints = false
        _playToolbar.cancelButton.setTitleColor(hcolor, for: .normal)
        _playToolbar.confirmButton.setTitleColor(hcolor, for: .normal)
        _playToolbar.cancelButton.addTarget(self, action: #selector(onCancel(_:)), for: .touchUpInside)
        _playToolbar.confirmButton.addTarget(self, action: #selector(onConfirm(_:)), for: .touchUpInside)
        
        _recordButton.translatesAutoresizingMaskIntoConstraints = false
        _recordButton.setBackgroundImage(UIImage(named: "aio_simulate_icon"), for: .normal)
        _recordButton.addTarget(self, action: #selector(onTouchStart(_:)), for: .touchDown)
        _recordButton.addTarget(self, action: #selector(onTouchDrag(_:withEvent:)), for: .touchDragInside)
        _recordButton.addTarget(self, action: #selector(onTouchDrag(_:withEvent:)), for: .touchDragOutside)
        _recordButton.addTarget(self, action: #selector(onTouchStop(_:)), for: .touchUpInside)
        _recordButton.addTarget(self, action: #selector(onTouchStop(_:)), for: .touchUpOutside)
        _recordButton.addTarget(self, action: #selector(onTouchStop(_:)), for: .touchCancel)
        
        // add subview
        addSubview(_recordButton)
        addSubview(_statusView)
        addSubview(_simulateView)
        addSubview(_playToolbar)
        
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerX, .equal, self, .centerX))
        addConstraint(_SALayoutConstraintMake(_recordButton, .centerY, .equal, self, .centerY, -8))
        
        addConstraint(_SALayoutConstraintMake(_simulateView, .top, .equal, self, .top))
        addConstraint(_SALayoutConstraintMake(_simulateView, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_simulateView, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_simulateView, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_playToolbar, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_playToolbar, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_playToolbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_statusView, .top, .equal, self, .top, 8))
        addConstraint(_SALayoutConstraintMake(_statusView, .bottom, .equal, _recordButton, .top, -8))
        addConstraint(_SALayoutConstraintMake(_statusView, .centerX, .equal, self, .centerX))
    }
    
    fileprivate lazy var _supportEffects: [SAAudioEffect] = [
        SAAudioEffect(type: .original),
        SAAudioEffect(type: .ef1),
        SAAudioEffect(type: .ef2),
        SAAudioEffect(type: .ef3),
        SAAudioEffect(type: .ef4),
        SAAudioEffect(type: .ef5),
    ]
    
    
    fileprivate lazy var _simulateViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    fileprivate lazy var _simulateView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._simulateViewLayout)
    
    fileprivate lazy var _playToolbar: SAAudioPlayToolbar = SAAudioPlayToolbar()
    
    fileprivate lazy var _recordButton: SAAudioRecordButton = SAAudioRecordButton()
    
    fileprivate lazy var _status: SAAudioStatus = .none
    fileprivate lazy var _statusView: SAAudioStatusView = SAAudioStatusView()
    
    fileprivate lazy var _recordFileAtURL: URL = URL(fileURLWithPath: NSTemporaryDirectory().appending("sa-audio-record.m3a"))
    
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

extension SAAudioSimulateView {
    
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
    @objc func onTouchDrag(_ sender: UIButton, withEvent event: UIEvent) {
        sender.isHighlighted = true
    }
}

extension SAAudioSimulateView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _supportEffects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAAudioEffectView else {
            return
        }
        cell.effect = _supportEffects[indexPath.item]
    }
}

// MARK: - SAAudioPlayerDelegate

extension SAAudioSimulateView: SAAudioPlayerDelegate {
    
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

extension SAAudioSimulateView: SAAudioRecorderDelegate {
    
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
                // 不能直接调用onCancel, 因为没有启动就没有失败
                return self.updateStatus(.none)
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
        _logger.trace()
        updateStatus(.processed)
    }
    public func recorder(didErrorOccur recorder: SAAudioRecorder, error: NSError) {
        _logger.trace(error)
        updateStatus(.error(error.localizedFailureReason ?? "Unknow error"))
    }
}

// MARK: - SAAudioStatusViewDelegate

extension SAAudioSimulateView: SAAudioStatusViewDelegate {
    
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
