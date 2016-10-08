//
//  SIMChatViewController.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit


// [ ] SIMChatViewController - 更新InputPanel
// [x] SAEmoticonInputView - 加载默认表情
// [x] SAEmoticonInputView - 加载大表情
// [ ] SAEmoticonInputView - 异步加载和同步


class SIMEmoticonGroup {
    
    init(row: Int, column: Int, type: SAEmoticonType = .small) {
        self.row = row
        self.column = column
        self.type = type
    }
    
    var row: Int
    var column: Int
    
    var type: SAEmoticonType
   
    var size: CGSize = .zero
    var minimumLineSpacing: CGFloat = 0
    var minimumInteritemSpacing: CGFloat = 0
}

///
/// 聊天控制器
///
open class SIMChatViewController: UIViewController {
    
    /// 初始化
    // public required init(conversation: SIMChatConversation) {
    //     _conversation = conversation
//  //       _messageManager = MessageManager(conversation: conversation)
    //     super.init(nibName: nil, bundle: nil)
//  //       _messageManager.contentView = contentView
    //     
    //     hidesBottomBarWhenPushed = true
    //     
    //     let name = conversation.receiver.name ?? conversation.receiver.identifier
    //     if conversation.receiver.type == .user {
    //         title = "正在和\(name)聊天"
    //     } else {
    //         title = name
    //     }
    // }
    deinit {
//        SIMChatNotificationCenter.removeObserver(self)
        SIMLog.trace()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        _init()
        
        view.backgroundColor = .white
        
        toolbar.delegate = self
        
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.image = SIMChatImageManager.defaultBackground
        backgroundView.contentMode = .scaleToFill
        
        contentView.frame = view.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.scrollsToTop = true
        contentView.keyboardDismissMode = .interactive
        contentView.alwaysBounceVertical = true
        contentView.separatorStyle = .none
        //contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        contentView.backgroundColor = .clear
        
        view.addSubview(backgroundView)
        view.addSubview(contentView)
        
        //if let group = SIMChatEmoticonGroup(contentsOfFile: SIMChatBundle.resourcePath("Emoticons/com.apple.emoji/Info.plist")!) {
        //    _emoticonGroups.append(group)
        //}
        if let group = SIMChatEmoticonGroup(contentsOfFile: SIMChatBundle.resourcePath("Emoticons/com.qq.classic/Info.plist")!) {
            _emoticonGroups.append(group)
        }
        if let group = SIMChatEmoticonGroup(contentsOfFile: SIMChatBundle.resourcePath("Emoticons/cn.com.a-li/Info.plist")!) {
            _emoticonGroups.append(group)
        }
        
        title = "Chat"
    }
    open func inputViewContentSize(_ inputView: UIView) -> CGSize {
        if isLandscape {
            return CGSize(width: view.frame.width, height: 193)
        }
        return CGSize(width: view.frame.width, height: 253)
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
        _logger.trace()
        
        _emoticonSendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        _emoticonSendBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10 + 8, 0, 8)
        _emoticonSendBtn.setTitle("Send", for: .normal)
        _emoticonSendBtn.setTitleColor(.white, for: .normal)
        _emoticonSendBtn.setTitleColor(.lightGray, for: .highlighted)
        _emoticonSendBtn.setTitleColor(.gray, for: .disabled)
        _emoticonSendBtn.setBackgroundImage(UIImage(named: "emoticon_btn_send_blue"), for: .normal)
        _emoticonSendBtn.setBackgroundImage(UIImage(named: "emoticon_btn_send_gray"), for: .disabled)
        _emoticonSendBtn.addTarget(self, action: #selector(onEmoticonSend(_:)), for: .touchUpInside)
        _emoticonSendBtn.isEnabled = false
        
        _emoticonSettingBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        _emoticonSettingBtn.setImage(UIImage(named: "emoticon_btn_setting"), for: .normal)
        _emoticonSettingBtn.setBackgroundImage(UIImage(named: "emoticon_btn_send_gray"), for: .normal)
        _emoticonSettingBtn.setBackgroundImage(UIImage(named: "emoticon_btn_send_gray"), for: .highlighted)
        _emoticonSettingBtn.addTarget(self, action: #selector(onEmoticonSetting(_:)), for: .touchUpInside)
    }
    
    fileprivate var _activedItem: SAInputItem?
    fileprivate var _activedPanel: UIView?
    
    fileprivate lazy var _toolbar: SAInputBar = SAInputBar(type: .value1)
    fileprivate lazy var _contentView: UITableView = UITableView(frame: .zero)
    fileprivate lazy var _backgroundView: UIImageView = UIImageView()
    
    fileprivate lazy var _emoticonGroups: [SIMChatEmoticonGroup] = []
    fileprivate lazy var _emoticonSendBtn: UIButton = UIButton()
    fileprivate lazy var _emoticonSettingBtn: UIButton = UIButton()
    
    fileprivate lazy var _inputViews: [String: UIView] = [:]
    
    fileprivate lazy var _toolboxItems: [SAToolboxItem] = {
        let R = { (n:String) -> UIImage? in
            SIMChatBundle.imageWithResource("InputPanel/\(n).png")
        }
        return [
            SAToolboxItem("page:voip", "网络电话", R("tool_voip")),
            SAToolboxItem("page:video", "视频电话", R("tool_video")),
            SAToolboxItem("page:video_s", "短视频", R("tool_video_short")),
            SAToolboxItem("page:favorite", "收藏", R("tool_favorite")),
            SAToolboxItem("page:red_pack", "发红包", R("tool_red_pack")),
            SAToolboxItem("page:transfer", "转帐", R("tool_transfer")),
            SAToolboxItem("page:shake", "抖一抖", R("tool_shake")),
            SAToolboxItem("page:file", "文件", R("tool_folder")),
            SAToolboxItem("page:camera", "照相机", R("tool_camera")),
            SAToolboxItem("page:pic", "相册", R("tool_pic")),
            SAToolboxItem("page:ptt", "录音", R("tool_ptt")),
            SAToolboxItem("page:music", "音乐", R("tool_music")),
            SAToolboxItem("page:location", "位置", R("tool_location")),
            SAToolboxItem("page:nameplate", "名片",   R("tool_share_nameplate")),
            SAToolboxItem("page:aa", "AA制", R("tool_aa_collection")),
            SAToolboxItem("page:gapp", "群应用", R("tool_group_app")),
            SAToolboxItem("page:gvote", "群投票", R("tool_group_vote")),
            SAToolboxItem("page:gvideo", "群视频", R("tool_group_video")),
            SAToolboxItem("page:gtopic", "群话题", R("tool_group_topic")),
            SAToolboxItem("page:gactivity", "群活动", R("tool_group_activity"))
        ]
    }()
    
    //private var _conversation: SIMChatConversation
//    private var _messageManager: MessageManager
//    
//    internal var messageManager: MessageManager { return _messageManager }
//}
//
//// MARK: - Public Propertys
//
//extension SIMChatViewController {
    ///
    /// 聊天会话
    ///
    //open var conversation: SIMChatConversation {
    //    return _conversation 
    //}
    //open var manager: SIMChatManager {
    //    guard let manager = conversation.manager else {
    //        fatalError("Must provider manager")
    //    }
    //    return manager
    //}
    
    open var toolbar: SAInputBar {
        return _toolbar
    }
    open var contentView: UITableView {
        return _contentView 
    }
    open var backgroundView: UIImageView { 
        return _backgroundView 
    }
    
    open override var inputAccessoryView: UIView? {
        return toolbar
    }
    open override var canBecomeFirstResponder: Bool {
        return true
    }
}

// MARK: - Touch Events

extension SIMChatViewController {
    
    open func onEmoticonSend(_ sender: Any) {
        _logger.trace()
        
        _toolbar.text = ""
    }
    open func onEmoticonSetting(_ sender: Any) {
        _logger.trace()
    }
    
}

// MARK: - SAInputBarDelegate & SAInputBarDisplayable

extension SIMChatViewController: SAInputBarDelegate, SAInputBarDisplayable {
    
    open var scrollView: UIScrollView {
        return contentView
    }
    
    open func inputView(with item: SAInputItem) -> UIView? {
        if let view = _inputViews[item.identifier] {
            return view
        }
        switch item.identifier {
        case "kb:audio":
            let view = SAAudioInputView()
            view.dataSource = self
            view.delegate = self
            _inputViews[item.identifier] = view
            return view
            
        case "kb:photo":
            let view = SAPhotoInputView()
            //view.dataSource = self
            view.delegate = self
            _inputViews[item.identifier] = view
            return view
            
        case "kb:emoticon":
            let view = SAEmoticonInputView()
            view.delegate = self
            view.dataSource = self
            _inputViews[item.identifier] = view
            return view
            
        case "kb:toolbox":
            let view = SAToolboxInputView()
            view.delegate = self
            view.dataSource = self
            _inputViews[item.identifier] = view
            return view
            
        default:
            return nil
        }
    }
    
    open func inputBar(_ inputBar: SAInputBar, shouldSelectFor item: SAInputItem) -> Bool {
        
        class TVC : UIViewController {
            override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                super.touchesBegan(touches, with: event)
                dismiss(animated: true, completion: nil)
            }
        }
        
        if item.identifier == "kb:video"  {
            let vc = UIViewController()
            vc.view.backgroundColor = .random
            self.navigationController?.pushViewController(vc, animated: true)
        } else if item.identifier == "kb:camera" {
            let vc = TVC()
            vc.view.backgroundColor = .random
            self.present(vc, animated: true, completion: nil)
        }
        
        guard let _ = inputView(with: item) else {
            return false
        }
        return true
    }
    open func inputBar(_ inputBar: SAInputBar, didSelectFor item: SAInputItem) {
        logger.debug(item.identifier)
        
        _activedItem = item
        
        if let kb = inputView(with: item) {
            inputBar.setInputMode(.selecting(kb), animated: true)
        }
    }
    
    open func inputBar(didChangeMode inputBar: SAInputBar) {
        logger.debug(inputBar.inputMode)
        
        if let item = _activedItem, !inputBar.inputMode.isSelecting {
            inputBar.deselectBarItem(item, animated: true)
        } 
    }
    
    open func inputBar(didChangeText inputBar: SAInputBar) {
        _emoticonSendBtn.isEnabled = inputBar.attributedText.length != 0
    }
}

// MARK: - SAAudioInputViewDataSource & SAAudioInputViewDelegate

extension SIMChatViewController: SAAudioInputViewDataSource, SAAudioInputViewDelegate {
    
    open func numberOfAudioTypes(in audio: SAAudioInputView) -> Int {
        return 3
    }
    open func audio(_ audio: SAAudioInputView, audioTypeForItemAt index: Int) -> SAAudioType {
        return SAAudioType(rawValue: index)!
    }
    
    open func audio(_ audio: SAAudioInputView, shouldStartRecord url: URL) -> Bool {
        return true
    }
    open func audio(_ audio: SAAudioInputView, didStartRecord url: URL) {
        _logger.trace()
    }
    
    open func audio(_ audio: SAAudioInputView, didRecordFailure url: URL, duration: TimeInterval) {
        _logger.trace("\(url)(\(duration))")
    }
    open func audio(_ audio: SAAudioInputView, didRecordComplete url: URL, duration: TimeInterval) {
        _logger.trace("\(url)(\(duration))")
    }
}

// MARK: - SAPhotoInputViewDelegate

extension SIMChatViewController: SAPhotoInputViewDelegate {
    
}

// MARK: - SAEmoticonInputViewDataSource & SAEmoticonInputViewDelegate

extension SIMChatViewController: SAEmoticonInputViewDataSource, SAEmoticonInputViewDelegate {
 
    open func numberOfEmotionGroups(in emoticon: SAEmoticonInputView) -> Int {
        return _emoticonGroups.count
    }
    open func emoticon(_ emoticon: SAEmoticonInputView, emotionGroupForItemAt index: Int) -> SAEmoticonGroup {
        return _emoticonGroups[index]
    }
    open func emoticon(_ emoticon: SAEmoticonInputView, numberOfRowsForGroupAt index: Int) -> Int {
        if isLandscape {
            return _emoticonGroups[index].rowsInLandscape
        }
        return _emoticonGroups[index].rows
    }
    open func emoticon(_ emoticon: SAEmoticonInputView, numberOfColumnsForGroupAt index: Int) -> Int {
        if isLandscape {
            return _emoticonGroups[index].columnsInLandscape
        }
        return _emoticonGroups[index].columns
    }
    open func emoticon(_ emoticon: SAEmoticonInputView, moreViewForGroupAt index: Int) -> UIView? { 
        if _emoticonGroups[index].type.isSmall {
            return _emoticonSendBtn
        } else {
            return _emoticonSettingBtn
        }
    }
    
    open func emoticon(_ emoticon: SAEmoticonInputView, insetForGroupAt index: Int) -> UIEdgeInsets {
        if isLandscape {
            return UIEdgeInsetsMake(4, 12, 4 + 24, 12)
        }
        return UIEdgeInsetsMake(12, 10, 12 + 24, 10)
    }
    
    open func emoticon(_ emoticon: SAEmoticonInputView, shouldSelectFor item: SAEmoticon) -> Bool {
        return true
    }
    open func emoticon(_ emoticon: SAEmoticonInputView, didSelectFor item: SAEmoticon) {
        _logger.debug(item)
        
        guard !item.isBackspace else {
            _toolbar.deleteBackward()
            return
        }
        guard let item = item as? SIMChatEmoticon else {
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
    
    open func emoticon(_ emoticon: SAEmoticonInputView, shouldPreviewFor item: SAEmoticon?) -> Bool {
        return true
    }
    open func emoticon(_ emoticon: SAEmoticonInputView, didPreviewFor item: SAEmoticon?) {
        _logger.debug("\(item)")
    }
}

// MARK: - SAToolboxInputViewDataSource & SAToolboxInputViewDelegate

extension SIMChatViewController: SAToolboxInputViewDataSource, SAToolboxInputViewDelegate {
    
    open func numberOfToolboxItems(in toolbox: SAToolboxInputView) -> Int {
        return _toolboxItems.count
    }
    open func toolbox(_ toolbox: SAToolboxInputView, toolboxItemForItemAt index: Int) -> SAToolboxItem {
        return _toolboxItems[index]
    }
    
    open func toolbox(_ toolbox: SAToolboxInputView, numberOfRowsForSectionAt index: Int) -> Int {
        return 2
    }
    open func toolbox(_ toolbox: SAToolboxInputView, numberOfColumnsForSectionAt index: Int) -> Int {
        if isLandscape {
            return 6
        }
        return 4
    }
    
    open func toolbox(_ toolbox: SAToolboxInputView, insetForSectionAt index: Int) -> UIEdgeInsets {
        if isLandscape {
            return UIEdgeInsetsMake(4, 12, 4, 12)
        }
        return UIEdgeInsetsMake(12, 10, 12, 10)
    }
    
    open func toolbox(_ toolbox: SAToolboxInputView, shouldSelectFor item: SAToolboxItem) -> Bool {
        return true
    }
    open func toolbox(_ toolbox: SAToolboxInputView, didSelectFor item: SAToolboxItem) {
        _logger.debug(item.identifier)
    }
}



// MARK: - Life Cycle

//extension SIMChatViewController {
//    
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        SIMLog.trace()
//        
//        // 背景
//        backgroundView.accessibilityLabel = "聊天背景"
//        backgroundView.frame = view.bounds
//        backgroundView.image = SIMChatImageManager.defaultBackground
//        backgroundView.contentMode = .scaleToFill
//        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        // 内容
//        contentView.accessibilityLabel = "聊天内容"
//        contentView.backgroundColor = .clear()
//        contentView.showsHorizontalScrollIndicator = false
//        contentView.scrollsToTop = true
//        contentView.keyboardDismissMode = .interactive
//        //contentView.showsVerticalScrollIndicator = false
//        contentView.separatorStyle = .none
//        
//        // add event
////        contentView.addGestureRecognizer(_tapGestureRecognizer)
//        
//        view.addSubview(backgroundView)
//        view.addSubview(contentView)
////        view.addSubview(inputBar)
////        view.addSubview(inputPanelContainer)
//        
////        contentView.addObserver(self,
////            forKeyPath: SIMChatViewContentViewPanStateKeyPath,
////            options: [.New],
////            context: nil)
//        
//        // 添加布局
//        _contentViewLayout = SIMChatLayout.make(contentView)
//            .top.equ(view).top
//            .left.equ(view).left
//            .right.equ(view).right
//            .bottom.equ(view).bottom
//            .submit()
//        
//        
////        SIMChatNotificationCenter.addObserver(
////            self,
////            selector: #selector(self.dynamicType.onInputBarChangeNtf(_:)),
////            name: SIMChatInputBarFrameDidChangeNotification)
//        
//        // 初始化工作
////        view.layoutIfNeeded()
////        setKeyboardHeight(0, animated: false)
//        
//        //inputBar = _inputBar
//        
//        _messageManager.prepare()
//    }
//    
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
////        let center = NSNotificationCenter.defaultCenter()
////        center.addObserver(
////            self,
////            selector: #selector(self.dynamicType.onKeyboardShowNtf(_:)),
////            name: UIKeyboardWillShowNotification,
////            object: nil)
////        center.addObserver(
////            self,
////            selector: #selector(self.dynamicType.onKeyboardHideNtf(_:)),
////            name: UIKeyboardWillHideNotification,
////            object: nil)
////        
////        // 添加转发
////        if let recognizer = navigationController?.interactivePopGestureRecognizer {
////            _forwarder = UIGestureRecognizerDelegateForwarder(recognizer.delegate, to: [self])
////            recognizer.delegate = _forwarder
////        }
//    }
//    
//    public override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
////        
////        let center = NSNotificationCenter.defaultCenter()
////        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
////        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//        
////        // 恢复原样
////        if let recognizer = navigationController?.interactivePopGestureRecognizer {
////            recognizer.delegate = _forwarder?.orign
////            _forwarder = nil
////        }
////        if inputBar.state.isEditingWithSystemKeyboard {
////            inputBar.state = .None
////        }
//    }
//    
//    public override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        
////        // 切换页面的时候停止播放
////        manager.mediaProvider.stop()
//    }
//    
//    public override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        _updateKeyboardSize()
//    }
//    
//    @inline(__always) private func _updateKeyboardSize() {
//        _logger.trace()
//        
//        
////        var curve = UIViewAnimationCurve.EaseInOut
////        
////        (7 as NSNumber).getValue(&curve)
////        
////        UIView.beginAnimations(nil, context: nil)
////        UIView.setAnimationDuration(0.25)
////        UIView.setAnimationCurve(curve)
//        // UIView.animateWithDuration(duration, delay:0, options:options, animations: handler, completion: nil)
////        UIView.animateWithDuration(0.25) {
////            let size = self.inputBar.intrinsicContentSize
////            let keyboardSize = self.inputBar.keyboardSize
//            
////            // 更新inset, 否则显示区域错误
////            var edg = self.contentView.contentInset
////        edg.top = self.topLayoutGuide.length;// + size.height;
////            edg.bottom = size.height
////            self.contentView.contentInset = edg
////            self.contentView.scrollIndicatorInsets = edg
//            
////            // 必须同时更新
////        self.contentViewLayout?.top = -size.height//keyboardSize.height
////        //self.contentViewLayout?.bottom = keyboardSize.height
////        self.contentView.layoutIfNeeded()
//        
////            // 必须先更新inset, 否则如果offset在0的位置时会产生肉眼可见的抖动
////            var edg = contentView.contentInset
////            edg.top = topLayoutGuide.length + newValue + inputBar.frame.height
////            contentView.contentInset = edg
////            contentView.scrollIndicatorInsets = edg
////            
////            // 必须同时更新
////            contentViewLayout?.top = -(newValue + inputBar.frame.height)
////            contentViewLayout?.bottom = newValue + inputBar.frame.height
////            contentView.layoutIfNeeded()
////            
////            inputBarLayout?.bottom = newValue
////            inputBar.layoutIfNeeded()
////        }
////        UIView.commitAnimations()
//    }
//}

//extension SIMChatViewController: UIGestureRecognizerDelegate {
//    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
//        if gestureRecognizer == _tapGestureRecognizer {
//            return !SIMChatMenuController.sharedMenuController().isCustomMenu()
//        }
//        if gestureRecognizer is UIScreenEdgePanGestureRecognizer {
//            let pt = touch.locationInView(view)
//            return !inputBar.frame.contains(pt) && !inputPanelContainer.frame.contains(pt)
//        }
//        return true
//    }
//}

////    init(conversation: SIMChatConversation) {
////        super.init(nibName: nil, bundle: nil)
////        self.conversation = conversation
////        self.conversation.delegate = self
////    }
//    /// 释放
//    deinit {
//        SIMLog.trace()
//        // 确保必须为空
//        SIMChatNotificationCenter.removeObserver(self)
//    }
////    /// 构建
////    override func build() {
////        SIMLog.trace()
////        
////        super.build()
////        
////        self.buildOfMessage()
////    }
//    
//    /// 加载完成
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let vs = ["tf" : textField]
//        
//        // 设置背景
//        view.backgroundColor = UIColor.clearColor()
//        view.layer.contents =  SIMChatImageManager.defaultBackground?.CGImage
//        view.layer.contentsGravity = kCAGravityResizeAspectFill//kCAGravityResize
//        view.layer.masksToBounds = true
//        // inputViewEx使用al
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.backgroundColor = UIColor(hex: 0xEBECEE)
//        textField.delegate = self
//        // tableView使用am
//        tableView.frame = view.bounds
//        tableView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
//        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
//        tableView.backgroundColor = UIColor.clearColor()
//        tableView.showsHorizontalScrollIndicator = false
//        tableView.showsVerticalScrollIndicator = true
//        tableView.rowHeight = 32
//        tableView.dataSource = self
//        tableView.delegate = self
//        //
//        maskView.backgroundColor = UIColor(white: 0, alpha: 0.2)
//        maskView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
//        
//        // add views
//        // 第一个视图必须是tableView, addSubview(tableView)在ios7下有点bug?
//        view.insertSubview(tableView, atIndex: 0)
//        view.insertSubview(textField, aboveSubview: tableView)
//        
//        //self.inputView = textField
//        //self.inputAccessoryView = textField
//        // add constraints
//        view.addConstraints(NSLayoutConstraintMake("H:|-(0)-[tf]-(0)-|", views: vs))
//        view.addConstraints(NSLayoutConstraintMake("V:[tf]|", views: vs))
//        
//        // add event
//        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "resignFirstResponder"))
//        
//        // 加载聊天历史
//        dispatch_async(dispatch_get_main_queue()) {
//            // 更新键盘
//            self.updateKeyboard(height: 0)
//            // 加载历史
//            self.loadHistorys(40)
//        }
//    }
//    
//    /// 视图将要出现
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        // add kvos
//        let center = NSNotificationCenter.defaultCenter()
//        
//        center.addObserver(self, selector: "onKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
//        center.addObserver(self, selector: "onKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
//    }
//    /// 视图将要消失
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        let center = NSNotificationCenter.defaultCenter()
//        
//        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//        
//        // 禁止播放
//        SIMChatAudioManager.sharedManager.stop()
//    }
//    /// 放弃编辑
//    override func resignFirstResponder() -> Bool {
//        return textField.resignFirstResponder()
//    }
//    
//    /// 最新的消息
//    var latest: SIMChatMessage?
//    /// 会话
//    var conversation: SIMChatConversation! {
//        willSet { conversation.delegate = nil  }
//        didSet  { conversation.delegate = self }
//    }
//    
//    private(set) lazy var maskView = UIView()
//    private(set) lazy var tableView = UITableView()
//    private(set) lazy var textField = SIMChatInputBar(frame: CGRectZero)
//  
//    /// 数据源
//    internal lazy var source = Array<SIMChatMessage>()
//    
//    /// 单元格
//    internal lazy var testers = Dictionary<String, SIMChatMessageCellProtocol>()
//    internal lazy var relations = Dictionary<String, SIMChatMessageCellProtocol.Type>()
//    internal lazy var relationDefault = NSStringFromClass(SIMChatMessageContentUnknow.self)
//    
//    /// 自定义键盘
//    internal lazy var keyboard = UIView?()
//    internal lazy var keyboards = Dictionary<SIMChatInputBarItemStyle, UIView>()
//    internal lazy var keyboardHeight =  CGFloat(0)
//    internal lazy var keyboardHiddenAnimation = false
//}
//
//// MARK: - Content
//extension SIMChatViewController : UITableViewDataSource {
//    /// 行数
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return source.count
//    }
//    /// 获取每一行的高度
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        // 获取数据
//        let message = source[indexPath.row]
//        let key: String = {
//            let type = NSStringFromClass(message.content.dynamicType)
//            if self.relations[type] != nil {
//                return type
//            }
//            return self.relationDefault
//        }()
//        // 己经计算过了?
//        if message.height != 0 {
//            return message.height
//        }
//        // 获取测试单元格
//        let cell = testers[key] ?? {
//            let tmp = tableView.dequeueReusableCellWithIdentifier(key) as! SIMChatMessageCell
//            // 隐藏
//            tmp.enabled = false
//            // 缓存
//            self.testers[key] = tmp
//            // 创建完成
//            return tmp
//        }()
//        // 更新环境
//        if let cell = cell as? UIView {
//            cell.frame = CGRectMake(0, 0, tableView.bounds.width, tableView.rowHeight)
//        }
//        cell.message = message
//        // 计算高度
//        message.height = cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
//        // 检查结果
//        SIMLog.debug("\(key): \(message.height)")
//        // ok
//        return message.height
//    }
//    ///
//    /// 加载单元格
//    ///
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        // 获取数据
//        let message = source[indexPath.row]
//        let key: String = {
//            let type = NSStringFromClass(message.content.dynamicType)
//            if self.relations[type] != nil {
//                return type
//            }
//            return self.relationDefault
//        }()
//        // 获取单元格, 如果不存在则创建
//        let cell = tableView.dequeueReusableCellWithIdentifier(key, forIndexPath: indexPath) as! SIMChatMessageCell
//        // 更新环境
//        cell.enabled = true
//        cell.message = message
//        cell.delegate = self
//        // 完成.
//        return cell
//    }
//}
//
//// MARK: - Content Event
//extension SIMChatViewController : UITableViewDelegate {
//    /// 开始拖动
//    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        if scrollView === tableView && textField.selectedStyle != .None {
//            self.resignFirstResponder()
//        }
//    }
//    ///
//    /// 将要结束拖动
//    ///
//    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        //Log.debug(targetContentOffset.memory)
//        // 
//        // let pt = scrollView.contentOffset
//        // 
//        // //Log.debug("\(pt.y) \(targetContentOffset.memory.y)")
//        // if pt.y < -scrollView.contentInset.top && targetContentOffset.memory.y <= -scrollView.contentInset.top {
//        //     dispatch_async(dispatch_get_main_queue()) {
//        //         //self.loadMore(nil)
//        //     }
//        // }
//    }
//    /// 结束减速
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        if scrollView === tableView && scrollView.contentOffset.y <= -scrollView.contentInset.top {
//            // self.loadHistorys(40, latest: self.latest)
//        }
//    }
//}
