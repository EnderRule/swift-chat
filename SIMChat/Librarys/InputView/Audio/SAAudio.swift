//
//  SAAudio.swift
//  SIMChat
//
//  Created by sagesse on 9/16/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public enum SAAudioType: CustomStringConvertible {
    
    case talkback               // 对讲
    case record                 // 录音
    case simulate               // 变声
    
    public var description: String { 
        switch self {
        case .talkback: return "Talkback"
        case .simulate: return "Simulate"
        case .record:   return "Record"
        }
    }
} 

open class SAAudio: NSObject {

    
    open var type: SAAudioType = .talkback
}


