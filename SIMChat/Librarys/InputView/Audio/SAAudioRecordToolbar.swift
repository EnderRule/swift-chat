//
//  SAAudioRecordToolbar.swift
//  SIMChat
//
//  Created by sagesse on 9/16/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAAudioRecordToolbar: UIView {
    
    var leftView: UIImageView { return _leftView }
    var rightView: UIImageView { return _rightView }
    
    var leftBackgroundView: UIImageView { return _leftBackgroundView }
    var rightBackgroundView: UIImageView { return _rightBackgroundView }
    
    private func _init() {
        _logger.trace()
        
        _line.image = UIImage(named: "aio_toolbar_op_line")
        _line.translatesAutoresizingMaskIntoConstraints = false
        
        _leftView.image = UIImage(named: "aio_toolbar_op_listen_nor")
        _leftView.highlightedImage = UIImage(named: "aio_toolbar_op_listen_press")
        _leftView.translatesAutoresizingMaskIntoConstraints = false
        
        _rightView.image = UIImage(named: "aio_toolbar_op_delete_nor")
        _rightView.highlightedImage = UIImage(named: "aio_toolbar_op_delete_press")
        _rightView.translatesAutoresizingMaskIntoConstraints = false
        
        _leftBackgroundView.image = UIImage(named: "aio_toolbar_op_nor")
        _leftBackgroundView.highlightedImage = UIImage(named: "aio_toolbar_op_press")
        _leftBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        _rightBackgroundView.image = UIImage(named: "aio_toolbar_op_nor")
        _rightBackgroundView.highlightedImage = UIImage(named: "aio_toolbar_op_press")
        _rightBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // add subview
        addSubview(_line)
        addSubview(_leftBackgroundView)
        addSubview(_rightBackgroundView)
        addSubview(_leftView)
        addSubview(_rightView)
        
        // add constraint s
        addConstraint(_SALayoutConstraintMake(_line, .top, .equal, self, .top, 14))
        addConstraint(_SALayoutConstraintMake(_line, .left, .equal, self, .left, 3.5))
        addConstraint(_SALayoutConstraintMake(_line, .right, .equal, self, .right, -3.5))
        addConstraint(_SALayoutConstraintMake(_line, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_leftBackgroundView, .top, .equal, self, .top))
        addConstraint(_SALayoutConstraintMake(_leftBackgroundView, .left, .equal, self, .left))
        
        addConstraint(_SALayoutConstraintMake(_rightBackgroundView, .top, .equal, self, .top))
        addConstraint(_SALayoutConstraintMake(_rightBackgroundView, .right, .equal, self, .right))
        
        addConstraint(_SALayoutConstraintMake(_leftView, .centerX, .equal, _leftBackgroundView, .centerX))
        addConstraint(_SALayoutConstraintMake(_leftView, .centerY, .equal, _leftBackgroundView, .centerY))
        addConstraint(_SALayoutConstraintMake(_rightView, .centerX, .equal, _rightBackgroundView, .centerX))
        addConstraint(_SALayoutConstraintMake(_rightView, .centerY, .equal, _rightBackgroundView, .centerY))
    }
    
    private lazy var _line: UIImageView = UIImageView()
    
    private lazy var _leftView: UIImageView = UIImageView()
    private lazy var _rightView: UIImageView = UIImageView()
    
    private lazy var _leftBackgroundView: UIImageView = UIImageView()
    private lazy var _rightBackgroundView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
}
