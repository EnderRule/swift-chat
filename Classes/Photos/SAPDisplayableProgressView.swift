//
//  SAPDisplayableProgressView.swift
//  SAPhotos
//
//  Created by sagesse on 11/1/16.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

// 44x44

open class SAPDisplayableProgressView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    // 0.0 .. 1.0, default is 0.0. values outside are pinned.
    open var progress: Double {
        set { return _updateOval(with: newValue, animated: false) }
        get { return _progress }
    }

    open var progressTintColor: UIColor? {
        willSet {
            _oval1.strokeColor = newValue?.cgColor ?? UIColor.gray.cgColor
            _oval2.strokeColor = newValue?.cgColor ?? UIColor.gray.cgColor
        }
    }
    
    open func setProgress(_ progress: Double, animated: Bool) {
        _updateOval(with: progress, animated: animated)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        _updateOval(with: _progress, animated: false)
    }
    
    private func _updateOval(with progress: Double, animated: Bool) {
        
        let st: CGFloat = 6
        
        if _oval1.bounds.size != bounds.size {
            _oval1.frame = bounds
            _oval1.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width / 2).cgPath
        }
        if _oval2.bounds.size != bounds.size || _progress != progress {
            
            _oval2.frame = bounds
            _oval2.path = {
                let frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(st, st, st, st))
                let center = CGPoint(x: frame.midX, y: frame.midY)
                guard progress != 0 else {
                    let path = UIBezierPath(roundedRect: frame, cornerRadius: frame.width / 2)
                    path.move(to: center)
                    return path.cgPath
                }
                guard progress != 1 else {
                    return nil
                }
                let path = UIBezierPath()
                
                path.move(to: center)
                path.addArc(withCenter: center, 
                            radius: frame.width / 2, 
                            startAngle: CGFloat(-M_PI_2),
                            endAngle: CGFloat(-M_PI_2) + CGFloat(2 * M_PI) * CGFloat(progress),
                            clockwise: false)
                path.close()
                
                return path.cgPath
            }()
            _progress = progress
        }
    }
    
    private func _init() {
        
        _oval1.lineWidth = 1 / UIScreen.main.scale
        _oval1.strokeColor = UIColor.gray.cgColor
        _oval1.fillColor = UIColor.clear.cgColor
        
        _oval2.lineWidth = 1 / UIScreen.main.scale
        _oval2.strokeColor = UIColor.gray.cgColor
        _oval2.fillColor = UIColor.clear.cgColor
        
        layer.addSublayer(_oval1)
        layer.addSublayer(_oval2)
    }
    
    private var _oval1: CAShapeLayer = CAShapeLayer()
    private var _oval2: CAShapeLayer = CAShapeLayer()
    
    private var _progress: Double = 0
}
