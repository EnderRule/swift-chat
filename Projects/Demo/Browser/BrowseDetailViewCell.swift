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
    dynamic func playHandler(_ sender: Any) {
        logger.debug()
        
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
        
        // 最后再更新UI信息
        _updateIcon(0)
        _updatexxx()
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
        
        _consoleView.stop()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard _cachedBounds != bounds else {
            return
        }
        _cachedBounds = bounds
        _updateIconLayoutIfNeeded()
        _updateCenterLayoutIfNeeded()
        _updateProgressLayoutIfNeeded()
    }
    
    private var _cachedBounds: CGRect?
    
    fileprivate var _containterInset: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    
    fileprivate var _asset: Browseable?
    
    fileprivate var _progress: Double = 0
    fileprivate var _progressOfLock: Double?
    fileprivate var _progressOfHidden: Bool = true
    
    fileprivate var _stateOfLock: Bool = false
    
    fileprivate func _updateStateLock(_ lock: Bool, animated: Bool) {
        guard _stateOfLock != lock && !_progressOfHidden else {
            return
        }
        _logger.debug("\(lock)")
        
        _stateOfLock = lock
        
        UIView.animate(withDuration: 0.25, animations: {
            self._consoleView.alpha = lock ? 0 : 1
        })
    }
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
    
    fileprivate func _updateIcon(_ icon: Any) {
        
        let view = _iconView
        if view.superview != self {
            addSubview(view)
        }
        _updateIconLayoutIfNeeded()
    }
    
    fileprivate func _updatexxx() {
        let view = _consoleView
        if view.superview != self {
            addSubview(view)
        }
        _updateCenterLayoutIfNeeded()
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
        let bounds = UIEdgeInsetsInsetRect(self.bounds, contentInset)
       
        var nframe = _iconView.frame
        nframe.origin.x = bounds.minX + edg.left
        nframe.origin.y = bounds.minY + edg.top
        nframe.size.height = 27
        _iconView.frame = nframe
    }
    fileprivate func _updateCenterLayoutIfNeeded() {
        
        _consoleView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    fileprivate func _updateProgressLayoutIfNeeded() {
        guard !_progressOfHidden else {
            return
        }
        //logger.debug(containterView.contentSize)
        
        let edg = _containterInset
        let size = _progressView.frame.size
        let frame = convert(detailView.frame, from: detailView.superview)
        let bounds = UIEdgeInsetsInsetRect(self.bounds, contentInset)
        
        let y2 = min(frame.maxY, bounds.maxY)
        let x2 = min(max(frame.maxX, min(max(frame.minX, bounds.minX) + frame.width, bounds.maxX)), bounds.maxX)
        
        _progressView.center = CGPoint(x: x2 - size.width / 2 - edg.right, y: y2 - size.height / 2 - edg.bottom)
    }
    
    
    private func _commonInit() {
        
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        detailView.backgroundColor = UIColor(white: 0.94, alpha: 1)
        
        containterView.frame = bounds
        containterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containterView.delegate = self
        containterView.addSubview(detailView)
        containterView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        _iconView.frame = CGRect(x: 0, y: 0, width: 60, height: 26)
        _iconView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        _iconView.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4)
        _iconView.isUserInteractionEnabled = false
        _iconView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        _iconView.tintColor = UIColor.black.withAlphaComponent(0.6)
        _iconView.layer.cornerRadius = 3
        _iconView.layer.masksToBounds = true
        
        _iconView.setTitle("HDR", for: .normal)
        _iconView.setImage(UIImage(named: "icon_hdr"), for: .normal)
        
        _consoleView.delegate = self
        
        _progressView.radius = (_progressView.bounds.width / 2) - 3
        _progressView.isUserInteractionEnabled = false
        
        super.addSubview(containterView)
    }
    
    fileprivate lazy var _iconView = UIButton(type: .system)
    fileprivate lazy var _consoleView = BrowseVideoConsoleView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
    fileprivate lazy var _progressView = BrowseOverlayProgressView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
}

extension BrowseDetailViewCell: BrowseVideoConsoleViewDelegate {
    
    func videoConsoleView(didPlay videoConsoleView: BrowseVideoConsoleView) {
        videoConsoleView.wait()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
            videoConsoleView.play()
        })
    }
    func videoConsoleView(didStop videoConsoleView: BrowseVideoConsoleView) {
        videoConsoleView.stop()
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
    
    func containterViewWillBeginDragging(_ containterView: BrowseContainterView) {
        _updateStateLock(true, animated: true)
    }
    
    func containterViewWillBeginZooming(_ containterView: BrowseContainterView, with view: UIView?) {
        _updateStateLock(true, animated: true)
    }
    
    func containterViewShouldBeginRotationing(_ containterView: BrowseContainterView, with view: UIView?) -> Bool {
        guard delegate?.browseDetailView?(self, containterView, shouldBeginRotationing: view) ?? true else {
            return false
        }
        
        _updateStateLock(true, animated: true)
        _updateProgressLock(true, animated: false)
        
        return true
    }
    
    func containterViewDidEndDragging(_ containterView: BrowseContainterView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        _updateStateLock(false, animated: true)
    }
    
    func containterViewDidEndDecelerating(_ containterView: BrowseContainterView) {
        _updateStateLock(false, animated: true)
    }
    
    func containterViewDidEndZooming(_ containterView: BrowseContainterView, with view: UIView?, atScale scale: CGFloat) {
        _updateStateLock(false, animated: true)
    }
    
    func containterViewDidEndRotationing(_ containterView: BrowseContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        self.orientation = orientation
        self.detailView.image = detailView.image?.withOrientation(orientation)
        
        delegate?.browseDetailView?(self, containterView, didEndRotationing: view, atOrientation: orientation)
        
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(false, animated: true)
//        }
        
        _updateProgressLock(false, animated: true)
        _updateStateLock(false, animated: true)
    }
}
