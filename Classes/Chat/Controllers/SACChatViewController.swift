//
//  SACChatViewController.swift
//  SAChat
//
//  Created by sagesse on 01/11/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

///
/// 聊天控制器
///
open class SACChatViewController: UIViewController {
    
     public required init(conversation: SACConversationProtocol) {
        self.conversation = conversation
         super.init(nibName: nil, bundle: nil)
        
         hidesBottomBarWhenPushed = true
         
//         let name = conversation.receiver.name ?? conversation.receiver.identifier
//         if conversation.receiver.type == .user {
//             title = "正在和\(name)聊天"
//         } else {
//             title = name
//         }
     }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
//        SACNotificationCenter.removeObserver(self)
//        SIMLog.trace()
    }
    
    
    open var conversation: SACConversationProtocol
    
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
