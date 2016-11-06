//
//  SAPBrowseableDetailView.swift
//  SAPhotos
//
//  Created by sagesse on 11/1/16.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

class TIImage: NSObject, Progressiveable {
    
    dynamic var content: Any?  {
        didSet {
            didChangeProgressiveContent()
        }
    }
    dynamic var progress: Double = 0 {
        didSet {
            didChangeProgressiveProgress()
        }
    }
}
class TIVideo: NSObject, Progressiveable {
    
    dynamic var content: Any?  {
        didSet {
            didChangeProgressiveContent()
        }
    }
    dynamic var progress: Double = 0 {
        didSet {
            didChangeProgressiveProgress()
        }
    }
}

class TestVideo: NSObject, SAPBrowseable {
    
    var browseType: SAPBrowseableType {
        return .Video
    }
    
    var browseSize: CGSize { 
        return CGSize(width: 1600, height: 1200)
    }
    var browseOrientation: UIImageOrientation  {
        return .up
    }
    
    var browseImage: Progressiveable? { 
        let item = TIImage() 
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            item.content = UIImage(named: "t1_t.jpg")
            item.progress = 0.15
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                item.content = UIImage(named: "t1_g.jpg")
                item.progress = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                    item.content = UIImage(named: "t1.jpg")
                    item.progress = 1
                }
            }
        }
        return item
    }
    var browseContent: Progressiveable? { 
        return nil
    }  // 这个参数只用于视频和音频
}

internal class SAPBrowseableDetailView: UIView, SAPContainterViewDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    var contentView: UIView {
        return _contentView
    }
    var containterView: SAPContainterView {
        return _containterView
    }
    
    private dynamic var _image: Any? {
        set { return _contentView.image = newValue }
        get { return _contentView.image }
    }
    private dynamic var _content: Any? {
        set { return _contentView.content = newValue }
        get { return _contentView.content }
    }
    
    private dynamic var progress: Double {
        set { return setProgress(newValue, animated: false) }
        get { return _progress }
    }
    
    dynamic var contents: SAPBrowseable? {
        willSet {
            guard contents !== newValue else {
                return
            }
            setProgressiveValue(newValue?.browseImage, forKey: #keyPath(SAPBrowseableDetailView._image))
            //setProgressiveValue(newValue?.browseContent, forKey: #keyPath(SAPBrowseableDetailView._content))
            
            _contentView.orientation = newValue?.browseOrientation ?? .up
            
            _containterView.contentSize = newValue?.browseSize ?? .zero
            _containterView.zoom(to: bounds, with: _contentView.orientation, animated: false)
            
            _updateEdgeInsets()
        }
    }
    
    override func progressiveValue(_ progressiveValue: Progressiveable?, didChangeProgress value: Any?, context: String) {
        guard context == #keyPath(SAPBrowseableDetailView._image) else {
            return
        }
        _logger.trace(value)
        
        setProgress(value as? Double ?? 0, animated: true)
    }
    
    
    func setProgress(_ progress: Double, animated: Bool) {
        
        _progressView.setProgress(progress, animated: _progress < progress && animated) 
        _progress = progress
        
        if fabs(1 - progress) < 0.000001 {
            // 隐藏进度条
            guard animated else {
                _hideProgressView(animated: animated)
                return
            }
            // 等待动画完成
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                guard progress == self._progress else {
                    return
                }
                self._hideProgressView(animated: animated)
            }
        } else {
            // 显示进度条
            guard _canChangeProgressView else {
                return
            }
            _showProgressView(animated: animated)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if _cacheBounds?.size != _contentView.bounds.size {
            _updateEdgeInsets()
        }
    }
    
    // MARK: - Events
    
    dynamic func tapHandler(_ sender: AnyObject) {
        _logger.trace()
        
    }
    dynamic func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        
        if _containterView.zoomScale != _containterView.minimumZoomScale {
            _containterView.setZoomScale(_containterView.minimumZoomScale, at: sender.location(in: _contentView), animated: true)
        } else {
            _containterView.setZoomScale(_containterView.maximumZoomScale, at: sender.location(in: _contentView), animated: true)
        }
    }
    
    
    func viewForZooming(in containterView: SAPContainterView) -> UIView? {
        return _contentView
    }
    
    func containterViewDidScroll(_ containterView: SAPContainterView) {
        if _canChangeProgressView {
            _updateEdgeInsets()
        }
    }
    func containterViewDidZoom(_ containterView: SAPContainterView) {
        if _canChangeProgressView {
            _updateEdgeInsets()
        }
    }
    
    func containterViewShouldBeginRotationing(_ containterView: SAPContainterView, with view: UIView?) -> Bool {
        _canChangeProgressView = false
        _hideProgressView(animated: false)
        return true
    }
    
    func containterViewDidEndRotationing(_ containterView: SAPContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        // 更新图片
        if let view = view as? SAPBrowseableContentView {
            view.orientation = orientation
        }
        if progress < 1 && 1 - progress > 0.000001 {
            // 并没有结束
            _updateEdgeInsets()
            _showProgressView(animated: true)
        }
        _canChangeProgressView = true
    }
    
    private func _showProgressView(animated: Bool) {
        guard _progressViewIsHidden else {
            return
        }
        _progressViewIsHidden = false
        
        // prepare
        let view = _progressView
        view.alpha = 0
        view.isHidden = false
        addSubview(view)
        
        let animations: (Void) -> Void = {
            view.alpha = 1
        }
        let completion: (Bool) -> Void = { _ in
            guard !self._progressViewIsHidden else {
                return
            }
            view.alpha = 1
            view.isHidden = false
        }
        guard animated else {
            animations()
            completion(false)
            return
        }
        UIView.transition(with: view, duration: 0.25, options: .curveEaseInOut, animations: animations, completion: completion)
    }
    private func _hideProgressView(animated: Bool) {
        guard !_progressViewIsHidden else {
            return
        }
        _progressViewIsHidden = true
        
        // prepare
        let view = _progressView
        view.alpha = 1
        view.isHidden = false
        
        let animations: (Void) -> Void = {
            view.alpha = 0
        }
        let completion: (Bool) -> Void = { _ in
            guard self._progressViewIsHidden else {
                return
            }
            view.alpha = 1
            view.isHidden = true
            view.removeFromSuperview()
        }
        guard animated else {
            animations()
            completion(false)
            return
        }
        UIView.transition(with: view, duration: 0.25, options: .curveEaseInOut, animations: animations, completion: completion)
    }
    
    private func _updateEdgeInsets() {
        
        let edg = UIEdgeInsetsMake(8, 8, 8, 8)
        let nframe = UIEdgeInsetsInsetRect(_contentView.frame, edg)
        let nbounds = UIEdgeInsetsInsetRect(self.bounds, _contentInset)
        
        let width_2 = _progressView.frame.width / 2
        let height_2 = _progressView.frame.height / 2
        
        var pt = convert(CGPoint(x: nframe.maxX - width_2, y: nframe.maxY - height_2), from: _contentView.superview)
        
        pt.x = max(min(pt.x, nbounds.maxX - width_2 - edg.right), nbounds.minX + edg.left + width_2)
        pt.y = max(min(pt.y, nbounds.maxY - height_2 - edg.bottom), nbounds.minY + edg.top + height_2)
        
        _progressView.center = pt
        _cacheBounds = _contentView.bounds
    }
    
    private func _init() {
        
        _tapGestureRecognizer.require(toFail: _doubleTapGestureRecognizer)
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        _contentView.isUserInteractionEnabled = false
        
        _containterView.frame = bounds
        _containterView.delegate = self
        _containterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _containterView.addSubview(contentView)
        
        _containterView.addGestureRecognizer(_tapGestureRecognizer)
        _containterView.addGestureRecognizer(_doubleTapGestureRecognizer)
        
        addSubview(_containterView)
        
        
//        let view = UIImageView()
//        let image = UIImage(named: "t3.jpg")
//        
//        view.image = image
//        view.backgroundColor = .random
//        view.isUserInteractionEnabled = false
//        
//        _containterView.addSubview(view)
//        _containterView.contentSize = image?.size ?? CGSize(width: 1600, height: 1200)
//        _contentView = view
        
        _contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        
//        //progress = 0.2
//        let t = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(clock), userInfo: nil, repeats: true)
//        
//        RunLoop.current.add(t, forMode: .commonModes)
//        
//        self.timer = t
//        self.timer?.fire()
        
        self.reload()
    }
    func clock() {
        
        if self.progress > 1 || fabs(1 - self.progress) < 0.000001 {
            self.setProgress(0, animated: true)
        } else {
            self.setProgress(progress + 0.25, animated: true)
        }
    }
    
    @IBAction func reload() {
        DispatchQueue.main.async {
            self.contents = TestVideo()
        }
    }
    
    var timer: Timer?
    
    private var _cacheBounds: CGRect?
    private var _canChangeProgressView: Bool = true
    
    private var _contentInset: UIEdgeInsets = .zero
    
    private var _contentView: SAPBrowseableContentView = SAPBrowseableContentView()
    
    private var _progress: Double = 1
    private var _progressView: SAPBrowseableProgressView = SAPBrowseableProgressView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
    private var _progressViewIsHidden: Bool = true
    
    private var _controlView: UIView?
    
    private lazy var _containterView: SAPContainterView = SAPContainterView()
    
    private lazy var _tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
    private lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
}
