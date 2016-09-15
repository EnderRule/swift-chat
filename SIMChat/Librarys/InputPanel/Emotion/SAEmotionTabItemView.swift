//
//  SAEmotionTabItemView.swift
//  SIMChatDev
//
//  Created by sagesse on 9/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAEmotionTabItemView: UICollectionViewCell {
    
    var group: SAEmotionGroup? {
        willSet {
            guard group !== newValue else {
                return
            }
            _imageView.image = newValue?.thumbnail
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        _imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        _line.frame = CGRect(x: bounds.maxX - 0.25, y: 8, width: 0.5, height: bounds.height - 16)
    }
    
    private func _init() {
        //_logger.trace()
        
        _line.backgroundColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        
        _imageView.contentMode = .scaleAspectFit
        _imageView.bounds = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        contentView.addSubview(_imageView)
        contentView.layer.addSublayer(_line)
        
        selectedBackgroundView = UIView()
    }
    
    private lazy var _imageView: UIImageView = UIImageView()
    private lazy var _line: CALayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

