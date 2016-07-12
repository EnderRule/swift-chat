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

// TODO: add landscape support
// TODO: add `init(coder: aDecoder)` support
// TODO: check memory circ

/// 输入栏大小发生改变
public let SIMChatInputBarFrameDidChangeNotification = "SIMChatInputBarFrameDidChangeNotification"

@objc
@available(iOS 7.0, *)
public enum SIMChatInputBarPosition: Int {
    case Top        = 0
    case Left       = 1
    case Right      = 3
    case Bottom     = 4
    case Center     = 2
}

@objc
@available(iOS 7.0, *)
public enum SIMChatInputBarAlignment: Int {
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

@objc
@available(iOS 7.0, *)
public class SIMChatInputBarItem: NSObject {
    
    public override init() {
        super.init()
    }
    public convenience init(image: UIImage?, target: AnyObject?, action: Selector) {
        self.init()
        self.image = image
        self.target = target
        self.action = action
    }
    public convenience init(title: String?, target: AnyObject?, action: Selector) {
        self.init()
        self.title = title
        self.target = target
        self.action = action
    }
    
    public convenience init(customView: UIView) {
        self.init()
        self.customView = customView
    }
    
    public static var defaultCenterBarItem: SIMChatInputBarItem = {
        let item = SIMChatInputBarItem()
        item.setBackgroundImage(UIImage(named: "chat_bottom_textfield2"), forState: .Normal)
        return item
    }()

    // MARK: property
    
    public var size: CGSize = CGSizeZero // default is CGSizeZero
    public var image: UIImage? // default is nil
    public var customView: UIView? // default is nil
    
    
    public var tag: Int = 0 // default is 0
    public var title: String? // default is nil
    public var enabled: Bool = true // default is YES
    
    public var font: UIFont? // default is nil
    
    public var action: Selector = nil // default is nil
    weak public var target: AnyObject? // default is nil
    
    public var tintColor: UIColor?
    public var alignment: SIMChatInputBarAlignment = .Automatic
    public var imageInsets: UIEdgeInsets = UIEdgeInsetsZero // default is UIEdgeInsetsZero
    
    // MARK: setter
    
    public func setTitle(title: String?, forState state: UIControlState) {
        _titles[state.rawValue] = title
    }
    public func setTitleColor(color: UIColor?, forState state: UIControlState) {
        _titleColors[state.rawValue] = color
    }
    public func setTitleShadowColor(color: UIColor?, forState state: UIControlState) {
        _titleShadowColors[state.rawValue] = color
    }
    public func setAttributedTitle(title: NSAttributedString?, forState state: UIControlState) {
        _attributedTitles[state.rawValue] = title
    }
    
    public func setImage(image: UIImage?, forState state: UIControlState) {
        _images[state.rawValue] = image
    }
    public func setBackgroundImage(image: UIImage?, forState state: UIControlState) {
        _backgroundImages[state.rawValue] = image
    }
    
    // MARK: getter
    
    public func titleForState(state: UIControlState) -> String? {
        return _titles[state.rawValue] ?? nil
    }
    public func titleColorForState(state: UIControlState) -> UIColor? {
        return _titleColors[state.rawValue] ?? nil
    }
    public func titleShadowColorForState(state: UIControlState) -> UIColor? {
        return _titleShadowColors[state.rawValue] ?? nil
    }
    public func attributedTitleForState(state: UIControlState) -> NSAttributedString? {
        return _attributedTitles[state.rawValue] ?? nil
    }
    
    public func imageForState(state: UIControlState) -> UIImage? {
        return _images[state.rawValue] ?? nil
    }
    public func backgroundImageForState(state: UIControlState) -> UIImage? {
        return _backgroundImages[state.rawValue] ?? nil
    }
    
    // MARK: apply
    
    public func apply(toButton button: UIButton) {
        Log.trace()
        
        button.tag = tag
        button.tintColor = tintColor
        button.enabled = enabled
        button.imageEdgeInsets = imageInsets
        
        button.setTitle(title, forState: .Normal)
        button.setImage(image, forState: .Normal)
        
        _titles.forEach {
            button.setTitle($1, forState: UIControlState(rawValue: $0))
        }
        _titleColors.forEach {
            button.setTitleColor($1, forState: UIControlState(rawValue: $0))
        }
        _titleShadowColors.forEach {
            button.setTitleShadowColor($1, forState: UIControlState(rawValue: $0))
        }
        _attributedTitles.forEach {
            button.setAttributedTitle($1, forState: UIControlState(rawValue: $0))
        }
        _images.forEach {
            button.setImage($1, forState: UIControlState(rawValue: $0))
        }
        _backgroundImages.forEach {
            button.setBackgroundImage($1, forState: UIControlState(rawValue: $0))
        }
    }
    
    // MARK: ivar
    
    private var _titles: [UInt: String?] = [:]
    private var _titleColors: [UInt: UIColor?] = [:]
    private var _titleShadowColors: [UInt: UIColor?] = [:]
    private var _attributedTitles: [UInt: NSAttributedString?] = [:]
    
    private var _images: [UInt: UIImage?] = [:]
    private var _backgroundImages: [UInt: UIImage?] = [:]
}

// MARK:

///
/// char input bar delegate
///
@objc
@available(iOS 7.0, *)
public protocol SIMChatInputBarDelegate: NSObjectProtocol {
    
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
    
    optional func inputBar(inputBar: SIMChatInputBar, shouldHighlightItem item: SIMChatInputBarItem) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, didHighlightItem item: SIMChatInputBarItem)
    
    optional func inputBar(inputBar: SIMChatInputBar, shouldSelectItem item: SIMChatInputBarItem) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, didSelectItem item: SIMChatInputBarItem)

    optional func inputBar(inputBar: SIMChatInputBar, shouldDeselectItem item: SIMChatInputBarItem) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, didDeselectItem item: SIMChatInputBarItem)
    
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
@objc
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
    @inline(__always) private func _deinit() {
        
        // events
        _removeKeyboardNotification()
    }
    
    
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
    
    private weak var _delegate: SIMChatInputBarDelegate?
    
    /// 不使用系统的, 因为系统的isFristResponder更新速度太慢了
    private var _textViewIsFristResponder: Bool = false
    
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
        view.inputBar = self
        view.backgroundColor = nil
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
        //let mWidth = frame.width - _leftBarItemSize.width - _rightBarItemSize.width
        let centerBarItemSize = _sizeForItem(_centerBarItem)
//        let textSize = _textView.sizeThatFits(CGSize(width: _textView.frame.width, height: CGFloat.max))
//                let textSize = _textView.sizeThatFits(CGSize(width: _textView.bounds.width, height: CGFloat.max))
//                return CGSizeMake(_textView.bounds.width, textSize.height + 0.5)
        
        let height = _textViewTop.constant + centerBarItemSize.height + _textViewBottom.constant
        Log.trace("\(centerBarItemSize) => \(height)")
        
        let size = CGSize(width: frame.width, height: height)
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
            _updateBarItemLayouts(false)
        }
    }
    
    /// A `placeholderView` for system `inputAccessoryView`
    var placeholderView: SIMChatInputPlaceholderView {
        return _placeholderView
    }
    
    // set
    weak var inputBar: SIMChatInputBar? {
        willSet {
            placeholderView.inputBar = newValue
        }
    }
    
    /// 文本己经改变.
    func textViewDidChange(textView: UITextView) {
        _layoutIfNeeded(true)
    }
    
    
    @inline(__always) private func _init() {
        
        addSubview(_collectionView)
        addSubview(_backgroundView)
        addSubview(_textView)
        
        _textView.translatesAutoresizingMaskIntoConstraints = false
        
        _backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            NSLayoutConstraintMake(_backgroundView, .Top, .Equal, _textView, .Top),
            NSLayoutConstraintMake(_backgroundView, .Left, .Equal, _textView, .Left),
            NSLayoutConstraintMake(_backgroundView, .Right, .Equal, _textView, .Right),
            NSLayoutConstraintMake(_backgroundView, .Bottom, .Equal, _textView, .Bottom),
            
            _textViewTop,
            _textViewLeft,
            _textViewRight,
            _textViewBottom,
        ])
        
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
        
        Log.trace("\(newValue) => \(oldValue)")
        
        guard newValue.height != oldValue.height && newValue.height <= 120  else {
            return
        }
        
        _cacheContentSize = newValue
        invalidateIntrinsicContentSize()
        
        UIView.animateWithDuration(0.25) {
            self._textView.setNeedsLayout()
            self._collectionView.reloadItemsAtIndexPaths([self._centerIndexPath])
            // 强制更新
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
        // 重置offset, 因为offset在文字更新之前己经做了修改
        _textView.setContentOffset(CGPoint.zero, animated: animated)
    }
    
    //  Items
    
    private var _topBarItems: [SIMChatInputBarItem] = []
    private var _leftBarItems: [SIMChatInputBarItem] = []
    private var _rightBarItems: [SIMChatInputBarItem] = []
    private var _bottomBarItems: [SIMChatInputBarItem] = []
    
    private lazy var _centerBarItem: SIMChatInputBarItem = {
        let item = SIMChatInputBarTextView.BarItem(textView: self._textView)
        return item
    }()
    private var _centerIndexPath: NSIndexPath {
        return NSIndexPath(forItem: 0, inSection: 2)
    }
    
    private var _selectedBarItems: Set<SIMChatInputBarItem> = []
    
    //  Subview
    
    private lazy var _backgroundView: UIImageView = {
        let view = UIImageView()
        
//        view.backgroundColor = UIColor.clearColor()
//        view.layer.borderWidth = 0.5
//        view.layer.borderColor = UIColor.grayColor().CGColor
//        view.layer.cornerRadius = 4
//        view.layer.masksToBounds = true
        
        return view
    }()
    
    private lazy var _textView: UITextView = {
        let view = UITextView()
        
        view.font = UIFont.systemFontOfSize(15)
        view.scrollsToTop = false
        view.returnKeyType = .Send
        view.backgroundColor = UIColor.clearColor()
        //view.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        view.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0)
        //view.enablesReturnKeyAutomatically = true
        view.delegate = self
        
        return view
    }()
    
    private lazy var _collectionView: UICollectionView = {
        let layout = SIMChatInputBarLayout()
        let view = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        
        view.delegate = self
        view.dataSource = self
        //view.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.2)
        view.backgroundColor = UIColor.clearColor()
        view.bounces = false
        view.scrollsToTop = false
        view.scrollEnabled = false
        view.allowsSelection = false
        view.multipleTouchEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delaysContentTouches = false
        view.canCancelContentTouches = false
        
        view.registerClass(SIMChatInputBarItemView.self, forCellWithReuseIdentifier: "SIMChatInputItemButton")
        view.registerClass(SIMChatInputBarItemView.self, forCellWithReuseIdentifier: "SIMChatInputItemContainer")
        
        return view
    }()
    private lazy var _placeholderView: SIMChatInputPlaceholderView = {
        let view = SIMChatInputPlaceholderView(view: self)
        // This is required to make the view grow vertically
        view.autoresizingMask = .FlexibleHeight
        view.backgroundColor = UIColor.clearColor()
        //view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return view
    }()
    
    // Layout
   
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
    
    //  Cache
    
    private var _cacheContentSize: CGSize?
    private var _cacheIntrinsicContentSize: CGSize?
    
    private var _cacheTopBarItemSize: CGSize?
    private var _cacheLeftBarItemSize: CGSize?
    private var _cacheRightBarItemSize: CGSize?
    private var _cacheBottomBarItemSize: CGSize?
    
    private var _cacheCenterBarItem: SIMChatInputBarItem?
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
internal class SIMChatInputBarLayout: UICollectionViewLayout/*UICollectionViewFlowLayout*/ {
    class Line {
        var frame: CGRect
        var inset: UIEdgeInsets
        var section: Int
        var attributes: [Attributes]
        
        var centerCount: Int = 0
        var centerWidth: CGFloat = 0
        
        var cacheMaxWidth: CGFloat?
        var cacheMaxHeight: CGFloat?
        
        init(_ firstItem: Attributes, _ inset: UIEdgeInsets = UIEdgeInsetsZero) {
            self.frame = firstItem.frame
            self.section = firstItem.indexPath.section
            self.inset = inset
            self.attributes = [firstItem]
            
            if firstItem.alignemt.contains(.HCenter) {
                centerCount = 1
                centerWidth = firstItem.size.width
            }
        }
        func addItem(item: Attributes, _ spacing: CGFloat) {
            
            let x = min(frame.minX, item.frame.minX)
            let y = min(frame.minY, item.frame.minY)
            let width = frame.width + spacing + item.size.width
            let height = max(frame.height, item.size.height)
            
            frame = CGRectMake(x, y, width, height)
            attributes.append(item)
            
            if item.alignemt.contains(.HCenter) {
                centerCount += 1
                centerWidth += item.size.width
            }
        }
        func canAddItem(item: Attributes, _ width: CGFloat, _ spacing: CGFloat) -> Bool {
            let nWidth = frame.width + spacing + item.size.width
            return nWidth <= width - inset.left - inset.right
        }
        func move(toPoint point: CGPoint) {
            let dx = point.x - frame.minX
            let dy = point.y - frame.minY
            
            attributes.forEach {
                $0.frame = CGRectOffset($0.frame, dx, dy)
            }
            
            frame.origin = point
        }
        func layout(atPoint point: CGPoint, maxWidth: CGFloat, maxHeight: CGFloat, _ spacing: CGFloat) {
            // 如果布局没有改变直接移动就好了
            if cacheMaxWidth == maxWidth && cacheMaxHeight == maxHeight {
                move(toPoint: point)
                return
            }
            frame.origin = point
            
            var left: CGFloat = 0
            var right: CGFloat = 0
            
            var sp: CGFloat = -1
            var lsp: CGFloat = inset.left
            var rsp: CGFloat = inset.right
            
            // vertical alignment
            let alignY = { (item: Attributes) -> CGFloat in
                if item.alignemt.contains(.Top) {
                    // aligned to the top
                    return 0
                }
                if item.alignemt.contains(.VResize) {
                    // resize
                    return 0
                }
                if item.alignemt.contains(.Bottom) {
                    // aligned to the bottom
                    return maxHeight - item.size.height
                }
                // aligned to the center
                return (maxHeight - item.size.height) / 2
            }
            // 从右边开始计算一直到第一个非Right的元素
            _ = attributes.reverse().indexOf {
                if $0.alignemt.contains(.Right)  {
                    // aligned to the right
                    let nx = point.x + (maxWidth - right - rsp - $0.size.width)
                    let ny = point.y + (alignY($0))
                    
                    $0.frame = CGRectMake(nx, ny, $0.size.width, $0.size.height)
                    
                    right = $0.size.width + rsp + right
                    rsp = spacing
                
                    return false
                }
                return true
            }
            // 然后从左边开始计算到右边第一个非right
            _ = attributes.indexOf {
                if $0.alignemt.contains(.Right) {
                    return true
                }
                if $0.alignemt.contains(.Left) {
                    // aligned to the left
                    let nx = point.x + (left + lsp)
                    let ny = point.y + (alignY($0))
                    
                    $0.frame = CGRectMake(nx, ny, $0.size.width, $0.size.height)
                    
                    left = left + lsp + $0.size.width
                    lsp = spacing
                    
                } else if $0.alignemt.contains(.HResize) {
                    // resize
                    let nx = point.x + (left + lsp)
                    let ny = point.y + (alignY($0))
                    let nwidth = maxWidth - left - lsp - right - rsp
                    let nheight = max(maxHeight, $0.size.height)
                    
                    $0.frame = CGRectMake(nx, ny, nwidth, nheight)
                    
                    left = left + lsp + nwidth
                    lsp = spacing
                    
                } else {
                    // NOTE: center must be calculated finally
                    if sp < 0 {
                        sp = (maxWidth - right - left - centerWidth) / CGFloat(centerCount + 1)
                    }
                    // aligned to the center
                    let nx = point.x + (left + sp)
                    let ny = point.y + (alignY($0))
                    
                    $0.frame = CGRectMake(nx, ny, $0.size.width, $0.size.height)
                    
                    left = left + sp + $0.size.width
                }
                return false
            }
            
            // 缓存
            cacheMaxWidth = maxWidth
            cacheMaxHeight = maxHeight
        }
    }
    struct Alignment: OptionSetType {
        var rawValue: Int
        
        static var None = Alignment(rawValue: 0x0000)
        
        static var Top = Alignment(rawValue: 0x0100)
        static var Bottom = Alignment(rawValue: 0x0200)
        static var VCenter = Alignment(rawValue: 0x0400)
        static var VResize = Alignment(rawValue: 0x0800)
        
        static var Left = Alignment(rawValue: 0x0001)
        static var Right = Alignment(rawValue: 0x0002)
        static var HCenter = Alignment(rawValue: 0x0004)
        static var HResize = Alignment(rawValue: 0x0008)
    }
    class Attributes: UICollectionViewLayoutAttributes {
        var item: SIMChatInputBarItem?
        var alignemt: Alignment = .None
        
        var cacheSize: CGSize?
    }
    
    var _cacheLayoutAllLines: [SIMChatInputBarPosition: [Line]] = [:]
    var _cacheLayoutAllAttributes: [SIMChatInputBarPosition: [Attributes]] = [:]
    
    var _cacheLayoutedAttributes: [Attributes]?
    
    var _prevCacheLayoutAllAttributes: [SIMChatInputBarPosition: [Attributes]] = [:]
    
    var contentInsets: UIEdgeInsets = UIEdgeInsetsMake(8, 10, 8, 10)
    
    var minimumLineSpacing: CGFloat = 8
    var minimumInteritemSpacing: CGFloat = 8
    
    // center attrib cache
    
    override func collectionViewContentSize() -> CGSize {
        return collectionView?.frame.size ?? CGSizeZero
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        Log.trace()
        

    }
    
    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayoutWithContext(context)
        _invalidateLayoutCache(context.invalidateEverything)
    }
    
    /// rewrite
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return _layoutIfNeed(inRect: rect)
    }
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if let position = SIMChatInputBarPosition(rawValue: indexPath.section) {
            if let attributes = _cacheLayoutAllAttributes[position] where indexPath.item < attributes.count {
                return attributes[indexPath.item]
            }
//            // 查找上一次的
//            if let attributes = _prevCacheLayoutAllAttributes[position] where indexPath.item < attributes.count {
//                return attributes[indexPath.item]
//            }
        }
        Log.trace("not found \(indexPath.item) - \(indexPath.section)")
        return nil
    }
    
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if collectionView?.frame.width != newBounds.width {
            return true
        }
        return false
    }
    
    var rm: Set<NSIndexPath> = []
    var add: Set<NSIndexPath> = []
    
    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        super.prepareForCollectionViewUpdates(updateItems)
        //Log.trace(updateItems)
        updateItems.forEach {
            switch $0.updateAction {
            case .Insert:
                add.insert($0.indexPathAfterUpdate!)
            case .Delete:
                rm.insert($0.indexPathBeforeUpdate!)
            case .Reload:
                break
//                add.insert($0.indexPathAfterUpdate!)
//                rm.insert($0.indexPathBeforeUpdate!)
            default:
                break
            }
        }
        Log.trace()
    }
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        Log.trace()
        add = []
        rm = []
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = self.layoutAttributesForItemAtIndexPath(itemIndexPath)
//        if add.contains(itemIndexPath) {
//            attr?.alpha = 0
//            //attr?.frame.origin.y -= 14
//            Log.trace(itemIndexPath)
//            add.remove(itemIndexPath)
//        }
        //attr?.transform = CGAffineTransformMakeScale(0.2, 0.2)
        return attr
    }
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        // 这里要查找旧的, 并且要进行y轴修正
        let attr = self.layoutAttributesForItemAtIndexPath(itemIndexPath)
//        if rm.contains(itemIndexPath) {
//            attr?.alpha = 0
//            //attr?.frame.origin.y -= 15
//            Log.trace(itemIndexPath)
//            rm.remove(itemIndexPath)
//        }
        //attr?.alpha = 0
        return attr
    }
    
    
    // MARK: private
    
    private func _layoutIfNeed(inRect rect: CGRect) -> [Attributes] {
        if let attributes = _cacheLayoutedAttributes {
            return attributes
        }
        Log.trace(rect)
        
        
        let mis = minimumInteritemSpacing // 列间隔
        let mls = minimumLineSpacing // 行间隔
        
        var y = contentInsets.top
        var attributes = [Attributes]()
        
        [.Top, .Center, .Bottom].forEach {
            _lines(atPosition: $0, inRect: rect).forEach {
                $0.layout(atPoint: CGPointMake(0, y), maxWidth: rect.width, maxHeight: $0.frame.height, mis)
                y = y + mls + $0.frame.height
                attributes.appendContentsOf($0.attributes)
            }
        }
        return attributes
    }
    
    private func _linesWithAttributes(attributes: [Attributes], inRect rect: CGRect) -> [Line] {
        Log.trace(rect)
        return attributes.reduce([Line]()) {
            // update cache
            if $1.cacheSize == nil {
                $1.cacheSize = $1.item?.size
                $1.size = $1.cacheSize ?? CGSizeZero
            }
            // check the width, if you can't hold, then create a new line
            guard let line = $0.last where line.canAddItem($1, rect.width, 0) else {
                var lines = $0
                lines.append(Line($1, contentInsets))
                return lines
            }
            line.addItem($1, minimumInteritemSpacing)
            return $0
        }
    }
    private func _attributesWithBarItems(barItems: [SIMChatInputBarItem], atPosition position: SIMChatInputBarPosition) -> [Attributes] {
        Log.trace(position.rawValue)
        // 查找左对齐和右对齐的item
        let ax = barItems.enumerate().reduce((-1, barItems.count)) {
            if $1.element.alignment == .Left {
                return (max($0.0, $1.index), barItems.count)
            }
            if $1.element.alignment == .Right {
                return ($0.0, min($0.1, $1.index))
            }
            return $0
        }
        return barItems.enumerate().map {
            let idx = NSIndexPath(forItem: $0, inSection: position.rawValue)
            let attr = Attributes(forCellWithIndexPath: idx)
            
            attr.item = $1
            attr.size = $1.size
            attr.cacheSize = $1.size
            attr.alignemt = Alignment(rawValue: $1.alignment.rawValue)
            
            // 额外处理水平对齐
            if $0 <= ax.0 {
                // left
                attr.alignemt.unionInPlace(.Left)
            } else if $0 >= ax.1 {
                // right
                attr.alignemt.unionInPlace(.Right)
            } else {
                // center
                attr.alignemt.unionInPlace(.HCenter)
            }
            // 额外处理垂直对齐
            if attr.alignemt.rawValue & 0xFF00 == 0 {
                // bottom
                attr.alignemt.unionInPlace(.Bottom)
            }
            
            // 特殊处理
            if position == .Center {
                // 强制resize
                attr.alignemt = [.HResize, .VResize]
            } else if position == .Left {
                // 强制左对齐
                attr.alignemt.unionInPlace(.Left)
            } else if position == .Right {
                // 强制右对齐
                attr.alignemt.unionInPlace(.Right)
            }
            
            return attr
        }
    }
    private func _lines(atPosition position: SIMChatInputBarPosition, inRect rect: CGRect) -> [Line] {
        if let lines = _cacheLayoutAllLines[position] {
            return lines
        }
        let attributes = { () -> [Attributes] in
            if position == .Center {
                let a1 = _attributes(atPosition: .Left)
                let a2 = _attributes(atPosition: .Center)
                let a3 = _attributes(atPosition: .Right)
                return a1 + a2 + a3
            }
            return _attributes(atPosition: position)
        }()
        let lines = _linesWithAttributes(attributes, inRect: rect)
        _cacheLayoutAllLines[position] = lines
        return lines
    }
    private func _attributes(atPosition position: SIMChatInputBarPosition) -> [Attributes] {
        if let attributes = _cacheLayoutAllAttributes[position] {
            return attributes
        }
        let barItems = _barItems(atPosition: position)
        let attributes = _attributesWithBarItems(barItems, atPosition: position)
        _cacheLayoutAllAttributes[position] = attributes
        return attributes
    }
    private func _barItems(atPosition position: SIMChatInputBarPosition) -> [SIMChatInputBarItem] {
        // 如果不是这样的话... 直接报错(高耦合, 反正不重用)
        let ds = collectionView?.dataSource as! SIMChatInputAccessoryView
        return ds.barItemsForPosition(position)
    }
    
    private func _invalidateLayoutCache(force: Bool) {
        Log.trace("force: \(force)")
        
        _prevCacheLayoutAllAttributes = _cacheLayoutAllAttributes
        _cacheLayoutedAttributes = nil
        
        if force {
            _cacheLayoutedAttributes = nil
            _cacheLayoutAllLines.removeAll(keepCapacity: true)
            _cacheLayoutAllAttributes.removeAll(keepCapacity: true)
            
            return
        }
        // 计算出变更的点
        [SIMChatInputBarPosition.Top, .Left, .Center, .Right, .Bottom].forEach {
            guard let attributes = _cacheLayoutAllAttributes[$0] else {
                return
            }
            var itemIsChanged = false
            var sizeIsChanged = false
            var boundsIsChanged = false
            
            let barItems = _barItems(atPosition: $0)
            
            // 数量不同. 重置
            if attributes.count != barItems.count {
                itemIsChanged = true
            } else {
                for index in 0 ..< attributes.count {
                    let attr = attributes[index]
                    let item = barItems[index]
                    
                    if attr.item != item {
                        itemIsChanged = true
                    }
                    if attr.cacheSize != item.size {
                        sizeIsChanged = true
                        attr.cacheSize = nil
                    }
                }
            }
            if let lines = _cacheLayoutAllLines[$0] {
                lines.forEach {
                    if $0.cacheMaxWidth != collectionView?.frame.width {
                        boundsIsChanged = true
                    }
                }
            }
            
            if itemIsChanged {
                Log.debug("item is change")
                _invalidateLayoutAllCache(atPosition: $0)
            } else if sizeIsChanged {
                Log.debug("size is change")
                _invalidateLayoutLineCache(atPosition: $0)
            } else if boundsIsChanged {
                Log.debug("bounds is change")
                _invalidateLayoutLineCache(atPosition: $0)
            } else {
                // no changed
            }
        }
    }

    private func _invalidateLayoutLineCache(atPosition position: SIMChatInputBarPosition) {
        Log.trace(position.rawValue)
        _cacheLayoutAllLines.removeValueForKey(position)
    }
    private func _invalidateLayoutAllCache(atPosition position: SIMChatInputBarPosition) {
        Log.trace(position.rawValue)
        _cacheLayoutAllLines.removeValueForKey(position)
        _cacheLayoutAllAttributes.removeValueForKey(position)
    }
}

/// inputbar bar item container view
internal class SIMChatInputBarItemView: UICollectionViewCell {
    
    var item: SIMChatInputBarItem? {
        willSet {
            UIView.performWithoutAnimation {
                self._updateItem(newValue)
            }
        }
    }
    
    func setSelected(selected: Bool, animated: Bool) {
        _button.setSelected(selected, animated: animated)
        //_button.selected = selected
//        if !animated {
//            _button.layer.removeAllAnimations()
//        }
    }
    
    weak var delegate: SIMChatInputBarItemButtonDelegate? {
        set { return _button.delegate = newValue }
        get { return _button.delegate }
    }
    
    @inline(__always) func _init() {
        clipsToBounds = true
        backgroundColor = UIColor.clearColor()
        //backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2)
    }
    @inline(__always) func _updateItem(newValue: SIMChatInputBarItem?) {
        guard let newValue = newValue else {
            // clear on nil
            _contentView?.removeFromSuperview()
            _contentView = nil
            return
        }
        guard item !== newValue else {
            return // no change
        }
        
        if let customView = newValue.customView {
            // 需要显示自定义视图
            _contentView?.removeFromSuperview()
            _contentView = customView
        } else {
            // 显示普通按钮
            if _contentView !== _button {
                _contentView?.removeFromSuperview()
                _contentView = _button
            }
            // 更新按钮属性
            _button.barItem = newValue
        }
        // 更新视图
        if let view = _contentView where view.superview != contentView {
            view.frame = contentView.bounds
            view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            contentView.addSubview(view)
        }
    }
    
    private var _contentView: UIView?
    private lazy var _button: SIMChatInputBarItemButton = {
        //let view = SIMChatInputBarItemButton(type: .Custom)
        let view = SIMChatInputBarItemButton(type: .System)
        view.multipleTouchEnabled = false
        view.exclusiveTouch = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

internal protocol SIMChatInputBarItemButtonDelegate: class {
    
    func barItemButton(shouldHighlight barItemButton: SIMChatInputBarItemButton) -> Bool
    func barItemButton(didHighlight barItemButton: SIMChatInputBarItemButton)
    func barItemButton(shouldSelect barItemButton: SIMChatInputBarItemButton) -> Bool
    func barItemButton(didSelect barItemButton: SIMChatInputBarItemButton)
    func barItemButton(shouldDeselect barItemButton: SIMChatInputBarItemButton) -> Bool
    func barItemButton(didDeselect barItemButton: SIMChatInputBarItemButton)
    
}

internal class SIMChatInputBarItemButton: UIButton {
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if delegate?.barItemButton(shouldHighlight: self) ?? true {
            delegate?.barItemButton(didHighlight: self)
            _allowsHighlight = true
        } else {
            _allowsHighlight = false
        }
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    override var highlighted: Bool {
        set {
            guard _allowsHighlight else {
                return
            }
            super.highlighted = newValue
            _setHighlighted(newValue, animated: true)
        }
        get { return super.highlighted }
    }
    
    override var state: UIControlState {
        // 永远禁止系统的选中
        return super.state.subtract(.Selected)
    }
    
    weak var delegate: SIMChatInputBarItemButtonDelegate?
    
    var barItem: SIMChatInputBarItem? {
        willSet {
            guard barItem !== newValue else {
                return
            }
            UIView.performWithoutAnimation { 
                newValue?.apply(toButton: self)
            }
        }
    }
    
    @inline(__always) private func _init() {
        addTarget(self, action: #selector(_touchHandler), forControlEvents: .TouchUpInside)
    }
    
    @inline(__always) private func _addAnimation(key: String) {
        let ani = CATransition()
        
        ani.duration = 0.35
        ani.fillMode = kCAFillModeBackwards
        ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        ani.type = kCATransitionFade
        ani.subtype = kCATransitionFromTop
        
        layer.addAnimation(ani, forKey: key)
    }
    
    func setSelected(selected: Bool, animated: Bool) {
        //Log.trace(selected)
        let op1: UIControlState = [(selected ? .Selected : .Normal), .Normal]
        let op2: UIControlState = [(selected ? .Selected : .Normal), .Highlighted]
        
        let n = barItem?.imageForState(op1) ?? barItem?.imageForState(.Normal)
        let h = barItem?.imageForState(op2)
        
        setImage(n, forState: .Normal)
        setImage(h, forState: .Highlighted)
        
        if animated {
            _addAnimation("selected")
        }
    }
    
    @inline(__always) private func _setHighlighted(highlighted: Bool, animated: Bool) {
        //Log.trace(highlighted)
        // 检查高亮的时候有没有设置图片, 如果有关闭系统的变透明效果
        if barItem?.imageForState([(selected ? .Selected : .Normal), .Highlighted]) != nil {
            imageView?.alpha = 1
        }
        if animated {
            _addAnimation("highlighted")
        }
    }
    
    @objc private func _touchHandler() {
        if let target = barItem?.target, action = barItem?.action {
            sendAction(action, to: target, forEvent: nil)
        }
        if !selected {
            guard delegate?.barItemButton(shouldSelect: self) ?? true else {
                return
            }
            setSelected(true, animated: true)
            delegate?.barItemButton(didSelect: self)
        } else {
            guard delegate?.barItemButton(shouldDeselect: self) ?? true else {
                return
            }
            setSelected(false, animated: true)
            delegate?.barItemButton(didDeselect: self)
        }
    }
    
    private var _allowsHighlight = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

///
/// 自定义的输入框
///
internal class SIMChatInputBarTextView: UITextView {
    
    class BarItem: SIMChatInputBarItem {
        init(textView: UITextView) {
            _textView = textView
            super.init()
            
            _textView.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
        }
        deinit {
            _textView.removeObserver(self, forKeyPath: "contentSize")
        }
        
        override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            let newValue = _textView.contentSize
            let oldValue = _cacheContentSize ?? CGSizeZero
            
            guard newValue.height != oldValue.height && newValue.height <= 120 else {
                return
            }
            
            _cacheContentSize = newValue
            _cacheSize = nil
        }
        
        override var size: CGSize {
            set { }
            get {
                if let size = _cacheSize {
                    return size
                }
                let textSize = _textView.sizeThatFits(CGSize(width: _textView.bounds.width, height: CGFloat.max))
                let size = CGSizeMake(_textView.bounds.width, min(textSize.height + 0.5, 120))
                _cacheContentSize = size
                return size
            }
        }
        
        var _textView: UITextView
        
        var _cacheSize: CGSize?
        var _cacheContentSize: CGSize?
    }
    
    
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

// MARK:

extension SIMChatInputBar {
    
    // MARK: barItem
    
    public func setCenterBarItem(editItem: SIMChatInputBarItem) {
        return _inputAccessoryView.setCenterBarItem(editItem)
    }
    
    public func setBarItems(barItems: [SIMChatInputBarItem], atPosition position: SIMChatInputBarPosition, animated: Bool) {
        return _inputAccessoryView.setBarItems(barItems, atPosition: position, animated: animated)
    }
    public func barItemsForPosition(position: SIMChatInputBarPosition) -> [SIMChatInputBarItem] {
        return _inputAccessoryView.barItemsForPosition(position)
    }
    
    public func canSelectBarItem(barItem: SIMChatInputBarItem) -> Bool {
        return _inputAccessoryView.canSelectBarItem(barItem)
    }
    public func canDeselectBarItem(barItem: SIMChatInputBarItem) -> Bool {
        return _inputAccessoryView.canDeselectBarItem(barItem)
    }
    
    public func selectBarItem(barItem: SIMChatInputBarItem, animated: Bool) {
        return _inputAccessoryView.selectBarItem(barItem, animated: animated)
    }
    public func deselectBarItem(barItem: SIMChatInputBarItem, animated: Bool) {
        return _inputAccessoryView.deselectBarItem(barItem, animated: animated)
    }
}

extension SIMChatInputAccessoryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SIMChatInputBarItemButtonDelegate {
    
    func selectBarItem(barItem: SIMChatInputBarItem, animated: Bool) {
        
        _selectedBarItems.insert(barItem)
        _collectionView.visibleCells().forEach {
            guard let cell = $0 as? SIMChatInputBarItemView where cell.item === barItem else {
                return
            }
            cell.setSelected(true, animated: animated)
        }
    }
    func deselectBarItem(barItem: SIMChatInputBarItem, animated: Bool) {
        
        _selectedBarItems.remove(barItem)
        _collectionView.visibleCells().forEach {
            guard let cell = $0 as? SIMChatInputBarItemView where cell.item === barItem else {
                return
            }
            cell.setSelected(false, animated: animated)
        }
    }
    func canSelectBarItem(barItem: SIMChatInputBarItem) -> Bool {
        return !_selectedBarItems.contains(barItem)
    }
    func canDeselectBarItem(barItem: SIMChatInputBarItem) -> Bool {
        return _selectedBarItems.contains(barItem)
    }
    
    func setCenterBarItem(editItem: SIMChatInputBarItem) {
        _centerBarItem = editItem
        _cacheCenterBarItem = nil
        
        
        if _isInitBarItemLayouts {
            _updateBarItemLayouts(true)
            
            self._textView.hidden = true
//            if editItem === SIMChatInputBarItem.defaultCenterBarItem {
//                self._textView.alpha = 0
//                self._textView.hidden = false
//                self._backgroundView.hidden = false
//                self._backgroundView.alpha = 0
//                
//                UIView.animateWithDuration(0.25, animations: {
//                    self._textView.alpha = 1
//                    self._backgroundView.alpha = 1
//                }, completion: { (f) in
//                })
//                //self._textView.becomeFirstResponder()
//            } else {
//                //self._textView.resignFirstResponder()
//                
//                UIView.animateWithDuration(0.25, animations: {
//                    self._textView.alpha = 0
//                    self._backgroundView.alpha = 0
//                }, completion: { (f) in
//                    self._textView.alpha = 1
//                    self._textView.hidden = true
//                    self._backgroundView.alpha = 1
//                    self._backgroundView.hidden = true
//                })
//            }
        }
    }
    
    func setBarItems(barItems: [SIMChatInputBarItem], atPosition position: SIMChatInputBarPosition, animated: Bool) {
        Log.trace()
        
        // TODO: 清除没有显示的item
        
        // 计算出, insert/delete/reload的数量
        
        switch position {
        case .Top:
            _topBarItems = barItems
            _cacheTopBarItemSize = nil
        case .Left:
            _leftBarItems = barItems
            _cacheLeftBarItemSize = nil
        case .Right:
            _rightBarItems = barItems
            _cacheRightBarItemSize = nil
        case .Bottom:
            _bottomBarItems = barItems
            _cacheBottomBarItemSize = nil
        case .Center:
            break
        }
        if _isInitBarItemLayouts {
            _updateBarItemLayouts(animated)
        }
    }
    
    func barItemsForPosition(position: SIMChatInputBarPosition) -> [SIMChatInputBarItem] {
        switch position {
        case .Top: return _topBarItems
        case .Left: return _leftBarItems
        case .Center: return [_centerBarItem]
        case .Right: return _rightBarItems
        case .Bottom: return _bottomBarItems
        }
    }
    
    // MARK: SIMChatInputBarItemButtonDelegate
    
    func barItemButton(shouldHighlight barItemButton: SIMChatInputBarItemButton) -> Bool {
        guard let ib = inputBar, barItem = barItemButton.barItem else {
            return false
        }
        return ib.delegate?.inputBar?(ib, shouldHighlightItem: barItem) ?? true
    }
    func barItemButton(didHighlight barItemButton: SIMChatInputBarItemButton) {
        guard let ib = inputBar, barItem = barItemButton.barItem else {
            return
        }
        ib.delegate?.inputBar?(ib, didHighlightItem: barItem)
    }
    func barItemButton(shouldSelect barItemButton: SIMChatInputBarItemButton) -> Bool {
        guard let ib = inputBar, barItem = barItemButton.barItem else {
            return false
        }
        return ib.delegate?.inputBar?(ib, shouldSelectItem: barItem) ?? true
    }
    func barItemButton(didSelect barItemButton: SIMChatInputBarItemButton) {
        guard let ib = inputBar, barItem = barItemButton.barItem else {
            return
        }
        _selectedBarItems.insert(barItem)
        ib.delegate?.inputBar?(ib, didSelectItem: barItem)
    }
    func barItemButton(shouldDeselect barItemButton: SIMChatInputBarItemButton) -> Bool {
        guard let ib = inputBar, barItem = barItemButton.barItem else {
            return false
        }
        return ib.delegate?.inputBar?(ib, shouldDeselectItem: barItem) ?? true
    }
    func barItemButton(didDeselect barItemButton: SIMChatInputBarItemButton) {
        guard let ib = inputBar, barItem = barItemButton.barItem else {
            return
        }
        _selectedBarItems.remove(barItem)
        ib.delegate?.inputBar?(ib, didDeselectItem: barItem)
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 5
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:  return _topBarItems.count
        case 1:  return _leftBarItems.count
        case 2:  return 1 // center
        case 3:  return _rightBarItems.count
        case 4:  return _bottomBarItems.count
        default: fatalError()
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if _centerIndexPath == indexPath {
            //if let cell = _cacheBarItemContainer {
            //    return cell
            //}
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SIMChatInputItemContainer", forIndexPath: indexPath)
            //_cacheBarItemContainer = cell
            return cell
        }
        return collectionView.dequeueReusableCellWithReuseIdentifier("SIMChatInputItemButton", forIndexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? SIMChatInputBarItemView else {
            return
        }
        let item = _barItem(at: indexPath)
        cell.delegate = self
        cell.item = item
        cell.setSelected(_selectedBarItems.contains(item), animated: false)
        
//        if item === _centerBarItem && item == SIMChatInputBarItem.defaultCenterBarItem {
//            cell.hidden = true
//        } else {
//            cell.hidden = false
//        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return _sectionInset(section)
//    }
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return _sizeForItem(_barItem(at: indexPath))
//    }
    
    // MARK: config data
    
    @inline(__always) private func _barItem(at indexPath: NSIndexPath) -> SIMChatInputBarItem {
        switch indexPath.section {
        case 0:
            if indexPath.item < _topBarItems.count {
                return _topBarItems[indexPath.item]
            }
        case 1:
            if indexPath.item < _leftBarItems.count {
                return _leftBarItems[indexPath.item]
            }
        case 2:
            return _centerBarItem
        case 3:
            if indexPath.item < _rightBarItems.count {
                return _rightBarItems[indexPath.item]
            }
        case 4:
            if indexPath.item < _bottomBarItems.count {
                return _bottomBarItems[indexPath.row]
            }
        default:
            break
        }
        fatalError("barItem not found at \(indexPath)")
    }
    @inline(__always) private func _barItemAlginment(at indexPath: NSIndexPath) -> SIMChatInputBarAlignment {
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
    
    @inline(__always) private func _sizeForItem(item: SIMChatInputBarItem) -> CGSize {
        if item === _centerBarItem {
            let mHeight = max(_leftBarItemSize.height, _rightBarItemSize.height)
//            if item === SIMChatInputBarItem.defaultCenterBarItem {
//                // width = left - right
//                // height = sizeThatFits
//                // - _ -
//                let textSize = _textView.sizeThatFits(CGSize(width: _textView.bounds.width, height: CGFloat.max))
//                return CGSizeMake(_textView.bounds.width, max(textSize.height + 0.5, mHeight))
//            } else {
                return CGSizeMake(_textView.bounds.width, max(item.size.height, mHeight))
//            }
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
    
    @inline(__always) func _reloadBarItemsAtIndexPaths(indexPaths: [NSIndexPath], animated: Bool) {
        class OState {
            var view: UIView
            var frame: CGRect
            //var alpha: CGFloat
            //var hidden: Bool
            init(view: UIView) {
                self.view = view
                self.frame = view.frame
                //self.alpha = view.alpha
                //self.hidden = view.hidden
            }
        }
        
        Log.trace()
        
        // frame, hidden
        
//        let oldCellFrames: [NSIndexPath: OState] = indexPaths.reduce([:]) {
//            guard let cell = self._collectionView.cellForItemAtIndexPath($1) else {
//                return $0
//            }
//            var rx = $0
//            Log.trace("old frame: \(cell.frame), at indexPath: \($1)")
//            rx[$1] = OState(view: cell)
//            return rx
//        }
        
        // 真正的更新操作.
        self._collectionView.performBatchUpdates({
            if self._leftBarItems.count == 2 {
                self._collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 1)])
                self._collectionView.reloadItemsAtIndexPaths([
                    NSIndexPath(forItem: 0, inSection: 1)])
//                    NSIndexPath(forItem: 1, inSection: 1),
//                    ])
            } else {
                self._collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 1)])
                self._collectionView.reloadItemsAtIndexPaths([
                    NSIndexPath(forItem: 0, inSection: 1)])
//                    NSIndexPath(forItem: 2, inSection: 1),
//                    ])
            }
            
        }, completion: { f in })
        
        //self._collectionView.reloadItemsAtIndexPaths(indexPaths)
        
//        let newCellFrames: [NSIndexPath: OState] = indexPaths.reduce([:]) {
//            guard let cell = self._collectionView.cellForItemAtIndexPath($1) else {
//                return $0
//            }
//            var rx = $0
//            Log.trace("new frame: \(cell.frame), at indexPath: \($1)")
//            rx[$1] = OState(view: cell)
//            return rx
//        }
//
//        // 更新完成之后进行动画恢复
//        
//        // 更新为旧frame, 禁止动画的
//        UIView.performWithoutAnimation {
//            oldCellFrames.forEach {
//                // 读取旧的状态
//                // 把新的cell移到旧的cell的位置
//                if let n = newCellFrames[$0] {
//                    n.view.frame = $1.frame
//                    n.view.layoutIfNeeded()
//                    n.view.layer.removeAllAnimations()
//                }
//                // 清除所有动画(no need)
//                //$1.view.layer.removeAllAnimations()
//            }
//        }
//        // 更新为新的frame
//        newCellFrames.forEach {
//            if let o = oldCellFrames[$0] {
//                o.view.frame = $1.frame
//                o.view.layoutIfNeeded()
//            }
//            $1.view.frame = $1.frame
//            $1.view.layoutIfNeeded()
//        }
        
    }
    
    @inline(__always) private func _updateBarItemLayouts(animated: Bool) {
        Log.trace()
        
        _textViewTop.constant = _sectionInset(0).top + _topBarItemSize.height + _sectionInset(1).top
        _textViewLeft.constant = _sectionInset(1).left + _leftBarItemSize.width
        _textViewRight.constant = _sectionInset(1).right + _rightBarItemSize.width
        _textViewBottom.constant = _sectionInset(2).bottom + _bottomBarItemSize.height + _sectionInset(1).bottom
        
        // 清除textview的缓存
        _cacheContentSize = nil
        
        // ..
        _backgroundView.image = SIMChatInputBarItem.defaultCenterBarItem.backgroundImageForState(.Normal)
        
        if animated {
            
            let cell = _collectionView.cellForItemAtIndexPath(_centerIndexPath)
            let size = _sizeForItem(_centerBarItem)
            
            Log.trace("\(cell?.bounds) => \(_textView.bounds) => \(size)")
            
            // 记录所有cell的位置
            
            //print(self._collectionView.visibleCells().first?.layer.animationForKey("position"))
            
            let idxs = [
                NSIndexPath(forItem:0, inSection:1),
                self._centerIndexPath
            ]
            
            UIView.animateWithDuration(0.25) {
                self._textView.layoutIfNeeded()
                self.invalidateIntrinsicContentSize()

                self._reloadBarItemsAtIndexPaths(idxs, animated: false)
                
                // 强制更新
                self.superview?.setNeedsLayout()
                self.superview?.layoutIfNeeded()
            }
        
        } else {
            self._textView.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
            //self._collectionView.layoutIfNeeded()
//            self._collectionView.reloadItemsAtIndexPaths([self._centerIndexPath])
//            // 强制更新
//            self.superview?.setNeedsLayout()
//            self.superview?.layoutIfNeeded()
        }
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
        let height = max((window?.frame.height ?? 0) - frame.minY - size.height, 0)
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
        guard sender.numberOfTouches() != 0 else {
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
        Log.trace(endFrame)
        
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
