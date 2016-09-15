//
//  SAAudioPanel.swift
//  SIMChat
//
//  Created by sagesse on 9/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc public class SAAudioPanel: UIView {
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: 253)
    }
    
    private func _init() {
        _logger.trace()
        
        backgroundColor = .orange
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
