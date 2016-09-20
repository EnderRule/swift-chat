//
//  SAPhotoInputView.swift
//  SIMChat
//
//  Created by sagesse on 9/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc
public protocol SAPhotoInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
    
    @objc optional func photo(_ photo: SAPhotoInputView, shouldStartRecord url: URL) -> Bool
    @objc optional func photo(_ photo: SAPhotoInputView, didStartRecord url: URL)
    
    @objc optional func photo(_ photo: SAPhotoInputView, didRecordComplete url: URL, duration: TimeInterval)
    @objc optional func photo(_ photo: SAPhotoInputView, didRecordFailure url: URL, duration: TimeInterval)
}

open class SAPhotoInputView: UIView {
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: 253)
    }
    
    private func _init() {
        _logger.trace()
        
        backgroundColor = .purple
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
