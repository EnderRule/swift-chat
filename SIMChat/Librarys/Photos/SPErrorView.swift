//
//  SPErrorView.swift
//  SIMChat
//
//  Created by sagesse on 9/28/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SPErrorView: UIView {
    
    var title: String? {
        set { return _titleLabel.text = newValue }
        get { return _titleLabel.text }
    }
    
    var subtitle: String? {
        set { return _subtitleLabel.text = newValue }
        get { return _subtitleLabel.text }
    }
    
    private func _init() {
        
        let view = UIView()
        
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        _titleLabel.font = UIFont.systemFont(ofSize: 28)
        _titleLabel.textColor = .lightGray
        _titleLabel.textAlignment = .center
        _titleLabel.numberOfLines = 0
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        _subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        _subtitleLabel.textColor = .lightGray
        _subtitleLabel.textAlignment = .center
        _subtitleLabel.numberOfLines = 0
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(_titleLabel)
        view.addSubview(_subtitleLabel)
        
        view.addConstraints([
            _SPLayoutConstraintMake(_titleLabel, .top, .equal, view, .top),
            _SPLayoutConstraintMake(_titleLabel, .left, .equal, view, .left),
            _SPLayoutConstraintMake(_titleLabel, .right, .equal, view, .right),
            
            _SPLayoutConstraintMake(_subtitleLabel, .top, .equal, _titleLabel, .bottom, 16),
            
            _SPLayoutConstraintMake(_subtitleLabel, .left, .equal, view, .left),
            _SPLayoutConstraintMake(_subtitleLabel, .right, .equal, view, .right),
            _SPLayoutConstraintMake(_subtitleLabel, .bottom, .equal, view, .bottom),
        ])
        
        addSubview(view)
        addConstraints([
            _SPLayoutConstraintMake(view, .left, .equal, self, .left, 20),
            _SPLayoutConstraintMake(view, .right, .equal, self, .right, -20),
            _SPLayoutConstraintMake(view, .centerY, .equal, self, .centerY),
        ])
    }
    
    private lazy var _titleLabel: UILabel = UILabel()
    private lazy var _subtitleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
