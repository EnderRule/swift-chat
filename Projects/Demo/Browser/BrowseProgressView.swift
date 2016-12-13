//
//  BrowseProgressView.swift
//  Browser
//
//  Created by sagesse on 12/9/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

open class BrowseProgressLayer: CAShapeLayer {
    
    public override init() {
        super.init()
        commonInit()
    }
    public override init(layer: Any) {
        super.init(layer: layer)
        commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    @NSManaged open var radius: CGFloat
    @NSManaged open var progress: Double
    
    open override func display() {
        super.display()
        updatePathIfNeeded(with: _currentProgress, radius: _currentRadius)
    }
    open override func layoutSublayers() {
        super.layoutSublayers()
        updatePathIfNeeded(with: _currentProgress, radius: _currentRadius)
    }
    
    open override func action(forKey key: String) -> CAAction? {
        switch key {
        case "radius":
            let animation = CABasicAnimation(keyPath: key)
            animation.fromValue = _currentRadius
            return animation
            
        case "progress":
            let animation = CABasicAnimation(keyPath: key)
            animation.fromValue = _currentProgress
            return animation
            
        default:
            return super.action(forKey: key)
        }
    }
    open override class func needsDisplay(forKey key: String) -> Bool {
        switch key {
        case "radius":
            return true
            
        case "progress":
            return true
            
        default:
            return super.needsDisplay(forKey: key)
        }
    }
    
    private func updatePathIfNeeded(with progress: Double, radius: CGFloat) {
        // nned update?
        guard _cacheProgress != progress || _cacheBounds != bounds || _cacheRadius != radius else {
            return // no change
        }
        _cacheRadius = radius
        _cacheProgress = progress
        _cacheBounds = bounds
        
        let it = (bounds.width / 2) - radius
        let edg = UIEdgeInsetsMake(it, it, it, it)
        
        let rect1 = bounds
        let rect2 = UIEdgeInsetsInsetRect(rect1, edg)
        
        let op = UIBezierPath(roundedRect: rect1, cornerRadius: rect1.width / 2)
        
        guard progress > 0.000001 else {
            // is <= 0, add round
            op.append(.init(roundedRect: rect2, cornerRadius: rect2.width / 2))
            path = op.cgPath
            return
        }
        guard progress < 0.999999 else {
            // is >= 1
            path = op.cgPath
            return
        }
        let s = 0 - CGFloat(M_PI / 2)
        let e = s + CGFloat(M_PI * 2 * progress)
        
        op.move(to: .init(x: rect2.midX, y: rect2.midY))
        op.addLine(to: .init(x: rect2.midX, y: rect2.minY))
        op.addArc(withCenter: .init(x: rect2.midX, y: rect2.midY), radius: rect2.width / 2, startAngle: s, endAngle: e, clockwise: false)
        op.close()
        
        path = op.cgPath
    }
    private func commonInit() {
        
        lineCap = kCALineCapRound
        lineJoin = kCALineJoinRound
        lineWidth = 1
        
        fillRule = kCAFillRuleEvenOdd
        fillColor = UIColor.white.cgColor
        
        strokeStart = 0
        strokeEnd = 1
        strokeColor = UIColor.lightGray.cgColor
    }
    
    private var _cacheRadius: CGFloat = 0
    private var _cacheProgress: Double = -1
    private var _cacheBounds: CGRect = .zero
    
    private var _currentRadius: CGFloat {
        return (presentation() as BrowseProgressLayer?)?.radius ?? radius
    }
    private var _currentProgress: Double {
        return (presentation() as BrowseProgressLayer?)?.progress ?? progress
    }
}


open class BrowseProgressView: UIView {
   
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    open var progress: Double {
        set { return setProgress(newValue, animated: false) }
        get { return _layer.progress }
    }
    
    open func setProgress(_ progress: Double, animated: Bool) {
        CATransaction.begin()
        
        if !animated {
            CATransaction.setDisableActions(true)
        }
        
        _layer.progress = progress
        
        CATransaction.commit()
    }
    
     open override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        _layer.radius = bounds.width / 2 - 3
        
        CATransaction.commit()
    }
    
    open override class var layerClass: AnyClass { 
        return BrowseProgressLayer.self
    }
    
    private func _commonInit() {
        
        backgroundColor = .clear
//        _layer.backgroundColor = UIColor.clear.cgColor
//        _layer.fillColor = UIColor.clear.cgColor
//        _layer.strokeColor = UIColor.lightGray.cgColor
        
        _layer.lineWidth = 1 / UIScreen.main.scale
    }
    
    private var _layer: BrowseProgressLayer {
        return layer as! BrowseProgressLayer
    }
}

