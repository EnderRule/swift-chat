//
//  SAPhotoPickerForPreviewerCell.swift
//  SIMChat
//
//  Created by sagesse on 9/24/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPickerForPreviewerCell: UICollectionViewCell {
   
    var loader: SAPhotoLoaderType? {
        set { return _photoView.loader = newValue }
        get { return _photoView.loader }
    }
    weak var delegate: SAPhotoBrowserViewDelegate? {
        set { return _photoView.delegate = newValue }
        get { return _photoView.delegate }
    }
    
    private func _init() {
        
        _photoView.frame = contentView.bounds
        _photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.addSubview(_photoView)
        contentView.clipsToBounds = true
    }
    
    private var _photoView: SAPhotoBrowserView = SAPhotoBrowserView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
