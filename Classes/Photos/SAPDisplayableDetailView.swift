//
//  SAPDisplayableDetailView.swift
//  SAPhotos
//
//  Created by sagesse on 11/1/16.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

internal class SAPDisplayableDetailView: UIView, SAPContainterViewDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    var progress: Double {
        set { return setProgress(newValue, animated: false) }
        get { return _progress }
    }
    
    func setProgress(_ progress: Double, animated: Bool) {
       
        _progress = progress
        _progressView?.setProgress(progress, animated: animated)
        
        if fabs(1 - progress) < 0.000001 {
            // 隐藏进度条
            guard let view = _progressView else {
                return
            }
            guard animated && !_containterView.isRotationing else {
                _progressView?.removeFromSuperview()
                _progressView = nil
                return
            }
            UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseIn, animations: {
                view.alpha = 0
            }, completion: { isFinished in
                guard progress == self._progress else {
                    return
                }
                self._progressView?.removeFromSuperview()
                self._progressView = nil
            })
        } else {
            // 显示进度条
            let view = _progressView ?? SAPDisplayableProgressView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
            
            _progressView = view
            _updateEdgeInsets()
            
            guard view.superview != self else {
                return
            }
            addSubview(view)
            _progressView?.setProgress(progress, animated: animated)
            
            guard !_containterView.isRotationing else {
                view.alpha = 0
                return
            }
            guard animated  else {
                view.alpha = 1
                return
            }
            
            view.alpha = 0
            UIView.transition(with: view, duration: 0.25, options: .curveEaseIn, animations: {
                view.alpha = 1
            }, completion: { isFinished in
                // ..
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _updateEdgeInsets()
    }
    
    // MARK: - Events
    
    dynamic func tapHandler(_ sender: AnyObject) {
        _logger.trace()
        
    }
    dynamic func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        guard let contentView = _contentView else {
            return
        }
        if _containterView.zoomScale != _containterView.minimumZoomScale {
            _containterView.setZoomScale(_containterView.minimumZoomScale, at: sender.location(in: contentView), animated: true)
        } else {
            _containterView.setZoomScale(_containterView.maximumZoomScale, at: sender.location(in: contentView), animated: true)
        }
    }
    
    
    func viewForZooming(in containterView: SAPContainterView) -> UIView? {
        return _contentView
    }
    
    func containterViewDidScroll(_ containterView: SAPContainterView) {
        if !containterView.isRotationing {
            _updateEdgeInsets()
        }
    }
    func containterViewDidZoom(_ containterView: SAPContainterView) {
        if !containterView.isRotationing {
            _updateEdgeInsets()
        }
    }
//    func containterViewDidRotation(_ containterView: SAPContainterView) {
//        _updateEdgeInsets()
//    }
    
    func containterViewShouldBeginRotationing(_ containterView: SAPContainterView, with view: UIView?) -> Bool {
        if let view = _progressView {
            UIView.animate(withDuration: 0.1) {
                view.alpha = 0
            }
        }
        return true
    }
    
    func containterViewDidEndRotationing(_ containterView: SAPContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        // 更新图片
        if let view = view as? UIImageView {
            view.image = view.image?.withOrientation(orientation)
        }
        _updateEdgeInsets()
        if let view = _progressView, view.alpha != 1 {
            UIView.animate(withDuration: 0.25) {
                view.alpha = 1
            }
        }
    }
    
    private func _updateEdgeInsets() {
        
        if let view = _progressView, let contentView = _contentView {
            let edg = UIEdgeInsetsMake(8, 8, 8, 8)
            let nframe = UIEdgeInsetsInsetRect(contentView.frame, edg)
            let nbounds = UIEdgeInsetsInsetRect(self.bounds, _contentInset)
            
            let width_2 = view.frame.width / 2
            let height_2 = view.frame.height / 2
            
            var pt = convert(CGPoint(x: nframe.maxX - width_2, y: nframe.maxY - height_2), from: contentView.superview)
            
            pt.x = max(min(pt.x, nbounds.maxX - width_2 - edg.right), nbounds.minX + edg.left + width_2)
            pt.y = max(min(pt.y, nbounds.maxY - height_2 - edg.bottom), nbounds.minY + edg.top + height_2)
            
            view.center = pt
        }
    }
    
    private func _init() {
        
        _tapGestureRecognizer.require(toFail: _doubleTapGestureRecognizer)
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        _containterView.frame = bounds
        _containterView.delegate = self
        _containterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _containterView.addGestureRecognizer(_tapGestureRecognizer)
        _containterView.addGestureRecognizer(_doubleTapGestureRecognizer)
        
        addSubview(_containterView)
        
        
        let view = UIImageView()
        let image = UIImage(named: "t3.jpg")
        
        view.image = image
        view.backgroundColor = .random
        view.isUserInteractionEnabled = false
        
        _containterView.addSubview(view)
        _containterView.contentSize = image?.size ?? CGSize(width: 1600, height: 1200)
        _contentView = view
        
        
        _contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        
        let t = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(clock), userInfo: nil, repeats: true)
        
        RunLoop.current.add(t, forMode: .commonModes)
        
        self.timer = t
        self.timer?.fire()
    }
    func clock() {
        
        if self.progress > 1 || fabs(1 - self.progress) < 0.000001 {
            self.setProgress(0, animated: true)
        } else {
            self.setProgress(progress + 0.25, animated: true)
        }
    }
    
    var timer: Timer?
    
    private var _contentInset: UIEdgeInsets = .zero
    
    private var _contentView: UIView?
    
    private var _progress: Double = 1
    private var _progressView: SAPDisplayableProgressView?
    private var _progressIsAnimating: Bool = false
    
    private var _controlView: UIView?
    
    private lazy var _containterView: SAPContainterView = SAPContainterView()
    
    private lazy var _tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
    private lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
}
