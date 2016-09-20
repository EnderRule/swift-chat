//
//  SAPhotoView.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

// TODO: 
// [ ] * - 渐进式解码
// [ ] * - 异步加载

internal class SAPhotoView: UIView {
    
    
    private func _init() {
        _logger.trace()
        
        
        _imageView.frame = bounds
        _imageView.backgroundColor = .random
        _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(_imageView)
        //addSubview(_selectedView)
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
