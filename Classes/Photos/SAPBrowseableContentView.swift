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
            // 如果是切换图片, 添加动画
            // 必须防止重叠动画
            if !CATransaction.disableActions() && UIView.areAnimationsEnabled && layer.animationKeys()?.isEmpty ?? true {
                let ani = CATransition()
                
                ani.type = kCATransitionFade
                ani.duration = 0.35
                
                _imageView.layer.add(ani, forKey: "image")
            }
            // 更新图片
            _imageView.image = newValue
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
            // 删除图片变更动画
            //_imageView.layer.removeAnimation(forKey: "image")
            
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
    
    private func _init() {
        
        _imageView.frame = bounds
        _imageView.contentMode = .scaleAspectFill
        _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(_imageView)
    }
    
    private var _playerView: UIView?
    private lazy var _imageView: UIImageView = UIImageView()
}
