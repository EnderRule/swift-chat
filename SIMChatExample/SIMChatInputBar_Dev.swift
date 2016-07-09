//
//  SIMChatInputBar.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit



//
//  输入框
//
// --------------------------------------------- <- shadowImage
//   +-------+-------+-------+-------+-------+
//   | Item1 | Item2 | Item3 | Item4 | Item5 |   <- top
//   +-------+-------+-------+-------+-------+  
//   | Item6 |         Input         | Item7 |   <- left + center + right
//   +-------+-------+-------+-------+-------+  
//   | Item8 | Item9 | ItemA | ItemB | ItemC |   <- bottom
//   +-------+-------+-------+-------+-------+
//                  

// TODO: Landscape support

/// 输入栏大小发生改变
public let SIMChatInputBarFrameDidChangeNotification = "SIMChatInputBarFrameDidChangeNotification"

///
/// item alignment
///
@available(iOS 7.0, *)
public enum SIMChatInputAlignment: Int {
    
                        //0xvvhh
    case Top            = 0x0104 // Top + Center(H)
    case Bottom         = 0x0204 // Bottom + Center(H)
    case Left           = 0x0401 // Center(V) + Left
    case Right          = 0x0402 // Center(V) + Right
    case TopLeft        = 0x0101 // Top + Left
    case TopRight       = 0x0102 // Top + Right
    case BottomLeft     = 0x0201 // Bottom + Left
    case BottomRight    = 0x0202 // Bottom + Right
    case Center         = 0x0404 // Center(V) + Center(H)
    
    case Automatic      = 0x0000
}

// MARK:

///
/// char input bar delegate
///
@objc public protocol SIMChatInputBarDelegate: NSObjectProtocol {
    
    // MARK: Text Edit
    
    optional func inputBarShouldBeginEditing(inputBar: SIMChatInputBar) -> Bool
    optional func inputBarDidBeginEditing(inputBar: SIMChatInputBar)
    
    optional func inputBarShouldEndEditing(inputBar: SIMChatInputBar) -> Bool
    optional func inputBarDidEndEditing(inputBar: SIMChatInputBar)
    
    optional func inputBarShouldClear(inputBar: SIMChatInputBar) -> Bool
    optional func inputBarShouldReturn(inputBar: SIMChatInputBar) -> Bool
    
    optional func inputBar(inputBar: SIMChatInputBar, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    
    optional func inputBarDidChange(inputBar: SIMChatInputBar)
    optional func inputBarDidChangeSelection(inputBar: SIMChatInputBar)
    
    // MARK: Accessory Item Selection
    
    optional func inputBar(inputBar: SIMChatInputBar, shouldHighlightItem item: UIBarButtonItem) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, didHighlightItem item: UIBarButtonItem)
    
    optional func inputBar(inputBar: SIMChatInputBar, shouldSelectItem item: UIBarButtonItem) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, didSelectItem item: UIBarButtonItem)

    optional func inputBar(inputBar: SIMChatInputBar, shouldDeselectItem item: UIBarButtonItem) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, didDeselectItem item: UIBarButtonItem)
    
//    func inputBar(inputBar: SIMChatInputBar,  sender: NSNotification)
//    func inputBar(inputBar: SIMChatInputBar, keyboardDidShow sender: NSNotification)
//    func inputBar(inputBar: SIMChatInputBar, keyboardWillHide sender: NSNotification)
//    func inputBar(inputBar: SIMChatInputBar, keyboardDidHide sender: NSNotification)
//    func inputBar(inputBar: SIMChatInputBar, keyboardWillChangeFrame sender: NSNotification)
//    func inputBar(inputBar: SIMChatInputBar, keyboardDidChangeFrame sender: NSNotification)
}

// MARK:


///
/// Chat input bar
///
@available(iOS 7.0, *)
public class SIMChatInputBar: UIView {
    
    /// A Boolean value that indicates whether the toolbar is translucent (true) or not (false).
    public var translucent: Bool {
        set { return _inputBackgroundView.translucent = newValue }
        get { return _inputBackgroundView.translucent }
    }
    /// Sets the image to use for the toolbar shadow in top
    public var shadowImage: UIImage? {
        set { return _inputBackgroundView.setShadowImage(newValue, forToolbarPosition: .Top) }
        get { return _inputBackgroundView.shadowImageForToolbarPosition(.Top) }
    }
    
    /// The toolbar style that specifies its appearance.
    public var barStyle: UIBarStyle {
        set { return _inputBackgroundView.barStyle = newValue }
        get { return _inputBackgroundView.barStyle }
    }
    /// The tint color to apply to the toolbar background.
    ///
    /// This color is made translucent by default unless you set the translucent property to false.
    public var barTintColor: UIColor? {
        set { return _inputBackgroundView.barTintColor = newValue }
        get { return _inputBackgroundView.barTintColor }
    }
    
    /// The view’s background color.
    public override var backgroundColor: UIColor? {
        set { return super.backgroundColor = nil }
        get { return super.backgroundColor }
    }
    /// The tint color to apply to the bar button items.
    public override var tintColor: UIColor? {
        set { return _inputBackgroundView.tintColor = newValue }
        get { return _inputBackgroundView.tintColor }
    }
    
    /// extension init
    @inline(__always) private func _init() {
        Log.trace()

        // 背景有两个策略: 1背景只包含`_inputAccessoryView`, 2背景包含所有, 这里采用第1种
        _inputBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        _inputBackgroundView.setContentHuggingPriority(700, forAxis: .Horizontal)
        _inputBackgroundView.setContentHuggingPriority(700, forAxis: .Vertical)
        _inputBackgroundView.setContentCompressionResistancePriority(200, forAxis: .Horizontal)
        _inputBackgroundView.setContentCompressionResistancePriority(200, forAxis: .Vertical)
        
        _inputView.translatesAutoresizingMaskIntoConstraints = false
        _inputAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加视图
        addSubview(_inputBackgroundView)
        addSubview(_inputAccessoryView)
        addSubview(_inputView)
        
        // 添加约束
        addConstraints([
            
            NSLayoutConstraintMake(_inputBackgroundView, .Top, .Equal, _inputAccessoryView, .Top),
            NSLayoutConstraintMake(_inputBackgroundView, .Left, .Equal, _inputAccessoryView, .Left),
            NSLayoutConstraintMake(_inputBackgroundView, .Right, .Equal, _inputAccessoryView, .Right),
            NSLayoutConstraintMake(_inputBackgroundView, .Bottom, .Equal, _inputAccessoryView, .Bottom),
            
            NSLayoutConstraintMake(_inputAccessoryView, .Left, .Equal, self, .Left),
            NSLayoutConstraintMake(_inputAccessoryView, .Right, .Equal, self, .Right),
            
            NSLayoutConstraintMake(_inputView, .Left, .Equal, self, .Left),
            NSLayoutConstraintMake(_inputView, .Right, .Equal, self, .Right),
            
            _inputViewBottom,
            _inputAccessoryViewBottom
        ])
        
        // events
        _addKeyboardNotification()
    }
    /// extension deinit
    @inline(__always) func _deinit() {
        
        // events
        _removeKeyboardNotification()
    }
    
//    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        Log.trace("\(keyPath) => \(change)")
//    }
    
//    lazy var placeholderView: SIMChatInputBarPlaceholderView = {
//        let view = SIMChatInputBarPlaceholderView(view: self)
//        view.autoresizingMask = .FlexibleHeight
//        view.backgroundColor = UIColor.orangeColor()
//        return view
//    }()
    
//    public override func canBecomeFirstResponder() -> Bool {
//        return true
//    }
//    public override func canResignFirstResponder() -> Bool {
//        return true
//    }
//    
//    public override var inputAccessoryView: UIView? {
//        return _inputAccessoryView.placeholderView
//    }
    
    
//        UIView.transitionWithView(self, duration: duration, options: options, animations: {
    
    
//    let textView = UITextView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        // This is required to make the view grow vertically
//        self.autoresizingMask = UIViewAutoresizing.FlexibleHeight
//        
//        // Setup textView as needed
//        self.addSubview(self.textView)
//        self.textView.translatesAutoresizingMaskIntoConstraints = false
//        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[textView]|", options: [], metrics: nil, views: ["textView": self.textView]))
//        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[textView]|", options: [], metrics: nil, views: ["textView": self.textView]))
//        
//        self.textView.delegate = self
//        self.textView.backgroundColor = UIColor.brownColor()
//        self.backgroundColor = UIColor.orangeColor()
//        
//        // Disabling textView scrolling prevents some undesired effects,
//        // like incorrect contentOffset when adding new line,
//        // and makes the textView behave similar to Apple's Messages app
//        self.textView.scrollEnabled = false
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

//    public override func intrinsicContentSize() -> CGSize {
//        // Calculate intrinsicContentSize that will fit all the text
//        //let textSize = self.textView.sizeThatFits(CGSize(width: self.textView.bounds.width, height: CGFloat.max))
//        //return CGSize(width: self.bounds.width, height: textSize.height + 1)
//        //return CGSizeMake(bounds.width, 88)
//    }
    
    /// 开关
    public var enabled: Bool = true {
        willSet {
            // TODO: 未实现的开关
        }
    }
    /// 编辑状态
    public var editing: Bool = false
//        {
//        set { return _textView.editing = newValue }
//        get { return _textView.editing }
//    }
    
    /// 内容
    public var text: String? {
        set { return textView.text = newValue }
        get { return textView.text }
    }
    /// 内容
    public var attributedText: NSAttributedString? {
        set { return textView.attributedText = newValue }
        get { return textView.attributedText }
    }

    
//    /// 当前选择的选项
//    public var selectedBarButtonItem: SIMChatInputItemProtocol? {
//        return _selectedBarButton?.item
//        
//    }
    /// 代理
    public weak var delegate: SIMChatInputBarDelegate? {
        set { return _delegate = newValue }
        get { return _delegate }
    }
    /// 输入框
    public var textView: UITextView { return _textView }
    /// 额外选项
//    public var leftBarButtonItemsView: UIView { return _leftBarButtonItemsView }
//    public var rightBarButtonItemsView: UIView { return _rightBarButtonItemsView }
//    public var bottomBarButtonItemsView: UIView { return _bottomBarButtonItemsView }
    /// 背景
//    public var backgroundView: UIView { return _backgroundView }
//    /// 左侧菜单项
//    public var leftBarButtonItems: [SIMChatInputItemProtocol]? {
//        set { return _leftBarButtonItemsView.items = newValue }
//        get { return _leftBarButtonItemsView.items }
//    }
//    /// 右侧菜单项
//    public var rightBarButtonItems: [SIMChatInputItemProtocol]? {
//        set { return _rightBarButtonItemsView.items = newValue }
//        get { return _rightBarButtonItemsView.items }
//    }
//    /// 底部菜单项
//    public var bottomBarButtonItems: [SIMChatInputItemProtocol]? {
//        set {
//            _bottomBarButtonItems = newValue
//            _bottomBarButtonItemsView.hidden = newValue?.isEmpty ?? true
//            _bottomBarButtonItemsView.reloadData()
//        }
//        get {
//            return _bottomBarButtonItems
//        }
//    }
    
    
//    public override func isFirstResponder() -> Bool {
//        return _inputAccessoryView.isFirstResponder()
////        if _selectedBarButton != nil {
////            return true
////        }
////        if _textViewIsFristResponder {
////            return true
////        }
////        return false
//    }
//    
//    public override func canResignFirstResponder() -> Bool {
////        if _selectedBarButton != nil {
////            return true
////        }
////        if _textViewIsFristResponder {
////            return true
////        }
////        return false
//        return true
//    }
    
    public override func resignFirstResponder() -> Bool {
//        if textView.isFirstResponder() {
        return _inputAccessoryView.resignFirstResponder()
//        }
//        barButtonDidDeselect()
//        super.resignFirstResponder()
//        
//        return false
    }
    
//    public override func canBecomeFirstResponder() -> Bool {
//        return true
//    }
    
    public override func becomeFirstResponder() -> Bool {
        return _inputAccessoryView.becomeFirstResponder()
    }
    
    
    
//    private lazy var _containerView = SIMChatCollectionView(frame: CGRectZero)
//    private lazy var _backgroundView = SIMChatInputBarBackgroundView(frame: CGRectZero)
    
    public override func intrinsicContentSize() -> CGSize {
        let h1 = _inputAccessoryView.intrinsicContentSize().height
        let h2 = _keyboardSize.height
        return CGSizeMake(frame.width, h1 + h2)
    }
    
//    private lazy var _backgroundView: UIImageView = {
//        let view =  UIImageView()
//        view.image = SIMChatImageManager.defautlInputBackground
//        return view
//    }()

    private lazy var _textView: UITextView = {
        let view = UITextView()
//        view.font = UIFont.systemFontOfSize(16)
//        view.scrollsToTop = false
//        view.returnKeyType = .Send
//        view.backgroundColor = UIColor.clearColor()
//        view.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0)
        return view
    }()
    
//    private lazy var _leftBarButtonItemsView: SIMChatInputBarListEmbedView = {
//        let view = SIMChatInputBarListEmbedView()
//        view.delegate = self
//        view.setContentHuggingPriority(UILayoutPriorityDefaultLow + 1, forAxis: .Horizontal)
//        return view
//    }()
//    private lazy var _rightBarButtonItemsView: SIMChatInputBarListEmbedView = {
//        let view = SIMChatInputBarListEmbedView()
//        view.delegate = self
//        view.setContentHuggingPriority(UILayoutPriorityDefaultLow + 1, forAxis: .Horizontal)
//        return view
//    }()
//    private lazy var _bottomBarButtonItemsView: SIMChatCollectionView = {
//        let view = SIMChatCollectionView(frame: self.bounds)
//        view.hidden = true
//        view.delegate = self
//        view.dataSource = self
//        view.backgroundColor = UIColor.clearColor()
//        view.scrollsToTop = false
//        return view
//    }()
    
    private weak var _delegate: SIMChatInputBarDelegate?
    
    /// 不使用系统的, 因为系统的isFristResponder更新速度太慢了
    private var _textViewIsFristResponder: Bool = false
//    private var _bottomBarButtonItems: [SIMChatInputItemProtocol]?
//    private var _selectedBarButton: SIMChatInputBarButton? {
//        didSet {
//            guard _selectedBarButton != oldValue else {
//                return
//            }
//            oldValue?.selected = false
//            if let btn = oldValue {
//                let ani = CATransition()
//                
//                ani.duration = 0.25
//                ani.fillMode = kCAFillModeBackwards
//                ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                ani.type = kCATransitionFade
//                ani.subtype = kCATransitionFromTop
//                
//                btn.layer.addAnimation(ani, forKey: "deselect")
//            }
////            _selectedBarButton?.selected = true
//        }
//    }
    
    /// keyboard event support
    private var _keyboardSize: CGSize = CGSizeZero
    private var _keyboardOffset: CGPoint = CGPointZero
    
    /// Subview
    
    private lazy var _inputView: SIMChatInputView = {
        let view = SIMChatInputView(frame: CGRect.zero)
        view.backgroundColor = nil
        return view
    }()
    private lazy var _inputAccessoryView: SIMChatInputAccessoryView = {
        let view = SIMChatInputAccessoryView(frame: CGRect.zero)
        view.backgroundColor = nil
        view.placeholderView.inputBar = self
        return view
    }()
    private lazy var _inputBackgroundView: SIMChatInputBackgroundView = {
        let view = SIMChatInputBackgroundView(frame: CGRect.zero)
        //view.barStyle = .Black
        view.backgroundColor = nil
        view.userInteractionEnabled = false
        return view
    }()
    
    /// Layout
    
    private lazy var _inputViewBottom: NSLayoutConstraint = {
        return NSLayoutConstraintMake(self, .Bottom, .Equal, self._inputView, .Bottom)
    }()
    private lazy var _inputAccessoryViewBottom: NSLayoutConstraint = {
        return NSLayoutConstraintMake(self, .Bottom, .Equal, self._inputAccessoryView, .Bottom)
    }()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    deinit {
        _deinit()
    }
}

/// 输入视图
internal class SIMChatInputView: UIView {
//    override func intrinsicContentSize() -> CGSize {
//        return CGSize(width: 320, height: 252)
//    }
}
/// 输入状态栏
internal class SIMChatInputAccessoryView: UIView, UITextViewDelegate {
   
    override func intrinsicContentSize() -> CGSize {
        if let size = _cacheIntrinsicContentSize {
            return size
        }
        // Calculate intrinsicContentSize that will fit all the text
        let textSize = _textView.sizeThatFits(CGSize(width: _textView.frame.width, height: CGFloat.max))
        let mHeight = max(_leftBarItemSize.height, _rightBarItemSize.height)
        let height = _textViewTop.constant + max(textSize.height, mHeight) + _textViewBottom.constant
        Log.trace("\(textSize) => \(height)")
        
        let size = CGSize(width: frame.width, height: height + 1)
        _cacheIntrinsicContentSize = size
        return size
    }
    override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        superview?.invalidateIntrinsicContentSize()
        // clear cache
        _cacheIntrinsicContentSize = nil
        // Must tell `placeholderView` the `intrinsicContentSize` has been changed
        placeholderView.invalidateIntrinsicContentSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // when the frame stability calculation again
        if !_isInitBarItemLayouts {
            _isInitBarItemLayouts = true
            _updateBarItemLayouts()
        }
    }
    
    /// A `placeholderView` for system `inputAccessoryView`
    var placeholderView: SIMChatInputPlaceholderView {
        return _placeholderView
    }
    
//    override func canResignFirstResponder() -> Bool {
//        return true
//    }
//    override func resignFirstResponder() -> Bool {
//        return _textView.resignFirstResponder()
//    }
//    override func canBecomeFirstResponder() -> Bool {
//        return false//true
//    }
//    override func becomeFirstResponder() -> Bool {
//        return _textView.becomeFirstResponder()
//    }
//
//    override func nextResponder() -> UIResponder? {
//        return superview?.nextResponder()
//    }
    
    /// 文本己经改变.
    func textViewDidChange(textView: UITextView) {
        _layoutIfNeeded(true)
    }
    
    @inline(__always) private func _init() {
        
        addSubview(_collectionView)
        addSubview(_textView)
        
        _textView.translatesAutoresizingMaskIntoConstraints = false
        
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.setContentHuggingPriority(700, forAxis: .Horizontal)
        _collectionView.setContentHuggingPriority(700, forAxis: .Vertical)
        _collectionView.setContentCompressionResistancePriority(200, forAxis: .Horizontal)
        _collectionView.setContentCompressionResistancePriority(200, forAxis: .Vertical)
        
        addConstraints([
            NSLayoutConstraintMake(_collectionView, .Top, .Equal, self, .Top),
            NSLayoutConstraintMake(_collectionView, .Left, .Equal, self, .Left),
            NSLayoutConstraintMake(_collectionView, .Right, .Equal, self, .Right),
            NSLayoutConstraintMake(_collectionView, .Bottom, .Equal, self, .Bottom),
            
            _textViewTop,
            _textViewLeft,
            _textViewRight,
            _textViewBottom,
        ])
        
        
        class TestBarItem:UIBarButtonItem {
            
            init(image: UIImage?, alignment: SIMChatInputAlignment = .Automatic) {
                _size = image?.size ?? CGSizeZero
                _image = image
                super.init()
                self.alignment = alignment
                self.image = image
            }
            
            init(size: CGSize, alignment: SIMChatInputAlignment) {
                _size = size
                super.init()
                self.alignment = alignment
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override var size: CGSize {
                return _size
            }
            
            var _size: CGSize
            var _image: UIImage?
        }
        
        // 对齐测试
        // _topBarItems = [
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Left),
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Left),
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Left),
        //     TestBarItem(size: CGSizeMake(132, 34), alignment: .Right),
        // ]
        // _leftBarItems = [
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Bottom),
        // ]
        // _rightBarItems = [
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Center),
        //     TestBarItem(size: CGSizeMake(34, 34), alignment: .Top),
        // ]
        // _bottomBarItems = [
        //     TestBarItem(size: CGSizeMake(32, 32), alignment: .TopLeft),
        //     TestBarItem(size: CGSizeMake(24, 24), alignment: .Center),
        //     TestBarItem(size: CGSizeMake(32, 32), alignment: .BottomLeft),
        //     TestBarItem(size: CGSizeMake(64, 64), alignment: .Center),
        //     TestBarItem(size: CGSizeMake(32, 32), alignment: .BottomRight),
        //     TestBarItem(size: CGSizeMake(24, 24), alignment: .Center),
        //     TestBarItem(size: CGSizeMake(32, 32), alignment: .TopRight),
        // ]
        
        // 图标测试
        // qqzone
        _topBarItems = [
            TestBarItem(image: UIImage(named:"mqz_input_atFriend"), alignment: .Left),
            TestBarItem(image: UIImage(named:"mqz_ugc_inputCell_face_icon"), alignment: .Left),
            TestBarItem(image: UIImage(named:"mqz_ugc_inputCell_pic_icon"), alignment: .Left),
            TestBarItem(image: UIImage(named:"mqz_ugc_inputCell_private_icon"), alignment: .Right),
        ]
        // // wexin
        // _leftBarItems = [
        //     TestBarItem(image: UIImage(named:"chat_bottom_PTT_nor"), alignment: .BottomLeft),
        // ]
        // _rightBarItems = [
        //     TestBarItem(image: UIImage(named:"chat_bottom_emotion_nor"), alignment: .BottomRight),
        //     TestBarItem(image: UIImage(named:"chat_bottom_more_nor"), alignment: .BottomRight),
        // ]
        // // qq
        // _bottomBarItems = [
        //     TestBarItem(image: UIImage(named:"chat_bottom_PTT_nor"), alignment: .Left),
        //     TestBarItem(image: UIImage(named:"chat_bottom_PTV_nor")),
        //     TestBarItem(image: UIImage(named:"chat_bottom_photo_nor")),
        //     TestBarItem(image: UIImage(named:"chat_bottom_Camera_nor")),
        //     TestBarItem(image: UIImage(named:"chat_bottom_red_pack_nor")),
        //     TestBarItem(image: UIImage(named:"chat_bottom_emotion_nor")),
        //     TestBarItem(image: UIImage(named:"chat_bottom_more_nor"), alignment: .Right),
        //     //TestBarItem(image: UIImage(named:"chat_bottom_file_nor")),
        //     //TestBarItem(image: UIImage(named:"chat_bottom_keyboard_nor")),
        //     //TestBarItem(image: UIImage(named:"chat_bottom_location_nor")),
        //     //TestBarItem(image: UIImage(named:"chat_bottom_mypc_nor")),
        //     //TestBarItem(image: UIImage(named:"chat_bottom_shake_nor")),
        // ]
        
//         bar.bottomBarButtonItems = [
//             SIMChatInputPanelAudioView.inputPanelItem(),
//            SIMChatBaseInputItem("", R("chat_bottom_PTV_nor"), R("chat_bottom_PTV_press")),
//            SIMChatBaseInputItem("kb:photo", R("chat_bottom_photo_nor"), R("chat_bottom_photo_press")),
//            SIMChatBaseInputItem("kb:camera", R("chat_bottom_Camera_nor"), R("chat_bottom_Camera_press")),
//            SIMChatBaseInputItem("", R("chat_bottom_red_pack_nor"), R("chat_bottom_red_pack_press")),
//            SIMChatInputPanelEmoticonView.inputPanelItem(),
//            SIMChatInputPanelToolBoxView.inputPanelItem()
//         ]
        
        //_updateBarItemLayouts()
        //_collectionView.reloadData()
    }
    @inline(__always) private func _deinit() {
    }
    
    @inline(__always) private func _layoutIfNeeded(animated: Bool) {
        let newValue = _textView.contentSize
        let oldValue = _cacheContentSize ?? CGSizeZero
        
        guard newValue.height != oldValue.height else {
            return
        }
        
        Log.trace("\(newValue) => \(oldValue)")
        
        _cacheContentSize = newValue
        invalidateIntrinsicContentSize()
        
        UIView.animateWithDuration(0.25) {
            self._collectionView.reloadItemsAtIndexPaths([self._centerIndexPath])
            // 强制更新
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
        // 重置offset, 因为offset在文字更新之前己经做了修改
        _textView.setContentOffset(CGPoint.zero, animated: animated)
    }
    
    // MARK: Items
    
    var _topBarItems: [UIBarButtonItem] = []
    var _leftBarItems: [UIBarButtonItem] = []
    var _rightBarItems: [UIBarButtonItem] = []
    var _bottomBarItems: [UIBarButtonItem] = []
    
    var _centerBarItem: UIBarButtonItem = UIBarButtonItem()
    var _centerIndexPath: NSIndexPath {
        return NSIndexPath(forItem: _leftBarItems.count, inSection: 1)
    }
    
    // MARK: Subview
    
    private lazy var _textView: UITextView = {
        let view = UITextView()
        
        view.font = UIFont.systemFontOfSize(16)
        view.scrollsToTop = false
        view.returnKeyType = .Send
        //view.backgroundColor = UIColor.clearColor()
        view.backgroundColor = UIColor.grayColor()
        view.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0)
        view.delegate = self
        
        return view
    }()
    
    private lazy var _collectionView: UICollectionView = {
        let layout = SIMChatInputAlignmentFlowLayout()
        let view = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = nil
        view.bounces = false
        view.scrollsToTop = false
        view.scrollEnabled = false
        view.allowsSelection = true//false
        view.multipleTouchEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        
        view.registerClass(SIMChatInputBarItemView.self, forCellWithReuseIdentifier: "SIMChatInputItemButton")
        view.registerClass(SIMChatInputBarItemView.self, forCellWithReuseIdentifier: "SIMChatInputItemContainer")
        
        return view
    }()
    private lazy var _placeholderView: SIMChatInputPlaceholderView = {
        let view = SIMChatInputPlaceholderView(view: self)
        // This is required to make the view grow vertically
        view.autoresizingMask = .FlexibleHeight
        view.backgroundColor = nil//UIColor(white: 0, alpha: 0.2)
        return view
    }()
    
    // MARK: Layout
   
    private lazy var _textViewTop: NSLayoutConstraint = {
        return NSLayoutConstraintMake(self._textView, .Top, .Equal, self, .Top)
    }()
    private lazy var _textViewLeft: NSLayoutConstraint = {
        return NSLayoutConstraintMake(self._textView, .Left, .Equal, self, .Left)
    }()
    private lazy var _textViewRight: NSLayoutConstraint = {
        return NSLayoutConstraintMake(self, .Right, .Equal, self._textView, .Right)
    }()
    private lazy var _textViewBottom: NSLayoutConstraint = {
        return NSLayoutConstraintMake(self, .Bottom, .Equal, self._textView, .Bottom)
    }()
    
    // MARK: Cache
    
    private var _cacheContentSize: CGSize?
    private var _cacheIntrinsicContentSize: CGSize?
    
    private var _cacheTopBarItemSize: CGSize?
    private var _cacheLeftBarItemSize: CGSize?
    private var _cacheRightBarItemSize: CGSize?
    private var _cacheBottomBarItemSize: CGSize?
    
    private var _cacheBarItemContainer: UICollectionViewCell?
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    deinit {
        _deinit()
    }
    
    private var _isInitBarItemLayouts = false
}
/// inputbar bacgkround view
internal class SIMChatInputBackgroundView: UIToolbar {
}
/// inputbar accessory placeholder view
internal class SIMChatInputPlaceholderView: UIView {
    
    /// never disable user interaction
    override var userInteractionEnabled: Bool {
        set { return }
        get { return false }
    }
    
    /// Mapping to `inputAccessoryView` the `intrinsicContentSize`
    override func intrinsicContentSize() -> CGSize {
        return accessoryView?.intrinsicContentSize() ?? super.intrinsicContentSize()
    }
    
    // Mapping to `inputAccessoryView`
    weak var accessoryView: UIView?
    // Mapping to `inputBar`
    weak var inputBar: SIMChatInputBar?
    
    init(view: UIView) {
        super.init(frame: CGRect.zero)
        accessoryView = view
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// a alignment flow collection view layout
internal class SIMChatInputAlignmentFlowLayout: UICollectionViewFlowLayout {
    /// rewrite
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElementsInRect(rect) else {
            return nil
        }
        guard let collectionView = collectionView else {
            return attributes
        }
        guard let delegate = collectionView.delegate as? SIMChatInputAlignmentDelegateFlowLayout else {
            return attributes
        }
        // process
        return delegate.collectionView(collectionView, layout:self, layoutAttributesForElements:attributes, inRect:rect)
    }
}


/// use in SIMChatInputAlignmentFlowLayout
internal protocol SIMChatInputAlignmentDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, layoutAttributesForElements: [UICollectionViewLayoutAttributes], inRect rect: CGRect) -> [UICollectionViewLayoutAttributes]
}

//extension SIMChatInputBar: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate, UIKeyInput {
//    
//    // MARK: UITextInputTraits & Forward
//    
//    public var autocapitalizationType: UITextAutocapitalizationType {
//        set { return textView.autocapitalizationType = newValue }
//        get { return textView.autocapitalizationType }
//    }
//    public var autocorrectionType: UITextAutocorrectionType {
//        set { return textView.autocorrectionType = newValue }
//        get { return textView.autocorrectionType }
//    }
//    public var spellCheckingType: UITextSpellCheckingType {
//        set { return textView.spellCheckingType = newValue }
//        get { return textView.spellCheckingType }
//    }
//    public var keyboardType: UIKeyboardType {
//        set { return textView.keyboardType = newValue }
//        get { return textView.keyboardType }
//    }
//    public var keyboardAppearance: UIKeyboardAppearance {
//        set { return textView.keyboardAppearance = newValue }
//        get { return textView.keyboardAppearance }
//    }
//    public var returnKeyType: UIReturnKeyType {
//        set { return textView.returnKeyType = newValue }
//        get { return textView.returnKeyType }
//    }
//    public var enablesReturnKeyAutomatically: Bool {
//        set { return textView.enablesReturnKeyAutomatically = newValue }
//        get { return textView.enablesReturnKeyAutomatically }
//    }
//    public var secureTextEntry: Bool {
//        get { return textView.secureTextEntry }
//    }
//    
//    // MARK: UIKeyInput
//    
//    public func hasText() -> Bool {
//        return textView.hasText()
//    }
//    public func insertText(text: String) {
//        textView.insertText(text)
//    }
//    public func insertAttributedText(attributedText: NSAttributedString) {
////        textView.insertAttributedText(attributedText)
//    }
//    public func deleteBackward() {
////        textView.deleteBackward()
//    }
//    public func clearText() {
////        return textView.clearText()
//    }
//
//    // MARK: UITextViewDelegate & Forward
//    
//    /// 将要编辑文本
//    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
//        guard delegate?.inputBarShouldBeginEditing?(self) ?? true else {
//            return false
//        }
//        _textViewIsFristResponder = true
//        return true
//    }
//    /// 己经开始编辑了
//    public func textViewDidBeginEditing(textView: UITextView) {
//        delegate?.inputBarDidBeginEditing?(self)
//        barButtonDidDeselect()
//    }
//    /// 将要结束
//    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
//        guard delegate?.inputBarShouldEndEditing?(self) ?? true else {
//            return false
//        }
//        _textViewIsFristResponder = false
//        return true
//    }
//    /// 己经结束
//    public func textViewDidEndEditing(textView: UITextView) {
//        delegate?.inputBarDidEndEditing?(self)
//    }
//    /// 文本将要改变
//    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        guard delegate?.inputBar?(self, shouldChangeCharactersInRange: range, replacementString: text) ?? true else {
//            return false
//        }
//        // 这是换行
//        if text == "\n" {
//            return delegate?.inputBarShouldReturn?(self) ?? true
//        }
//        // 这是clear
//        if text.isEmpty && range.location == 0 && range.length == (self.text as NSString?)?.length {
//            return delegate?.inputBarShouldClear?(self) ?? true
//        }
//        
//        return true
//    }
//    
//    /// 文本己经改变.
//    public func textViewDidChange(textView: UITextView) {
//        delegate?.inputBarDidChange?(self)
//        
//        //_layoutIfNeeded(true)
//    }
//    /// 选择改变
//    public func textViewDidChangeSelection(textView: UITextView) {
//        delegate?.inputBarDidChangeSelection?(self)
//    }
//    
//    // MARK: UICollectionViewDelegate & UICollectionViewDelegate
//    
//    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 99//bottomBarButtonItems?.count ?? 0
//    }
//    
//    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
////        guard let count = bottomBarButtonItems?.count where count > 0 else {
////            return 0
////        }
//        let count = 8
//        var width = bounds.width
//        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
//            width -= layout.sectionInset.left + layout.sectionInset.right
//            width -= layout.itemSize.width * CGFloat(min(count, 7))
//        }
//        return max(width / CGFloat(min(count, 7)), 10)
//    }
//    
//    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        return collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
//    }
//    
//    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
////        guard let cell = cell as? SIMChatInputBarCell, item = bottomBarButtonItems?[indexPath.row] else {
////            return
////        }
////        cell.button.delegate = self
////        cell.button.item = item
//    }
//}
//
//
//// MARK: - SIMChatInputItemProtocolViewDelegate
//
//extension SIMChatInputBar: SIMChatInputBarButtonDelegate {
//    /// 选择这个选项
//    func inputBarButtonDidSelect(inputBarButton: SIMChatInputBarButton) {
////        guard let accessory = inputBarButton.item where _selectedBarButton != inputBarButton else {
////            return
////        }
////        if delegate?.inputBar?(self, shouldSelectItem: accessory) ?? true {
////            if let accessory = inputBarButton.item {
////                delegate?.inputBar?(self, willDeselectItem: accessory)
////            }
////            
////            let oldValue = _selectedBarButton
////            _selectedBarButton = inputBarButton
////            
////            if textView.isFirstResponder() {
////                textView.resignFirstResponder()
////            }
////            
////            if let accessory = oldValue?.item {
////                delegate?.inputBar?(self, didDeselectItem: accessory)
////            }
////            delegate?.inputBar?(self, didSelectItem: accessory)
////        }
//    }
//    /// 取消选择
//    private func barButtonDidDeselect() {
////        guard let barButton = _selectedBarButton else {
////            return
////        }
////        _selectedBarButton = nil
////        if let accessory = barButton.item {
////            delegate?.inputBar?(self, didDeselectItem: accessory)
////        }
//    }
//}
//
/////
/////
/////
//internal class SIMChatInputBarButton: UIButton {
//    private override init(frame: CGRect) {
//        super.init(frame: frame)
//        addTarget(self, action: #selector(self.dynamicType.onClicked), forControlEvents: .TouchUpInside)
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        addTarget(self, action: #selector(self.dynamicType.onClicked), forControlEvents: .TouchUpInside)
//    }
//    
//    /// 点击事件.
//    private dynamic func onClicked() {
//        delegate?.inputBarButtonDidSelect(self)
//    }
//    
//    override var selected: Bool {
//        set {
//            guard selected != newValue else {
//                return
//            }
////            if newValue {
////                setImage(item?.itemSelectImage, forState: .Normal)
////                setImage(item?.itemImage, forState: .Highlighted)
////            } else {
////                setImage(item?.itemImage, forState: .Normal)
////                setImage(item?.itemSelectImage, forState: .Highlighted)
////            }
//            _selected = newValue
//        }
//        get {
//            return _selected
//        }
//    }
////    private var item: SIMChatInputItemProtocol? {
////        didSet {
////            _selected = true
////            selected = false
////        }
////    }
//    
//    private var _selected: Bool = false
//    private weak var delegate: SIMChatInputBarButtonDelegate?
//}
//
///////
/////// 自定义单元格
///////
////internal class SIMChatInputBarCell: UICollectionViewCell {
////    lazy var button: SIMChatInputBarButton = {
////        let button = SIMChatInputBarButton()
////        button.frame = self.bounds
////        button.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
////        self.addSubview(button)
////        return button
////    }()
////}
//

/// inputbar bar item container view
internal class SIMChatInputBarItemView: UICollectionViewCell {
    
    var item: UIBarButtonItem? {
        willSet {
            _updateItem(newValue)
        }
    }
    
    @inline(__always) func _init() {
        backgroundColor = UIColor.clearColor()
    }
    
    @inline(__always) func _updateItem(item: UIBarButtonItem?) {
        //backgroundColor = UIColor.purpleColor()
        //self.contentView.layer.contentsGravity = kCAGravityCenter
        self.contentView.layer.contents = item?.image?.CGImage
    }
    
    override var highlighted: Bool {
        willSet {
            Log.trace(newValue)
        }
    }
    override var selected: Bool {
        willSet {
            Log.trace(newValue)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._init()
    }
}

///
/// 自定义的输入框
///
internal class SIMChatInputBarTextView: UITextView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        build()
    }
    
    @inline(__always) private func build() {
        addSubview(_caretView)
    }
    
    @inline(__always) private func updateCaretView() {
        _caretView.frame = caretRectForPosition(selectedTextRange?.start ?? UITextPosition())
    }
    
    override func insertText(text: String) {
        super.insertText(text)
        updateCaretView()
    }
//    override func insertAttributedText(attributedText: NSAttributedString) {
//        super.insertAttributedText(attributedText)
//        updateCaretView()
//    }
//    override func deleteBackward() {
//        super.deleteBackward()
//        updateCaretView()
//    }
//    override func clearText() {
//        super.clearText()
//        updateCaretView()
//    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        if newWindow != nil {
            updateCaretView()
        }
        super.willMoveToWindow(newWindow)
    }
    
//    override func becomeFirstResponder() -> Bool {
//        let b = super.becomeFirstResponder()
//        if b {
//            _isFirstResponder = true
//        }
//        return b
//    }
//    
//    override func nextResponder() -> UIResponder? {
//        return superview?.nextResponder()
//    }
//    
//    override func resignFirstResponder() -> Bool {
//        let b = super.resignFirstResponder()
//        if b {
//            updateCaretView()
//            _isFirstResponder = false
//        }
//        return b
//    }
    
    
    var maxHeight: CGFloat = 93
    var editing: Bool = false {
        didSet {
            if editing {
                _caretView.hidden = _isFirstResponder
            } else {
                _caretView.hidden = true
            }
        }
    }
    
//    override var contentSize: CGSize {
//        didSet {
//            guard oldValue != contentSize /*&& (oldValue.height <= maxHeight || contentSize.height <= maxHeight)*/ else {
//                return
//            }
//            invalidateIntrinsicContentSize()
//            // 只有正在显示的时候才添加动画
//            guard window != nil else {
//                return
//            }
//            UIView.animateWithDuration(0.25) {
//                // 必须在更新父视图之前
//                self.layoutIfNeeded()
//                // 必须显示父视图, 因为这个改变会导致父视图大小改变
//                self.superview?.layoutIfNeeded()
//            }
//            SIMChatNotificationCenter.postNotificationName(SIMChatInputBarFrameDidChangeNotification, object: superview)
//        }
//    }
//    
//    override func intrinsicContentSize() -> CGSize {
////        if contentSize.height > maxHeight {
////            return CGSizeMake(contentSize.width, maxHeight)
////        }
//        return contentSize
//    }
    
//    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
//        // 如果是自定义菜单, 完全转发
//        if SIMChatMenuController.sharedMenuController().isCustomMenu() {
//            return SIMChatMenuController.sharedMenuController().canPerformAction(action, withSender: sender)
//        }
//        return super.canPerformAction(action, withSender: sender)
//    }
//    
//    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
//        // 如果是自定义菜单, 完全转发
//        if SIMChatMenuController.sharedMenuController().isCustomMenu() {
//            return SIMChatMenuController.sharedMenuController().forwardingTargetForSelector(aSelector)
//        }
//        return super.forwardingTargetForSelector(aSelector)
//    }
    
    var _isFirstResponder: Bool = false {
        didSet {
            editing = !(!editing)
        }
    }
    
    lazy var _caretView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        view.backgroundColor = UIColor.purpleColor()
        view.hidden = true
        return view
    }()
}

/////
///// 内容
/////
//internal class SIMChatCollectionView: UICollectionView {
//    
//    init(frame: CGRect) {
//        let layout = UICollectionViewFlowLayout()
//        
//        layout.itemSize = CGSizeMake(34, 34)
//        layout.sectionInset = UIEdgeInsetsMake(8, 10, 8, 10)
//        
//        super.init(frame: frame, collectionViewLayout: layout)
//        
//        scrollEnabled = false
//        showsHorizontalScrollIndicator = false
//        showsVerticalScrollIndicator = false
//        registerClass(SIMChatInputBarCell.self, forCellWithReuseIdentifier: "Cell")
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    override func updateConstraints() {
//        super.updateConstraints()
//        collectionViewLayout.invalidateLayout()
//    }
//    override func intrinsicContentSize() -> CGSize {
//        if numberOfItemsInSection(0) == 0 {
//            return CGSizeMake(contentSize.width, 0)
//        }
//        return contentSize
//    }
//    
//    override var contentSize: CGSize {
//        didSet {
//            if oldValue != contentSize {
//                invalidateIntrinsicContentSize()
//            }
//        }
//    }
//}
//
//
//
/////
///// 自定义菜单栏(嵌入)
/////
//internal class SIMChatInputBarListEmbedView: UIView {
////        override func intrinsicContentSize() -> CGSize {
////            return CGSizeMake(CGFloat(items?.count ?? 0) * (34 + 5) - 5, 34)
////        }
////        override func layoutSubviews() {
////            super.layoutSubviews()
////            var x = CGFloat(0)
////            buttons.forEach {
////                let nframe = CGRectMake(x, 0, 34, 34)
////                $0.frame = nframe
////                x += nframe.width + 5
////            }
////        }
////        
////        /// 重新加载数据
////        func reloadData() {
////            var btns = buttons
////            buttons = []
////            items?.forEach { [weak self] in
////                let btn = btns.isEmpty ? SIMChatInputBarButton() : btns.removeFirst()
////                
////                btn.item = $0
////                btn.delegate = self?.delegate
////                
////                self?.addSubview(btn)
////                self?.buttons.append(btn)
////            }
////            btns.forEach {
////                $0.removeFromSuperview()
////            }
////            setNeedsLayout()
////        }
//    
//        weak var delegate: SIMChatInputBarButtonDelegate?
//        var buttons: [SIMChatInputBarButton] = []
////        var items: [SIMChatInputItemProtocol]? {
////            didSet {
////                reloadData()
////                guard items?.count != oldValue?.count else {
////                    return
////                }
////                invalidateIntrinsicContentSize()
////            }
////        }
//}

//internal protocol SIMChatInputBarButtonDelegate: class {
//    func inputBarButtonDidSelect(inputBarButton: SIMChatInputBarButton)
//}

// MARK:

///
/// Accessory Item Support
///
extension SIMChatInputAccessoryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SIMChatInputAlignmentDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:  return _topBarItems.count
        case 1:  return _leftBarItems.count + 1 + _rightBarItems.count
        case 2:  return _bottomBarItems.count
        default: fatalError()
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if _centerIndexPath == indexPath {
            if let cell = _cacheBarItemContainer {
                return cell
            }
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SIMChatInputItemContainer", forIndexPath: indexPath)
            _cacheBarItemContainer = cell
            return cell
        }
        return collectionView.dequeueReusableCellWithReuseIdentifier("SIMChatInputItemButton", forIndexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? SIMChatInputBarItemView else {
            return
        }
        cell.item = _barItem(at: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        Log.trace(indexPath)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return _sectionInset(section)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return _sizeForItem(_barItem(at: indexPath))
    }
    
    // MARK: SIMChatInputAlignmentDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, layoutAttributesForElements attributes: [UICollectionViewLayoutAttributes], inRect rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        Log.trace()
        
        var newAttributes: [UICollectionViewLayoutAttributes] = []
        // each line
        class Line: CustomStringConvertible {
            var frame: CGRect
            var inset: UIEdgeInsets
            var section: Int
            var items: Array<UICollectionViewLayoutAttributes>
            
            var description: String {
                return "<Line> section: \(section); frame: \(frame); inset: \(inset); items: \(items); "
            }
            
            init(_ firstItem: UICollectionViewLayoutAttributes, _ inset: UIEdgeInsets = UIEdgeInsetsZero) {
                self.frame = firstItem.frame
                self.section = firstItem.indexPath.section
                self.inset = inset
                self.items = [firstItem]
            }
            func addItem(item: UICollectionViewLayoutAttributes, _ spacing: CGFloat) {
                
                let x = min(frame.minX, item.frame.minX)
                let y = min(frame.minY, item.frame.minY)
                let width = frame.width + spacing + item.frame.width
                let height = max(frame.height, item.frame.height)
                
                frame = CGRectMake(x, y, width, height)
                items.append(item)
            }
            func canAddItem(item: UICollectionViewLayoutAttributes, _ width: CGFloat, _ spacing: CGFloat) -> Bool {
                let nWidth = frame.width + spacing + item.frame.width
                return nWidth <= width - inset.left - inset.right
            }
        }
        // step 0: converting the data lines
        let result = attributes.reduce([Line]()) {
            // step 0.0: check section, if changed, then create a new line
            guard let line = $0.last where line.section == $1.indexPath.section else {
                var lines = $0
                lines.append(Line($1, _sectionInset($1.indexPath.section)))
                return lines
            }
            // step 0.1: check the width, if you can't hold, then create a new line
            guard line.canAddItem($1, rect.width, _minimumInteritemSpacing()) else {
                var lines = $0
                lines.append(Line($1, _sectionInset($1.indexPath.section)))
                return lines
            }
            line.addItem($1, _minimumInteritemSpacing())
            return $0
        }
        // step 1: for alignment operation
        result.forEach { line in
            var centersCnt: Int = 0
            var centersWidth: CGFloat = 0
            // step 1.0: once obtained the position of the left and right position
            var leftIndex = -1
            var rightIndex = line.items.count
            line.items.enumerate().forEach { index, item in
                let alignment = _barItemAlginment(at: item.indexPath)
                if alignment.rawValue & 0x0001 != 0 {
                    // [0 ~ index] aligned to the left
                    leftIndex = index
                    // reset, not allowed in the left align area exist in the right align
                    centersCnt = 0
                    centersWidth = 0
                    rightIndex = line.items.count
                } else if alignment.rawValue & 0x0002 != 0 {
                    // [index ~ end] aligned to the right
                    rightIndex = min(rightIndex, index)
                } else if alignment.rawValue & 0x0004 != 0 {
                    // aligned to the center
                    if index < rightIndex {
                        centersCnt += 1
                        centersWidth += item.frame.width
                    }
                }
            }
            // step 1.1: add the processing sequence
            var indexs: [Int] = []
            
            indexs.appendContentsOf((rightIndex ..< line.items.endIndex).reverse())
            indexs.appendContentsOf((line.items.startIndex ..< rightIndex))
            
            // step 1.2: apply all chagne
            var left: CGFloat = 0
            var right: CGFloat = 0
            var cspace: CGFloat = -1
            var lspace: CGFloat = line.inset.left
            var rspace: CGFloat = line.inset.right
            
            indexs.forEach { index in
                // must copy `UICollectionViewLayoutAttributes`
                let item = line.items[index].copy() as! UICollectionViewLayoutAttributes
                var x = item.frame.minX
                var y = item.frame.minY
                let width = item.frame.width
                let height = item.frame.height
                let alignment = _barItemAlginment(at: item.indexPath)
                // horizontal alignment
                if index <= leftIndex {
                    // aligned to the left
                    x = left + lspace
                    left = left + lspace + width
                    lspace = _minimumInteritemSpacing()
                } else if index >= rightIndex {
                    // aligned to the right
                    x = rect.width - right - rspace - width
                    right = width + rspace + right
                    rspace = _minimumInteritemSpacing()
                } else if alignment.rawValue & 0x0004 != 0 {
                    // aligned to then center
                    // NOTE: center must be calculated finally
                    if cspace < 0 {
                        cspace = (rect.width - right - left - centersWidth) / CGFloat(centersCnt + 1)
                    }
                    x = left + cspace
                    left = left + cspace + width
                }
                // vertical alignment
                if alignment.rawValue & 0x0100 != 0 {
                    // aligned to the top
                    y = line.frame.minY
                } else if alignment.rawValue & 0x0200 != 0 {
                    // aligned to the bottom
                    y = line.frame.maxY - height
                } else if alignment.rawValue & 0x0400 != 0 {
                    // aligned to the center
                    // the default is centered vertically, does not need to be modified
                    //y = line.frame.minY + (line.frame.height - height) / 2
                }
                item.frame = CGRectMake(x, y, width, height)
                newAttributes.append(item)
            }
        }
        return newAttributes
    }
    
    // MARK: config data
    
    @inline(__always) private func _barItem(at indexPath: NSIndexPath) -> UIBarButtonItem {
        switch indexPath.section {
        case 0:
            if indexPath.item < _topBarItems.count {
                return _topBarItems[indexPath.item]
            }
        case 1:
            if indexPath.item < _leftBarItems.count {
                return _leftBarItems[indexPath.item]
            }
            if indexPath.item == _centerIndexPath.item {
                return _centerBarItem
            }
            if indexPath.item < _rightBarItems.count + _leftBarItems.count + 1 {
                return _rightBarItems[indexPath.item - _leftBarItems.count - 1]
            }
        case 2:
            if indexPath.item < _bottomBarItems.count {
                return _bottomBarItems[indexPath.row]
            }
        default:
            break
        }
        fatalError("barItem not found at \(indexPath)")
    }
    @inline(__always) private func _barItemAlginment(at indexPath: NSIndexPath) -> SIMChatInputAlignment {
        let item = _barItem(at: indexPath)
        if item.alignment == .Automatic {
            // in automatic mode, the section will have different performance
            switch indexPath.section {
            case 0:  return .Bottom
            case 1:  return .Bottom
            case 2:  return .Bottom
            default: return .Center
            }
        }
        return item.alignment
    }
    
    @inline(__always) private func _sizeForItem(item: UIBarButtonItem) -> CGSize {
        if item === _centerBarItem {
            
            // width = left - right
            // height = sizeThatFits
            // - _ -
            let textSize = _textView.sizeThatFits(CGSize(width: _textView.bounds.width, height: CGFloat.max))
            return CGSizeMake(_textView.bounds.width, textSize.height + 1)
        }
        return item.size
    }
    @inline(__always) func _sectionInset(inSection: Int) -> UIEdgeInsets {
        switch inSection {
        case 0:
            if _collectionView.numberOfItemsInSection(inSection) != 0 {
                return UIEdgeInsetsMake(8, 10, 0, 10)
            }
            return UIEdgeInsetsZero
        case 1:
            return UIEdgeInsetsMake(8, 10, 8, 10)
        case 2:
            if _collectionView.numberOfItemsInSection(inSection) != 0 {
                return UIEdgeInsetsMake(0, 10, 8, 10)
            }
            return UIEdgeInsetsZero
        default:
            return UIEdgeInsetsZero
        }
    }
    @inline(__always) func _minimumLineSpacing() -> CGFloat {
        return 8
    }
    @inline(__always) func _minimumInteritemSpacing() -> CGFloat {
        return 8
    }
    
    // MARK: calculation layout
    
    private var _topBarItemSize: CGSize {
        if let size = _cacheTopBarItemSize {
            return size
        }
        if _topBarItems.isEmpty {
            return CGSizeZero
        }
        var mWidth: CGFloat = 0
        var mHeight: CGFloat = 0
        // width: (sizeForItem.width + minimumInteritemSpacing) * column - minimumInteritemSpacing
        // height: (sizeForItem.height + minimumLineSpacing) * row - minimumLineSpacing
        let mls = _minimumLineSpacing()
        let mis = _minimumInteritemSpacing()
        let frame = UIEdgeInsetsInsetRect(self.frame, _sectionInset(0))
        let size = _topBarItems.reduce(CGSizeMake(-mis, -mls)) {
            let size = _sizeForItem($1)
            let width = $0.width + mis + size.width
            guard width < frame.width else {
                let nsize = CGSizeMake(-mls, $0.height + mHeight + mls)
                
                mWidth = max(mWidth, $0.width)
                mHeight = size.height
                
                return nsize
            }
            mWidth = max(mWidth, width)
            mHeight = max(mHeight, size.height)
            return CGSizeMake(width, $0.height)
        }
        
        let newSize = CGSizeMake(mWidth, size.height + mls + mHeight)
        _cacheTopBarItemSize = newSize
        return newSize
    }
    private var _leftBarItemSize: CGSize {
        if let size = _cacheLeftBarItemSize {
            return size
        }
        if _leftBarItems.isEmpty {
            return CGSizeZero
        }
        // width: sizeForItem.width * count + minimumInteritemSpacing * count - 1
        // height: max(sizeForItem.height, ...)
        let mis = _minimumInteritemSpacing()
        let size = _leftBarItems.reduce(CGSizeMake(0, 0)) {
            let size = _sizeForItem($1)
            return CGSizeMake($0.width + size.width + mis, max($0.height, size.height))
        }
        
        _cacheLeftBarItemSize = size
        return size
    }
    private var _rightBarItemSize: CGSize {
        if let size = _cacheRightBarItemSize {
            return size
        }
        if _rightBarItems.isEmpty {
            return CGSizeZero
        }
        // width: sizeForItem.width * count + minimumInteritemSpacing * count - 1
        // height: max(sizeForItem.height, ...)
        let mis = _minimumInteritemSpacing()
        let size = _rightBarItems.reduce(CGSizeMake(0, 0)) {
            let size = _sizeForItem($1)
            return CGSizeMake($0.width + size.width + mis, max($0.height, size.height))
        }
        
        _cacheRightBarItemSize = size
        return size
    }
    private var _bottomBarItemSize: CGSize {
        if let size = _cacheBottomBarItemSize {
            return size
        }
        if _bottomBarItems.isEmpty {
            return CGSizeZero
        }
        var mWidth: CGFloat = 0
        var mHeight: CGFloat = 0
        // width: (sizeForItem.width + minimumInteritemSpacing) * column - minimumInteritemSpacing
        // height: (sizeForItem.height + minimumLineSpacing) * row - minimumLineSpacing
        let mis = _minimumInteritemSpacing()
        let mls = _minimumLineSpacing()
        let frame = UIEdgeInsetsInsetRect(self.frame, _sectionInset(0))
        let size = _bottomBarItems.reduce(CGSizeMake(-mis, -mls)) {
            let size = _sizeForItem($1)
            let width = $0.width + mis + size.width
            guard width < frame.width else {
                let nsize = CGSizeMake(-mls, $0.height + mHeight + mls)
                
                mWidth = max(mWidth, $0.width)
                mHeight = size.height
                
                return nsize
            }
            mWidth = max(mWidth, width)
            mHeight = max(mHeight, size.height)
            return CGSizeMake(width, $0.height)
        }
        
        let newSize = CGSizeMake(mWidth, size.height + mls + mHeight)
        _cacheBottomBarItemSize = newSize
        return newSize
    }
    
    @inline(__always) private func _updateBarItemLayouts() {
        Log.trace()
        
        _textViewTop.constant = _sectionInset(0).top + _topBarItemSize.height + _sectionInset(1).top
        _textViewLeft.constant = _sectionInset(1).left + _leftBarItemSize.width
        _textViewRight.constant = _sectionInset(1).right + _rightBarItemSize.width
        _textViewBottom.constant = _sectionInset(2).bottom + _bottomBarItemSize.height + _sectionInset(1).bottom
        
        invalidateIntrinsicContentSize()
        _textView.layoutIfNeeded()
    }
}

// MARK:

///
/// System Keyboard Event
///
extension SIMChatInputBar {
    
    // MARK: Notifiation
    
    ///
    /// Add system keyboard observation event
    ///
    @inline(__always) private func _addKeyboardNotification() {
        Log.trace()
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector:#selector(_keyboard(willChangeFrame:)), name:UIKeyboardWillChangeFrameNotification, object:nil)
    }
    ///
    /// Remove system keyboard observation event
    ///
    @inline(__always) private func _removeKeyboardNotification() {
        Log.trace()
        
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }
    ///
    /// update keyboard size, this will override the keyboard offset
    ///
    /// - parameter newSize:  new keyboard size, it must have a different
    /// - parameter duration: keyboard pop animation duration
    /// - parameter options:  keyboard pop animation options
    ///
    @inline(__always) private func _updateKeyboardSize(newSize: CGSize, duration: NSTimeInterval, options:UIViewAnimationOptions = .CurveLinear) {
        guard _inputAccessoryViewBottom.constant != newSize.height
            || _keyboardSize.height != newSize.height else {
            return // no change
        }
        Log.trace(newSize)
        
        // if keyboard size change, reset the inputBar size
        if _keyboardSize.height != newSize.height {
            invalidateIntrinsicContentSize()
        }
        
        _keyboardSize = newSize
        
        let handler = {
            self._inputAccessoryViewBottom.constant = self._keyboardSize.height
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        
        UIView.animateWithDuration(duration, delay:0, options:options, animations: handler, completion: nil)
    }
    ///
    /// update keyboard offset
    ///
    /// - parameter newPoint: new keyboard offset, it must
    /// - parameter animated: need animation?
    ///
    @inline(__always) private func _updateKeyboardOffset(newPoint: CGPoint, animated: Bool) {
        let ty = _keyboardSize.height - newPoint.y
        guard _inputAccessoryViewBottom.constant != ty else {
            return // no change
        }
        Log.trace(newPoint)
        
        _keyboardOffset = newPoint
        
        let handler = {
            self._inputAccessoryViewBottom.constant = ty
            self._inputAccessoryView.layoutIfNeeded()
            self.layoutIfNeeded()
        }
        if !animated {
            handler()
            return
        }
        UIView.animateWithDuration(0.25, animations: handler)
    }
    ///
    /// Calculation system keyboard visible size
    ///
    /// - parameter frame: keyboard notification frame
    /// - returns: keyboard visible size
    ///
    @inline(__always) private func _systemKeyboardVisibleSize(frame: CGRect) -> CGSize {
        let size = _inputAccessoryView.placeholderView.intrinsicContentSize()
        let height = (window?.frame.height ?? 0) - frame.minY - size.height
        return CGSizeMake(frame.width, height)
    }
    
    // MARK: Event Handler
    
    ///
    /// Keyboard scroll event
    ///
    @objc private func _keyboard(didScroll sender: UIPanGestureRecognizer) {
        guard sender.state == .Began || sender.state == .Changed else {
            // TODO: recgognizer is end, process custom event
            return
        }
        // You must use the first touch to calculate the position
        let y = sender.locationOfTouch(0, inView: self).y
        let ty = min(max(0, y), _keyboardSize.height)
        //
        _updateKeyboardOffset(CGPointMake(0, ty), animated: false)
    }
    
    ///
    /// Keyboard frame change event
    ///
    @objc private func _keyboard(willChangeFrame sender: NSNotification) {
        guard let u = sender.userInfo,
            //let beginFrame = (u[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(),
            let endFrame = (u[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(),
            let curve = (u[UIKeyboardAnimationCurveUserInfoKey] as? Int),
            let duration = (u[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval) else {
                return
        }
        let newSize = _systemKeyboardVisibleSize(endFrame)
        
        // TODO: if this operator from system keyboard to custom keyboard
        Log.trace()
        
        //
        _updateKeyboardSize(newSize, duration: duration, options: {
            switch UIViewAnimationCurve(rawValue:curve) ?? .EaseInOut {
                case .EaseInOut: return .CurveEaseInOut
                case .EaseIn:    return .CurveEaseIn
                case .EaseOut:   return .CurveEaseOut
                case .Linear:    return .CurveLinear
            }
        }())
    }
}

        //return NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: self._textView, attribute: .Top, multiplier: 1, constant: 0)

// MARK:

///
/// Accessory Bar Button Item Support
///
extension UIBarButtonItem {
    
    public var size: CGSize {
        // 读取图片大小
        return CGSizeMake(34, 34)
    }
    
    /// 对齐方式
    public var alignment: SIMChatInputAlignment {
        get {
            guard let rawValue = objc_getAssociatedObject(self, &_UIBarButtonItem_Alignment) as? Int else {
                return .Automatic
            }
            guard let oldValue = SIMChatInputAlignment(rawValue: rawValue) else {
                return .Automatic
            }
            return oldValue
        }
        set {
            objc_setAssociatedObject(self, &_UIBarButtonItem_Alignment, newValue.rawValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

///
/// InputBar dismissMode support
///
extension UIScrollView {
    /// method inject
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        if self !== UIScrollView.self {
            return
        }
        dispatch_once(&Static.token) {
            let cls = UIScrollView.self
            let selector = #selector(willMoveToSuperview(_:))
            
            let imp1 = cls.instanceMethodForSelector(selector)
            let imp2 = UIView.instanceMethodForSelector(selector)
            
            if imp1 == imp2 {
                // if there is no rewrite UIScrollView, use `sa_didMoveToSuperview`
                let m1 = class_getInstanceMethod(cls, selector)
                let m2 = class_getInstanceMethod(cls, #selector(sa_willMoveToSuperview(_:)))
                let imp = method_getImplementation(m2)
                let type = method_getTypeEncoding(m1)
                //
                class_addMethod(cls, selector, imp, type)
            } else {
                // if the UIScrollView rewrite didMoveToSuperview, use `saw_didMoveToSuperview`
                let m1 = class_getInstanceMethod(cls, selector)
                let m3 = class_getInstanceMethod(cls, #selector(saw_willMoveToSuperview(_:)))
                //
                method_exchangeImplementations(m1, m3)
            }
        }
    }
    /// overwrite method `willMoveToSuperview`
    @objc private func sa_willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        guard superview == nil else {
            return
        }
        // :)
        panGestureRecognizer.removeTarget(self, action: #selector(sa_handlePan(_:)))
        panGestureRecognizer.addTarget(self, action: #selector(sa_handlePan(_:)))
    }
    /// inject method `willMoveToSuperview`
    @objc private func saw_willMoveToSuperview(newSuperview: UIView?) {
        self.saw_willMoveToSuperview(newSuperview)
        guard superview == nil else {
            return
        }
        // :)
        panGestureRecognizer.removeTarget(self, action: #selector(sa_handlePan(_:)))
        panGestureRecognizer.addTarget(self, action: #selector(sa_handlePan(_:)))
    }
    /// gesture recognizer handler
    @objc private func sa_handlePan(sender: UIPanGestureRecognizer) {
        guard keyboardDismissMode == .Interactive else {
            return
        }
        // find inputBar
        guard let placeholderView = inputAccessoryView as? SIMChatInputPlaceholderView,
            let inputBar = placeholderView.inputBar else {
            return
        }
        inputBar._keyboard(didScroll: sender)
    }
}

///
/// InputBar display support
///
extension UIViewController {
    
//    /// 占位视图位置发生改变
//    public func inputAccessoryPlaceholderView(placeholderView: UIView, didScroll contentOffset: CGPoint) {
//        let y = contentOffset.y + placeholderView.frame.height;
//        Log.trace(y)
//    }
    
    public override var inputAccessoryView: UIView? {
        if let inputBar = self.inputBar2 {
            return inputBar._inputAccessoryView.placeholderView
        }
        return super.inputAccessoryView
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }

    /// inputBar
    public var inputBar2: SIMChatInputBar? {
        set {
            // no change
            if inputBar2 === newValue {
                return
            }
            
            // TODO: 这里需要确保inputBar一直在底部
            
//            if let inputBar = inputBar2 {
//                view.removeConstraints(inputBarConstraints)
//                
//                inputBar.removeFromSuperview()
//                inputBarConstraints.removeAll()
//            }
            
            objc_setAssociatedObject(self, &_inputBar, newValue, .OBJC_ASSOCIATION_RETAIN)
            
            if let inputBar = newValue {
                view.addSubview(inputBar)
                
                inputBar.translatesAutoresizingMaskIntoConstraints = false
                
                view.addConstraints([
                    NSLayoutConstraintMake(inputBar, .Left, .Equal, view, .Left),
                    NSLayoutConstraintMake(inputBar, .Right, .Equal, view, .Right),
                    NSLayoutConstraintMake(inputBar, .Bottom, .Equal, bottomLayoutGuide, .Bottom),
                ])
            }
        }
        get {
            return objc_getAssociatedObject(self, &_inputBar) as? SIMChatInputBar
        }
    }
    
    /// inputBar layout
    private var inputBarConstraints: [NSLayoutConstraint]? {
        set { return objc_setAssociatedObject(self, &_inputBarConstraints, newValue, .OBJC_ASSOCIATION_RETAIN) }
        get { return objc_getAssociatedObject(self, &_inputBarConstraints) as? [NSLayoutConstraint] }
    }
}

// MARK: - Helper

/// Cretae an `NSLayoutConstraint`
private func NSLayoutConstraintMake(item: AnyObject,
                                    _ attr1: NSLayoutAttribute,
                                    _ related: NSLayoutRelation,
                                    _ toItem: AnyObject? = nil,
                                    _ attr2: NSLayoutAttribute = .NotAnAttribute,
                                    _ constant: CGFloat = 0,
                                    _ multiplier: CGFloat = 1) -> NSLayoutConstraint {
    return NSLayoutConstraint(item:item, attribute:attr1, relatedBy:related, toItem:toItem, attribute:attr2, multiplier:multiplier, constant:constant)
}

// MARK: - Global private variable

private var _inputBar = "_inputBar"
private var _inputBarConstraints = "_inputBarConstraints"
private var _UIBarButtonItem_Alignment = "_UIBarItem_Alignment"