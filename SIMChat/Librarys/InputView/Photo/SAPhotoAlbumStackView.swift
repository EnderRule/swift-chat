//
//  SAPhotoAlbumStackView.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoAlbumStackView: UIView, SAPhotoProgressiveableObserver {
    
    /// 显示的图片
    var photos: [SAPhoto]? {
        willSet {
            _updatePhotos(newValue ?? [])
        }
    }
    
    func progressiveable(_ progressiveable: SAPhotoProgressiveable, didChangeContent content: Any?) {
        guard let index = _images.index(where: { $1 === progressiveable }) else {
            return
        }
        let key = _images[index].key
        guard key < _imageLayers.count else {
            return
        }
        _imageLayers[key].contents = (content as? UIImage)?.cgImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let h = bounds.height
        let w = bounds.width
        let sw: CGFloat = 4
        
        _imageLayers.enumerated().forEach {
            let fidx = CGFloat($0)
            var nframe = CGRect(x: 0, y: 0, width: w - sw * fidx, height: h - sw * fidx)
            nframe.origin.x = (w - nframe.width) / 2
            nframe.origin.y = (0 - (sw / 2) * fidx)
            $1.frame = nframe
        }
    }
    
    private func _updatePhotos(_ photos: [SAPhoto]) {
        _logger.trace(photos.count)
        
        // 更新内容
        var size = bounds.size
        
        size.width *= UIScreen.main.scale
        size.height *= UIScreen.main.scale
        
        _imageLayers.enumerated().forEach { 
            guard !photos.isEmpty else {
                // 这是一个空的相册
                $0.element.isHidden = false
                $0.element.backgroundColor = UIColor(white: 0.8, alpha: 1).cgColor
                
                return _setImage(nil, at: $0.offset)
            }
            guard $0.offset < photos.count else {
                // 这个相册并没有3张图片
                $0.element.isHidden = true
                
                return _setImage(nil, at: $0.offset)
            }
            let photo = photos[$0.offset]
            
            $0.element.isHidden = false
            $0.element.backgroundColor = UIColor.white.cgColor
            
            _setImage(photo.image(with: size) as? SAPhotoProgressiveableImage, at: $0.offset)
        }
    }
    
    private func _setImage(_ newValue: SAPhotoProgressiveableImage?, at index: Int) {
        
        let oldValue = _images[index] ?? nil
        guard oldValue != newValue else {
            return
        }
        
        oldValue?.removeObserver(self)
        newValue?.addObserver(self)
        
        _images[index] = newValue
        _imageLayers[index].contents = (newValue?.content as? UIImage)?.cgImage
    }
    
    private func _init() {
        //_logger.trace()
        
        _imageLayers = (0 ..< 3).map { index in
            let il = CALayer()
            
            il.masksToBounds = true
            il.borderWidth = 0.5
            il.borderColor = UIColor.white.cgColor
            il.contentsGravity = kCAGravityResizeAspectFill
            
            layer.insertSublayer(il, at: 0)
            
            return il
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
    
    private lazy var _images: [Int: SAPhotoProgressiveableImage?] = [:]
    private lazy var _imageLayers: [CALayer] = []
}