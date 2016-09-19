//
//  SAAudioEffect.swift
//  SIMChat
//
//  Created by sagesse on 9/19/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal enum SAAudioEffectType: Int {
    
    case original = 0
    case ef1 = 1 // 萝莉
    case ef2 = 2 // 大叔
    case ef3 = 3 // 惊悚
    case ef4 = 4// 搞怪
    case ef5 = 5// 空灵
    
    case custom = 999
    
}

internal class SAAudioEffect: NSObject {
    
    init(type: SAAudioEffectType) {
        self.type = type
        super.init()
    }
    
    var type: SAAudioEffectType
    
    var title: String? {
        if type.rawValue < _titles.count {
            return _titles[type.rawValue]
        }
        return nil
    }
    var image: UIImage? {
        if let image = _image {
            return image
        }
        let image = UIImage(named: "aio_simulate_effect_\(type.rawValue)")
        _image = image
        return image
    }
    
    private var _image: UIImage??
    private lazy var _titles: [String] = [
        "原声",
        "萝莉",
        "大叔",
        "惊悚",
        "搞怪",
        "空灵",
    ]
}
