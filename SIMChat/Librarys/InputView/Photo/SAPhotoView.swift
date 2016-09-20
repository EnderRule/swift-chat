//
//  SAPhotoView.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoView: UIView {
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateEdge()
    }
    
    func updateEdge() {
        guard let window = window else {
            return
        }
        let x = convert(CGPoint(x: window.bounds.width, y: 0), from: window).x
        let edg = UIEdgeInsetsMake(4.5, 4.5, 4.5, 4.5)

        var nframe = _selectedView.bounds
        
        // 悬停处理
        nframe.origin.x = max(min(x, bounds.width) - edg.right - nframe.width, edg.left)
        nframe.origin.y = edg.top
        
        if _selectedView.frame != nframe {
            _selectedView.frame = nframe
        }
    }
    
    var photo: SAPhoto? {
        willSet {
            //_logger.trace(photo?.identifier)
        }
    }
    
    private func _init() {
        _logger.trace()
        
        _imageView.frame = bounds
        _imageView.backgroundColor = .random
        _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _selectedView.frame = CGRect(x: bounds.width - 4.5 - 23, y: 4.5, width: 23, height: 23)
        _selectedView.backgroundColor = .random
        _selectedView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        
        addSubview(_imageView)
        addSubview(_selectedView)
    }
    
    private lazy var _imageView: UIImageView = UIImageView()
    private lazy var _selectedView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
