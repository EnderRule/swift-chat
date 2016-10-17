//
//  SAPhotoPickerForAssetsCell.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


internal class SAPhotoPickerForAssetsCell: UICollectionViewCell {
    
    var album: SAPhotoAlbum?
    
    lazy var photoView: SAPhotoView = SAPhotoView()
    
    override var contentView: UIView {
        return photoView
    }
    
    private func _init() {
        
        photoView.frame = bounds
        photoView.allowsSelection = true
        photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        super.contentView.removeFromSuperview()
        addSubview(contentView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
