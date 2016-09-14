//
//  SAInputItem.swift
//  SAInputBar
//
//  Created by sagesse on 8/3/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public class SAInputItem: NSObject {
    
    // MARK: property
    
    public lazy var identifier: String = UUID().uuidString
    
    public var size: CGSize = CGSize.zero // default is CGSizeZero
    public var image: UIImage? // default is nil
    public var customView: UIView? // default is nil
    
    public var tag: Int = 0 // default is 0
    public var title: String? // default is nil
    public var enabled: Bool = true // default is YES
    
    public var font: UIFont? // default is nil
    public var backgroundColor: UIColor? // default is nil
    
    public var handler: ((SAInputItem) -> Void)? // default is nil
    
    public var tintColor: UIColor?
    public var alignment: SAInputItemAlignment = .automatic
    public var imageInsets: UIEdgeInsets = .zero // default is UIEdgeInsetsZero
    
    // MARK: setter
    
    public func setTitle(_ title: String?, for state: UIControlState) {
        _titles[state.rawValue] = title
    }
    public func setTitleColor(_ color: UIColor?, for state: UIControlState) {
        _titleColors[state.rawValue] = color
    }
    public func setTitleShadowColor(_ color: UIColor?, for state: UIControlState) {
        _titleShadowColors[state.rawValue] = color
    }
    public func setAttributedTitle(_ title: NSAttributedString?, for state: UIControlState) {
        _attributedTitles[state.rawValue] = title
    }
    public func setImage(_ image: UIImage?, for state: UIControlState) {
        _images[state.rawValue] = image
    }
    public func setBackgroundImage(_ image: UIImage?, for state: UIControlState) {
        _backgroundImages[state.rawValue] = image
    }
    
    // MARK: getter
    
    public func title(for state: UIControlState) -> String? {
        return _titles[state.rawValue] ?? nil
    }
    public func titleColor(for state: UIControlState) -> UIColor? {
        return _titleColors[state.rawValue] ?? nil
    }
    public func titleShadowColor(for state: UIControlState) -> UIColor? {
        return _titleShadowColors[state.rawValue] ?? nil
    }
    public func attributedTitle(for state: UIControlState) -> NSAttributedString? {
        return _attributedTitles[state.rawValue] ?? nil
    }
    public func image(for state: UIControlState) -> UIImage? {
        return _images[state.rawValue] ?? nil
    }
    public func backgroundImage(for state: UIControlState) -> UIImage? {
        return _backgroundImages[state.rawValue] ?? nil
    }
    
    // MARK: create
    
    public override init() {
        super.init()
    }
    public convenience init(image: UIImage?, handler: ((SAInputItem) -> Void)? = nil) {
        self.init()
        self.image = image
        self.handler = handler
    }
    public convenience init(title: String?, handler: ((SAInputItem) -> Void)? = nil) {
        self.init()
        self.title = title
        self.handler = handler
    }
    
    public convenience init(customView: UIView) {
        self.init()
        self.customView = customView
    }
    
    public override var hash: Int {
        return identifier.hash
    }
    public override var hashValue: Int {
        return identifier.hashValue
    }
    
    // MARK: ivar
    
    internal var _titles: [UInt: String?] = [:]
    internal var _titleColors: [UInt: UIColor?] = [:]
    internal var _titleShadowColors: [UInt: UIColor?] = [:]
    internal var _attributedTitles: [UInt: NSAttributedString?] = [:]
    
    internal var _images: [UInt: UIImage?] = [:]
    internal var _backgroundImages: [UInt: UIImage?] = [:]
}

