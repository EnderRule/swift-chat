//
//  SIMChatBaseContent+Audio.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation


///
/// 音频
///
public class SIMChatBaseMessageAudioContent: SIMChatMessageContentProtocol {
    ///
    /// 使用本地链接创建内容
    ///
    /// - parameter origin: 音频文件
    /// - parameter duration: 音频文件时长
    ///
    public init(origin: SIMChatResourceProtocol, duration: NSTimeInterval) {
        self.origin = origin
        self.duration = duration
        
        self.localURL = nil
    }
    
    public var played: Bool = false
    //public var downloaded: Bool = false
    public var downloading: Bool = false
    
    /// 音频在本地的路径, 只有在需要上传的时候这个值才会存在
    public let localURL: NSURL?
    
    /// 持续时间
    public let duration: NSTimeInterval
    /// 原文件
    public let origin: SIMChatResourceProtocol
}

public let SIMChatMessageAudioContentType = "simchat.audio"