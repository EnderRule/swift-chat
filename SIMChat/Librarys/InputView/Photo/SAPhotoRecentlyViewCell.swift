//
//  SAPhotoRecentlyViewCell.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
    

internal class SAPhotoRecentlyViewCell: UICollectionViewCell {
    
    lazy var photoView: SAPhotoView = SAPhotoView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoView.updateEdge()
    }
    
    private func _init() {
        
        photoView.frame = bounds
        photoView.allowsSelection = true
        photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(photoView)
        backgroundColor = .white
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
