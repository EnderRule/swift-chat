//
//  SAAudio.swift
//  SIMChat
//
//  Created by sagesse on 9/16/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public enum SAAudioType {
    case talkback               // 对讲
    case record                 // 录音
    case simulate               // 变声
} 

open class SAAudio: NSObject {

    
    open var type: SAAudioType = .talkback
}


