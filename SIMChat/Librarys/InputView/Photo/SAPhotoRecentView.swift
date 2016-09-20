//
//  SAPhotoRecentView.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoRecentView: UICollectionViewCell {
    
    
    private func _init() {
        _logger.trace()
        
        _photoView.frame = bounds
        _photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(_photoView)
    }
    
    private lazy var _photoView: SAPhotoView = SAPhotoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
