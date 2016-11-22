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
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    lazy var previewView: UIImageView = UIImageView()
    
    var asset: Browseable? {
        willSet {
            guard asset !== newValue else {
                return
            }
            previewView.backgroundColor = newValue?.backgroundColor
            previewView.image = newValue?.browseImage
        }
    }
    
    private func _init() {
        
        previewView.contentMode = .scaleAspectFill
        previewView.frame = contentView.bounds
        previewView.clipsToBounds = true
        previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.addSubview(previewView)
    }
}

