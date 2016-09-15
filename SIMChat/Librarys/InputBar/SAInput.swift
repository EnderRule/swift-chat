//
//  SAInput.swift
//  SAInputBar
//
//  Created by sagesse on 8/3/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public enum SAInputMode {
    case none
    case editing
    case selecting(UIView)
}
public enum SAInputItemPosition: Int {
    case top        = 0
    case left       = 1
    case right      = 3
    case bottom     = 4
    case center     = 2
}
public enum SAInputItemAlignment: Int {
    //0xvvhh
    case top            = 0x0104 // Top + Center(H)
    case bottom         = 0x0204 // Bottom + Center(H)
    case left           = 0x0401 // Center(V) + Left
    case right          = 0x0402 // Center(V) + Right
    case topLeft        = 0x0101 // Top + Left
    case topRight       = 0x0102 // Top + Right
    case bottomLeft     = 0x0201 // Bottom + Left
    case bottomRight    = 0x0202 // Bottom + Right
    case center         = 0x0404 // Center(V) + Center(H)
    
    case automatic      = 0x0000
}

extension SAInputMode: CustomStringConvertible {
    public var isNone: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
    public var isEditing: Bool {
        switch self {
        case .editing: return true
        default: return false
        }
    }
    public var isSelecting: Bool {
        switch self {
        case .selecting: return true
        default: return false
        }
    }
    
    public var description: String {
        switch self {
        case .none: return "None"
        case .editing(_): return "Editing"
        case .selecting(_): return "Selecting"
        }
    }
}
extension SAInputItemPosition: CustomStringConvertible {
    public var description: String {
        switch self {
        case .top: return "Top(\(rawValue))"
        case .left: return "Left(\(rawValue))"
        case .right: return "Right(\(rawValue))"
        case .bottom: return "Bottom(\(rawValue))"
        case .center:  return "Center(\(rawValue))"
        }
    }
}

/// Cretae an `NSLayoutConstraint`
@inline(__always)
internal func _SAInputLayoutConstraintMake(_ item: AnyObject, _ attr1: NSLayoutAttribute, _ related: NSLayoutRelation, _ toItem: AnyObject? = nil, _ attr2: NSLayoutAttribute = .notAnAttribute, _ constant: CGFloat = 0, _ multiplier: CGFloat = 1, output: UnsafeMutablePointer<NSLayoutConstraint?>? = nil) -> NSLayoutConstraint {
    
    let c = NSLayoutConstraint(item:item, attribute:attr1, relatedBy:related, toItem:toItem, attribute:attr2, multiplier:multiplier, constant:constant)
    if output != nil {
        output?.pointee = c
    }
    
    return c
}

@inline(__always)
internal func _SAInputExchangeSelector(_ cls: AnyClass?, _ sel1: String, _ sel2: String) {
    _SAInputExchangeSelector(cls, Selector(sel1), Selector(sel2))
}
@inline(__always)
internal func _SAInputExchangeSelector(_ cls: AnyClass?, _ sel1: Selector, _ sel2: Selector) {
    guard let cls = cls else {
        return
    }
    method_exchangeImplementations(class_getInstanceMethod(cls, sel1), class_getInstanceMethod(cls, sel2))
}

internal var _SAInputDefaultTextFieldBackgroundImage: UIImage? = {
    // 生成默认图片
    
    let radius = CGFloat(8)
    let rect = CGRect(x: 0, y: 0, width: 32, height: 32)
    let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
    
    UIColor.white.setFill()
    
    path.fill()
    path.addClip()
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image?.resizableImage(withCapInsets: UIEdgeInsetsMake(radius, radius, radius, radius))
}()

internal var _SAInputDefaultAnimateDuration: TimeInterval = 0.25
internal var _SAInputDefaultAnimateCurve: UIViewAnimationCurve = UIViewAnimationCurve(rawValue: 7) ?? .easeInOut

