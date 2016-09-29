//
//  SAPhotoBrowserView.swift
//  SIMChat
//
//  Created by sagesse on 9/29/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal protocol SAPhotoImageLoader {
    
    func loader(_ loader: Any)
    
}

internal class SAPhotoImageView: UIImageView {
    
    override var transform: CGAffineTransform {
        set {
            guard !ignoreTransformChanges else {
                return
            }
            return super.transform = newValue
        }
        get {
            return super.transform
        }
    }
    
    
    var ignoreTransformChanges: Bool = false
}


internal class SAPhotoBrowserView: UIScrollView {
    
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
    
    @objc private func tapHandler(_ sender: Any) {
        _logger.trace()
    }
    @objc private func rotationHandler(_ sender: UIRotationGestureRecognizer) {
        _logger.trace(sender.rotation)
        
        
        let isEnd = sender.state == .ended || sender.state == .cancelled || sender.state == .failed
        
        _imageView.ignoreTransformChanges = !isEnd
        ignoreContentOffsetChanges = !isEnd
        
        self.transform = CGAffineTransform(rotationAngle: sender.rotation)
    }
    @objc private func doubleTapHandler(_ sender: Any) {
        _logger.trace()
        
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            setZoomScale(maximumZoomScale, animated: true)
        }
    }
    
    private func _init() {
        
        _tapGestureRecognizer.require(toFail: _doubleTapGestureRecognizer)
        
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        //panGestureRecognizer.require(toFail: _rotationGestureRecognizer)
        _rotationGestureRecognizer.delegate = self
        
        delegate = self
        clipsToBounds = false
        
        delaysContentTouches = false
        canCancelContentTouches = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        addSubview(_imageView)
        
        addGestureRecognizer(_tapGestureRecognizer)
        addGestureRecognizer(_doubleTapGestureRecognizer)
        addGestureRecognizer(_rotationGestureRecognizer)
    }
    
    override var contentOffset: CGPoint {
        set {
            guard !ignoreContentOffsetChanges else {
                return
            }
            return super.contentOffset = newValue
        }
        get {
            return super.contentOffset
        }
    }
    
    var ignoreContentOffsetChanges: Bool = false
    
    
    fileprivate lazy var _tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
    fileprivate lazy var _rotationGestureRecognizer: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationHandler(_:)))
    fileprivate lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
    
    fileprivate lazy var _imageView: SAPhotoImageView = SAPhotoImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

extension SAPhotoBrowserView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self === otherGestureRecognizer.view {
            return true
        }
        return false
    }
}

extension SAPhotoBrowserView: UIScrollViewDelegate {
    
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
