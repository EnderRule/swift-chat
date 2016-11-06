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
            let oldValue = _imageView.image
            let newValue = newValue as? UIImage
            guard newValue != oldValue else {
                return // no change
            }
            // 更新图片和背景色
            _imageView.image = newValue
            _imageView.backgroundColor = _backgroundColor(with: newValue)
            // 如果是切换图片, 添加动画
            // 必须防止重叠动画
            if !CATransaction.disableActions() && UIView.areAnimationsEnabled /*&& layer.animationKeys()?.isEmpty ?? true*/ {
                // 添加内容变更
                let ani1 = CABasicAnimation(keyPath: "contents")
                
                ani1.fromValue = oldValue?.cgImage ?? _image(with: newValue?.size ?? .zero)?.cgImage
                ani1.toValue = newValue?.cgImage ?? _image(with: oldValue?.size ?? .zero)?.cgImage
                ani1.duration = 0.35
                
                _imageView.layer.add(ani1, forKey: "contents")
            }
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
    
    private func _backgroundColor(with image: UIImage?) -> UIColor {
        guard image == nil else {
            return UIColor.clear
        }
        return UIColor(white: 0.94, alpha: 1)
    }
    
    private func _image(with size: CGSize) -> UIImage? {
        guard size.width != 0 && size.height != 0 else {
            return nil
        }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let color = _backgroundColor(with: nil)
        
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
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
        _imageView.backgroundColor = _backgroundColor(with: nil)
        
        addSubview(_imageView)
    }
    
    private var _playerView: UIView?
    private lazy var _imageView: UIImageView = UIImageView()
}
