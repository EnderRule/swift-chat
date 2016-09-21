//
//  SAPhotoStackView.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoStackView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let h = bounds.height
        let w = bounds.width
        let sw: CGFloat = 4
        
        _layers.enumerated().forEach {
            let fidx = CGFloat($0)
            var nframe = CGRect(x: 0, y: 0, width: w - sw * fidx, height: h - sw * fidx)
            nframe.origin.x = (w - nframe.width) / 2
            nframe.origin.y = (0 - (sw / 2) * fidx)
            $1.frame = nframe
        }
    }
    var layers: [CALayer] {
        return _layers
    }
    
    private func _init() {
        _layers = (0 ..< 3).map { index in
            let layer = CALayer()
            
            layer.masksToBounds = true
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.white.cgColor
            layer.backgroundColor = UIColor.random.cgColor
            layer.contentsGravity = kCAGravityResizeAspectFill 
            
            self.layer.insertSublayer(layer, at: 0)
            
            return layer
        }
    }
    
    private var _layers: [CALayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
