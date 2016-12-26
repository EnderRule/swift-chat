//
//  SACChatViewController.swift
//  SAChat
//
//  Created by sagesse on 01/11/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit
import SAInput

///
/// 聊天控制器
///
open class SACChatViewController: UIViewController {
    
    public required init(conversation: SACConversationProtocol) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
        
        self.title = "正在和\(conversation.receiver.name ?? "<Unknow>")聊天"
        self.hidesBottomBarWhenPushed = true
        
        _init()
        _logger.trace()
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        //        SACNotificationCenter.removeObserver(self)
        
        _logger.trace()
    }
    
    open override func loadView() {
        super.loadView()
        self.view = chatView
    }
    
    lazy var chatViewLayout: SACChatViewLayout = SACChatViewLayout()
    lazy var chatView: SACChatView = SACChatView(frame: .zero, collectionViewLayout: self.chatViewLayout)
    
    open var conversation: SACConversationProtocol
    
    
//    var isLandscape: Bool {
//        // iOS 8.0+
//        let io = UIScreen.main.value(forKey: "_interfaceOrientation") as! Int
//        if UIInterfaceOrientation(rawValue: io)?.isLandscape ?? false {
//            return true
//        }
//        return false
//    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
         SACChatViewLayoutAttributes().calc(with: CGSize(width: 320, height: 120))
        
//        view.backgroundColor = .white
        
        _toolbar.delegate = self
        
        
        chatView.register(SACChatViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        chatView.delegate = self
        chatView.dataSource = self
        chatView.keyboardDismissMode = .interactive
        
//        contentView.frame = view.bounds
//        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        contentView.scrollsToTop = true
//        contentView.keyboardDismissMode = .interactive
//        contentView.alwaysBounceVertical = true
//        contentView.separatorStyle = .none
//        //contentView.showsHorizontalScrollIndicator = false
//        contentView.showsVerticalScrollIndicator = false
//        contentView.backgroundColor = .clear
        
//        view.addSubview(contentView)
        
        if let group = SACEmoticonGroup(identifier: "com.qq.classic") {
            _emoticonGroups.append(group)
        }
        if let group = SACEmoticonGroup(identifier: "cn.com.a-li") {
            _emoticonGroups.append(group)
        }
        
//        if let group = SACEmoticonGroup(contentsOfFile: SACBundle.resourcePath("Emoticons/com.qq.classic/Info.plist")!) {
//            _emoticonGroups.append(group)
//        }
//        if let group = SACEmoticonGroup(contentsOfFile: SACBundle.resourcePath("Emoticons/cn.com.a-li/Info.plist")!) {
//            _emoticonGroups.append(group)
//        }
    }
    
    open override var inputAccessoryView: UIView? {
        return _toolbar
    }
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var isLandscape: Bool {
        // iOS 8.0+
        let io = UIScreen.main.value(forKey: "_interfaceOrientation") as! Int
        if UIInterfaceOrientation(rawValue: io)?.isLandscape ?? false {
            return true
        }
        return false
    }
    
    private func _init() {
        
        _emoticonSendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        _emoticonSendBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10 + 8, 0, 8)
        _emoticonSendBtn.setTitle("Send", for: .normal)
        _emoticonSendBtn.setTitleColor(.white, for: .normal)
        _emoticonSendBtn.setTitleColor(.lightGray, for: .highlighted)
        _emoticonSendBtn.setTitleColor(.gray, for: .disabled)
        _emoticonSendBtn.setBackgroundImage(UIImage.sac_init(named: "chat_emoticon_btn_send_blue"), for: .normal)
        _emoticonSendBtn.setBackgroundImage(UIImage.sac_init(named: "chat_emoticon_btn_send_gray"), for: .disabled)
        //_emoticonSendBtn.addTarget(self, action: #selector(onEmoticonSend(_:)), for: .touchUpInside)
        _emoticonSendBtn.isEnabled = false
        
        _emoticonSettingBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        _emoticonSettingBtn.setImage(UIImage.sac_init(named: "chat_emoticon_btn_setting"), for: .normal)
        _emoticonSettingBtn.setBackgroundImage(UIImage.sac_init(named: "chat_emoticon_btn_send_gray"), for: .normal)
        _emoticonSettingBtn.setBackgroundImage(UIImage.sac_init(named: "chat_emoticon_btn_send_gray"), for: .highlighted)
        //_emoticonSettingBtn.addTarget(self, action: #selector(onEmoticonSetting(_:)), for: .touchUpInside)
    }
    

    fileprivate lazy var _toolbar: SAIInputBar = SAIInputBar(type: .value1)
    fileprivate lazy var _contentView: UITableView = UITableView()
    
    fileprivate lazy var _emoticonGroups: [SACEmoticonGroup] = []
    fileprivate lazy var _emoticonSendBtn: UIButton = UIButton()
    fileprivate lazy var _emoticonSettingBtn: UIButton = UIButton()
    
    fileprivate weak var _inputItem: SAIInputItem?
    fileprivate lazy var _inputViews: [String: UIView] = [:]
    
    fileprivate lazy var _toolboxItems: [SAIToolboxItem] = {
        return [
            SAIToolboxItem("page:voip", "网络电话", UIImage.sac_init(named: "chat_tool_voip")),
            SAIToolboxItem("page:video", "视频电话", UIImage.sac_init(named: "chat_tool_video")),
            SAIToolboxItem("page:video_s", "短视频", UIImage.sac_init(named: "chat_tool_video_short")),
            SAIToolboxItem("page:favorite", "收藏", UIImage.sac_init(named: "chat_tool_favorite")),
            SAIToolboxItem("page:red_pack", "发红包", UIImage.sac_init(named: "chat_tool_red_pack")),
            SAIToolboxItem("page:transfer", "转帐", UIImage.sac_init(named: "chat_tool_transfer")),
            SAIToolboxItem("page:shake", "抖一抖", UIImage.sac_init(named: "chat_tool_shake")),
            SAIToolboxItem("page:file", "文件", UIImage.sac_init(named: "chat_tool_folder")),
            SAIToolboxItem("page:camera", "照相机", UIImage.sac_init(named: "chat_tool_camera")),
            SAIToolboxItem("page:pic", "相册", UIImage.sac_init(named: "chat_tool_pic")),
            SAIToolboxItem("page:ptt", "录音", UIImage.sac_init(named: "chat_tool_ptt")),
            SAIToolboxItem("page:music", "音乐", UIImage.sac_init(named: "chat_tool_music")),
            SAIToolboxItem("page:location", "位置", UIImage.sac_init(named: "chat_tool_location")),
            SAIToolboxItem("page:nameplate", "名片",   UIImage.sac_init(named: "chat_tool_share_nameplate")),
            SAIToolboxItem("page:aa", "AA制", UIImage.sac_init(named: "chat_tool_aa_collection")),
            SAIToolboxItem("page:gapp", "群应用", UIImage.sac_init(named: "chat_tool_group_app")),
            SAIToolboxItem("page:gvote", "群投票", UIImage.sac_init(named: "chat_tool_group_vote")),
            SAIToolboxItem("page:gvideo", "群视频", UIImage.sac_init(named: "chat_tool_group_video")),
            SAIToolboxItem("page:gtopic", "群话题", UIImage.sac_init(named: "chat_tool_group_topic")),
            SAIToolboxItem("page:gactivity", "群活动", UIImage.sac_init(named: "chat_tool_group_activity")),
        ]
    }()
}


extension SACChatViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 99
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = .random
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 320, height: 120)
    }
    
}

// MARK: - SAInputBarDelegate & SAInputBarDisplayable

extension SACChatViewController: SAIInputBarDelegate, SAIInputBarDisplayable {
    
    open var scrollView: UIScrollView {
        return chatView
    }
    
    open func inputView(with item: SAIInputItem) -> UIView? {
        if let view = _inputViews[item.identifier] {
            return view
        }
        switch item.identifier {
        case "kb:audio":
            let view = SAIAudioInputView()
            view.dataSource = self
            view.delegate = self
            _inputViews[item.identifier] = view
            return view
            
        case "kb:photo":
            let view = SAIPhotoInputView()
            //view.dataSource = self
            //view.delegate = self
            _inputViews[item.identifier] = view
            return view
            
        case "kb:emoticon":
            let view = SAIEmoticonInputView()
            view.delegate = self
            view.dataSource = self
            _inputViews[item.identifier] = view
            return view
            
        case "kb:toolbox":
            let view = SAIToolboxInputView()
            view.delegate = self
            view.dataSource = self
            _inputViews[item.identifier] = view
            return view
            
        default:
            return nil
        }
    }
    
    open func inputViewContentSize(_ inputView: UIView) -> CGSize {
        if isLandscape {
            return CGSize(width: view.frame.width, height: 193)
        }
        return CGSize(width: view.frame.width, height: 253)
    }
    
    open func inputBar(_ inputBar: SAIInputBar, shouldSelectFor item: SAIInputItem) -> Bool {
        
        class TVC : UIViewController {
            override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                super.touchesBegan(touches, with: event)
                dismiss(animated: true, completion: nil)
            }
        }
        
        if item.identifier == "kb:video"  {
            let vc = UIViewController()
//            vc.view.backgroundColor = .random
            self.navigationController?.pushViewController(vc, animated: true)
        } else if item.identifier == "kb:camera" {
            let vc = TVC()
//            vc.view.backgroundColor = .random
            self.present(vc, animated: true, completion: nil)
        }
        
        guard let _ = inputView(with: item) else {
            return false
        }
        return true
    }
    open func inputBar(_ inputBar: SAIInputBar, didSelectFor item: SAIInputItem) {
        _logger.debug(item.identifier)
        
        _inputItem = item
        
        if let kb = inputView(with: item) {
            inputBar.setInputMode(.selecting(kb), animated: true)
        }
    }
    
    open func inputBar(didChangeMode inputBar: SAIInputBar) {
        _logger.debug(inputBar.inputMode)
        
        if let item = _inputItem, !inputBar.inputMode.isSelecting {
            inputBar.deselectBarItem(item, animated: true)
        }
    }
    
    open func inputBar(didChangeText inputBar: SAIInputBar) {
        _emoticonSendBtn.isEnabled = inputBar.attributedText.length != 0
    }
}

// MARK: - SAIAudioInputViewDataSource & SAIAudioInputViewDelegate

extension SACChatViewController: SAIAudioInputViewDataSource, SAIAudioInputViewDelegate {
    
    open func numberOfAudioTypes(in audio: SAIAudioInputView) -> Int {
        return 3
    }
    open func audio(_ audio: SAIAudioInputView, audioTypeForItemAt index: Int) -> SAIAudioType {
        return SAIAudioType(rawValue: index)!
    }
    
    open func audio(_ audio: SAIAudioInputView, shouldStartRecord url: URL) -> Bool {
        return true
    }
    open func audio(_ audio: SAIAudioInputView, didStartRecord url: URL) {
        _logger.trace()
    }
    
    open func audio(_ audio: SAIAudioInputView, didRecordFailure url: URL, duration: TimeInterval) {
        _logger.trace("\(url)(\(duration))")
    }
    open func audio(_ audio: SAIAudioInputView, didRecordComplete url: URL, duration: TimeInterval) {
        _logger.trace("\(url)(\(duration))")
    }
}


// MARK: - SAIEmoticonInputViewDataSource & SAIEmoticonInputViewDelegate

extension SACChatViewController: SAIEmoticonInputViewDataSource, SAIEmoticonInputViewDelegate {
 
    open func numberOfEmotionGroups(in emoticon: SAIEmoticonInputView) -> Int {
        return _emoticonGroups.count
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, emotionGroupForItemAt index: Int) -> SAIEmoticonGroup {
        return _emoticonGroups[index]
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, numberOfRowsForGroupAt index: Int) -> Int {
        if isLandscape {
            return _emoticonGroups[index].rowsInLandscape
        }
        return _emoticonGroups[index].rows
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, numberOfColumnsForGroupAt index: Int) -> Int {
        if isLandscape {
            return _emoticonGroups[index].columnsInLandscape
        }
        return _emoticonGroups[index].columns
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, moreViewForGroupAt index: Int) -> UIView? { 
        if _emoticonGroups[index].type.isSmall {
            return _emoticonSendBtn
        } else {
            return _emoticonSettingBtn
        }
    }
    
    open func emoticon(_ emoticon: SAIEmoticonInputView, insetForGroupAt index: Int) -> UIEdgeInsets {
        if isLandscape {
            return UIEdgeInsetsMake(4, 12, 4 + 24, 12)
        }
        return UIEdgeInsetsMake(12, 10, 12 + 24, 10)
    }
    
    open func emoticon(_ emoticon: SAIEmoticonInputView, shouldSelectFor item: SAIEmoticon) -> Bool {
        return true
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, didSelectFor item: SAIEmoticon) {
        _logger.debug(item)
        
        guard !item.isBackspace else {
            _toolbar.deleteBackward()
            return
        }
        guard let item = item as? SACEmoticon else {
            return
        }
        if let img = item.contents as? UIImage {
            
            let d = _toolbar.font?.descender ?? 0
            let h = _toolbar.font?.lineHeight ?? 0
            
            let attachment = NSTextAttachment()
            
            attachment.image = img
            attachment.bounds = CGRect(x: 0, y: d, width: h, height: h)
            
            _toolbar.insertAttributedText(NSAttributedString(attachment: attachment))
        } else {
            _toolbar.insertText("/\(item.title)")
        }
    }
    
    open func emoticon(_ emoticon: SAIEmoticonInputView, shouldPreviewFor item: SAIEmoticon?) -> Bool {
        return true
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, didPreviewFor item: SAIEmoticon?) {
        _logger.debug("\(item)")
    }
}


// MARK: - SAIToolboxInputViewDataSource & SAIToolboxInputViewDelegate

extension SACChatViewController: SAIToolboxInputViewDataSource, SAIToolboxInputViewDelegate {
    
    open func numberOfToolboxItems(in toolbox: SAIToolboxInputView) -> Int {
        return _toolboxItems.count
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, toolboxItemForItemAt index: Int) -> SAIToolboxItem {
        return _toolboxItems[index]
    }
    
    open func toolbox(_ toolbox: SAIToolboxInputView, numberOfRowsForSectionAt index: Int) -> Int {
        return 2
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, numberOfColumnsForSectionAt index: Int) -> Int {
        if isLandscape {
            return 6
        }
        return 4
    }
    
    open func toolbox(_ toolbox: SAIToolboxInputView, insetForSectionAt index: Int) -> UIEdgeInsets {
        if isLandscape {
            return UIEdgeInsetsMake(4, 12, 4, 12)
        }
        return UIEdgeInsetsMake(12, 10, 12, 10)
    }
    
    open func toolbox(_ toolbox: SAIToolboxInputView, shouldSelectFor item: SAIToolboxItem) -> Bool {
        return true
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, didSelectFor item: SAIToolboxItem) {
        _logger.debug(item.identifier)
    }
    
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

