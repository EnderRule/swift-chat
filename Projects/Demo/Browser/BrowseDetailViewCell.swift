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
        
        _progressView.progress = 0
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
        
        _progress = 0.25
        
        // 最后再更新进度信息
        _updateProgress(false, progress: _progress, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self._progress = 0.35
            self._updateProgress(false, progress: self._progress, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self._progress = 0.65
                self._updateProgress(false, progress: self._progress, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    self._progress = 1
                    self._updateProgress(false, progress: self._progress, animated: true)
                })
            })
        })
    }
    
    fileprivate var _asset: Browseable?
    
    fileprivate lazy var _progress: Double = 0.25
    fileprivate lazy var _progressView: BrowseProgressView = BrowseProgressView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
    fileprivate lazy var _progressIsHidden: Bool = true
    
    fileprivate func _updateProgress(_ proposedHidden: Bool, animated: Bool) {
        _updateProgress(proposedHidden, progress: _progress, animated: animated)
    }
    fileprivate func _updateProgress(_ proposedHidden: Bool, progress: Double, animated: Bool) {
        let view = _progressView
        let full = progress > 0.999999 // progress >= 1.0(±0.000001)
        let hidden = proposedHidden 
        
        // progress is change && required show
        
        _progress = progress
        
        // required show & progress is full & animation enable = dely
        
        if !hidden {
            _progressView.setProgress(progress, animated: animated)
            _updateProgressLayoutIfNeeded()
        }
        // 是否需要延迟
        
        // show(animation) => progress(animation)
        // progress(animation) => hide(animation)
        
        guard _progressIsHidden != hidden else {
            return
        }
        if !hidden {
            addSubview(view)
        }
        _progressIsHidden = hidden
        _updateProgressLayoutIfNeeded()
        
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        CATransaction.setCompletionBlock { 
            // if hidden need remove view
            guard self._progressIsHidden else {
                return
            }
            view.removeFromSuperview()
        }
        
        // need animation?
        if !animated {
            CATransaction.setDisableActions(true)
        }
        
        // if is hidden alpha is 0 else alpha is 1
        view.alpha = hidden ? 0 : 1
        
        CATransaction.commit()
    }
    fileprivate func _updateProgressLayoutIfNeeded() {
        guard !_progressIsHidden else {
            return
        }
        logger.debug(containterView.contentSize)
        
        let edg = UIEdgeInsetsMake(8, 8, 8, 8)
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
        
        
        _updateProgress(true, animated: true)
        
        return true//delegate?.browseDetailView?(self, containterView, shouldBeginRotationing: view) ?? true
    }
    
    func containterViewDidEndRotationing(_ containterView: BrowseContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        self.orientation = orientation
        self.detailView.image = detailView.image?.withOrientation(orientation)
        
        delegate?.browseDetailView?(self, containterView, didEndRotationing: view, atOrientation: orientation)
        
//        if _automaticallyAdjustsControlViewIsHidden {
//            _updateControlViewIsHidden(false, animated: true)
//        }
        
        
        _updateProgress(false, animated: true)
    }
}
