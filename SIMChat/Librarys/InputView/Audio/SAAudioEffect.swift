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

internal protocol SAAudioEffectDelegate: NSObjectProtocol {
    
    func audioEffect(_ audioEffect: SAAudioEffect, shouldPrepareProcessAt url: URL) -> Bool
    func audioEffect(_ audioEffect: SAAudioEffect, didPrepareProcessAt url: URL)
    
    func audioEffect(_ audioEffect: SAAudioEffect, shouldStartProcessAt url: URL) -> Bool
    func audioEffect(_ audioEffect: SAAudioEffect, didStartProcessAt url: URL)
    
    func audioEffect(_ audioEffect: SAAudioEffect, didFinishProcessAt url: URL)
    func audioEffect(_ audioEffect: SAAudioEffect, didErrorOccur error: NSError)
}

internal class SAAudioEffect: NSObject {
    
    func stop() {
    }
    
    func process(at url: URL) {
        
        guard delegate?.audioEffect(self, shouldPrepareProcessAt: url) ?? true else {
            return
        }
        dispatch_after_at_now(1, .main) { 
            self.delegate?.audioEffect(self, didPrepareProcessAt: url)
            
            //        let nurl = url.appendingPathExtension(".\(type).ef")
            
            guard self.delegate?.audioEffect(self, shouldStartProcessAt: url) ?? true else {
                return
            }
            self.delegate?.audioEffect(self, didStartProcessAt: url)
                
            dispatch_after_at_now(1, .main) { 
                //self.delegate?.audioEffect(self, didErrorOccur: nurl)
                self.delegate?.audioEffect(self, didFinishProcessAt: url)
            }
        }
    }
    
    var type: SAAudioEffectType
    weak var delegate: SAAudioEffectDelegate?
    
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
    
    init(type: SAAudioEffectType) {
        self.type = type
        super.init()
    }
    
}
