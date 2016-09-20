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
    
    func audioEffect(_ audioEffect: SAAudioEffect, shouldStartProcessAt url: URL) -> Bool
    func audioEffect(_ audioEffect: SAAudioEffect, didStartProcessAt url: URL)
    
    func audioEffect(_ audioEffect: SAAudioEffect, didFinishProcessAt url: URL)
    func audioEffect(_ audioEffect: SAAudioEffect, didErrorOccur error: NSError)
}

internal class SAAudioEffect: NSObject {
    
    func stop() {
    }
    
    func process(at url: URL) {
        guard delegate?.audioEffect(self, shouldStartProcessAt: url) ?? true else {
            return
        }
        delegate?.audioEffect(self, didStartProcessAt: url)
        
        // 如果是原声, 直接返回不需要做任何处理
        guard type != .original else {
            delegate?.audioEffect(self, didFinishProcessAt: url)
            return
        }
        let nurl = url.appendingPathExtension("\(type).ef")
        // 如果己经处理过了, 直接返回不需要做额外处理
        if let dst = lastDestURL, lastSrcURL == url {
            delegate?.audioEffect(self, didFinishProcessAt: dst)
            return
        }
        // 开始处理
        process(from: url, to: nurl) {
            if let err = $1 {
                self.lastSrcURL = url
                self.lastDestURL = nil
                self.delegate?.audioEffect(self, didErrorOccur: err)
            } else {
                self.lastSrcURL = url
                self.lastDestURL = $0
                self.delegate?.audioEffect(self, didFinishProcessAt: $0)
            }
        }
    }
    
    func process(from srcURL: URL, to destURL: URL, clouser: @escaping (URL, NSError?) -> Void) {
        dispatch_after_at_now(1, .global()) {
            let fm = FileManager.default
            
            _ = try? fm.removeItem(at: srcURL)
            _ = try? fm.copyItem(at: srcURL, to: destURL)
            
            DispatchQueue.main.async {
                clouser(destURL, nil)
            }
        }
    }
    
    func clearCache() {
        lastSrcURL = nil
        lastDestURL = nil
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
    
    // 最后一次处理的文件
    var lastSrcURL: URL?
    var lastDestURL: URL?
    
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
