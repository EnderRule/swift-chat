//
//  SAInputTextFieldItem.swift
//  SAInputBar
//
//  Created by sagesse on 8/3/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAInputTextFieldItem: SAInputItem {
    
    init(textView: UITextView, backgroundView: UIImageView) {
        super.init()
        
        _textView = textView
        _backgroundView = backgroundView
        
        _backgroundView.image = _SAInputDefaultTextFieldBackgroundImage
    }
    
    override var font: UIFont? {
        set { return _textView.font = newValue }
        get { return _textView.font }
    }
    
    override var tintColor: UIColor? {
        set { return _textView.tintColor = newValue }
        get { return _textView.tintColor }
    }
    
    override var image: UIImage? {
        set { return _backgroundView.image = newValue }
        get { return _backgroundView.image }
    }
    
    var needsUpdateContent: Bool {
        let newValue = _textView.contentSize
        let oldValue = _cacheContentSize ?? CGSize.zero
        
        if newValue.width != _textView.frame.width {
            return true
        }
        if newValue.height == oldValue.height {
            return false
        }
        if newValue.height <= _maxHeight {
            // 没有超出去
            return true
        }
        if oldValue.height < _maxHeight {
            // 虽然己经超出去了, 但还没到最大值呢
            return true
        }
        return false
    }
    var contentSize: CGSize {
        return size
    }
    
    override var size: CGSize {
        set { }
        get {
            if let size = _cacheSize {
                return size
            }
            let size = sizeThatFits()
            _cacheSize = size
            _cacheContentSize = _textView.contentSize
            return size
        }
    }
    
    func contentSizeChanged() {
        if needsUpdateContent {
            _cacheSize = nil
        }
        //self.setNeedsLayout()
    }
    
    func invalidateCache() {
        _logger.trace()
        
        _cacheSize = nil
        _cacheContentSize = nil
    }
    
    func sizeThatFits() -> CGSize {
        _logger.trace()
        
        let textSize = _textView.sizeThatFits(CGSize(width: _textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let size = CGSize(width: _textView.bounds.width, height: min(textSize.height + 0.5, _maxHeight))
        return size
    }
    
    var _maxHeight: CGFloat = 106
    
    var _cacheSize: CGSize?
    var _cacheContentSize: CGSize?
    
    weak var _textView: UITextView!
    weak var _backgroundView: UIImageView!
}
