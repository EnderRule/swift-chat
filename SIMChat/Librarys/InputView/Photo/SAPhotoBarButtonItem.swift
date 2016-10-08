//
//  SAPhotoBarButtonItem.swift
//  SIMChat
//
//  Created by sagesse on 9/22/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal enum SAPhotoBarButtonItemType: Int {
    case normal
    case original
    case send
}

internal class SAPhotoBarButtonItem: UIBarButtonItem {

    override var title: String? {
        set {
            _customView.titleLabel?.text = newValue
            _customView.setTitle(newValue, for: .normal)
            _customView.sizeToFit()
            
            if _type == .send {
                var nframe = _customView.frame
                nframe.size.width = max(nframe.width, 70)
                _customView.frame = nframe
            }
        }
        get {
            return _customView.title(for: .normal)
        }
    }
    
    override var isEnabled: Bool {
        set { return _customView.isEnabled = newValue }
        get { return _customView.isEnabled }
    }
    
    var button: UIButton {
        return _customView
    }
    
    init(title: String?, type: SAPhotoBarButtonItemType = .normal, target: Any?, action: Selector?) {
        switch type {
        case .normal:
            _type = type
            _customView = SAPhotoBarButtonItem._makeNormalButton(title)
            
        case .original:
            _type = type
            _customView = SAPhotoBarButtonItem._makeNormalButton(title)
            _customView.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4)
            _customView.setImage(UIImage(named: "photo_small_checkbox_normal"), for: .normal)
            _customView.setImage(UIImage(named: "photo_small_checkbox_selected"), for: .selected)
            _customView.sizeToFit()
            
        case .send:
            _type = type
            _customView = SAPhotoBarButtonItem._makeSendButton(title)
            
        }
        
        super.init()
        customView = _customView
        isEnabled = true
        
        guard let action = action else {
            return
        }
        _customView.addTarget(target, action: action, for: .touchUpInside)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func _makeNormalButton(_ title: String?) -> UIButton {
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.sizeToFit()
        
        return button
    }
    private static func _makeSendButton(_ title: String?) -> UIButton {
        let button = UIButton(type: .custom)
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.contentEdgeInsets = UIEdgeInsetsMake(4, 8, 4, 8)
        button.setBackgroundImage(UIImage(named: "photo_button_confirm_nor"), for: .normal)
        button.setBackgroundImage(UIImage(named: "photo_button_confirm_press"), for: .highlighted)
        button.setBackgroundImage(UIImage(named: "photo_button_confirm_disabled"), for: .disabled)
        button.sizeToFit()
        button.frame = CGRect(x: 0, y: 0, width: 70, height: button.frame.height)
        
        return button
    }
    
    private var _customView: UIButton
    private var _type: SAPhotoBarButtonItemType
}

