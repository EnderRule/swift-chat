//
//  BrowseOverlayProgressView.swift
//  Browser
//
//  Created by sagesse on 12/9/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


open class BrowseOverlayProgressView: UIView {
   
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    open var radius: CGFloat = 3 {
        didSet {
            _layer.radius = radius
            let ani = CABasicAnimation(keyPath: "radius")
            ani.toValue = radius 
            _layer.add(ani, forKey: "radius")
        }
    }
    
    open var progress: Double {
        set { return setProgress(newValue, animated: false) }
        get { return _layer.progress }
    }
    
    open func setProgress(_ progress: Double, animated: Bool) {
        _layer.progress = progress
        guard !animated else {
            return
        }
        let ani = CABasicAnimation(keyPath: "progress")
        ani.toValue = progress
        _layer.add(ani, forKey: "progress")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard progress < -0.000001 else {
            return super.point(inside: point, with: event)
        }
        return true
    }
    
    open override class var layerClass: AnyClass { 
        return BrowseOverlayProgressLayer.self
    }
    
    private func _commonInit() {
        
        backgroundColor = .clear
        
//        _layer.backgroundColor = UIColor.clear.cgColor
//        _layer.fillColor = UIColor.clear.cgColor
//        _layer.strokeColor = UIColor.lightGray.cgColor
        
        _layer.lineWidth = 1 / UIScreen.main.scale
        _layer.radius = 3
    }
    
    private lazy var _layer: BrowseOverlayProgressLayer = {
        return self.layer as! BrowseOverlayProgressLayer
    }()
}

