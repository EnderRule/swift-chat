//
//  SAAudioPlayToolbar.swift
//  SIMChat
//
//  Created by sagesse on 9/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAAudioPlayToolbar: UIView {
    
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
        
        let line1 = UIView()
        let line2 = UIView()
        
        line1.backgroundColor = .lightGray
        line1.translatesAutoresizingMaskIntoConstraints = false
        line2.backgroundColor = .lightGray
        line2.translatesAutoresizingMaskIntoConstraints = false
        
        _confirmButton.setTitle("发送", for: UIControlState())
        _confirmButton.setTitleColor(.gray, for: .normal)
        _confirmButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_nor"), for: .normal)
        _confirmButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_press"), for: .highlighted)
        _confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        _cancelButton.setTitle("取消", for: UIControlState())
        _cancelButton.setTitleColor(.gray, for: UIControlState())
        _cancelButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_nor"), for: .normal)
        _cancelButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_press"), for: .highlighted)
        _cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(_cancelButton)
        addSubview(_confirmButton)
        addSubview(line1)
        addSubview(line2)
        
        addConstraint(_SALayoutConstraintMake(_cancelButton, .top, .equal, line2, .bottom))
        addConstraint(_SALayoutConstraintMake(_cancelButton, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_cancelButton, .right, .equal, line1, .left))
        addConstraint(_SALayoutConstraintMake(_cancelButton, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_cancelButton, .width, .equal, _confirmButton, .width))
        
        addConstraint(_SALayoutConstraintMake(_confirmButton, .top, .equal, line2, .bottom))
        addConstraint(_SALayoutConstraintMake(_confirmButton, .left, .equal, line1, .right))
        addConstraint(_SALayoutConstraintMake(_confirmButton, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_confirmButton, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(line1, .top, .equal, line2, .bottom))
        addConstraint(_SALayoutConstraintMake(line1, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(line2, .top, .equal, self, .top))
        addConstraint(_SALayoutConstraintMake(line2, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(line2, .right, .equal, self, .right))
        
        addConstraint(_SALayoutConstraintMake(line1, .width, .equal, nil, .width, 1 / UIScreen.main.scale))
        addConstraint(_SALayoutConstraintMake(line2, .height, .equal, nil, .height, 1 / UIScreen.main.scale))
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
