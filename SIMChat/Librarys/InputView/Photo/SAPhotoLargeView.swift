//
//  SAPhotoLargeView.swift
//  SIMChat
//
//  Created by sagesse on 9/26/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal class SAPhotoLargeView: UIScrollView {
    
    var photo: SAPhoto? {
        didSet {
            guard let newValue = photo else {
                return
            }
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic//highQualityFormat
            options.resizeMode = .fast
            
            let scale = UIScreen.main.scale
            let size = CGSize(width: CGFloat(newValue.pixelWidth), height: CGFloat(newValue.pixelHeight))
            
            self._imageView.image = nil
            
            SAPhotoLibrary.shared.requestImage(for: newValue, targetSize: size, contentMode: .aspectFill, options: options) { img, _ in
                guard self.photo == newValue else {
                    return
                }
                self._logger.trace(img)
                self._imageView.image = img
                self.zoomToFit(animated: false)
            }
        }
    }
    
    ///
    /// 缩放到最合适
    ///
    func zoomToFit(animated flag: Bool) {
        let from = _imageView.bounds.size
        var to = _imageView.image?.size ?? CGSize.zero
        
        to.width = max(to.width, 1)
        to.height = max(to.height, 1)
        
        // 计算出最小的.
        let scale = min(min(bounds.width, to.width) / to.width, min(bounds.height, to.height) / to.height)
        let fit = CGRect(x: 0, y: 0, width: scale * to.width, height: scale * to.height)
        
        // 还有中心点问题
        let pt = CGPoint(x: max(fit.width, bounds.width) / 2, y: max(fit.height, bounds.height) / 2)
        
        zoomScale = 1
        minimumZoomScale = 1
        maximumZoomScale = max(max(to.width / fit.width, to.height / fit.height), 2)
        
        
        _logger.trace("from: \(from), to: \(to), scale: \(maximumZoomScale)")
        
        if flag {
            UIView.animate(withDuration: 0.25) {
                self._imageView.bounds = fit
                self._imageView.center = pt
            }
        } else {
            _imageView.bounds = fit
            _imageView.center = pt
        }
    }
    /// 更新布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = max(contentSize.width, bounds.width)
        let height = max(contentSize.height, bounds.height)
        
        _imageView.center = CGPoint(x: width / 2, y: height / 2)
    }
    
    var image: UIImage?
    var largeImage: UIImage?
    
    
    private func _init() {
        
        delegate = self
        
        addSubview(_imageView)
    }
    
    fileprivate var _imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

extension SAPhotoLargeView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return _imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let x = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0;
        let y = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0;
        // 更新
        _imageView.center = CGPoint(x: scrollView.contentSize.width / 2 + x, y: scrollView.contentSize.height / 2 + y)
    }
}
