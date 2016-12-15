//
//  BrowseVisualEffectButton.swift
//  Browser
//
//  Created by sagesse on 15/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseVisualEffectButton: UIControl {
    
    func setImage(_ image: UIImage?, for state: UIControlState) {
        _allImages[state.rawValue] = image
        _updateState()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _imageView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        _backgroundView.layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
    
    override var isSelected: Bool {
        didSet {
            _updateState()
        }
    }
    override var isEnabled: Bool {
        didSet {
            _updateState()
        }
    }
    override var isHighlighted: Bool {
        didSet {
            _updateState()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 禁止其他的所有手势(独占模式)
        return false
    }
    
    func _updateState() {
        let image = _allImages[state.rawValue] ?? nil
        
        _imageView.image = image
        _imageView.sizeToFit()
        _backgroundImageView.image = image
    }
    func _commonInit() {
        
        _imageView.alpha = 0.3
        _imageView.isUserInteractionEnabled = false
        
        _backgroundView.frame = bounds
        _backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        _backgroundView.isUserInteractionEnabled = false
        _backgroundView.layer.masksToBounds = true
        
        _backgroundView.addSubview(_backgroundEffectView)
        _backgroundView.addSubview(_backgroundImageView)
        
        _backgroundEffectView.frame = bounds
        _backgroundEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _backgroundEffectView.isUserInteractionEnabled = false
        
        _backgroundImageView.frame = bounds
        _backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _backgroundImageView.isUserInteractionEnabled = false
        
        _backgroundImageView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        addSubview(_backgroundView)
        addSubview(_imageView)
    }
    
    private lazy var _allImages: [UInt: UIImage?] = [:]
    
    private lazy var _imageView: UIImageView = UIImageView()
    private lazy var _backgroundView: UIView = UIView()
    private lazy var _backgroundImageView = BrowseVisualEffectBackgroundView(frame: .zero)
    private lazy var _backgroundEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
}

class BrowseVisualEffectBackgroundView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commitInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commitInit()
    }
    
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var backgroundColor: UIColor? {
        set {
            _backgroundColor = newValue
            setNeedsDisplay()
        }
        get {
            return _backgroundColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        backgroundColor?.setFill()
        context.fill(rect)
        guard let img = image?.cgImage else {
            return
        }
        context.clip(to: rect, mask: img)
        context.clear(rect)
    }
    
    func _commitInit() {
        super.backgroundColor = .clear
    }
    
    var _backgroundColor: UIColor?
}
