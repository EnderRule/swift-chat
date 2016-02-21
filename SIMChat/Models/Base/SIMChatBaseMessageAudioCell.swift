//
//  SIMChatBaseCell+Audio.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 音频
///
public class SIMChatBaseMessageAudioCell: SIMChatBaseMessageBubbleCell {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // TODO: 有性能问题, 需要重新实现
        
        let vs = ["c": titleLabel,
            "i": animationView]
        
        let ms = ["s0": 20,
            "m0": 0,
            "hp0": hPriority2,
            "hp1": hPriority2 - 1]
        
        let addConstraints = bubbleView.contentView.addConstraints
        
        // config
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // add views
        bubbleView.contentView.addSubview(animationView)
        bubbleView.contentView.addSubview(titleLabel)
        
        // add constraints
        addConstraints(NSLayoutConstraintMake("H:|-12@hp1-[c]-10@hp1-[i]-10@hp1-|", views: vs, options: .AlignAllCenterY, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:|-10@hp0-[i]-10@hp0-[c]-12@hp0-|", views: vs, options: .AlignAllCenterY, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|->=8-[i]->=8-|", views: vs))
        addConstraints(NSLayoutConstraintMake("H:[i(s0)]", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:[i(s0)]", views: vs, metrics: ms))
        
        // get constraints
        for c in bubbleView.contentView.constraints {
            if c.priority == hPriority2 {
                leftConstraints2.append(c)
            }
        }
    }
    
    public override func initEvents() {
        super.initEvents()
        // add kvo
        SIMChatNotificationCenter.addObserver(self, selector: "audioDidStop:", name: SIMChatAudioManagerWillStopNotification)
        SIMChatNotificationCenter.addObserver(self, selector: "audioDidStop:", name: SIMChatAudioManagerWillRecordNotification)
        SIMChatNotificationCenter.addObserver(self, selector: "audioDidPlay:", name: SIMChatAudioManagerWillPlayNotification)
        
        SIMChatNotificationCenter.addObserver(self, selector: "audioWillLoad:", name: SIMChatAudioManagerWillLoadNotification)
        SIMChatNotificationCenter.addObserver(self, selector: "audioDidLoad:", name: SIMChatAudioManagerDidLoadNotification)
    }
    
    /// 显示类型
    public override var style: Style {
        didSet {
            // 没有改变
            guard oldValue != style else {
                return
            }
            // 检查
            switch style {
            case .Left:
                
                animationView.animationDuration = 1
                titleLabel.textColor = UIColor.blackColor()
                (animationView.image, animationView.animationImages) = self.dynamicType.leftImages
                
            case .Right:
                
                titleLabel.textColor = UIColor.whiteColor()
                animationView.stopAnimating()
                animationView.animationDuration = 1
                (animationView.image, animationView.animationImages) = self.dynamicType.rightImages
                
            case .Unknow:
                break
            }
            
            for c in leftConstraints2 {
                c.priority = style == .Left ? hPriority2 : 1
            }
            
            setNeedsLayout()
        }
    }
    /// 消息内容
    public override var message: SIMChatMessageProtocol? {
        didSet {
            guard let content = message?.content as? SIMChatBaseMessageAudioContent else {
                return
            }
        
            // 播放中.
            if content.playing {
                if !animationView.isAnimating() {
                    animationView.startAnimating()
                }
            } else {
                if animationView.isAnimating() {
                    animationView.stopAnimating()
                }
            }
            // 有改变
            guard message !== oldValue else {
                return
            }
            titleLabel.text = _formatAudioDuration(content.duration)
        }
    }
    
    @inline(__always) private func _formatAudioDuration(duration: NSTimeInterval) -> String {
        if duration < 60 {
            return String(format: "%d''", Int(duration % 60))
        }
        return String(format: "%d'%02d''", Int(duration / 60), Int(duration % 60))
    }
    
    private let hPriority2 = UILayoutPriority(750)
    private lazy var leftConstraints2 = [NSLayoutConstraint]()
    
    private lazy var titleLabel = UILabel()
    private lazy var animationView = UIImageView()
}


// MARK: - Event

extension SIMChatBaseMessageAudioCell {
    
    /// 音频开始播放
    internal func audioDidPlay(sender: NSNotification) {
        guard let message = message where sender.object === message.content else {
            return
        }
        SIMLog.trace(message.identifier)
        // 更新消息状态
        conversation?.updateMessage(message, status: .Played)
        // 更新UI
        if !animationView.isAnimating() {
            animationView.startAnimating()
        }
    }
    /// 音频停止播放
    internal func audioDidStop(sender: NSNotification) {
        // 全部停止
        if animationView.isAnimating() {
            animationView.stopAnimating()
        }
        guard let message = message where sender.object === message.content else {
            return
        }
        SIMLog.trace(message.identifier)
    }
    /// 音频加载开始
    internal func audioWillLoad(sender: NSNotification) {
        guard let message = message where sender.object === message.content else {
            return
        }
        SIMLog.trace(message.identifier)
        // 更新状态
        conversation?.updateMessage(message, status: .Receiving)
    }
    /// 音频加载完成
    internal func audioDidLoad(sender: NSNotification) {
        guard let message = message where sender.object === message else {
            return
        }
        SIMLog.trace(message.identifier)
        // 更新状态
        conversation?.updateMessage(message, status: .Received)
    }
}

// MARK: - Resources

extension SIMChatBaseMessageAudioCell {
    /// 左边
    static let leftImages: (UIImage?, [UIImage]?) = {
        let a = NSMutableArray()
        for n in ["simchat_audio_receive_icon_nor",
            "simchat_audio_receive_icon_1",
            "simchat_audio_receive_icon_2",
            "simchat_audio_receive_icon_3"] {
                if let img = UIImage(named: n) {
                    a.addObject(img)
                }
        }
        return (a[0] as? UIImage, a.subarrayWithRange(NSMakeRange(1, a.count - 1)) as? [UIImage])
    }()
    
    /// 右边
    static let rightImages: (UIImage?, [UIImage]?) = {
        let a = NSMutableArray()
        for n in ["simchat_audio_send_icon_nor",
            "simchat_audio_send_icon_1",
            "simchat_audio_send_icon_2",
            "simchat_audio_send_icon_3"] {
                if let img = UIImage(named: n) {
                    a.addObject(img)
                }
        }
        return (a[0] as? UIImage, a.subarrayWithRange(NSMakeRange(1, a.count - 1)) as? [UIImage])
    }()
}