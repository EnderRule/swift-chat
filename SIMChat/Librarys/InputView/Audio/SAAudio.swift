//
//  SAAudio.swift
//  SIMChat
//
//  Created by sagesse on 9/16/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    
    open func recorder(at url: URL) -> AVAudioRecorder? {
        // remove old file
        if FileManager.default.fileExists(atPath: url.path) {
            try! FileManager.default.removeItem(at: url)
        }
        // config
        let settings: Dictionary<String, AnyObject> =  [
            AVFormatIDKey: Int(kAudioFormatLinearPCM) as AnyObject,               // 设置录音格式: kAudioFormatLinearPCM
            AVSampleRateKey: 44100 as AnyObject,                                  // 设置录音采样率(Hz): 8000/44100/96000(影响音频的质量)
            AVNumberOfChannelsKey: 1 as AnyObject,                                // 录音通道数: 1/2
            AVLinearPCMBitDepthKey: 16 as AnyObject,                              // 线性采样位数: 8/16/24/32
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue as AnyObject   // 录音的质量
        ]
        // 开启音频会话
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        _ = try? AVAudioSession.sharedInstance().setActive(true)
        // create
        return try? AVAudioRecorder(url: url as URL, settings: settings)
    }
    open func requestRecordPermission(_ response: @escaping (Bool) -> Void) {
        //AVAudioSession.sharedInstance().requestRecordPermission(response)
        AVAudioSession.sharedInstance().requestRecordPermission({ b in
            dispatch_after_at_now(1, DispatchQueue.main, { 
                response(b)
            })
        })
    }
    
    open var type: SAAudioType = .talkback
}

