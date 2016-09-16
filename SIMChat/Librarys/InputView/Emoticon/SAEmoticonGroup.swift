//
//  SAEmoticonGroup.swift
//  SIMChat
//
//  Created by sagesse on 9/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public enum SAEmoticonType: Int {
    
    case small = 0
    case large = 1
    
    public var isSmall: Bool { return self == .small }
    public var isLarge: Bool { return self == .large }
}

open class SAEmoticonGroup: NSObject {
    
    open lazy var id: String = UUID().uuidString
    
    open var title: String?
    open var thumbnail: UIImage?
    
    open var type: SAEmoticonType = .small
    open var emoticons: [SAEmoticon] = []
}

