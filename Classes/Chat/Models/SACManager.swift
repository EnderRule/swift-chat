//
//  SACManager.swift
//  SAChat
//
//  Created by sagesse on 01/11/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

open class SACManager: NSObject {
    
    public init(user: SACUserProtocol) {
        self.user = user
        super.init()
    }
    deinit {
    }
   
    open var user: SACUserProtocol
    
    
    ///
    /// 获取一个会话/创建一个会话
    ///
    /// - parameter receiver: 接收者信息
    /// - returns: 会话信息
    ///
    open func conversation(with receiver: SACUserProtocol) -> SACConversationProtocol {
        return SACConversation(receiver: receiver, sender: user)
    }
    
    
    internal static var mainBundle: Bundle? {
        return _frameworkMainBundle
    }
}

private weak var _frameworkMainBundle: Bundle? = Bundle(identifier: "SA.SAChat")
