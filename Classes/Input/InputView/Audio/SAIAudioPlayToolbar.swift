//
//  SAIAudioPlayToolbar.swift
//  SAC
//
//  Created by sagesse on 9/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAIAudioPlayToolbar: UIView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: -1, height: 44)
    }
    
    internal var confirmButton: UIButton {
        return _confirmButton
    }
    internal var cancelButton: UIButton {
        return _cancelButton
    }
    
    private func _init() {
        _logger.trace()
        
        _confirmButton.setTitle("发送", for: UIControlState())
        _confirmButton.setTitleColor(.gray, for: .normal)
        _confirmButton.setTitleColor(.gray, for: .disabled)
        _confirmButton.setBackgroundImage(UIImage(named: "aio_toolbar_send_nor"), for: .normal)
        _confirmButton.setBackgroundImage(UIImage(named: "aio_toolbar_send_nor"), for: .disabled)
        _confirmButton.setBackgroundImage(UIImage(named: "aio_toolbar_send_press"), for: .highlighted)
        _confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        _cancelButton.setTitle("取消", for: UIControlState())
        _cancelButton.setTitleColor(.gray, for: UIControlState())
        _cancelButton.setBackgroundImage(UIImage(named: "aio_toolbar_cancel_nor"), for: .normal)
        _cancelButton.setBackgroundImage(UIImage(named: "aio_toolbar_cancel_oress"), for: .highlighted)
        _cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(_cancelButton)
        addSubview(_confirmButton)
        
        addConstraint(_SAAudioLayoutConstraintMake(_cancelButton, .top, .equal, self, .top))
        addConstraint(_SAAudioLayoutConstraintMake(_cancelButton, .left, .equal, self, .left))
        addConstraint(_SAAudioLayoutConstraintMake(_cancelButton, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAAudioLayoutConstraintMake(_cancelButton, .right, .equal, _confirmButton, .left))
        addConstraint(_SAAudioLayoutConstraintMake(_cancelButton, .width, .equal, _confirmButton, .width))
        
        addConstraint(_SAAudioLayoutConstraintMake(_confirmButton, .top, .equal, self, .top))
        addConstraint(_SAAudioLayoutConstraintMake(_confirmButton, .right, .equal, self, .right))
        addConstraint(_SAAudioLayoutConstraintMake(_confirmButton, .bottom, .equal, self, .bottom))
    }
    
    private lazy var _cancelButton: UIButton = UIButton()
    private lazy var _confirmButton: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
