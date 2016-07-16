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

// TODO: add `init(coder: aDecoder)` support


// MARK:

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

@available(iOS 7.0, *)
public enum SIMChatInputBarState {
    case None
    case Editing(keyboard: UIView?)  // 编辑中
    case Selecting(keyboard: UIView)   // 选择中
}

@objc
@available(iOS 7.0, *)
public class SIMChatInputBarItem: NSObject {
    
    // MARK: property
    
    public var size: CGSize = CGSizeZero // default is CGSizeZero
    public var image: UIImage? // default is nil
    public var customView: UIView? // default is nil
    
    public var tag: Int = 0 // default is 0
    public var title: String? // default is nil
    public var enabled: Bool = true // default is YES
    
    public var font: UIFont? // default is nil
    
    public var handler: (SIMChatInputBarItem -> Void)? // default is nil
    
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
    
    // MARK: create
    
    public override init() {
        super.init()
    }
    public convenience init(image: UIImage?, handler: (SIMChatInputBarItem -> Void)? = nil) {
        self.init()
        self.image = image
        self.handler = handler
    }
    public convenience init(title: String?, handler: (SIMChatInputBarItem -> Void)? = nil) {
        self.init()
        self.title = title
        self.handler = handler
    }
    
    public convenience init(customView: UIView) {
        self.init()
        self.customView = customView
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

@objc
@available(iOS 7.0, *)
public protocol SIMChatInputBarDelegate: NSObjectProtocol {
    
    // MARK: Text Edit
    
    optional func inputBar(shouldBeginEditing inputBar: SIMChatInputBar) -> Bool
    optional func inputBar(shouldEndEditing inputBar: SIMChatInputBar) -> Bool
    
    optional func inputBar(didBeginEditing inputBar: SIMChatInputBar)
    optional func inputBar(didEndEditing inputBar: SIMChatInputBar)
    
    optional func inputBar(shouldReturn inputBar: SIMChatInputBar) -> Bool
    optional func inputBar(shouldClear inputBar: SIMChatInputBar) -> Bool
    
    optional func inputBar(didChangeSelection inputBar: SIMChatInputBar)
    optional func inputBar(didChange inputBar: SIMChatInputBar)
    
    optional func inputBar(inputBar: SIMChatInputBar, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool
    
    // MARK: Accessory Item Selection
    
    optional func inputBar(inputBar: SIMChatInputBar, shouldHighlightItem item: SIMChatInputBarItem) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, shouldDeselectItem item: SIMChatInputBarItem) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, shouldSelectItem item: SIMChatInputBarItem) -> Bool
    
    optional func inputBar(inputBar: SIMChatInputBar, didHighlightItem item: SIMChatInputBarItem)
    optional func inputBar(inputBar: SIMChatInputBar, didDeselectItem item: SIMChatInputBarItem)
    optional func inputBar(inputBar: SIMChatInputBar, didSelectItem item: SIMChatInputBarItem)
}

// MARK:

@objc
@available(iOS 7.0, *)
public class SIMChatInputBar: UIView {
    
    
    public override func resignFirstResponder() -> Bool {
        _logger.trace()
        return _inputAccessoryView.resignFirstResponder()
    }
    public override func becomeFirstResponder() -> Bool {
        _logger.trace()
        return _inputAccessoryView.becomeFirstResponder()
    }
    
    public override func intrinsicContentSize() -> CGSize {
        let h1 = _inputAccessoryView.intrinsicContentSize().height
        let h2 = _keyboardSize.height
        return CGSizeMake(frame.width, h1 + h2)
    }
    
    /// extension init
    @inline(__always) private func _init() {
        _logger.trace()

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
            
            NSLayoutConstraintMake(_inputView, .Top, .Equal, _inputAccessoryView, .Bottom),
            NSLayoutConstraintMake(_inputView, .Left, .Equal, self, .Left),
            NSLayoutConstraintMake(_inputView, .Right, .Equal, self, .Right),
            
            _inputViewBottom,
            _inputAccessoryViewBottom
        ])
        
        _addKeyboardNotification()
    }
    /// extension deinit
    @inline(__always) private func _deinit() {
        _logger.trace()
        
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
    
    // TODO: no imp
//    /// 内容
//    public var text: String? {
//        set { return textView.text = newValue }
//        get { return textView.text }
//    }
//    /// 内容
//    public var attributedText: NSAttributedString? {
//        set { return textView.attributedText = newValue }
//        get { return textView.attributedText }
//    }

    
    /// 代理
    public weak var delegate: SIMChatInputBarDelegate?
    
    public var editItem: SIMChatInputBarItem {
        return _inputAccessoryView.editItem
    }
    
    
    private var _inputState: SIMChatInputBarState = .None
    
    /// keyboard event support
    private var _keyboardSize: CGSize = CGSizeZero
    private var _keyboardOffset: CGPoint = CGPointZero
    
    private var _cacheBounds: CGRect?
    
    // MARK: View
    
    private lazy var _inputView: SIMChatInputView = {
        let view = SIMChatInputView(frame: CGRect.zero)
        view.backgroundColor = nil
        //view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    private lazy var _inputAccessoryView: SIMChatInputAccessoryView = {
        let view = SIMChatInputAccessoryView(frame: CGRect.zero)
        view.inputBar = self
        view.delegate = self
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
    
    private lazy var _inputViewBottom: NSLayoutConstraint = {
        return NSLayoutConstraintMake(self, .Bottom, .Equal, self._inputView, .Bottom)
    }()
    private lazy var _inputAccessoryViewBottom: NSLayoutConstraint = {
        return NSLayoutConstraintMake(self, .Bottom, .Equal, self._inputAccessoryView, .Bottom)
    }()
    
    // MARK: Init
    
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

// MARK: - Base

/// 输入视图
internal class SIMChatInputView: UIView {
    
    override func intrinsicContentSize() -> CGSize {
        switch _state {
        case .None:
            return CGSizeZero
            
        case .Editing(let keyboard):
            return keyboard?.intrinsicContentSize() ?? CGSizeZero
            
        case .Selecting(let keyboard):
            return keyboard.intrinsicContentSize()
        }
    }
    
    @inline(__always) private func _init() {
        _logger.trace()
    }
    @inline(__always) private func _deinit() {
        _logger.trace()
    }
    
    var _state: SIMChatInputBarState = .None
    var _keyboard: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    deinit {
        _deinit()
    }
}
/// 输入状态栏
internal class SIMChatInputAccessoryView: UIView {
    
    override func becomeFirstResponder() -> Bool {
        logger.trace()
        return _textView.becomeFirstResponder()
    }
    override func resignFirstResponder() -> Bool {
        logger.trace()
        return _textView.resignFirstResponder()
    }
   
    override func intrinsicContentSize() -> CGSize {
        if let size = _cacheIntrinsicContentSize {
            return size
        }
        // Calculate intrinsicContentSize that will fit all the text
        //let mWidth = frame.width - _leftBarItemSize.width - _rightBarItemSize.width
        let centerBarItemSize = _centerBarItem.size
        let height = _textViewTop.constant + centerBarItemSize.height + _textViewBottom.constant
        let size = CGSize(width: frame.width, height: height)
        
        _logger.debug("\(centerBarItemSize) => \(height)")
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
    
    /// A `placeholderView` for system `inputAccessoryView`
    var placeholderView: SIMChatInputPlaceholderView {
        return _placeholderView
    }
    
    var textView: UITextView {
        return _textView
    }
    var backgroundView: UIView {
        return _backgroundView
    }
    
    lazy var editItem: SIMChatInputBarEditItem = {
        let item = SIMChatInputBarEditItem(textView: self._textView)
        return item
    }()
    
    weak var delegate: protocol<UITextViewDelegate, SIMChatInputBarItemDelegate>?
    
    weak var inputBar: SIMChatInputBar? {
        willSet {
            placeholderView.inputBar = newValue
        }
    }
    
    @inline(__always) private func _init() {
        _logger.trace()
        
        // 配置一些基本信息
        _textView.translatesAutoresizingMaskIntoConstraints = false
        _backgroundView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.setContentHuggingPriority(700, forAxis: .Horizontal)
        _collectionView.setContentHuggingPriority(700, forAxis: .Vertical)
        _collectionView.setContentCompressionResistancePriority(200, forAxis: .Horizontal)
        _collectionView.setContentCompressionResistancePriority(200, forAxis: .Vertical)
        
        // 添加初视图
        addSubview(_backgroundView)
        addSubview(_collectionView)
        addSubview(_textView)
        
        // 添加约束
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
        
        _updateBackgroundView()
        _initForCollectionView()
    }
    @inline(__always) private func _deinit() {
        _logger.trace()
    }
    
    //  MARK: Items
    
    private var _topBarItems: [SIMChatInputBarItem] = []
    private var _leftBarItems: [SIMChatInputBarItem] = []
    private var _rightBarItems: [SIMChatInputBarItem] = []
    private var _bottomBarItems: [SIMChatInputBarItem] = []
    
    private lazy var _centerBarItem: SIMChatInputBarItem  = {
        return self.editItem
    }()
    
    
    private var _centerIndexPath: NSIndexPath {
        return NSIndexPath(forItem: 0, inSection: 2)
    }
    
    private var _selectedBarItems: Set<SIMChatInputBarItem> = []
    
    //  MARK: Subview
    
    private lazy var _backgroundView: UIImageView = {
        let view = UIImageView()
        
//        view.backgroundColor = UIColor.clearColor()
//        view.layer.borderWidth = 0.5
//        view.layer.borderColor = UIColor.grayColor().CGColor
//        view.layer.cornerRadius = 4
//        view.layer.masksToBounds = true
        
        return view
    }()
    
    private lazy var _textView: SIMChatInputBarTextView = {
        let view = SIMChatInputBarTextView()
        
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
    
    private lazy var _collectionViewLayout: SIMChatInputBarLayout = {
        let layout = SIMChatInputBarLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        return layout
    }()
    private lazy var _collectionView: UICollectionView = {
        let layout = self._collectionViewLayout
        let view = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
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
    
    private var _cacheBoundsSize: CGSize?
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
}

// MARK: - Editing Support

extension SIMChatInputBar: UITextViewDelegate, UIKeyInput {
    
    // MARK: Forwarding => UITextView
    
    public var text: String! {
        set { return _inputAccessoryView.textView.text = newValue }
        get { return _inputAccessoryView.textView.text }
    }
    public var font: UIFont? {
        set { return _inputAccessoryView.textView.font = newValue }
        get { return _inputAccessoryView.textView.font }
    }
    public var textColor: UIColor? {
        set { return _inputAccessoryView.textView.textColor = newValue }
        get { return _inputAccessoryView.textView.textColor }
    }
    
    public var attributedText: NSAttributedString! {
        set { return _inputAccessoryView.textView.attributedText = newValue }
        get { return _inputAccessoryView.textView.attributedText }
    }
    
    public var textAlignment: NSTextAlignment {
        set { return _inputAccessoryView.textView.textAlignment = newValue }
        get { return _inputAccessoryView.textView.textAlignment }
    }
    public var selectedRange: NSRange {
        set { return _inputAccessoryView.textView.selectedRange = newValue }
        get { return _inputAccessoryView.textView.selectedRange }
    }
    
    public var editable: Bool {
        set { return _inputAccessoryView.textView.editable = newValue }
        get { return _inputAccessoryView.textView.editable }
    }
    public var selectable: Bool {
        set { return _inputAccessoryView.textView.selectable = newValue }
        get { return _inputAccessoryView.textView.selectable }
    }
    
    // MARK: Forwarding => UIKeyInput
    
    public func hasText() -> Bool {
        return _inputAccessoryView.textView.hasText()
    }
    public func insertText(text: String) {
        return _inputAccessoryView.textView.insertText(text)
    }
    public func deleteBackward() {
        return _inputAccessoryView.textView.deleteBackward()
    }
    
    // MARK: Forwarding => UITextInputTraits
    
    public var autocapitalizationType: UITextAutocapitalizationType {
        set { return _inputAccessoryView.textView.autocapitalizationType = newValue }
        get { return _inputAccessoryView.textView.autocapitalizationType }
    }
    public var autocorrectionType: UITextAutocorrectionType {
        set { return _inputAccessoryView.textView.autocorrectionType = newValue }
        get { return _inputAccessoryView.textView.autocorrectionType }
    }
    public var spellCheckingType: UITextSpellCheckingType {
        set { return _inputAccessoryView.textView.spellCheckingType = newValue }
        get { return _inputAccessoryView.textView.spellCheckingType }
    }
    public var keyboardType: UIKeyboardType {
        set { return _inputAccessoryView.textView.keyboardType = newValue }
        get { return _inputAccessoryView.textView.keyboardType }
    }
    public var keyboardAppearance: UIKeyboardAppearance {
        set { return _inputAccessoryView.textView.keyboardAppearance = newValue }
        get { return _inputAccessoryView.textView.keyboardAppearance }
    }
    public var returnKeyType: UIReturnKeyType {
        set { return _inputAccessoryView.textView.returnKeyType = newValue }
        get { return _inputAccessoryView.textView.returnKeyType }
    }
    public var enablesReturnKeyAutomatically: Bool {
        set { return _inputAccessoryView.textView.enablesReturnKeyAutomatically = newValue }
        get { return _inputAccessoryView.textView.enablesReturnKeyAutomatically }
    }
    public var secureTextEntry: Bool {
        get { return _inputAccessoryView.textView.secureTextEntry }
    }
    
    // MARK: Forwarding => UITextViewDelegate
    
    /// forwarding + input state change
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if let r = delegate?.inputBar?(shouldBeginEditing: self) where !r {
            return false
        }
        _updateInputStateForTextView(.Editing(keyboard: nil), animated: true)
        return true
    }
    /// forwarding
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if let r = delegate?.inputBar?(shouldEndEditing: self) where !r {
            return false
        }
        return true
    }
    
    /// forwarding
    public func textViewDidBeginEditing(textView: UITextView) {
        delegate?.inputBar?(didBeginEditing: self)
    }
    /// forwarding + input state change
    public func textViewDidEndEditing(textView: UITextView) {
        delegate?.inputBar?(didEndEditing: self)
        _updateInputStateForTextView(.None, animated: true)
    }
    
    /// forwarding
    public func textViewDidChangeSelection(textView: UITextView) {
        delegate?.inputBar?(didChangeSelection: self)
    }
    /// forwarding
    public func textViewDidChange(textView: UITextView) {
        delegate?.inputBar?(didChange: self)
    }

    /// forwarding
    public func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        if let r = delegate?.inputBar?(self, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange) where !r {
            return false
        }
        return true
    }
    /// forwarding + preprocess
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let r = delegate?.inputBar?(self, shouldChangeCharactersInRange: range, replacementString: text) where !r {
            return false
        }
        // This is return
        if text == "\n" {
            return delegate?.inputBar?(shouldReturn: self) ?? true
        }
        // This is clear
        if text.isEmpty && range.length - range.location == (textView.text as NSString).length {
            return delegate?.inputBar?(shouldClear: self) ?? true
        }
        return true
    }
    /// forwarding
    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        if let r = delegate?.inputBar?(self, shouldInteractWithURL: URL, inRange: characterRange) where !r {
            return false
        }
        return true
    }
}

extension SIMChatInputAccessoryView: UITextViewDelegate {
    
    // MARK: Private
    
    @inline(__always) func _updateContentSizeIfNeeded(animated: Bool) {
        //_logger.trace(_textView.contentSize)
        if editItem.contentIsChanged {
            logger.debug(_textView.contentSize)
            invalidateIntrinsicContentSize()
            
            UIView.animateWithDuration(_defaultAnimateDurationt) {
                self._textView.setNeedsLayout()
                self._collectionView.reloadItemsAtIndexPaths([self._centerIndexPath])
                // 强制更新
                self.superview?.setNeedsLayout()
                self.superview?.layoutIfNeeded()
            }
            // 重置offset, 因为offset在文字更新之前己经做了修改
            _textView.setContentOffset(CGPoint.zero, animated: animated)
        }
    }
    
    // MARK: Forwarding => UITextViewDelegate
    
    /// forwarding
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return delegate?.textViewShouldBeginEditing?(textView) ?? true
    }
    /// forwarding
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return delegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    /// forwarding
    func textViewDidBeginEditing(textView: UITextView) {
        delegate?.textViewDidBeginEditing?(textView)
    }
    /// forwarding
    func textViewDidEndEditing(textView: UITextView) {
        delegate?.textViewDidEndEditing?(textView)
    }
    
    /// forwarding
    func textViewDidChangeSelection(textView: UITextView) {
        delegate?.textViewDidChangeSelection?(textView)
    }
    /// forwarding + content size change
    func textViewDidChange(textView: UITextView) {
        delegate?.textViewDidChange?(textView)
        _updateContentSizeIfNeeded(true)
    }
    
    /// forwarding
    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        return delegate?.textView?(textView, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange) ?? true
    }
    /// forwarding
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return delegate?.textView?(textView, shouldChangeTextInRange: range, replacementText: text) ?? true
    }
    /// forwarding
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return delegate?.textView?(textView, shouldInteractWithURL: URL, inRange: characterRange) ?? true
    }
}

/// 自定义的输入框
internal class SIMChatInputBarTextView: UITextView {
    
    
//    @inline(__always) private func build() {
//        addSubview(_caretView)
//    }
//    
//    @inline(__always) private func updateCaretView() {
//        _caretView.frame = caretRectForPosition(selectedTextRange?.start ?? UITextPosition())
//    }
//    
//    override func insertText(text: String) {
//        super.insertText(text)
//        updateCaretView()
//    }
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
//    
//    override func willMoveToWindow(newWindow: UIWindow?) {
//        if newWindow != nil {
//            updateCaretView()
//        }
//        super.willMoveToWindow(newWindow)
//    }
    
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
    
//    
//    var maxHeight: CGFloat = 93
//    var editing: Bool = false {
//        didSet {
//            if editing {
//                _caretView.hidden = _isFirstResponder
//            } else {
//                _caretView.hidden = true
//            }
//        }
//    }
    
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
    
//    var _isFirstResponder: Bool = false {
//        didSet {
//            editing = !(!editing)
//        }
//    }
//    
//    lazy var _caretView: UIView = {
//        let view = UIView()
//        view.layer.cornerRadius = 1
//        view.clipsToBounds = true
//        view.backgroundColor = UIColor.purpleColor()
//        view.hidden = true
//        return view
//    }()
    
    @inline(__always) private func _init() {
        _logger.trace()
    }
    @inline(__always) private func _deinit() {
        _logger.trace()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    deinit {
        _deinit()
    }
}


// MARK: - Background Support

extension SIMChatInputBar {
    
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
    
}
/// inputbar bacgkround view
internal class SIMChatInputBackgroundView: UIToolbar {
}

// MARK: - Accessory Support

extension SIMChatInputBar: SIMChatInputBarItemDelegate {
    
    // MARK: Setter/Getter
    
    ///
    /// set a accessory item at position
    ///
    /// - parameter barItem: new accessory item
    /// - parameter position: applied position
    /// - parameter animated: need animation?
    ///
    public func setBarItem(barItem: SIMChatInputBarItem, atPosition position: SIMChatInputBarPosition, animated: Bool = true) {
        return _inputAccessoryView.updateBarItems([barItem], atPosition: position, animated: animated)
    }
    ///
    /// set some accessory item at position
    ///
    /// - parameter barItems: some accessory item
    /// - parameter position: applied position
    /// - parameter animated: need animation?
    ///
    public func setBarItems(barItems: [SIMChatInputBarItem], atPosition position: SIMChatInputBarPosition, animated: Bool = true) {
        return _inputAccessoryView.updateBarItems(barItems, atPosition: position, animated: animated)
    }
    
    ///
    /// at positoin the accessory items
    ///
    /// - parameter position: at position
    ///
    public func barItems(atPosition position: SIMChatInputBarPosition) -> [SIMChatInputBarItem] {
        return _inputAccessoryView.barItems(atPosition: position)
    }
    
    // MARK: Selection
    
    ///
    /// Check the accessory item can be selected
    ///
    /// - parameter barItem: need check the accessory
    ///
    public func canSelectBarItem(barItem: SIMChatInputBarItem) -> Bool {
        return _inputAccessoryView.canSelectBarItem(barItem)
    }
    ///
    /// Check the accessory item can be deselected
    ///
    /// - parameter barItem: need check the accessory
    ///
    public func canDeselectBarItem(barItem: SIMChatInputBarItem) -> Bool {
        return _inputAccessoryView.canDeselectBarItem(barItem)
    }
    
    ///
    /// select the accessory item
    ///
    /// - parameter barItem: need select the accessory
    /// - parameter animated: need animation?
    ///
    public func selectBarItem(barItem: SIMChatInputBarItem, animated: Bool) {
        return _inputAccessoryView.selectBarItem(barItem, animated: animated)
    }
    ///
    /// deselect the accessory item
    ///
    /// - parameter barItem: need deselect the accessory
    /// - parameter animated: need animation?
    ///
    public func deselectBarItem(barItem: SIMChatInputBarItem, animated: Bool) {
        return _inputAccessoryView.deselectBarItem(barItem, animated: animated)
    }
    
    // MARK: Forwarding => SIMChatInputBarItemDelegate
    
    /// forwarding
    public func barItem(shouldHighlight barItem: SIMChatInputBarItem) -> Bool {
        return delegate?.inputBar?(self, shouldHighlightItem: barItem) ?? true
    }
    /// forwarding
    public func barItem(shouldDeselect barItem: SIMChatInputBarItem) -> Bool {
        return delegate?.inputBar?(self, shouldDeselectItem: barItem) ?? true
    }
    /// forwarding
    public func barItem(shouldSelect barItem: SIMChatInputBarItem) -> Bool {
        return delegate?.inputBar?(self, shouldSelectItem: barItem) ?? true
    }
    
    /// forwarding
    public func barItem(didHighlight barItem: SIMChatInputBarItem) {
        delegate?.inputBar?(self, didHighlightItem: barItem)
    }
    /// forwarding
    public func barItem(didDeselect barItem: SIMChatInputBarItem) {
        delegate?.inputBar?(self, didDeselectItem: barItem)
    }
    /// forwarding
    public func barItem(didSelect barItem: SIMChatInputBarItem) {
        delegate?.inputBar?(self, didSelectItem: barItem)
    }
}

extension SIMChatInputAccessoryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SIMChatInputBarItemDelegate {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // bounds.width is change, need reupdate
        if _cacheBoundsSize?.width != bounds.width {
            _cacheBoundsSize = bounds.size
            _updateBarItemLayouts(false)
        }
    }
    
    // MARK: Data Source
    
    @inline(__always) private func _initForCollectionView() {
        _logger.trace()
        
        (0 ..< numberOfSectionsInCollectionView(_collectionView)).forEach {
            _collectionView.registerClass(SIMChatInputBarCell.self, forCellWithReuseIdentifier: "Cell-\($0)")
        }
    }
    
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
    
    // MARK: Setter/Getter
    
    /// update accessory item at position
    func updateBarItems(barItems: [SIMChatInputBarItem], atPosition position: SIMChatInputBarPosition, animated: Bool) {
        _logger.trace()
        
        switch position {
        case .Top:
            _topBarItems = barItems
            
        case .Left:
            _leftBarItems = barItems
            
        case .Right:
            _rightBarItems = barItems
            
        case .Bottom:
            _bottomBarItems = barItems
            
        case .Center:
            _centerBarItem = barItems.first ?? editItem
            _updateBackgroundView()
        }
        // if _cacheBoundsSize is nil, the layout is not initialize
        if _cacheBoundsSize != nil {
            _collectionViewLayout.invalidateLayoutIfNeeded(atPosition: position)
            _updateBarItemLayouts(animated)
        }
    }
    /// at positoin the accessory items
    func barItems(atPosition position: SIMChatInputBarPosition) -> [SIMChatInputBarItem] {
        switch position {
        case .Top: return _topBarItems
        case .Left: return _leftBarItems
        case .Center: return [_centerBarItem]
        case .Right: return _rightBarItems
        case .Bottom: return _bottomBarItems
        }
    }
    
    // MARK: Selection
    
    /// Check the accessory item can be selected
    func canSelectBarItem(barItem: SIMChatInputBarItem) -> Bool {
        return !_selectedBarItems.contains(barItem)
    }
    /// Check the accessory item can be deselected
    func canDeselectBarItem(barItem: SIMChatInputBarItem) -> Bool {
        return _selectedBarItems.contains(barItem)
    }
    
    /// select the accessory item
    func selectBarItem(barItem: SIMChatInputBarItem, animated: Bool) {
        _logger.trace()
        
        _selectedBarItems.insert(barItem)
        // need to be updated in the visible part of it
        _collectionView.visibleCells().forEach {
            guard let cell = $0 as? SIMChatInputBarCell where cell.item === barItem else {
                return
            }
            cell.setSelected(true, animated: animated)
        }
    }
    /// deselect the accessory item
    func deselectBarItem(barItem: SIMChatInputBarItem, animated: Bool) {
        _logger.trace()
        
        _selectedBarItems.remove(barItem)
        // need to be updated in the visible part of it
        _collectionView.visibleCells().forEach {
            guard let cell = $0 as? SIMChatInputBarCell where cell.item === barItem else {
                return
            }
            cell.setSelected(false, animated: animated)
        }
    }
    
    // MARK: Update
    
    @inline(__always) private func _updateBackgroundView() {
        logger.trace()
        if _centerBarItem == editItem {
            _backgroundView.image = _centerBarItem.backgroundImageForState(.Normal)
        }
    }
    @inline(__always) private func _updateBarItemLayouts(animated: Bool) {
        _logger.trace()
        
        editItem.invalidateCache()
        
        var contentInsets = _collectionViewLayout.contentInsets
        // 合并顶部
        let topSize = _collectionViewLayout.sizeThatFits(bounds.size, atPosition: .Top)
        if topSize.height != 0 {
            contentInsets.top += topSize.height + _collectionViewLayout.minimumLineSpacing
        }
        // 合并左侧
        let leftSize = _collectionViewLayout.sizeThatFits(bounds.size, atPosition: .Left)
        if leftSize.width != 0 {
            contentInsets.left += leftSize.width + _collectionViewLayout.minimumInteritemSpacing
        }
        // 合并右侧
        let rightSize = _collectionViewLayout.sizeThatFits(bounds.size, atPosition: .Right)
        if rightSize.width != 0 {
            contentInsets.right += rightSize.width + _collectionViewLayout.minimumInteritemSpacing
        }
        // 合并底部
        let bottomSize = _collectionViewLayout.sizeThatFits(bounds.size, atPosition: .Bottom)
        if bottomSize.height != 0 {
            contentInsets.bottom += bottomSize.height + _collectionViewLayout.minimumLineSpacing
        }
        
        logger.debug(contentInsets)
        
        // 更新约束
        _textViewTop.constant = contentInsets.top
        _textViewLeft.constant = contentInsets.left
        _textViewRight.constant = contentInsets.right
        _textViewBottom.constant = contentInsets.bottom
        
        let handler = { () -> () in
            if self._centerBarItem != self.editItem {
                self._textView.alpha = 0
                self._backgroundView.alpha = 0
            } else {
                self._textView.alpha = 1
                self._backgroundView.alpha = 1
            }
            self._textView.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
            self._updateBarItemsIfNeeded(false)
            
            // 强制更新
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration(_defaultAnimateDurationt, animations: handler) { finished in
                //self._backgroundView.hidden = (self._centerBarItem != self.editItem)
            }
        } else {
            UIView.performWithoutAnimation(handler)
        }
    }
    @inline(__always) func _updateBarItemsIfNeeded(animated: Bool) {
        _logger.trace()
        
        // TODO: No imp
        
        // TODO: 计算出变更的indexPath
        // TODO: 动画处理
        
        self._collectionView.reloadItemsAtIndexPaths([self._centerIndexPath])
    }
    
    // MARK: UICollectionViewDataSource & UICollectionViewDelegate
    
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
        return collectionView.dequeueReusableCellWithReuseIdentifier("Cell-\(indexPath.section)", forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? SIMChatInputBarCell else {
            return
        }
        let item = _barItem(at: indexPath)
        cell.delegate = self
        cell.item = item
        cell.setSelected(_selectedBarItems.contains(item), animated: false)
        
        cell.hidden = (item == editItem)
    }
    
    
    // MARK: Forwarding => SIMChatInputBarItemDelegate
    
    /// forwarding
    func barItem(shouldHighlight barItem: SIMChatInputBarItem) -> Bool {
        return delegate?.barItem(shouldHighlight: barItem) ?? true
    }
    /// forwarding
    func barItem(shouldDeselect barItem: SIMChatInputBarItem) -> Bool {
        return delegate?.barItem(shouldDeselect: barItem) ?? true
    }
    /// forwarding
    func barItem(shouldSelect barItem: SIMChatInputBarItem) -> Bool {
        return delegate?.barItem(shouldSelect: barItem) ?? true
    }
    
    /// forwarding
    func barItem(didHighlight barItem: SIMChatInputBarItem) {
        delegate?.barItem(didHighlight: barItem)
    }
    /// forwarding + state records
    func barItem(didDeselect barItem: SIMChatInputBarItem) {
        _logger.trace()
        _selectedBarItems.remove(barItem)
        
        delegate?.barItem(didDeselect: barItem)
    }
    /// forwarding + state records
    func barItem(didSelect barItem: SIMChatInputBarItem) {
        _logger.trace()
        _selectedBarItems.insert(barItem)
        
        delegate?.barItem(didSelect: barItem)
    }
    
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
        logger.trace()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        logger.trace()
    }
}

/// inputbar bar item container view
internal class SIMChatInputBarCell: UICollectionViewCell {
    
    var item: SIMChatInputBarItem? {
        willSet {
            UIView.performWithoutAnimation {
                self._updateItem(newValue)
            }
        }
    }
    
    weak var delegate: SIMChatInputBarItemDelegate? {
        set { return _button.delegate = newValue }
        get { return _button.delegate }
    }
    
    func setSelected(selected: Bool, animated: Bool) {
        _button.setSelected(selected, animated: animated)
    }
    
    @inline(__always) func _init() {
        _logger.trace()
        
        clipsToBounds = true
        backgroundColor = UIColor.clearColor()
        //backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2)
    }
    @inline(__always) func _deinit() {
        _logger.trace()
    }
    @inline(__always) func _updateItem(newValue: SIMChatInputBarItem?) {
        _logger.trace(newValue)
        
        guard let newValue = newValue else {
            // clear on nil
            _contentView?.removeFromSuperview()
            _contentView = nil
            return
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
    private lazy var _button: SIMChatInputBarButton = {
        //let view = SIMChatInputBarButton(type: .Custom)
        let view = SIMChatInputBarButton(type: .System)
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
    deinit {
        _deinit()
    }
}

internal class SIMChatInputBarButton: UIButton {
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        guard let barItem = self.barItem else {
            return super.beginTrackingWithTouch(touch, withEvent: event)
        }
        if delegate?.barItem(shouldHighlight: barItem) ?? true {
            allowsHighlight = true
            delegate?.barItem(didHighlight: barItem)
        } else {
            allowsHighlight = false
        }
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
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
    weak var delegate: SIMChatInputBarItemDelegate?
    
    var allowsHighlight = true
    
    override var highlighted: Bool {
        set {
            guard allowsHighlight else {
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
    
    func setSelected(selected: Bool, animated: Bool) {
        //logger.trace(selected)
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
    @inline(__always) private func _setHighlighted(highlighted: Bool, animated: Bool) {
        //logger.trace(highlighted)
        // 检查高亮的时候有没有设置图片, 如果有关闭系统的变透明效果
        if barItem?.imageForState([(selected ? .Selected : .Normal), .Highlighted]) != nil {
            imageView?.alpha = 1
        }
        if animated {
            _addAnimation("highlighted")
        }
    }
    
    @objc private func _touchHandler() {
        guard let barItem = barItem else {
            return
        }
        // delegate before the callback
        barItem.handler?(barItem)
        
        if !selected {
            // select
            guard delegate?.barItem(shouldSelect: barItem) ?? true else {
                return
            }
            setSelected(true, animated: true)
            delegate?.barItem(didSelect: barItem)
        } else {
            // deselect
            guard delegate?.barItem(shouldDeselect: barItem) ?? true else {
                return
            }
            setSelected(false, animated: true)
            delegate?.barItem(didDeselect: barItem)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

/// a alignment flow collection view layout
internal class SIMChatInputBarLayout: UICollectionViewLayout/*UICollectionViewFlowLayout*/ {
    class Line {
        var frame: CGRect
        var inset: UIEdgeInsets
        var section: Int
        var attributes: [Attributes]
        
        var cacheMaxWidth: CGFloat?
        var cacheMaxHeight: CGFloat?
        
        init(_ firstItem: Attributes, _ inset: UIEdgeInsets = UIEdgeInsetsZero) {
            self.frame = firstItem.frame
            self.section = firstItem.indexPath.section
            self.inset = inset
            self.attributes = [firstItem]
            
        }
        
        func addItem(item: Attributes, _ spacing: CGFloat) {
            
            let x = min(frame.minX, item.frame.minX)
            let y = min(frame.minY, item.frame.minY)
            let width = frame.width + spacing + item.size.width
            let height = max(frame.height, item.size.height)
            
            frame = CGRectMake(x, y, width, height)
            attributes.append(item)
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
            
            var centerCount = 0
            var centerWidth = CGFloat(0)
            
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
                if $0.alignemt.contains(.HCenter) {
                    centerCount += 1
                    centerWidth += $0.size.width
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
    
    // MARK: Property
    
    var minimumLineSpacing: CGFloat = 8
    var minimumInteritemSpacing: CGFloat = 8
    
    var contentInsets: UIEdgeInsets = UIEdgeInsetsMake(8, 10, 8, 10)
    
    // MARK: Invalidate
    
    override func prepareLayout() {
        super.prepareLayout()
        _logger.trace()
    }
    override func collectionViewContentSize() -> CGSize {
        return collectionView?.frame.size ?? CGSizeZero
    }
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if collectionView?.frame.width != newBounds.width {
            return true
        }
        return false
    }
    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayoutWithContext(context)
        _invalidateLayoutCache(context.invalidateEverything)
    }
    
    // MAKR: Layout
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return _layoutIfNeed(inRect: rect)
    }
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return _layoutAttributesForItemAtIndexPath(indexPath)
    }
    
    // MARK: Change Animation
    
    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        super.prepareForCollectionViewUpdates(updateItems)
        
        _logger.trace()
        
        updateItems.forEach {
            switch $0.updateAction {
            case .Insert:
                add.insert($0.indexPathAfterUpdate!)
            case .Delete:
                rm.insert($0.indexPathBeforeUpdate!)
            case .Reload:
                reload.insert($0.indexPathAfterUpdate!)
                //rm.insert($0.indexPathBeforeUpdate!)
            default:
                break
            }
        }
    }
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        logger.trace()
        reload = []
        add = []
        rm = []
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = _layoutAttributesForItemAtIndexPath(itemIndexPath)
        // TODO: no imp
        if reload.contains(itemIndexPath) {
            let attro = _layoutAttributesForItemAtOldIndexPath(itemIndexPath)?.copy() as? Attributes
            
            attro?.alpha = 0
            
            _logger.trace("is reload at \(itemIndexPath.item)-\(itemIndexPath.section) => \(attr?.frame)")
            reload.remove(itemIndexPath)
            return attro
        }
        return attr
    }
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        // TODO: 这里要查找旧的, 并且要进行y轴修正
        // TODO: no imp
        let attr = _layoutAttributesForItemAtOldIndexPath(itemIndexPath)
        if reload.contains(itemIndexPath) {
            let attrn = _layoutAttributesForItemAtIndexPath(itemIndexPath)?.copy() as? Attributes
            attrn?.alpha = 0
            _logger.trace("is reload at \(itemIndexPath.item)-\(itemIndexPath.section) => \(attr?.frame)")
            return attrn
        }
        //attr?.alpha = 1
        return attr
    }
    
    func sizeThatFits(maxSize: CGSize, atPosition position: SIMChatInputBarPosition) -> CGSize {
        if let size = _cacheLayoutSizes[position] {
            return size
        }
        let maxRect = CGRectMake(0, 0, maxSize.width, maxSize.height)
        let mls = minimumLineSpacing
        let newSize = _lines(atPosition: position, inRect: maxRect).reduce(CGSizeMake(0, -mls)) {
            CGSizeMake(max($0.width, $1.frame.width),
                       $0.height + mls + $1.frame.height)
        }
        let size = CGSizeMake(newSize.width, max(newSize.height, 0))
        _cacheLayoutSizes[position] = size
        return size
    }
    
    func invalidateLayout(atPosition position: SIMChatInputBarPosition) {
        _invalidateLayoutAllCache(atPosition: position)
    }
    func invalidateLayoutIfNeeded(atPosition position: SIMChatInputBarPosition) {
        _logger.trace(position)
        
        guard let attributes = _cacheLayoutAllAttributes[position] else {
            return
        }
        var itemIsChanged = false
        var sizeIsChanged = false
        var boundsIsChanged = false
        
        let barItems = _barItems(atPosition: position)
        
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
        if let lines = _cacheLayoutAllLines[position] {
            lines.forEach {
                if $0.cacheMaxWidth != collectionView?.frame.width {
                    boundsIsChanged = true
                }
            }
        }
        
        if itemIsChanged {
            _logger.debug("\(position) item is change")
            _invalidateLayoutAllCache(atPosition: position)
        } else if sizeIsChanged {
            _logger.debug("\(position) size is change")
            _invalidateLayoutLineCache(atPosition: position)
        } else if boundsIsChanged {
            _logger.debug("\(position) bounds is change")
            _invalidateLayoutLineCache(atPosition: position)
        } else {
            // no changed
        }
    }
    
    // MARK: private
    
    @inline(__always) private func _layoutIfNeed(inRect rect: CGRect) -> [Attributes] {
        _logger.trace(rect)
        
        if let attributes = _cacheLayoutedAttributes {
            return attributes
        }
        _logger.debug("reset")
        
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
        
        // cache => save
        _cacheLayoutAllAttributesOfPrevious = _cacheLayoutAllAttributesOfCurrent
        _cacheLayoutAllAttributesOfCurrent = _cacheLayoutAllAttributes
        
        return attributes
    }
    
    @inline(__always) private func _layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> Attributes? {
        if let position = SIMChatInputBarPosition(rawValue: indexPath.section) {
            if let attributes = _cacheLayoutAllAttributesOfCurrent[position] where indexPath.item < attributes.count {
                return attributes[indexPath.item]
            }
        }
        _logger.debug("not found \(indexPath.item) - \(indexPath.section)")
        return nil
    }
    @inline(__always) private func _layoutAttributesForItemAtOldIndexPath(indexPath: NSIndexPath) -> Attributes? {
        if let position = SIMChatInputBarPosition(rawValue: indexPath.section) {
            if let attributes = _cacheLayoutAllAttributesOfPrevious[position] where indexPath.item < attributes.count {
                return attributes[indexPath.item]
            }
        }
        _logger.debug("not found \(indexPath.item) - \(indexPath.section)")
        return nil
    }
    
    @inline(__always) private func _linesWithAttributes(attributes: [Attributes], inRect rect: CGRect) -> [Line] {
        _logger.trace()
        return attributes.reduce([Line]()) {
            // update cache
            if $1.cacheSize == nil || $1.cacheSize != $1.item?.size {
                $1.cacheSize = $1.item?.size
                $1.size = $1.cacheSize ?? CGSizeZero
            }
            // check the width, if you can't hold, then create a new line
            guard let line = $0.last where line.canAddItem($1, rect.width, minimumInteritemSpacing) else {
                var lines = $0
                lines.append(Line($1, contentInsets))
                return lines
            }
            line.addItem($1, minimumInteritemSpacing)
            return $0
        }
    }
    @inline(__always) private func _attributesWithBarItems(barItems: [SIMChatInputBarItem], atPosition position: SIMChatInputBarPosition) -> [Attributes] {
        _logger.trace(position)
        // 查找左对齐和右对齐的item
        let ax = barItems.enumerate().reduce((-1, barItems.count)) {
            if $1.element.alignment.rawValue & 0x00FF == 1 {
                return (max($0.0, $1.index), barItems.count)
            }
            if $1.element.alignment.rawValue & 0x00FF == 2 {
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
                attr.alignemt.unionInPlace(.Left)
            } else if $0 >= ax.1 {
                attr.alignemt.unionInPlace(.Right)
            } else {
                attr.alignemt.unionInPlace(.HCenter)
            }
            // 额外处理垂直对齐
            if attr.alignemt.rawValue & 0xFF00 == 0 {
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
    @inline(__always) private func _lines(atPosition position: SIMChatInputBarPosition, inRect rect: CGRect) -> [Line] {
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
    @inline(__always) private func _attributes(atPosition position: SIMChatInputBarPosition) -> [Attributes] {
        if let attributes = _cacheLayoutAllAttributes[position] {
            return attributes
        }
        let barItems = _barItems(atPosition: position)
        let attributes = _attributesWithBarItems(barItems, atPosition: position)
        _cacheLayoutAllAttributes[position] = attributes
        return attributes
    }
    @inline(__always) private func _barItems(atPosition position: SIMChatInputBarPosition) -> [SIMChatInputBarItem] {
        // 如果不是这样的话... 直接报错(高耦合, 反正不重用)
        let ds = collectionView?.dataSource as! SIMChatInputAccessoryView
        return ds.barItems(atPosition: position)
    }
    
    @inline(__always) private func _invalidateLayoutCache(force: Bool) {
        _logger.trace("isForce => \(force)")
        
        guard !force else {
            _invalidateLayoutAllCache()
            return
        }
        // 计算出变更的点
        [.Top, .Left, .Center, .Right, .Bottom].forEach {
            invalidateLayoutIfNeeded(atPosition: $0)
        }
    }
    
    @inline(__always) private func _invalidateLayoutAllCache() {
        _logger.trace()
        
        _cacheLayoutSizes.removeAll(keepCapacity: true)
        _cacheLayoutAllLines.removeAll(keepCapacity: true)
        _cacheLayoutAllAttributes.removeAll(keepCapacity: true)
        _cacheLayoutedAttributes = nil
    }
    @inline(__always) private func _invalidateLayoutAllCache(atPosition position: SIMChatInputBarPosition) {
        _logger.trace(position)
        
        _cacheLayoutSizes.removeValueForKey(position)
        _cacheLayoutAllLines.removeValueForKey(position)
        _cacheLayoutAllAttributes.removeValueForKey(position)
        
        // center总是要清的
        if position == .Left || position == .Right {
            _cacheLayoutSizes.removeValueForKey(.Center)
            _cacheLayoutAllLines.removeValueForKey(.Center)
            _cacheLayoutAllAttributes.removeValueForKey(.Center)
        }
        
        _cacheLayoutedAttributes = nil
    }
    @inline(__always) private func _invalidateLayoutLineCache(atPosition position: SIMChatInputBarPosition) {
        _logger.trace(position)
        
        _cacheLayoutSizes.removeValueForKey(position)
        _cacheLayoutAllLines.removeValueForKey(position)
        
        // center总是要清的
        if position == .Left || position == .Right {
            _cacheLayoutSizes.removeValueForKey(.Center)
            _cacheLayoutAllLines.removeValueForKey(.Center)
            _cacheLayoutAllAttributes[.Center]?.forEach {
                $0.cacheSize = nil
            }
        }
        
        _cacheLayoutedAttributes = nil
    }
    
    // MARK: Cache
    
    var rm: Set<NSIndexPath> = []
    var add: Set<NSIndexPath> = []
    var reload: Set<NSIndexPath> = []
    
    var _cacheLayoutAllAttributesOfCurrent: [SIMChatInputBarPosition: [Attributes]] = [:]
    var _cacheLayoutAllAttributesOfPrevious: [SIMChatInputBarPosition: [Attributes]] = [:]
    
    var _cacheLayoutSizes: [SIMChatInputBarPosition: CGSize] = [:]
    var _cacheLayoutAllLines: [SIMChatInputBarPosition: [Line]] = [:]
    var _cacheLayoutAllAttributes: [SIMChatInputBarPosition: [Attributes]] = [:]
    
    var _cacheLayoutedAttributes: [Attributes]?
    
    // MARK: Init
    
    override init() {
        super.init()
        logger.trace()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        logger.trace()
    }
    deinit {
        logger.trace()
    }
}

internal class SIMChatInputBarEditItem: SIMChatInputBarItem {
    init(textView: UITextView) {
        _textView = textView
        super.init()
        
        _logger.trace()
        _textView.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
        
        setBackgroundImage(UIImage(named: "chat_bottom_textfield"), forState: .Normal)
    }
    deinit {
        _logger.trace()
        _textView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if contentIsChanged {
            _cacheSize = nil
        }
    }
    
    var contentIsChanged: Bool {
        let newValue = _textView.contentSize
        let oldValue = _cacheContentSize ?? CGSizeZero
        
        if newValue.width != _textView.frame.width {
            return true
        }
        if newValue.height != oldValue.height && newValue.height <= _maxHeight {
            return true
        }
        return false
    }
    var contentSize: CGSize {
        return size
    }
    
    override var size: CGSize {
        set { }
        get {
            if let size = _cacheSize {
                return size
            }
            let size = sizeThatFits()
            _cacheSize = size
            _cacheContentSize = _textView.contentSize
            return size
        }
    }
    
    func invalidateCache() {
        _logger.trace()
        
        _cacheSize = nil
        _cacheContentSize = nil
    }
    
    func sizeThatFits() -> CGSize {
        _logger.trace()
        
        let textSize = _textView.sizeThatFits(CGSize(width: _textView.bounds.width, height: CGFloat.max))
        let size = CGSizeMake(_textView.bounds.width, min(textSize.height + 0.5, _maxHeight))
        return size
    }
    
    var _textView: UITextView
    var _maxHeight: CGFloat = 120
    
    var _cacheSize: CGSize?
    var _cacheContentSize: CGSize?
}


// MARK: - Keyboard Support

extension SIMChatInputBar {
    
    ///
    /// input state. animatable
    ///
    public var state: SIMChatInputBarState {
        set { return _updateInputState(newValue, animated: true) }
        get { return _inputState }
    }
    ///
    /// Set the new input state.
    ///
    /// - parameter newState a new state.
    /// - parameter animated need animation?
    ///
    public func setState(newState: SIMChatInputBarState, animated: Bool) {
        _updateInputState(newState, animated: animated)
    }
    
    ///
    /// if sub layout is changed, reset keyboard size
    ///
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard _cacheBounds?.width != bounds.width else {
            return
        }
        _logger.debug("bounds is change => \(bounds)")
        _cacheBounds = bounds
        guard !self.state.isNone else {
            return
        }
        _updateKeyboardSizeWithState(self.state, animated: true)
    }
    
    // MARK: Input State
    
    ///
    /// update input state.
    ///
    /// - parameter newState a new state.
    /// - parameter animated need animation?
    ///
    @inline(__always) private func _updateInputState(newState: SIMChatInputBarState, animated: Bool) {
        _logger.trace(newState)
        
        let oldState = _inputState
        _inputState = newState
        
        _inputView.updateInputState(newState, oldState: oldState, animated: animated)
        _inputAccessoryView.updateInputState(newState, oldState: oldState, animated: animated)
        
        _updateKeyboardSizeWithState(newState, animated: animated)
    }
    ///
    /// Set the new input state of textview,
    /// textView only allows setting two states, `None` or `Editing`
    /// and don't need to do other operations.
    ///
    /// - parameter newState: a new state.
    /// - parameter animated: need animation?
    ///
    @inline(__always) private func _updateInputStateForTextView(newState: SIMChatInputBarState,  animated: Bool) {
        _logger.trace(newState)
        
        let oldState = _inputState
        if newState.isNone {
            if !oldState.isEditing {
                return
            }
        } else {
            if oldState.isEditing {
                return
            }
        }
        _inputState = newState
        _inputView.updateInputState(newState, oldState: self.state, animated: animated)
    }
    ///
    /// update keyboard size for state
    ///
    @inline(__always) private func _updateKeyboardSizeWithState(state: SIMChatInputBarState, animated: Bool) {
        _logger.trace()
        
        switch state {
        case .None:
            var curve = UIViewAnimationCurve.EaseInOut
            NSNumber(integer: 7).getValue(&curve)
            _updateKeyboardSize(CGSizeZero, duration: 0.25, curve: curve)
            
        case .Editing(let keyboard):
            guard let keyboard = keyboard else {
                return
            }
            // TODO: Keep the input current cursor
            _updateKeyboardSize(keyboard.intrinsicContentSize(), duration: 0.25)
            
        case .Selecting(let keyboard):
            _updateKeyboardSize(keyboard.intrinsicContentSize(), duration: 0.25)
        }
    }
    
    // MARK: Notifiation
    
    ///
    /// Add system keyboard observation event
    ///
    @inline(__always) private func _addKeyboardNotification() {
        _logger.trace()
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector:#selector(_keyboard(willChangeFrame:)), name:UIKeyboardWillChangeFrameNotification, object:nil)
    }
    ///
    /// Remove system keyboard observation event
    ///
    @inline(__always) private func _removeKeyboardNotification() {
        _logger.trace()
        
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
    @inline(__always) private func _updateKeyboardSize(newSize: CGSize, duration: NSTimeInterval, curve:UIViewAnimationCurve = .EaseInOut) {
        _logger.trace(newSize)
        
        guard _inputAccessoryViewBottom.constant != newSize.height
            || _keyboardSize.height != newSize.height else {
                return // no change
        }
        // if keyboard size change, reset the inputBar size
        if _keyboardSize.height != newSize.height {
            invalidateIntrinsicContentSize()
        }
        
        _keyboardSize = newSize
        
        let handler = {
            self._inputViewBottom.constant = 0
            self._inputAccessoryViewBottom.constant = self._keyboardSize.height
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        handler()
        // UIView.animateWithDuration(duration, delay:0, options:options, animations: handler, completion: nil)
        UIView.commitAnimations()
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
        //_logger.trace(newPoint)
        _keyboardOffset = newPoint
        
        let handler = {
            self._inputViewBottom.constant = -newPoint.y
            self._inputAccessoryViewBottom.constant = ty
            //self._inputAccessoryView.layoutIfNeeded()
            //self._inputView.layoutIfNeeded()
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
        // if inputbar state is `None`, ignore this event
        if self.state.isNone {
            return
        }
        // if recgognizer is end, process custom event
        if sender.state != .Began && sender.state != .Changed && sender.state != .Possible {
            // in system keyboard, the show/dismiss is automatic process
            if !self.state.isEditingWithSystemKeyboard {
                if sender.velocityInView(self).y <= 0 {
                    // show
                    _updateKeyboardOffset(CGPointZero, animated: true)
                } else {
                    // dismiss
                    _updateInputState(.None, animated: true)
                }
            }
            return
        }
        guard sender.numberOfTouches() != 0 else {
            return
        }
        // You must use the first touch to calculate the position
        let y = sender.locationOfTouch(0, inView: self).y
        let ty = min(max(0, y), _keyboardSize.height)
        
        _updateKeyboardOffset(CGPointMake(0, ty), animated: false)
    }
    
    ///
    /// Keyboard frame change event
    ///
    @objc private func _keyboard(willChangeFrame sender: NSNotification) {
        //_logger.debug(sender)
        // only inputbar state for editing event
        guard self.state.isEditingWithSystemKeyboard else {
            return
        }
        guard let u = sender.userInfo,
            //let beginFrame = (u[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(),
            let endFrame = (u[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(),
            let curveX = (u[UIKeyboardAnimationCurveUserInfoKey] as? NSValue),
            let duration = (u[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval) else {
                return
        }
        var curve = UIViewAnimationCurve.EaseInOut
        let newSize = _systemKeyboardVisibleSize(endFrame)
        
        curveX.getValue(&curve)
        
        _logger.trace(endFrame)
        _updateKeyboardSize(newSize, duration: max(duration, 0.25), curve: curve)
    }
}

extension SIMChatInputView {
    
    ///
    /// after input status changes
    ///
    /// - parameter newState: new input state
    /// - parameter oldState: old input state
    /// - parameter animated: need animation?
    ///
    func updateInputState(newState: SIMChatInputBarState, oldState: SIMChatInputBarState, animated: Bool) {
        _logger.trace(newState)
        
        switch newState {
        case .None:
            // don't need to do anything
            // updateKeyboard(nil, oldKeyboard: _keyboard, animated: animated)
            break
            
        case .Editing(let keyboard):
            updateKeyboard(keyboard, oldKeyboard: _keyboard, animated: animated)
            
        case .Selecting(let keyboard):
            updateKeyboard(keyboard, oldKeyboard: _keyboard, animated: animated)
        }
    }
    ///
    /// update keyboard
    ///
    /// - parameter newKeyboard: new keyboard
    /// - parameter oldKeyboard: old keyboard
    /// - parameter animated: need animation?
    ///
    func updateKeyboard(newKeyboard: UIView?, oldKeyboard: UIView?, animated: Bool) {
        _logger.trace()
        
        // 隐藏旧的
        if let keyboard = oldKeyboard {
            keyboard.transform = CGAffineTransformIdentity
            UIView.animateWithDuration(0.25, animations: {
                keyboard.transform = CGAffineTransformMakeTranslation(0, self.bounds.height)
            }, completion: { f in
                // if the user use the keyboard again, can't remove it
                guard keyboard != self._keyboard else {
                    return
                }
                keyboard.removeFromSuperview()
            })
        }
        _keyboard = newKeyboard
        // 显示新的
        if let keyboard = newKeyboard {
            keyboard.frame = bounds
            keyboard.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            addSubview(keyboard)
            
            keyboard.transform = CGAffineTransformMakeTranslation(0, self.bounds.height)
            UIView.animateWithDuration(0.25) {
                keyboard.transform = CGAffineTransformIdentity
            }
        }
    }
}

extension SIMChatInputAccessoryView {
    ///
    /// after input status changes
    ///
    /// - parameter newState: new input state
    /// - parameter oldState: old input state
    /// - parameter animated: need animation?
    ///
    func updateInputState(newState: SIMChatInputBarState, oldState: SIMChatInputBarState, animated: Bool) {
        _logger.trace(newState)
        
        switch newState {
        case .None:
            if oldState.isEditing {
                resignFirstResponder()
            }
        case .Editing(let keyboard):
            if keyboard == nil {
                becomeFirstResponder()
            }
        case .Selecting(_):
            if oldState.isEditing {
                resignFirstResponder()
            }
        }
    }
}

extension UIScrollView {
    /// method inject
    public override class func initialize() {
        if self !== UIScrollView.self {
            return
        }
        dispatch_once(&_scrollView_KeyboardDismissMode) {
            let cls = UIScrollView.self
            let sel1 = #selector(willMoveToSuperview(_:))
            let sel2 = #selector(sa_willMoveToSuperview(_:))
            
            // Check whether willMoveToSuperview method be rewritten
            let imp1 = cls.instanceMethodForSelector(sel1)
            let imp2 = UIView.instanceMethodForSelector(sel1)
            _scrollView_willMoveToSuperviewIsOverwrite = (imp1 != imp2)
            
            if _scrollView_willMoveToSuperviewIsOverwrite {
                // if the UIScrollView rewrite didMoveToSuperview, inject method
                let m1 = class_getInstanceMethod(cls, sel1)
                let m3 = class_getInstanceMethod(cls, sel2)
                
                method_exchangeImplementations(m1, m3)
            } else {
                // if there is no rewrite UIScrollView, add method
                let m1 = class_getInstanceMethod(cls, sel1)
                let m2 = class_getInstanceMethod(cls, sel2)
                let imp = method_getImplementation(m2)
                let type = method_getTypeEncoding(m1)
                
                class_addMethod(cls, sel1, imp, type)
            }
        }
    }
    /// inject method `willMoveToSuperview`
    @objc private func sa_willMoveToSuperview(newSuperview: UIView?) {
        if _scrollView_willMoveToSuperviewIsOverwrite {
            self.sa_willMoveToSuperview(newSuperview)
        } else {
            super.willMoveToSuperview(newSuperview)
        }
        guard superview == nil else {
            return
        }
        // :)
        panGestureRecognizer.removeTarget(self, action: #selector(sa_handlePan(_:)))
        panGestureRecognizer.addTarget(self, action: #selector(sa_handlePan(_:)))
    }
    /// gesture recognizer handler
    @objc private func sa_handlePan(sender: UIPanGestureRecognizer) {
        guard keyboardDismissMode != .None else {
            return
        }
        // find inputBar
        guard let placeholderView = inputAccessoryView as? SIMChatInputPlaceholderView,
            let inputBar = placeholderView.inputBar else {
                return
        }
        if keyboardDismissMode == .OnDrag {
            guard !inputBar.state.isNone &&
                !inputBar.state.isEditingWithSystemKeyboard else {
                    return
            }
            // is `OnDrag`
            inputBar._updateInputState(.None, animated: true)
        } else {
            // is `Interactive`
            inputBar._keyboard(didScroll: sender)
        }
    }
}

// MARK: - Display Support

extension UIViewController {
    
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
            
            if let inputBar = inputBar2 {
                view.removeConstraints(inputBarConstraints)
                
                inputBar.removeFromSuperview()
                inputBarConstraints.removeAll()
            }
            
            objc_setAssociatedObject(self, &_viewController_inputBar, newValue, .OBJC_ASSOCIATION_RETAIN)
            
            // TODO: Keep inputBar has been at the bottom
            if let inputBar = newValue {
                view.addSubview(inputBar)
                
                inputBar.translatesAutoresizingMaskIntoConstraints = false
                
                let constraints = [
                    NSLayoutConstraintMake(inputBar, .Left, .Equal, view, .Left),
                    NSLayoutConstraintMake(inputBar, .Right, .Equal, view, .Right),
                    NSLayoutConstraintMake(inputBar, .Bottom, .Equal, bottomLayoutGuide, .Bottom),
                ]
                view.addConstraints(constraints)
            }
        }
        get {
            return objc_getAssociatedObject(self, &_viewController_inputBar) as? SIMChatInputBar
        }
    }
    
    /// inputBar layout
    private var inputBarConstraints: [NSLayoutConstraint] {
        set { return objc_setAssociatedObject(self, &_viewController_inputBarConstraints, newValue, .OBJC_ASSOCIATION_RETAIN) }
        get { return objc_getAssociatedObject(self, &_viewController_inputBarConstraints) as? [NSLayoutConstraint] ?? [] }
    }
}

// MARK: - Helper


/// Cretae an `NSLayoutConstraint`
private func NSLayoutConstraintMake(item: AnyObject, _ attr1: NSLayoutAttribute, _ related: NSLayoutRelation, _ toItem: AnyObject? = nil, _ attr2: NSLayoutAttribute = .NotAnAttribute, _ constant: CGFloat = 0, _ multiplier: CGFloat = 1) -> NSLayoutConstraint {
    return NSLayoutConstraint(item:item, attribute:attr1, relatedBy:related, toItem:toItem, attribute:attr2, multiplier:multiplier, constant:constant)
}

// MARK: -

extension SIMChatInputBarPosition: CustomStringConvertible {
    public var description: String {
        switch self {
        case Top: return "Top(\(rawValue))"
        case Left: return "Left(\(rawValue))"
        case Right: return "Right(\(rawValue))"
        case Bottom: return "Bottom(\(rawValue))"
        case Center:  return "Center(\(rawValue))"
        }
    }
}

extension SIMChatInputBarState: CustomStringConvertible {
    public var isNone: Bool {
        switch self {
        case .None: return true
        default: return false
        }
    }
    public var isEditing: Bool {
        switch self {
        case .Editing: return true
        default: return false
        }
    }
    public var isEditingWithSystemKeyboard: Bool {
        switch self {
        case .Editing(let keyboard): return keyboard == nil
        default: return false
        }
    }
    public var isSelecting: Bool {
        switch self {
        case .Selecting: return true
        default: return false
        }
    }
    public var description: String {
        switch self {
        case .None: return "None"
        case .Editing(let kb) where kb == nil: return "Editing(With System Keyboard)"
        case .Editing(_): return "Editing(With Custom Keyboard)"
        case .Selecting(_): return "Selecting"
        }
    }
}

extension SIMChatInputBarItem {
    func apply(toButton button: UIButton) {
        
        let states: [UIControlState] = [
            [.Normal],
            [.Highlighted],
            [.Disabled],
            [.Selected, .Normal],
            [.Selected, .Highlighted],
            [.Selected, .Disabled]
        ]
        // 清除
        states.forEach {
            button.setTitle(nil, forState: $0)
            button.setTitleShadowColor(nil, forState: $0)
            button.setAttributedTitle(nil, forState: $0)
            button.setImage(nil, forState: $0)
            button.setBackgroundImage(nil, forState: $0)
        }
        
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
}


// MARK: - Internal Delegate

internal protocol SIMChatInputBarItemDelegate: class {
    
    func barItem(shouldHighlight barItem: SIMChatInputBarItem) -> Bool
    func barItem(shouldDeselect barItem: SIMChatInputBarItem) -> Bool
    func barItem(shouldSelect barItem: SIMChatInputBarItem) -> Bool
    
    func barItem(didHighlight barItem: SIMChatInputBarItem)
    func barItem(didDeselect barItem: SIMChatInputBarItem)
    func barItem(didSelect barItem: SIMChatInputBarItem)
    
}


// MARK: - Global

private var _defaultAnimateDurationt: NSTimeInterval = 0.25

private var _viewController_inputBar = "_inputBar"
private var _viewController_inputBarConstraints = "_inputBarConstraints"

private var _scrollView_KeyboardDismissMode = dispatch_once_t()
private var _scrollView_willMoveToSuperviewIsOverwrite = false
