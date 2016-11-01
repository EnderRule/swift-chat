//
//  SACConversation.swift
//  SAChat
//
//  Created by sagesse on 01/11/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

open class SACConversation: NSObject, SACConversationProtocol {
    
    init(receiver: SACUserProtocol, sender: SACUserProtocol) {
        self.sender = sender
        self.receiver = receiver
        super.init()
    }
    
    /// 发送者
    open var sender: SACUserProtocol
    
    /// 接收者
    open var receiver: SACUserProtocol
    
}
