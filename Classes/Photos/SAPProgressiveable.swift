//
//  SAPProgressiveable.swift
//  SIMChat
//
//  Created by sagesse on 10/13/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 可渐进协议
///
@objc public protocol SAPProgressiveable: NSObjectProtocol {
    
    ///
    /// 内容
    ///
    var content: Any? { set get }
    
    ///
    /// 添加监听者
    ///
    /// - Parameter observer: 监听者, 这是weak
    ///
    func addObserver(_ observer: SAPProgressiveableObserver)
    
    ///
    /// 移除监听者(如果有)
    ///
    /// - Parameter observer: 监听者
    ///
    func removeObserver(_ observer: SAPProgressiveableObserver)
}


///
/// 可渐进监听器
///
@objc public protocol SAPProgressiveableObserver: NSObjectProtocol {
    
    ///
    /// 内容发生改变
    ///
    func progressiveable(_ progressiveable: SAPProgressiveable, didChangeContent content: Any?)
}

