//
//  BrowseProgressLayer.swift
//  Browser
//
//  Created by sagesse on 07/12/2016.
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
    
    /// progress
    @NSManaged open var progress: Double
    
    open override func display() {
        super.display()
        updatePathIfNeeded(with: _currentProgress)
    }
    open override func layoutSublayers() {
        super.layoutSublayers()
        updatePathIfNeeded(with: _currentProgress)
    }
    
    open override func action(forKey key: String) -> CAAction? {
        if key == "progress" {
            let animation = CABasicAnimation(keyPath: key)
            
            //animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = _currentProgress
            
            return animation
        }
        return super.action(forKey: key)
    }
    open override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    private func updatePathIfNeeded(with progress: Double) {
        // nned update?
        guard _cacheProgress != progress || _cacheBounds != bounds else {
            return // no change
        }
        _cacheProgress = progress
        _cacheBounds = bounds
        
        let edg = UIEdgeInsetsMake(20, 20, 20, 20)
        
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
        lineWidth = 2
        
        fillRule = kCAFillRuleEvenOdd
        
        strokeColor = UIColor.gray.cgColor
        fillColor = UIColor.white.cgColor
    }
    
    private var _cacheBounds: CGRect = .zero
    private var _cacheProgress: Double = -1
    
    private var _currentProgress: Double {
        return (presentation() as BrowseProgressLayer?)?.progress ?? progress
    }
}


