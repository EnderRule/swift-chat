//
//  BrowseDetailViewCell.swift
//  Browser
//
//  Created by sagesse on 11/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

extension UIImage {
    
    public func withOrientation(_ orientation: UIImageOrientation) -> UIImage? {
        guard imageOrientation != orientation else {
            return self
        }
        if let image = cgImage {
            return UIImage(cgImage: image, scale: scale, orientation: orientation)
        }
        if let image = ciImage {
            return UIImage(ciImage: image, scale: scale, orientation: orientation)
        }
        return nil
    }
}

class BrowseDetailViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    var asset: Browseable? 
    
    var orientation: UIImageOrientation = .up
    
    lazy var detailView: UIImageView = UIImageView()
    lazy var containterView: BrowseContainterView = BrowseContainterView()
    lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
    
    
    weak var delegate: BrowseDetailViewDelegate?
    
    fileprivate var _canChangeProgressView: Bool = true
    
    fileprivate var _automaticallyAdjustsControlViewIsHidden: Bool = true
    fileprivate var _automaticallyAdjustsProgressViewIsHidden: Bool = true
    
    fileprivate var _progressViewIsHidden: Bool = true
    
    override var contentView: UIView {
        return containterView
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard contentInset != oldValue else {
                return
            }
            _updateIconLayoutIfNeeded()
            _updateProgressLayoutIfNeeded()
        }
    }
    
    dynamic func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: detailView)
        
        DispatchQueue.main.async {
            let containterView = self.containterView
            if containterView.zoomScale != containterView.minimumZoomScale {
                containterView.setZoomScale(containterView.minimumZoomScale, at: location, animated: true)
            } else {
                containterView.setZoomScale(containterView.maximumZoomScale, at: location, animated: true)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置
        _progressOfHidden = true
        _progressOfLock = nil
        _progressView.progress = 0
        _progressView.removeFromSuperview()
        _progressView.alpha = 0
        _progress = 0
    }
    
    func apply(_ asset: Browseable?) {
        guard let newValue = asset else {
            // 清除
            _asset = nil
            
            return
        }
        guard _asset !== newValue else {
            return
        }
        _asset = asset
        //playable
        // // Load the asset's "playable" key
        // [asset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{
        //     NSError *error = nil;
        //     AVKeyValueStatus status =
        //         [asset statusOfValueForKey:@"playable" error:&error];
        //     switch (status) {
        //     case AVKeyValueStatusLoaded:
        //         // Sucessfully loaded, continue processing
        //         break;
        //     case AVKeyValueStatusFailed:
        //         // Examine NSError pointer to determine failure
        //         break;
        //     case AVKeyValueStatusCancelled:
        //         // Loading cancelled
        //         break;
        //     default:
        //         // Handle all other cases
        //         break;
        //     }
        // }];
        
        //AVAsynchronousKeyValueLoading
        
        detailView.backgroundColor = newValue.backgroundColor
        detailView.image = newValue.browseImage?.withOrientation(orientation)
        containterView.contentSize = newValue.browseContentSize
        containterView.zoom(to: bounds, with: orientation, animated: false)
        //containterView.setZoomScale(containterView.maximumZoomScale, animated: false)
        
        // 最后再更新进度信息
        _updateIcon(0, animated: false)
        _updateProgress(0.25, force: false, animated: false)
        //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        //    self._updateProgress(0.35, animated: true)
        //    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
        //        self._updateProgress(0.65, animated: true)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
        //            self._updateProgress(1.00, animated: true)
        //        })
        //    })
        //})
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard _cachedBounds != bounds else {
            return
        }
        _cachedBounds = bounds
        _updateIconLayoutIfNeeded()
        _updateProgressLayoutIfNeeded()
    }
    
    private var _cachedBounds: CGRect?
    
    fileprivate var _containterInset: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    
    fileprivate var _asset: Browseable?
    
    fileprivate var _progress: Double = 0
    fileprivate var _progressOfLock: Double?
    fileprivate var _progressOfHidden: Bool = true
    
    fileprivate lazy var _iconView: UIButton = {
        let view = UIButton(type: .system)
        
        view.frame = CGRect(x: 0, y: 0, width: 60, height: 26)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        view.tintColor = UIColor.black.withAlphaComponent(0.6)
        view.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0)
        
        view.setTitle("HDR", for: .normal)
        view.setImage(UIImage(named: "icon_hdr"), for: .normal)
        
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        
        return view
    }()
    fileprivate lazy var _progressView: BrowseProgressView = BrowseProgressView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
    
    fileprivate func _updateProgressLock(_ lock: Bool, animated: Bool) {
        if lock {
            // 锁定
            let progress = _progress
            _updateProgress(progress, force: true, animated: animated)
            _progressOfLock = progress
        } else {
            // 解锁, 并尝试恢复
            let progress = _progressOfLock ?? _progress
            _progressOfLock = nil
            _updateProgress(progress, force: false, animated: animated)
        }
    }
    
    fileprivate func _updateIcon(_ icon: Any, animated: Bool) {
        
        let view = _iconView
        if view.superview != self {
            addSubview(view)
        }
        _updateIconLayoutIfNeeded()
    }
    fileprivate func _updateProgress(_ progress: Double, force: Bool? = nil, animated: Bool) {
        guard _progressOfLock == nil else {
            // is lock
            _progressOfLock = progress
            return
        }
        let full = progress > 0.999999 // progress >= 1.0(±0.000001)
        let view = _progressView
        
        let oldProgress = _progress
        let oldHidden = _progressOfHidden
        let newProgress = progress
        let newHidden = (force ?? full) || full
        
        guard newProgress != oldProgress || newHidden != oldHidden else {
            return // no change
        }
        _progress = newProgress
        _progressOfHidden = newHidden
        
        if (newProgress != view.progress || !newHidden) && view.superview == nil {
            addSubview(view)
        }
        _updateProgressLayoutIfNeeded()
        
        guard animated else {
            view.setProgress(newProgress, animated: false)
            if newHidden {
                view.alpha = 0
                view.removeFromSuperview()
            } else {
                view.alpha = 1
            }
            return
        }
        
        // show if need
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            guard newProgress != oldProgress || !newHidden else {
                return
            }
            view.alpha = 1
        }, completion: { isFinish in
            var delay: TimeInterval = 0.35
            // set if need
            if newProgress == oldProgress {
                delay = 0
            }
            view.setProgress(newProgress, animated: true)
            // hidden if need
            UIView.animate(withDuration: 0.25, delay: delay, options: .curveLinear, animations: {
                guard view.progress > 0.999999 || newHidden else {
                    return
                }
                view.alpha = 0
            }, completion: { isFinish in
                guard isFinish else {
                    return
                }
                guard view.progress > 0.999999 || self._progressOfHidden else {
                    return
                }
                view.removeFromSuperview()
            })
        })
    }
    
    fileprivate func _updateIconLayoutIfNeeded() {
        
        let edg = _containterInset
        let nbounds = UIEdgeInsetsInsetRect(self.bounds, contentInset)
       
        var nframe = _iconView.frame
        nframe.origin.x = nbounds.minX + edg.left
        nframe.origin.y = nbounds.minY + edg.top
        nframe.size.height = 27
        _iconView.frame = nframe
    }
    fileprivate func _updateProgressLayoutIfNeeded() {
        guard !_progressOfHidden else {
            return
        }
        //logger.debug(containterView.contentSize)
        
        let edg = _containterInset
        let nframe = UIEdgeInsetsInsetRect(detailView.frame, edg)
        let nbounds = UIEdgeInsetsInsetRect(self.bounds, contentInset)
        
        let width_2 = _progressView.frame.width / 2
        let height_2 = _progressView.frame.height / 2
        
        var pt = convert(CGPoint(x: nframe.maxX - width_2, y: nframe.maxY - height_2), from: detailView.superview)
        
        pt.x = max(min(pt.x, nbounds.maxX - width_2 - edg.right), nbounds.minX + edg.left + width_2)
        pt.y = max(min(pt.y, nbounds.maxY - height_2 - edg.bottom), nbounds.minY + edg.top + height_2)
        
        _progressView.center = pt
    }
    
    
    private func _commonInit() {
        
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        detailView.backgroundColor = UIColor(white: 0.94, alpha: 1)
        
        containterView.frame = bounds
        containterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containterView.delegate = self
        containterView.addSubview(detailView)
        containterView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        super.addSubview(containterView)
    }
}

extension BrowseDetailViewCell: BrowseContainterViewDelegate {
   
    func viewForZooming(in containterView: BrowseContainterView) -> UIView? {
        return detailView
    }
    
    func containterViewDidScroll(_ containterView: BrowseContainterView) {
        _updateProgressLayoutIfNeeded()
    }
    func containterViewDidZoom(_ containterView: BrowseContainterView) {
        _updateProgressLayoutIfNeeded()
    }
    
//    
//    func containterViewWillBeginDragging(_ containterView: SAPContainterView) {
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(true, animated: true)
//        }
//    }
//    func containterViewWillBeginZooming(_ containterView: SAPContainterView, with view: UIView?) {
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(true, animated: true)
//        }
//    }
//    func containterViewShouldBeginRotationing(_ containterView: SAPContainterView, with view: UIView?) -> Bool {
//        _canChangeProgressView = false
//        
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(true, animated: true)
//        }
//        if _automaticallyAdjustsProgressViewIsHidden {
//            _updateProgressViewIsHidden(true, animated: false)
//        }
//        
//        return true
//    }
//    
//    func containterViewDidEndDragging(_ containterView: SAPContainterView, willDecelerate decelerate: Bool) {
//        guard !decelerate else {
//            return
//        }
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(false, animated: true)
//        }
//    }
//    func containterViewDidEndDecelerating(_ containterView: SAPContainterView) {
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(false, animated: true)
//        }
//    }
//    func containterViewDidEndZooming(_ containterView: SAPContainterView, with view: UIView?, atScale scale: CGFloat) {
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(false, animated: true)
//        }
//    }
//    func containterViewDidEndRotationing(_ containterView: SAPContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
//        _canChangeProgressView = true
//        _contentView.orientation = orientation
//        
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(false, animated: true)
//        }
//        if _automaticallyAdjustsProgressViewIsHidden && progress <= 0.999999 {
//            _updateProgressViewLayout()
//            _updateProgressViewIsHidden(false, animated: true)
//        }
//    }
    
    func containterViewShouldBeginRotationing(_ containterView: BrowseContainterView, with view: UIView?) -> Bool {
        
        _canChangeProgressView = false
        
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(true, animated: true)
//        }
        
        
        _updateProgressLock(true, animated: false)
        
        return true//delegate?.browseDetailView?(self, containterView, shouldBeginRotationing: view) ?? true
    }
    
    func containterViewDidEndRotationing(_ containterView: BrowseContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        self.orientation = orientation
        self.detailView.image = detailView.image?.withOrientation(orientation)
        
        delegate?.browseDetailView?(self, containterView, didEndRotationing: view, atOrientation: orientation)
        
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(false, animated: true)
//        }
        
        
        _updateProgressLock(false, animated: true)
    }
}
