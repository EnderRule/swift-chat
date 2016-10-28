//
//  SAMAudioSession.swift
//  SAMedia
//
//  Created by sagesse on 27/10/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

open class SAMAudioSession: NSObject {
    
    open static func setCategory(_ category: String) throws {
        try AVAudioSession.sharedInstance().setCategory(category)
    }
    open static func setCategory(_ category: String, with options: AVAudioSessionCategoryOptions) throws {
        try AVAudioSession.sharedInstance().setCategory(category, with: options)
    }
    
    open static func setActive(_ active: Bool, context: AnyObject? = nil) throws {
        try SAMAudioSessionSynchronized(SAMAudioSession.self) {
            guard !active else {
                _task = NSUUID().uuidString
                _context = context
                _hashValue = context?.hashValue
                try AVAudioSession.sharedInstance().setActive(active)
                return
            }
            deactive(delay: 1, context: context) {
                _ = try? AVAudioSession.sharedInstance().setActive(active)
            }
        }
    }
    open static func setActive(_ active: Bool, with options: AVAudioSessionSetActiveOptions, context: AnyObject? = nil) throws {
        try SAMAudioSessionSynchronized(SAMAudioSession.self) {
            guard !active else {
                _task = NSUUID().uuidString
                _context = context
                _hashValue = context?.hashValue
                try AVAudioSession.sharedInstance().setActive(active, with: options)
                return
            }
            deactive(delay: 1, context: context) {
                _ = try? AVAudioSession.sharedInstance().setActive(active, with: options)
            }
        }
    }
    
    open static func deactive(delay: TimeInterval, context: AnyObject?, execute: @escaping (Void) -> Void) {
        SAMAudioSessionSynchronized(SAMAudioSession.self) {
            
            guard _context == nil || _hashValue == context?.hashValue else {
                return // 不匹配, 说明别人正在使用
            }
            let task = NSUUID().uuidString
            let hashValue = context?.hashValue
            
            if _hashValue != hashValue {
                _context = context
            }
        
            _task = task
            _hashValue = hashValue
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000))) {
                SAMAudioSessionSynchronized(SAMAudioSession.self) {
                    guard _task == task else {
                        return // can't deactive, the task is expire
                    }
                    guard _context == nil || _hashValue == hashValue else {
                        return // can't deactive, the other is use
                    }
                    execute()
                    _hashValue = nil
                }
            }
        }
    }
    
    private static var _task: String?
    private static var _hashValue: Int?
    private static weak var _context: AnyObject?
}

internal func SAMAudioSessionSynchronized<Result>(_ ob: AnyObject, invoking body: () throws -> Result) rethrows -> Result {
    objc_sync_enter(ob)
    defer {
        objc_sync_exit(ob)
    }
    return try body()
}
