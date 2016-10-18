//
//  SAPhotoPickerForPreviewerCell.swift
//  SIMChat
//
//  Created by sagesse on 9/24/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPickerForPreviewerCell: UICollectionViewCell {
    
    var photo: SAPhoto? {
        set { return photoView.photo = newValue }
        get { return photoView.photo }
    }
    var photoContentOrientation: UIImageOrientation {
        set { return photoView.photoContentOrientation = newValue }
        get { return photoView.photoContentOrientation }
    }
    
    weak var delegate: SAPhotoBrowserViewDelegate? {
        set { return photoView.delegate = newValue }
        get { return photoView.delegate }
    }
    
    private func _init() {
        
        photoView.frame = contentView.bounds
        photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.addSubview(photoView)
        contentView.clipsToBounds = true
    }
    
    lazy var photoView: SAPhotoBrowserView = SAPhotoBrowserView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
