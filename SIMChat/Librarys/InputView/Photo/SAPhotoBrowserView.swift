//
//  SAPhotoBrowserView.swift
//  SIMChat
//
//  Created by sagesse on 9/29/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

@objc
internal protocol SAPhotoBrowserViewDelegate: NSObjectProtocol {
    
    @objc optional func browserView(_ browserView: SAPhotoBrowserView, didTapWith sender: AnyObject)
    @objc optional func browserView(_ browserView: SAPhotoBrowserView, didDoubleTapWith sender: AnyObject)
    
    @objc optional func browserView(_ browserView: SAPhotoBrowserView, shouldRotation orientation: UIImageOrientation) -> Bool
    @objc optional func browserView(_ browserView: SAPhotoBrowserView, didRotation orientation: UIImageOrientation)
}

internal class SAPhotoBrowserView: UIView, SAPhotoPreviewing {
    
    var loader: SAPhotoLoaderType? {
        didSet {
            oldValue?.delegate = nil 
            oldValue?.cancelRequestImage()
            
            _imageView.image = nil
            
            loader?.delegate = self
            loader?.requestImage()
        }
    }
    weak var delegate: SAPhotoBrowserViewDelegate? {
        set { return _delegate = newValue }
        get { return _delegate }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if _cacheBounds?.width != bounds.width {
            _restoreContent(loader?.size ?? .zero, oldBounds: _cacheBounds ?? bounds, animated: false)
            _cacheBounds = bounds
        }
    }
    
    override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView? {
        let view = UIImageView()
        
        view.frame = frame
        view.image = _imageView.image
        //view.contentMode = .scaleAspectFit
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        return view
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
    
    private func _minimumZoomScale(_ size: CGSize) -> CGFloat {
        return 1
    }
    private func _maximumZoomScale(_ size: CGSize) -> CGFloat {
        let scale = _aspectFitZoomScale(size)
        let width = max(size.width * scale, 1)
        let height = max(size.height * scale, 1)
        return max(max(size.width / width, size.height / height), 2)
    }
    private func _aspectFitZoomScale(_ size: CGSize) -> CGFloat {
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        return min(min(bounds.width, width) / width, min(bounds.height, height) / height)
    }
    
    private func _sizeThatFits(_ size: CGSize) {

        let scale = _aspectFitZoomScale(size)
        let minimumZoomScale = _minimumZoomScale(size)
        let maximumZoomScale = _maximumZoomScale(size)
        
        let fit = CGSize(width: size.width * scale, height: size.height * scale)
        let nbounds = CGRect(origin: .zero, size: fit)
        
        _scrollView.minimumZoomScale = minimumZoomScale
        _scrollView.maximumZoomScale = maximumZoomScale
        _scrollView.zoomScale = 1
        
        _imageView.frame = nbounds.applying(transform)
        _imageView.center = CGPoint(x: _scrollView.bounds.midX, y: _scrollView.bounds.midY)
    }
    
    private func _restoreContent(_ size: CGSize, oldBounds: CGRect, animated: Bool) {
        _logger.trace()
        
        let fitZoomScale = _aspectFitZoomScale(size)
        let minimumZoomScale = _minimumZoomScale(size)
        let maximumZoomScale = _maximumZoomScale(size)
        
        let zoomScaleRatio = (_scrollView.zoomScale - _scrollView.minimumZoomScale) / (_scrollView.maximumZoomScale - _scrollView.minimumZoomScale)
        let zoomScale = (minimumZoomScale + (maximumZoomScale - minimumZoomScale) * zoomScaleRatio)
        
        let pt = _scrollView.contentOffset
        let npt = pt
        
        _imageView.bounds = CGRect(x: 0, y: 0, width: size.width * fitZoomScale, height: size.height * fitZoomScale)
        _imageView.center = CGPoint(x: _scrollView.bounds.midX, y: _scrollView.bounds.midY)
        
        _scrollView.minimumZoomScale = minimumZoomScale
        _scrollView.maximumZoomScale = maximumZoomScale
        _scrollView.zoomScale = zoomScale
        
        _scrollView.setContentOffset(npt, animated: animated)
    }
    
   
    fileprivate func _updateContent(for loader: SAPhotoLoaderType, animated: Bool) {
        //_logger.trace()
        
        _imageView.image = loader.image
        _sizeThatFits(loader.size ?? .zero)
    }
    fileprivate func _updateOrientation(for rotation: CGFloat, animated: Bool) {
        //_logger.trace(rotation)
        
        let angle = round(rotation / CGFloat(M_PI_2)) * CGFloat(M_PI_2)
        let oldOrientation = loader?.orientation ?? .up
        let newOrientation = _orientation(for: _rotation(for: oldOrientation) + angle)
        
        // 如果旋转的角度没有超过阀值或者没有设置图片, 那么放弃手势
        guard oldOrientation != newOrientation else {
            guard animated else {
                _scrollView.transform = .identity
                _delegate?.browserView?(self, didRotation: newOrientation)
                return
            }
            UIView.animate(withDuration: 0.35, animations: { [_scrollView] in
                _scrollView.transform = .identity
            }, completion: { [_delegate] b in
                _delegate?.browserView?(self, didRotation: newOrientation)
            })
            return
        }
        // 生成新的图片(符合方向的)
        loader?.rotation(newOrientation)
        
        let newSize = loader?.size ?? .zero
        let newImage = loader?.image
        
        let scale = _aspectFitZoomScale(newSize)
        let minimumZoomScale = _minimumZoomScale(newSize)
        let maximumZoomScale = _maximumZoomScale(newSize)
        
        let nbounds = CGRect(x: 0, y: 0, width: newSize.width * scale, height: newSize.height * scale)
        let transform = CGAffineTransform(rotationAngle: angle)
        let ignoreContentOffsetChanges = _scrollView.ignoreContentOffsetChanges
        
        // version 2
        UIView.animate(withDuration: 0.35, animations: { [_scrollView, _imageView] in
            
            _scrollView.transform = transform
            _scrollView.frame = self.bounds
            
            _scrollView.minimumZoomScale = minimumZoomScale
            _scrollView.maximumZoomScale = maximumZoomScale
            _scrollView.zoomScale = 1
            
            _scrollView.contentSize = self.bounds.size
            _scrollView.setContentOffset(.zero, animated: false)
            _scrollView.ignoreContentOffsetChanges = false
            
            _imageView.frame = nbounds.applying(transform)
            _imageView.center = CGPoint(x: _scrollView.bounds.midX, y: _scrollView.bounds.midY)
            
        }, completion: { [_scrollView, _imageView, _delegate] b in
            
            _scrollView.transform = .identity
            _scrollView.frame = self.bounds
            _scrollView.contentSize = self.bounds.size
            _scrollView.ignoreContentOffsetChanges = ignoreContentOffsetChanges
            
            _imageView.image = newImage
            _imageView.frame = nbounds
            _imageView.center = CGPoint(x: _scrollView.bounds.midX, y: _scrollView.bounds.midY)
            
            _delegate?.browserView?(self, didRotation: newOrientation)
        })
    }
    
    private func _init() {
        
        _tapGestureRecognizer.require(toFail: _doubleTapGestureRecognizer)
        _rotationGestureRecognizer.delegate = self
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        _imageView.backgroundColor = .random
        
        _scrollView.frame = bounds
        _scrollView.delegate = self
        _scrollView.clipsToBounds = false
        _scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _scrollView.delaysContentTouches = false
        _scrollView.canCancelContentTouches = false
        _scrollView.showsVerticalScrollIndicator = false
        _scrollView.showsHorizontalScrollIndicator = false
        //_scrollView.alwaysBounceVertical = true
        //_scrollView.alwaysBounceHorizontal = true
        _scrollView.addSubview(_imageView)
        
        addSubview(_scrollView)
        
        addGestureRecognizer(_tapGestureRecognizer)
        addGestureRecognizer(_doubleTapGestureRecognizer)
        addGestureRecognizer(_rotationGestureRecognizer)
    }
    
    fileprivate var _isRotationing: Bool = false {
        willSet {
            // 旋转的时候锁定缩放和移动事件
            //_imageView.ignoreTransformChanges = newValue
            //_scrollView.ignoreContentOffsetChanges = newValue
        }
    }
    
    private var _cacheBounds: CGRect?
    
    fileprivate weak var _delegate: SAPhotoBrowserViewDelegate?
    
    fileprivate lazy var _tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
    fileprivate lazy var _rotationGestureRecognizer: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationHandler(_:)))
    fileprivate lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
    
    fileprivate lazy var _imageView: SAPhotoImageView = SAPhotoImageView()
    fileprivate lazy var _scrollView: SAPhotoScrollView = SAPhotoScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

private extension SAPhotoBrowserView {
    
    dynamic func tapHandler(_ sender: AnyObject) {
        //_logger.trace()
        
        _delegate?.browserView?(self, didTapWith: sender)
    }
    dynamic func rotationHandler(_ sender: UIRotationGestureRecognizer) {
        //_logger.trace(sender.rotation)
        
        guard sender.state == .ended || sender.state == .cancelled || sender.state == .failed else {
            // 开始旋转
            if !_isRotationing {
                guard _delegate?.browserView?(self, shouldRotation: loader?.orientation ?? .up) ?? true else {
                    return // .. 不允许旋转
                }
                _isRotationing = true
            }
            _scrollView.transform = CGAffineTransform(rotationAngle: sender.rotation)
            return
        }
        guard _isRotationing else {
            return // 并没有开始旋转
        }
        // 停止旋转
        _isRotationing = false
        _updateOrientation(for: sender.rotation, animated: true)
    }
    dynamic func doubleTapHandler(_ sender: UITapGestureRecognizer) {
         //_logger.trace()
        
        if _scrollView.zoomScale > _scrollView.minimumZoomScale {
            _scrollView.setZoomScale(_scrollView.minimumZoomScale, animated: true)
        } else {
            let scale = _scrollView.maximumZoomScale
            let size = CGSize(width: _imageView.bounds.width * scale, height: _imageView.bounds.height * scale)
            let pt = sender.location(in: _imageView)
            
            let ratioX = max(min(pt.x, _imageView.bounds.width), 0) / max(_imageView.bounds.width, 1)
            let ratioY = max(min(pt.y, _imageView.bounds.height), 0) / max(_imageView.bounds.height, 1)
            
            let x = max(min(size.width * ratioX - _scrollView.frame.width / 2, size.width - _scrollView.frame.width), 0)
            let y = max(min(size.height * ratioY - _scrollView.frame.height / 2, size.height - _scrollView.frame.height), 0)
            
            UIView.animate(withDuration: 0.35, animations: { [_scrollView] in
                _scrollView.zoomScale = _scrollView.maximumZoomScale
                _scrollView.contentOffset = CGPoint(x: x, y: y)
            })
        }
        
        delegate?.browserView?(self, didDoubleTapWith: sender)
    }
    
}

extension SAPhotoBrowserView: SAPhotoLoaderDelegate {
    
    func loader(_ loader: SAPhotoLoaderType, didChangeSize size: CGSize?) {
        _logger.trace()
        
        _updateContent(for: loader, animated: true)
    }
    func loader(_ loader: SAPhotoLoaderType, didChangeImage image: UIImage?) {
        _logger.trace()
        
        _imageView.image = image
    }
    
    func loader(didStart loader: SAPhotoLoader) {
        _logger.trace()
    }
    func loader(didComplate loader: SAPhotoLoader, image: UIImage?) {
        _logger.trace()
        
        _updateContent(for: loader, animated: false)
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
