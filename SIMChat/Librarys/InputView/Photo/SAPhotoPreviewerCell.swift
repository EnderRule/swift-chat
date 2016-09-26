//
//  SAPhotoPreviewerCell.swift
//  SIMChat
//
//  Created by sagesse on 9/24/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPreviewerCell: UICollectionViewCell {
   
    var photo: SAPhoto? {
        set { return _photoView.photo = newValue }
        get { return _photoView.photo }
    }
    
    private func _init() {
        
        _photoView.frame = contentView.bounds
        _photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.addSubview(_photoView)
    }
    
    private var _photoView: SAPhotoLargeView = SAPhotoLargeView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
