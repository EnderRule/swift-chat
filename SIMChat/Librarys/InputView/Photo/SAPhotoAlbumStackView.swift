//
//  SAPhotoAlbumStackView.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoAlbumStackView: UIView {
    
    /// 显示的图片
    var photos: [SAPhoto]? {
        willSet {
            _updatePhotos(newValue ?? [])
        }
    }
    
    private func _updatePhotos(_ photos: [SAPhoto]) {
        _logger.trace(photos.count)
        
        // 更新空白
        _imageViews.forEach {
            if photos.isEmpty {
                $0.image = nil
                $0.isHidden = false
                $0.backgroundColor = UIColor(white: 0.8, alpha: 1)
            } else {
                $0.image = nil
                $0.isHidden = true
                $0.backgroundColor = UIColor.white
            }
        }
        // 更新内容
        var size = bounds.size
        
        size.width *= UIScreen.main.scale
        size.height *= UIScreen.main.scale
        
        photos.enumerated().forEach {
            let photo = $0.element
            let imageView = _imageViews[$0.offset]
            
            imageView.image = photo.image(with: size)
            imageView.isHidden = false
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let h = bounds.height
        let w = bounds.width
        let sw: CGFloat = 4
        
        _imageViews.enumerated().forEach {
            let fidx = CGFloat($0)
            var nframe = CGRect(x: 0, y: 0, width: w - sw * fidx, height: h - sw * fidx)
            nframe.origin.x = (w - nframe.width) / 2
            nframe.origin.y = (0 - (sw / 2) * fidx)
            $1.frame = nframe
        }
    }
    
    
    private func _init() {
        _logger.trace()
        
        
        _imageViews = (0 ..< 3).map { index in
            let imageView = UIImageView()
            
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.borderWidth = 0.5
            imageView.layer.borderColor = UIColor.white.cgColor
            
            insertSubview(imageView, at: 0)
            
            return imageView
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    
    private lazy var _imageViews: [UIImageView] = []
}
