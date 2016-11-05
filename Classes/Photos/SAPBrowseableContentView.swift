//
//  SAPBrowseableContentView.swift
//  SAPhotos
//
//  Created by sagesse on 11/5/16.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

internal class SAPBrowseableContentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    var image: Any? {
        set { 
            
            
            return _imageView.image = newValue as? UIImage 
        }
        get { 
            return _imageView.image 
        }
    }
    var content: Any?
    
    private func _init() {
        
        _imageView.frame = bounds
        _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(_imageView)
    }
    
    private lazy var _imageView: UIImageView = UIImageView()
}
