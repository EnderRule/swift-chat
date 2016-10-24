//
//  SAPhotoScrollView2.swift
//  SIMChat
//
//  Created by sagesse on 10/24/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


public class SAPhotoVVVVV: UIImageView {
}

public class SAPhotoContainter: UIView {

    public override func layoutSubviews() {
        super.layoutSubviews()
        //_imageView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        guard _cacheBounds?.size != bounds.size else {
            return
        }
        _cacheBounds = bounds
        
        if let view = viewForZooming(in: _scrollView) {
            // 计算宽高
            let width = max(view.bounds.width * _scrollView.maximumZoomScale, 1)
            let height = max(view.bounds.height * _scrollView.maximumZoomScale, 1)
            // 计算最小缩放比和最大缩放比
            let nscale = min(min(bounds.width / width, bounds.height / height), 1)
            let nmscale = 1 / nscale
            // 计算当前的缩放比
            var oscale = max(view.frame.width / width, view.frame.height / height) * nmscale
            // 边界检查
            if _scrollView.zoomScale == _scrollView.maximumZoomScale {
                oscale = nmscale // max
            }
            if _scrollView.zoomScale == _scrollView.minimumZoomScale {
                oscale = 1 // min
            }
            
            let nwidth = width * nscale
            let nheight = height * nscale
            
            view.bounds = CGRect(x: 0, y: 0, width: nwidth, height: nheight)
            //view.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            
            _scrollView.minimumZoomScale = 1
            _scrollView.maximumZoomScale = nmscale
            _scrollView.zoomScale = max(min(oscale, nmscale), 1)
            
            //_logger.debug("(\(width), \(height)) => (\(nscale), \(nmscale), \(oscale))")
            
            // 重置中心点
            scrollViewDidZoom(_scrollView)
        }
    }
    
    private func _init() {
        
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
        
        _rotationGestureRecognizer.delegate = self
        
        super.addSubview(_scrollView)
        super.addGestureRecognizer(_rotationGestureRecognizer)
        
        _scrollView.backgroundColor = .random
        backgroundColor = .random
        
        _imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 240)
        _imageView.image = UIImage(named: "t1_g.jpg")
        _imageView.backgroundColor = .random
        //_imageView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin]
        
        _scrollView.minimumZoomScale = 1
        _scrollView.maximumZoomScale = 1600 / 320.0
        _scrollView.zoomScale = 1
        
        _scrollView.addSubview(_imageView)
    }
    
    private var _cacheBounds: CGRect?
    
    
    fileprivate lazy var _imageView: UIImageView = SAPhotoVVVVV()
    
//    fileprivate lazy var _tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
    fileprivate lazy var _rotationGestureRecognizer: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationHandler(_:)))
//    fileprivate lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
    
    fileprivate lazy var _scrollView: UIScrollView = UIScrollView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

extension SAPhotoContainter {
    
    func tapHandler(_ sender: UITapGestureRecognizer) {
    }
    
    func doubleTapHandler(_ sender: UITapGestureRecognizer) {
    }
    
    func rotationHandler(_ sender: UIRotationGestureRecognizer) {
    }
}

extension SAPhotoContainter: UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view === _scrollView {
            return true
        }
        return false
    }
    
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return _imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let view = viewForZooming(in: scrollView) else {
            return
        }
        // 重置大小
        let size = view.sizeThatFits(bounds.size)
        
        // 重置中心点
        let x = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let y = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        
        view.center = CGPoint(x: scrollView.contentSize.width / 2 + x, y: scrollView.contentSize.height / 2 + y)
    }
}
