//
//  SAAudioEffectView.swift
//  SIMChat
//
//  Created by sagesse on 9/19/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAAudioEffectView: UICollectionViewCell {
    
    var effect: SAAudioEffect? {
        willSet {
            _updateEffect(newValue)
        }
    }
    
    override var isSelected: Bool {
        set {
            _updateSelected(newValue)
            super.isSelected = newValue
        }
        get {
            return super.isSelected 
        }
    }
    
    private func _updateSelected(_ newValue: Bool) {
        
        _titleButton.isSelected = newValue
    }
    
    private func _updateEffect(_ newValue: SAAudioEffect?) {
        
        _titleButton.setTitle(newValue?.title, for: .normal)
        _playButton.setBackgroundImage(newValue?.image, for: .normal)
    }
    
    private func _init() {
        _logger.trace()
        
        _playButton.translatesAutoresizingMaskIntoConstraints = false
        
        _titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        _titleButton.setTitleColor(.black, for: .normal)
        _titleButton.setTitleColor(.white, for: .selected)
        _titleButton.setBackgroundImage(UIImage(named: "aio_simulate_text_select"), for: .selected)
        _titleButton.isUserInteractionEnabled = false
        _titleButton.translatesAutoresizingMaskIntoConstraints = false
        _titleButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
        
        addSubview(_playButton)
        addSubview(_titleButton)
        
        addConstraints([
            _SALayoutConstraintMake(_playButton, .top, .equal, self, .top),
            _SALayoutConstraintMake(_playButton, .centerX, .equal, self, .centerX),
            
            _SALayoutConstraintMake(_titleButton, .top, .equal, _playButton, .bottom, 4),
            _SALayoutConstraintMake(_titleButton, .centerX, .equal, _playButton, .centerX),
        ])
    }
    
    fileprivate lazy var _playButton: UIButton = UIButton()
    fileprivate lazy var _titleButton: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
