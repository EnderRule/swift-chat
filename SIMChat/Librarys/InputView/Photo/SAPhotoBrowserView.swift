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



internal class SAPhotoBrowserView: UIView {
    
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
        
        _scrollView.zoomScale = 1
        _scrollView.minimumZoomScale = 1
        _scrollView.maximumZoomScale = max(max(to.width / fit.width, to.height / fit.height), 2)
        
        _logger.trace("from: \(from), to: \(to), scale: \(_scrollView.maximumZoomScale)")
        
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
        
//        let width = max(_scrollView.contentSize.width, _scrollView.bounds.width)
//        let height = max(_scrollView.contentSize.height, _scrollView.bounds.height)
//        
//        _imageView.center = CGPoint(x: width / 2, y: height / 2)
    }
    
    var image: UIImage?
    var largeImage: UIImage?
    
    @objc private func tapHandler(_ sender: Any) {
        _logger.trace()
    }
    @objc private func rotationHandler(_ sender: UIRotationGestureRecognizer) {
        //_logger.trace(sender.rotation)
        
//        _imageView.ignoreTransformChanges = !isEnd
//        ignoreContentOffsetChanges = !isEnd
        
        _scrollView.transform = CGAffineTransform(rotationAngle: angle + sender.rotation)
        
        if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            _updateContentSize(for: angle + sender.rotation)
            
        }
    }
    @objc private func doubleTapHandler(_ sender: Any) {
        _logger.trace()
        
        if _scrollView.zoomScale > _scrollView.minimumZoomScale {
            _scrollView.setZoomScale(_scrollView.minimumZoomScale, animated: true)
        } else {
            _scrollView.setZoomScale(_scrollView.maximumZoomScale, animated: true)
        }
    }
    
    
    private func _updateZoomToFits(for size: CGSize) {
       _logger.trace(size)
        
        
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        
        let scale = min(min(bounds.width, width) / width, min(bounds.height, height) / height)
        let fit = CGSize(width: width * scale, height: height * scale)
        
        
        _logger.debug("\(size) => \(fit)")
        
        _scrollView.zoomScale = 1
        _scrollView.minimumZoomScale = 0.01
        _scrollView.maximumZoomScale = max(max(width / fit.width, height / fit.height), 2)
        
        
        let nbounds = CGRect(origin: .zero, size: fit)
        let ncenter = CGPoint(x: max(fit.width, bounds.width) / 2, y: max(fit.height, bounds.height) / 2)
        
//        UIView.animate(withDuration: 0.25) { [_imageView, _scrollView] in
            _imageView.bounds = nbounds
            _imageView.center = ncenter
//        }
    }
    
    private func _minimumZoomScale(_ size: CGSize) -> CGFloat {
        return 1
    }
    private func _maximumZoomScale(_ size: CGSize) -> CGFloat {
        let scale = _aspectFitZoomScale(size)
        let width = max(size.width * scale, 1)
        let height = max(size.height * scale, 1)
        return max(max(bounds.width / width, bounds.height / height), 2)
    }
    private func _aspectFitZoomScale(_ size: CGSize) -> CGFloat {
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        return min(min(bounds.width, width) / width, min(bounds.height, height) / height)
    }
    
    private func _rotation(for orientation: UIImageOrientation) -> CGFloat {
        switch orientation {
        case .up,
             .upMirrored:
            return 0 * CGFloat(M_PI_2)
        case .right,
             .rightMirrored:
            return 1 * CGFloat(M_PI_2)
        case .down,
             .downMirrored:
            return 2 * CGFloat(M_PI_2)
        case .left,
             .leftMirrored:
            return 3 * CGFloat(M_PI_2)
        }
    }
    private func _orientation(for rotation: CGFloat) -> UIImageOrientation {
        switch Int(rotation / CGFloat(M_PI_2)) % 4 {
        case 0:     return .up
        case 1, -3: return .right
        case 2, -2: return .down
        case 3, -1: return .left
        default:    return .up
        }
    }
    
    private func _updateContentSize(for size: CGSize) {
        
//        _scrollView.minimumZoomScale = 1
//        _scrollView.maximumZoomScale = max(max(to.width / fit.width, to.height / fit.height), 2)
    }
    
    private func _updateContentSize(for rotation: CGFloat) {
        let angle = round(rotation / CGFloat(M_PI_2)) * CGFloat(M_PI_2)
        
        //_logger.trace("\(rotation) => \(angle)")
        
        var image: UIImage?
        var nsize: CGSize = .zero
        var osize: CGSize = _imageView.image?.size ?? .zero
        
        if let uiimg = _imageView.image, let cgimg = uiimg.cgImage {
            let ori = _orientation(for: angle)
            let nimg = UIImage(cgImage: cgimg, scale: uiimg.scale, orientation: ori)
            
            //_logger.debug("\(ori.rawValue) => \(uiimg.size) => \(nimg.size)")
            
            image = nimg
            
            nsize = nimg.size
        }
        
        // vs
        // hs 
        
        let scale = _aspectFitZoomScale(nsize)
        let nbounds = CGRect(x: 0, y: 0, width: nsize.width * scale, height: nsize.height * scale)
        
        
        _logger.trace("\(osize) => \(nsize)(\(nbounds))")
        
        let transform = CGAffineTransform(rotationAngle: angle)
        
        UIView.animate(withDuration: 0.25, animations: {
            
            
            //self._imageView.transform = .identity
            self._scrollView.transform = transform
            self._scrollView.frame = self.bounds
            self._scrollView.contentSize = nsize
            
            self._imageView.bounds = nbounds.applying(transform)
            self._imageView.center = CGPoint(x: self._scrollView.bounds.midX, y: self._scrollView.bounds.midY)
            
            self._scrollView.zoomScale = 1
            self._scrollView.minimumZoomScale = self._minimumZoomScale(nsize)
            self._scrollView.maximumZoomScale = self._maximumZoomScale(nsize)
            
            
        }, completion: { b in
            
//            self._scrollView.transform = .identity
            //self._imageView.transform = .identity
        })
        
        self.angle = angle.remainder(dividingBy: CGFloat(M_PI * 2))
    }
    
    private func _init() {
        
        _tapGestureRecognizer.require(toFail: _doubleTapGestureRecognizer)
        _rotationGestureRecognizer.delegate = self
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        _scrollView.backgroundColor = .random
        _scrollView.frame = bounds
        _scrollView.delegate = self
        _scrollView.clipsToBounds = false
        _scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _scrollView.delaysContentTouches = false
        _scrollView.canCancelContentTouches = false
        _scrollView.showsVerticalScrollIndicator = false
        _scrollView.showsHorizontalScrollIndicator = false
        _scrollView.addSubview(_imageView)
        
        addSubview(_scrollView)
        
        addGestureRecognizer(_tapGestureRecognizer)
        addGestureRecognizer(_doubleTapGestureRecognizer)
        addGestureRecognizer(_rotationGestureRecognizer)
    }
    
//    override var contentOffset: CGPoint {
//        set {
//            guard !ignoreContentOffsetChanges else {
//                return
//            }
//            return super.contentOffset = newValue
//        }
//        get {
//            return super.contentOffset
//        }
//    }
    
    var angle: CGFloat = 0
    
    var ignoreContentOffsetChanges: Bool = false
    
    
    fileprivate lazy var _tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
    fileprivate lazy var _rotationGestureRecognizer: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationHandler(_:)))
    fileprivate lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
    
    fileprivate lazy var _imageView: UIImageView = UIImageView()
    fileprivate lazy var _scrollView: UIScrollView = UIScrollView()
    
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
        if otherGestureRecognizer.view === _scrollView {
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
