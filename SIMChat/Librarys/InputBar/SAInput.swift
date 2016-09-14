//
//  SAInput.swift
//  SAInputBar
//
//  Created by sagesse on 8/3/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

//
// 关于为什么采用inputAccessoryView
//
// 1. 如果使用view，present转场的时候图片会直接覆盖键盘(自定义键盘和选项), 而accessoryView不会
// 2. 如果使用accessoryView可以避免侧滑手势的冲突问题
// 3. 如果使用view并且self.view是scrollview， 为了保持键盘在低部 需要不停的调整他的位置， 这必然会造成性能损耗
//

// 需要测试的动画: present, dismiss, pop(返回上一级), pop(从下一级回来), push

// accessoryview + subview 可行, 但切换自定义键盘的时候动画可能发生抖动(第三方输入法非常明显), 暂采用该方案. 
//   发生抖动的原因是因为, 多次调整约束, 导致动画不同步.
//   或许可以在动画期间添加一个参考视图在window上 - 失败
//   或许可以在第二次调整约束的时候同时调整动画 - 有效(暂采用, 可是过滤还是不完美, 很生硬)
//
// accessoryview + contentView(subview + 全屏模式), iOS8的dimmsMode不支持(不同步的约束, contentView位置改变了)
// accessoryview + superview 好像可行, 但是未测试动画
// accessoryview + subview + superview.superview.bottom 失败(动画并没有任何改变)

// 快照的方式有两种:
//    -[UIScreen snapshotViewAfterScreenUpdates:]
//    -[UIView snapshotViewAfterScreenUpdates:] UIView => UIInputSetContainerView

// ## TODO
// [x] SAInputTextField - 动态高度支持
// [x] SAInputAccessoryView - barItem支持, 更随意的组合, 上下左右+中心
// [x] SAInputAccessoryView - barItem对齐支持
// [x] SAInputAccessoryView - barItem自定义支持
// [x] SAInputAccessoryView - barItem选中支持
// [x] SAInputBar - dismmsMode支持
// [ ] SAInputBar - 切换自定键盘和第三方输入法时的键盘抖动问题 - 还是有问题, 背景导致的(暂时禁用动画)
// [ ] SAInputTextField - 输入框自定表情支持(TextKit) - p2
// [x] SAInputTextField - 输入框高度限制
// [x] SAInputAccessoryView - 更新barItem - 自动计算
// [x] SAInputAccessoryView - 更新barItem - 动画(包含: 插入, 删除, 更新)
// [x] SAInputView - 自定义键盘的切换动画
// [x] SAInputView - 高度显示错误
// [x] SAInputView - AutoLayout支持
// [ ] SAInputView - iOS8键盘重叠
// [x] SAInputView - 多次切换后键盘消失
// [x] SAInputAccessoryView - iOS8的图片拉伸问题 
// [x] SAInputAccessoryView - iOS8自定义键盘切换至系统键盘(物理键盘输入)位置异常
// [x] * - 分离源文件
// [ ] * - code review - p2
// [x] * - 内嵌资源(矢量图)
// [ ] * - 移除跟踪日志 - p0
// [ ] SAInputAccessoryView - barItem重用支持(现是不允许存在两个相同的barItem)
// [ ] SAInputBar - 横/竖屏双布局(InputAccessView和InputView)
// [x] SAInputAccessoryView - 多次转屏后barItem会报错
// [ ] SAInputAccessoryView - 批量更新barItem(多组更新)
// [x] SAInputBarDisplayable - 弹出事件(两个模式: 跟随模式)
// [x] SAInputBarDisplayable - 大小改变事件, 跟随模式
// [ ] SAInputBarDisplayable - 转屏后contentOffset可能超出contentSize
// [x] SAInputBarDisplayable - dismmsMode支持, scrollIndicatorInsets跟随
// [x] SAInputBarDisplayable - 切换页面时显示异常
// [x] SAInputBarDisplayable - 初始化动画异常
// [ ] SAInputBarDisplayable - 兼容UICollectionViewController/UITableViewController - 中止(系统行为太多)
// [x] SAInputBackgroundViwe - 自定义背景
// [ ] SAInputBackgroundViwe - 透明背景显示异常

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
internal func _SAInputLayoutConstraintMake(_ item: AnyObject, _ attr1: NSLayoutAttribute, _ related: NSLayoutRelation, _ toItem: AnyObject? = nil, _ attr2: NSLayoutAttribute = .notAnAttribute, _ constant: CGFloat = 0, _ multiplier: CGFloat = 1, output: UnsafeMutablePointer<NSLayoutConstraint?>? = nil) -> NSLayoutConstraint {
    
    let c = NSLayoutConstraint(item:item, attribute:attr1, relatedBy:related, toItem:toItem, attribute:attr2, multiplier:multiplier, constant:constant)
    if output != nil {
        output?.pointee = c
    }
    
    return c
}

internal func _SAInputExchangeSelector(_ cls: AnyClass?, _ sel1: String, _ sel2: String) {
    _SAInputExchangeSelector(cls, Selector(sel1), Selector(sel2))
}
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

