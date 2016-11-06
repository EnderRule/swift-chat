//
//  SAPBrowseableContentView.swift
//  SAPhotos
//
//  Created by sagesse on 11/5/16.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

internal class SAPBrowseableContentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    var image: Any? {
        set {
            let newValue = newValue as? UIImage
            guard newValue != _imageView.image else {
                return // no change
            }
            _imageView.image = newValue
            _updateBackgroundColor()
//            // 添加动画
//            let ani = CATransition()
//            ani.type = kCATransitionFade
//            ani.duration = 0.25
//            _imageView.layer.add(ani, forKey: "image")
            
        }
        get {
            return _imageView.image 
        }
    }
    var content: Any?
    
    var orientation: UIImageOrientation = .up {
        willSet {
            guard newValue != orientation else {
                return
            }
            
            _imageView.transform = CGAffineTransform(rotationAngle: _angle(orientation: newValue))
            _imageView.frame = bounds
            
            _playerView?.transform = CGAffineTransform(rotationAngle: _angle(orientation: newValue))
            _playerView?.frame = bounds
        }
    }
    
    private func _angle(orientation: UIImageOrientation) -> CGFloat {
        switch orientation {
        case .up, .upMirrored:  return 0 * CGFloat(M_PI_2)
        case .right, .rightMirrored: return 1 * CGFloat(M_PI_2)
        case .down, .downMirrored: return 2 * CGFloat(M_PI_2)
        case .left, .leftMirrored: return 3 * CGFloat(M_PI_2)
        }
    }
    
    private func _updateBackgroundColor() {
        if _imageView.image == nil {
            _imageView.backgroundColor = UIColor(white: 0.94, alpha: 1)
        } else {
            _imageView.backgroundColor = UIColor.clear
        }
    }
    
    private func _init() {
        
        _imageView.frame = bounds
        _imageView.contentMode = .scaleAspectFill
        _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _updateBackgroundColor()
        
        addSubview(_imageView)
    }
    
    private var _playerView: UIView?
    private lazy var _imageView: UIImageView = UIImageView()
}
