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

internal enum SAAudioStatus: CustomStringConvertible {
    
    case none
    case waiting
    case recording
    case processing
    case processed
    case playing
    case error(String)
    
    var isNone: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
    var isWaiting: Bool {
        switch self {
        case .waiting: return true
        default: return false
        }
    }
    var isRecording: Bool {
        switch self {
        case .recording: return true
        default: return false
        }
    }
    var isProcessing: Bool {
        switch self {
        case .processing: return true
        default: return false
        }
    }
    var isProcessed: Bool {
        switch self {
        case .processed: return true
        default: return false
        }
    }
    var isPlaying: Bool {
        switch self {
        case .playing: return true
        default: return false
        }
    }
    var isError: Bool {
        switch self {
        case .error(_): return true
        default: return false
        }
    }
    
    var description: String {
        switch self {
        case .none: return "None"
        case .waiting: return "Waiting"
        case .recording: return "Recording"
        case .processing: return "Processing"
        case .processed: return "Processed"
        case .playing: return "Playing"
        case .error(let e): return "Error(\(e))"
        }
    }
}


open class SAAudio: NSObject {
    
    open var type: SAAudioType = .talkback
}

////extension         try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
////try AVAudioSession.sharedInstance().setActive(true)
//
//extension AVAudioSession {
//    
//    open func setActive(_ active: Bool, with options: AVAudioSessionSetActiveOptions = [], with context: AnyObject? = nil) throws {
//        sa_activeContext = context
//        try setActive(active, with: options)
//    }
//    
//    var sa_activeContext: AnyObject? {
//        set {
//        }
//        get {
//            return nil
//        }
//    }
//}
//
//private var _SAAudioSessionAudio


