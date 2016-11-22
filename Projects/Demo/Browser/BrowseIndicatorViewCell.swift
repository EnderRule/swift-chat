//
//  BrowseIndicatorViewCell.swift
//  Browser
//
//  Created by sagesse on 11/22/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseIndicatorViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    
    var asset: Browseable? {
        willSet {
            imageView.image = newValue?.browseImage
            imageView.backgroundColor = newValue?.backgroundColor
        }
    }
    override var contentView: UIView {
        return imageView
    }
    
    private func _commonInit() {
        
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        clipsToBounds = true
        
        super.addSubview(imageView)
        super.contentView.removeFromSuperview()
    }
    
    lazy var imageView: UIImageView = UIImageView()
}
