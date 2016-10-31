//
//  SAAudioEffectView.swift
//  SIMChat
//
//  Created by sagesse on 9/19/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal protocol SAAudioEffectViewDelegate: NSObjectProtocol {
    
    func audioEffectView(_ audioEffectView: SAAudioEffectView, shouldSelectItem audioEffect: SAAudioEffect) -> Bool
    func audioEffectView(_ audioEffectView: SAAudioEffectView, didSelectItem audioEffect: SAAudioEffect)
    
    func audioEffectViewGetCurrentTime(_ audioEffectView: SAAudioEffectView) -> TimeInterval
    func audioEffectViewGetProgress(_ audioEffectView: SAAudioEffectView) -> CGFloat
    
    func audioEffectView(_ audioEffectView: SAAudioEffectView, spectrumView: SAAudioSpectrumMiniView, peakPowerFor channel: Int) -> Float
    func audioEffectView(_ audioEffectView: SAAudioEffectView, spectrumView: SAAudioSpectrumMiniView, averagePowerFor channel: Int) -> Float
    
    func audioEffectView(_ audioEffectView: SAAudioEffectView, spectrumViewWillUpdateMeters: SAAudioSpectrumMiniView)
    func audioEffectView(_ audioEffectView: SAAudioEffectView, spectrumViewDidUpdateMeters: SAAudioSpectrumMiniView)
    
}

internal class SAAudioEffectView: UICollectionViewCell {
    
    weak var delegate: SAAudioEffectViewDelegate?
    
    var status: SAAudioStatus = .none {
        willSet {
            _updateStatus(newValue)
        }
    }
    var effect: SAAudioEffect? {
        willSet {
            _updateEffect(newValue)
        }
    }
    
    override var isSelected: Bool {
        set {
            _titleButton.isSelected = newValue
            super.isSelected = newValue
        }
        get {
            return super.isSelected 
        }
    }
    
    func onTap(_ sender: Any) {
        guard let effect = effect else {
            return
        }
        if delegate?.audioEffectView(self, shouldSelectItem: effect) ?? true {
            delegate?.audioEffectView(self, didSelectItem: effect)
        }
    }
    
    private func _updateStatus(_ newValue: SAAudioStatus) {
        _logger.trace(newValue)
        
        switch newValue {
        case .none:
            
            _tipsLabel.isHidden = true
            
            _playButton.progress = 0
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _activityIndicatorView.isHidden = true
            _activityIndicatorView.stopAnimating()
            
            _foregroundView.isHidden = true
            
        case .waiting:
            
            _tipsLabel.text = "等待中"
            _tipsLabel.isHidden = false
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _activityIndicatorView.isHidden = false
            _activityIndicatorView.startAnimating()
            
            _foregroundView.isHidden = false
            
        case .processing:
            
            _tipsLabel.text = "处理中"
            _tipsLabel.isHidden = false
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _activityIndicatorView.isHidden = false
            _activityIndicatorView.startAnimating()
            
            _foregroundView.isHidden = false
            
        case .playing:
            
            _tipsLabel.text = "00:00"
            _tipsLabel.isHidden = false
            
            _activityIndicatorView.isHidden = true
            _activityIndicatorView.stopAnimating()
            
            _spectrumView.isHidden = false
            _spectrumView.startAnimating()
            
            _foregroundView.isHidden = false
            
        default:
            break
        }
        
    }
    
    private func _updateEffect(_ newValue: SAAudioEffect?) {
        
        _backgroundView.image = newValue?.image
        _titleButton.setTitle(newValue?.title, for: .normal)
        //_playButton.setBackgroundImage(newValue?.image, for: .normal)
    }
    
    private func _init() {
        _logger.trace()
        
        let hcolor = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
        
        
        _backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        _foregroundView.isHidden = true
        _foregroundView.translatesAutoresizingMaskIntoConstraints = false
        _foregroundView.image = UIImage(named: "aio_simulate_effect_select")
        
        _playButton.translatesAutoresizingMaskIntoConstraints = false
        _playButton.progress = 0
        _playButton.progressColor = hcolor
        _playButton.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        _playButton.setBackgroundImage(UIImage(named: "aio_simulate_effect_press"), for: .highlighted)
        
        _titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        _titleButton.setTitleColor(.black, for: .normal)
        _titleButton.setTitleColor(.white, for: .selected)
        _titleButton.setBackgroundImage(UIImage(named: "aio_simulate_text_select"), for: .selected)
        _titleButton.isUserInteractionEnabled = false
        _titleButton.translatesAutoresizingMaskIntoConstraints = false
        _titleButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
        
        _tipsLabel.isHidden = true
        _tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        _tipsLabel.font = UIFont.systemFont(ofSize: 12)
        _tipsLabel.text = "准备中"
        _tipsLabel.textColor = .white
        
        _spectrumView.color = .white
        _spectrumView.dataSource = self
        _spectrumView.translatesAutoresizingMaskIntoConstraints = false
        _spectrumView.isHidden = true
        
        _activityIndicatorView.isHidden = true
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(_backgroundView)
        addSubview(_titleButton)
        addSubview(_foregroundView)
        addSubview(_playButton)
        
        addSubview(_spectrumView)
        addSubview(_activityIndicatorView)
        addSubview(_tipsLabel)
        
        addConstraint(_SAAudioLayoutConstraintMake(_backgroundView, .top, .equal, self, .top))
        addConstraint(_SAAudioLayoutConstraintMake(_backgroundView, .centerX, .equal, self, .centerX))
        
        addConstraint(_SAAudioLayoutConstraintMake(_foregroundView, .top, .equal, _backgroundView, .top))
        addConstraint(_SAAudioLayoutConstraintMake(_foregroundView, .left, .equal, _backgroundView, .left))
        addConstraint(_SAAudioLayoutConstraintMake(_foregroundView, .right, .equal, _backgroundView, .right))
        addConstraint(_SAAudioLayoutConstraintMake(_foregroundView, .bottom, .equal, _backgroundView, .bottom))
        
        addConstraint(_SAAudioLayoutConstraintMake(_playButton, .top, .equal, _backgroundView, .top))
        addConstraint(_SAAudioLayoutConstraintMake(_playButton, .left, .equal, _backgroundView, .left))
        addConstraint(_SAAudioLayoutConstraintMake(_playButton, .right, .equal, _backgroundView, .right))
        addConstraint(_SAAudioLayoutConstraintMake(_playButton, .bottom, .equal, _backgroundView, .bottom))
        
        addConstraint(_SAAudioLayoutConstraintMake(_titleButton, .top, .equal, _backgroundView, .bottom, 4))
        addConstraint(_SAAudioLayoutConstraintMake(_titleButton, .centerX, .equal, _backgroundView, .centerX))
        
        // status view
        
        let size = _tipsLabel.sizeThatFits(CGSize(width: .max, height: .max))
        
        addConstraint(_SAAudioLayoutConstraintMake(_spectrumView, .centerX, .equal, self, .centerX))
        addConstraint(_SAAudioLayoutConstraintMake(_spectrumView, .centerY, .equal, self, .centerY, -(size.height + 4)))
        addConstraint(_SAAudioLayoutConstraintMake(_activityIndicatorView, .centerX, .equal, _spectrumView, .centerX))
        addConstraint(_SAAudioLayoutConstraintMake(_activityIndicatorView, .centerY, .equal, _spectrumView, .centerY))
        addConstraint(_SAAudioLayoutConstraintMake(_tipsLabel, .top, .equal, _spectrumView, .bottom, 4))
        addConstraint(_SAAudioLayoutConstraintMake(_tipsLabel, .centerX, .equal, _spectrumView, .centerX))
    }
    
    fileprivate lazy var _playButton: SAAudioPlayButton = SAAudioPlayButton()
    
    fileprivate lazy var _backgroundView: UIImageView = UIImageView()
    fileprivate lazy var _foregroundView: UIImageView = UIImageView()
    fileprivate lazy var _titleButton: UIButton = UIButton()
    
    fileprivate lazy var _tipsLabel: UILabel = UILabel()
    fileprivate lazy var _spectrumView: SAAudioSpectrumMiniView = SAAudioSpectrumMiniView()
    fileprivate lazy var _activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

extension SAAudioEffectView: SAAudioSpectrumMiniViewDataSource {
    
    func spectrumMiniView(willUpdateMeters spectrumMiniView: SAAudioSpectrumMiniView) {
        _updateTime()
        delegate?.audioEffectView(self, spectrumViewWillUpdateMeters: spectrumMiniView)
    }
    func spectrumMiniView(didUpdateMeters spectrumMiniView: SAAudioSpectrumMiniView) {
        delegate?.audioEffectView(self, spectrumViewDidUpdateMeters: spectrumMiniView)
    }
    
    func spectrumMiniView(_ spectrumMiniView: SAAudioSpectrumMiniView, peakPowerFor channel: Int) -> Float {
        return delegate?.audioEffectView(self, spectrumView: spectrumMiniView, peakPowerFor: channel) ?? -160
    }
    func spectrumMiniView(_ spectrumMiniView: SAAudioSpectrumMiniView, averagePowerFor channel: Int) -> Float {
        return delegate?.audioEffectView(self, spectrumView: spectrumMiniView, averagePowerFor: channel) ?? -160
    }
    
    private func _updateTime() {
        guard status.isPlaying else {
            return
        }
        let time = delegate?.audioEffectViewGetCurrentTime(self) ?? 0
        let progress = delegate?.audioEffectViewGetProgress(self) ?? 0
        
        _tipsLabel.text = String(format: "%0d:%02d", Int(time) / 60, Int(time) % 60)
        _playButton.setProgress(progress, animated: true)
    }
}
