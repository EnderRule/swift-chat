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
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
        _updateEdgeInsets()
    }
    
    // MARK: - Events
    
    dynamic func tapHandler(_ sender: AnyObject) {
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
    
    func containterViewDidZoom(_ containterView: SAPContainterView) {
        _updateEdgeInsets()
    }
    func containterViewDidEndRotationing(_ containterView: SAPContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        // 更新图片
        if let view = view as? UIImageView {
            view.image = view.image?.withOrientation(orientation)
        }
        
        _updateEdgeInsets()
    }
    
    private func _updateEdgeInsets() {
        
        if let view = _progressView, let contentView = _contentView {
            
            
            var nframe = view.frame
            
            nframe.origin.x = contentView.frame.maxX - nframe.width - 8
            nframe.origin.y = contentView.frame.maxY - nframe.height - 8
            
            _logger.trace("\(convert(nframe, from: _containterView)) => \(contentView.superview?.frame)")
            

            view.frame = nframe
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
        
        backgroundColor = .random
        _containterView.backgroundColor = .random
        
        
        let view = UIImageView()
        
        view.image = UIImage(named: "t1_g.jpg")
        view.backgroundColor = .random
        view.isUserInteractionEnabled = false
        
        _containterView.addSubview(view)
        _containterView.contentSize = CGSize(width: 1600, height: 1200)
        _contentView = view
        
        
        let view2 = SAPDisplayableProgressView()
        
        view2.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        view2.progress = 0.2
        view2.isUserInteractionEnabled = false
        
        _progressView = view2
        
        _containterView.addSubview(view2)
    }
    
    private var _contentInset: UIEdgeInsets = .zero
    
    private var _contentView: UIView?
    
    private var _controlView: UIView?
    private var _progressView: UIView?
    
    private lazy var _containterView: SAPContainterView = SAPContainterView()
    
    private lazy var _tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
    private lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
}
