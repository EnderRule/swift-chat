//
//  BrowseIndicatorViewCell.swift
//  Browser
//
//  Created by sagesse on 11/22/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseIndicatorViewCell: BrowseTilingViewCell {
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let size = asset?.browseContentSize {
            let scale = bounds.height / size.height
            let width = size.width * scale
            let height = bounds.height
            
            imageView.frame = CGRect(x: (bounds.width - width) / 2, y: (bounds.height - height) / 2, width: width, height: height)
        }
    }
    
    private func _commonInit() {
        
        //imageView.frame = bounds
        //imageView.contentMode = .scaleAspectFill
        //imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        clipsToBounds = true
        
        addSubview(imageView)
    }
    
    lazy var imageView: UIImageView = UIImageView()
}
