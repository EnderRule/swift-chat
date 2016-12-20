//
//  BrowseViewCell.swift
//  Browser
//
//  Created by sagesse on 11/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseViewCell: UICollectionViewCell {
    
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
            guard asset !== newValue else {
                return
            }
            _previewView.backgroundColor = newValue?.backgroundColor
            _previewView.image = newValue?.browseImage
        }
    }
    
    var previewView: UIImageView {
        return _previewView
    }
    
    private func _commonInit() {
        
        _previewView.contentMode = .scaleAspectFill
        _previewView.frame = contentView.bounds
        _previewView.clipsToBounds = true
        _previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _badgeBar.frame = CGRect(x: 0, y: contentView.bounds.height - 20, width: contentView.bounds.width, height: 20)
        _badgeBar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        
        contentView.addSubview(_previewView)
        contentView.addSubview(_badgeBar)
    }
    
    private lazy var _previewView = UIImageView(frame: .zero)
    private lazy var _badgeBar = BrowseBadgeBar(frame: .zero)
}

