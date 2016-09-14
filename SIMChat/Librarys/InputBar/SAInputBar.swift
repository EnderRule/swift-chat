//
//  SAInputbar.swift
//  SAInputBar
//
//  Created by sagesse on 7/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


@objc public protocol SAInputBarDelegate: NSObjectProtocol {
    
    // MARK: Text Edit
    
    @objc optional func inputBar(shouldBeginEditing inputBar: SAInputBar) -> Bool
    @objc optional func inputBar(shouldEndEditing inputBar: SAInputBar) -> Bool
    
    @objc optional func inputBar(didBeginEditing inputBar: SAInputBar)
    @objc optional func inputBar(didEndEditing inputBar: SAInputBar)
    
    @objc optional func inputBar(shouldReturn inputBar: SAInputBar) -> Bool
    @objc optional func inputBar(shouldClear inputBar: SAInputBar) -> Bool
    
    @objc optional func inputBar(didChangeSelection inputBar: SAInputBar)
    @objc optional func inputBar(didChangeText inputBar: SAInputBar)
    
    @objc optional func inputBar(_ inputBar: SAInputBar, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool
    @objc optional func inputBar(_ inputBar: SAInputBar, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    @objc optional func inputBar(_ inputBar: SAInputBar, shouldInteractWithURL URL: URL, inRange characterRange: NSRange) -> Bool
    
    // MARK: Accessory Item Selection
    
    @objc optional func inputBar(_ inputBar: SAInputBar, shouldHighlightItem item: SAInputItem) -> Bool
    @objc optional func inputBar(_ inputBar: SAInputBar, shouldDeselectItem item: SAInputItem) -> Bool
    @objc optional func inputBar(_ inputBar: SAInputBar, shouldSelectItem item: SAInputItem) -> Bool
    
    @objc optional func inputBar(_ inputBar: SAInputBar, didHighlightItem item: SAInputItem)
    @objc optional func inputBar(_ inputBar: SAInputBar, didDeselectItem item: SAInputItem)
    @objc optional func inputBar(_ inputBar: SAInputBar, didSelectItem item: SAInputItem)
    
    // MARK: Input Mode
    
    @objc optional func inputBar(willChangeMode inputBar: SAInputBar)
    @objc optional func inputBar(didChangeMode inputBar: SAInputBar)
}

// MARK: -

///
/// multifunction input bar
///
/// If the delegate follow SAInputDisplayable agreement, 
//  will automatically pop-up keyboard events management
///
/// Sample:
///    ```swift
///    lazy var toolbar: SAInputBar = SAInputBar(nextResponder: self)
/// 
///    override var inputAccessoryView: UIView? {
///        return toolbar
///    }
///    override var canBecomeFirstResponder: Bool {
///        return true
///    }
///    ```
///
/// 当页面切换后键盘自动隐藏
///    ```swift
///    override func viewDidDisappear(animated: Bool) {
///        super.viewDidDisappear(animated)
///        toolbar.inputMode = .None
///    }
///    ```
///
/// 切换到自定义输入栏, 并隐藏键盘, 效果参考: 微信的语音输入
///    ```swift
///    inputBar.setBarItem(_customCenterBarItem, atPosition: .Center)
///    inputBar.setInputMode(.None, animated: true)
///    ```
///
@objc public class SAInputBar: UIView, UITextViewDelegate, UIKeyInput, SAInputItemViewDelegate {
    
    
    public override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        _cacheContentSize = nil
    }
    public override var intrinsicContentSize: CGSize {
        if let size = _cacheContentSize, size.width == frame.width {
            return size
        }
        let size = _contentSizeWithoutCache
        _cacheContentSize = size
        return size
    }
    
    public override func resignFirstResponder() -> Bool {
        return _inputAccessoryView.resignFirstResponder()
    }
    public override func becomeFirstResponder() -> Bool {
        return _inputAccessoryView.becomeFirstResponder()
    }
    public override var next: UIResponder? {
        return ib_nextResponderOverride ?? super.next
    }
    
    open var textItem: SAInputItem { 
        return _inputAccessoryView.textField.item 
    }
    
    open var inputMode: SAInputMode {
        set { return _updateInputMode(newValue, animated: true) }
        get { return _inputMode }
    }
    open func setInputMode(_ mode: SAInputMode, animated: Bool) {
        _updateInputMode(mode, animated: animated)
    }
    
    open var contentSize: CGSize {
        return _inputAccessoryView.intrinsicContentSize
    }
    open var keyboardSize: CGSize {
        return _keyboardSizeWithoutCache
    }
    
    open var allowsSelection: Bool = true // default is YES
    open var allowsMultipleSelection: Bool = false // default is NO
    
    open weak var delegate: SAInputBarDelegate? {
        didSet {
            _displayable = delegate as? SAInputBarDisplayable
        }
    }
    
    // MARK: - UITextView(Forwarding)
    
    open var text: String! {
        set { return _inputAccessoryView.textField.text = newValue }
        get { return _inputAccessoryView.textField.text }
    }
    open var font: UIFont? {
        set { return _inputAccessoryView.textField.font = newValue }
        get { return _inputAccessoryView.textField.font }
    }
    open var textColor: UIColor? {
        set { return _inputAccessoryView.textField.textColor = newValue }
        get { return _inputAccessoryView.textField.textColor }
    }
    
    open var attributedText: NSAttributedString! {
        set { return _inputAccessoryView.textField.attributedText = newValue }
        get { return _inputAccessoryView.textField.attributedText }
    }
    
    open var textAlignment: NSTextAlignment {
        set { return _inputAccessoryView.textField.textAlignment = newValue }
        get { return _inputAccessoryView.textField.textAlignment }
    }
    open var selectedRange: NSRange {
        set { return _inputAccessoryView.textField.selectedRange = newValue }
        get { return _inputAccessoryView.textField.selectedRange }
    }
    
    open var editable: Bool {
        set { return _inputAccessoryView.textField.isEditable = newValue }
        get { return _inputAccessoryView.textField.isEditable }
    }
    open var selectable: Bool {
        set { return _inputAccessoryView.textField.isSelectable = newValue }
        get { return _inputAccessoryView.textField.isSelectable }
    }
    
    // MARK: - UIKeyInput(Forwarding)
    
    open var hasText: Bool {
        return _inputAccessoryView.textField.hasText
    }
    open func insertText(_ text: String) {
        return _inputAccessoryView.textField.insertText(text)
    }
    open func deleteBackward() {
        return _inputAccessoryView.textField.deleteBackward()
    }
    
    // MARK: - UITextInputTraits(Forwarding)
    
    open var autocapitalizationType: UITextAutocapitalizationType {
        set { return _inputAccessoryView.textField.autocapitalizationType = newValue }
        get { return _inputAccessoryView.textField.autocapitalizationType }
    }
    open var autocorrectionType: UITextAutocorrectionType {
        set { return _inputAccessoryView.textField.autocorrectionType = newValue }
        get { return _inputAccessoryView.textField.autocorrectionType }
    }
    open var spellCheckingType: UITextSpellCheckingType {
        set { return _inputAccessoryView.textField.spellCheckingType = newValue }
        get { return _inputAccessoryView.textField.spellCheckingType }
    }
    open var keyboardType: UIKeyboardType {
        set { return _inputAccessoryView.textField.keyboardType = newValue }
        get { return _inputAccessoryView.textField.keyboardType }
    }
    open var keyboardAppearance: UIKeyboardAppearance {
        set { return _inputAccessoryView.textField.keyboardAppearance = newValue }
        get { return _inputAccessoryView.textField.keyboardAppearance }
    }
    open var returnKeyType: UIReturnKeyType {
        set { return _inputAccessoryView.textField.returnKeyType = newValue }
        get { return _inputAccessoryView.textField.returnKeyType }
    }
    open var enablesReturnKeyAutomatically: Bool {
        set { return _inputAccessoryView.textField.enablesReturnKeyAutomatically = newValue }
        get { return _inputAccessoryView.textField.enablesReturnKeyAutomatically }
    }
    open var isSecureTextEntry: Bool {
        @objc(setSecureTextEntry:) 
        set { return _inputAccessoryView.textField.isSecureTextEntry = newValue }
        get { return _inputAccessoryView.textField.isSecureTextEntry }
    }
    
    // MARK: - UITextViewDelegate(Forwarding)
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let r = delegate?.inputBar?(shouldBeginEditing: self), !r {
            return false
        }
        _updateInputModeForResponder(.editing, animated: true)
        return true
    }
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let r = delegate?.inputBar?(shouldEndEditing: self), !r {
            return false
        }
        return true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.inputBar?(didBeginEditing: self)
    }
    public func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.inputBar?(didEndEditing: self)
        _updateInputModeForResponder(.none, animated: true)
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.inputBar?(didChangeSelection: self)
    }
    public func textViewDidChange(_ textView: UITextView) {
        delegate?.inputBar?(didChangeText: self)
    }

    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        if let r = delegate?.inputBar?(self, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange), !r {
            return false
        }
        return true
    }
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let r = delegate?.inputBar?(self, shouldChangeCharactersInRange: range, replacementString: text), !r {
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
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if let r = delegate?.inputBar?(self, shouldInteractWithURL: URL, inRange: characterRange), !r {
            return false
        }
        return true
    }
    
    // MARK: - SAInputAccessoryView(Forwarding)
    
    open func barItems(atPosition position: SAInputItemPosition) -> [SAInputItem] {
        return _inputAccessoryView.barItems(atPosition: position)
    }
    open func setBarItem(_ barItem: SAInputItem, atPosition position: SAInputItemPosition, animated: Bool = true) {
        return _inputAccessoryView.setBarItems([barItem], atPosition: position, animated: animated)
    }
    open func setBarItems(_ barItems: [SAInputItem], atPosition position: SAInputItemPosition, animated: Bool = true) {
        return _inputAccessoryView.setBarItems(barItems, atPosition: position, animated: animated)
    }
    
    open func canSelectBarItem(_ barItem: SAInputItem) -> Bool {
        return _inputAccessoryView.canSelectBarItem(barItem)
    }
    open func canDeselectBarItem(_ barItem: SAInputItem) -> Bool {
        return _inputAccessoryView.canDeselectBarItem(barItem)
    }
    
    open func selectBarItem(_ barItem: SAInputItem, animated: Bool) {
        _selectedItems.insert(barItem)
        return _inputAccessoryView.selectBarItem(barItem, animated: animated)
    }
    open func deselectBarItem(_ barItem: SAInputItem, animated: Bool) {
        _selectedItems.remove(barItem)
        return _inputAccessoryView.deselectBarItem(barItem, animated: animated)
    }
    
    // MARK: - SAInputItemViewDelegate(Forwarding)
    
    public func barItem(shouldHighlight barItem: SAInputItem) -> Bool {
        return delegate?.inputBar?(self, shouldHighlightItem: barItem) ?? true
    }
    public func barItem(shouldDeselect barItem: SAInputItem) -> Bool {
        if !allowsMultipleSelection {
            return false // not allowed to cancel
        }
        return delegate?.inputBar?(self, shouldDeselectItem: barItem) ?? true 
    }
    public func barItem(shouldSelect barItem: SAInputItem) -> Bool {
        guard allowsSelection else {
            // do not allow the selected
            return false
        }
        if _selectedItems.contains(barItem) {
            // has been selected
            return false
        }
        guard delegate?.inputBar?(self, shouldSelectItem: barItem) ?? true else {
            // users are not allowed to select
            return false
        }
        if !allowsMultipleSelection {
            // don't allow a multiple-select, cancel has been chosen
            for item in _selectedItems  {
                if !(self.delegate?.inputBar?(self, shouldDeselectItem: item) ?? true) {
                    // Not allowed to cancel, so do not allow the selected
                    return false
                }
            }
            // 
            _selectedItems.forEach{ 
                self.deselectBarItem($0, animated: true)
                self.barItem(didDeselect: $0)
            }
            _selectedItems = []
        }
        return true
    }
    
    public func barItem(didHighlight barItem: SAInputItem) {
        delegate?.inputBar?(self, didHighlightItem: barItem)
    }
    public func barItem(didDeselect barItem: SAInputItem) {
        delegate?.inputBar?(self, didDeselectItem: barItem)
        // Remove from the selected list
        _selectedItems.remove(barItem)
    }
    public func barItem(didSelect barItem: SAInputItem) {
        delegate?.inputBar?(self, didSelectItem: barItem)
        // Added to the selected list
        _selectedItems.insert(barItem)
    }
    
    // MARK: - System Keyboard Event
    
    @objc func ntf_keyboard(willShow sender: Notification) {
        //_logger.debug(sender)
        guard let window = window else {
            return
        }
        _ntf_animation(sender) { bf, ef in
            let ef1 = UIEdgeInsetsInsetRect(window.frame, UIEdgeInsetsMake(ef.minY, 0, 0, 0))
            _logger.debug("\(bf) => \(ef) | \(ef1)")
            _updateSystemKeyboard(ef1.size, animated: false)
            
            _displayable?.ib_inputBar(self, showWithFrame: _frameInWindow)
        }
    }
    @objc func ntf_keyboard(willHide sender: Notification) {
        //_logger.debug(sender)
        guard let window = window else {
            return
        }
        _ntf_animation(sender) { bf, ef in
            let ef1 = UIEdgeInsetsInsetRect(window.frame, UIEdgeInsetsMake(ef.minY, 0, 0, 0))
            _logger.debug("\(bf) => \(ef) | \(ef1)")
            
            _cacheSystemKeyboardSize = ef1.size
            //_updateSystemKeyboard(ef1.size, animated: false)
            _cacheKeyboardSize = _keyboardSizeWithoutCache
            
            _displayable?.ib_inputBar(self, hideWithFrame: _frameInWindow)
        }
    }
    @objc func ntf_keyboard(didScroll sender: UIPanGestureRecognizer) {
        // if inputbar state is `None`, ignore this event
        if _inputMode.isNone {
            return
        }
        // if recgognizer state is end, process custom event
        guard sender.state == .began || sender.state == .changed || sender.state == .possible else {
            // clear keyboard offset
            _cacheKeyboardOffset = CGPoint.zero
            // ignore system keyboard, in system keyboard, the show/dismiss is automatic process
            guard _inputMode.isSelecting else {
                return
            }
            // if nheight > height, this means that it at outside of the keyboard, cancel the event
            if sender.location(in: _inputAccessoryView).y < 0 {
                // cancel touch at outside
                _updateKeyboardOffsetIfNeeded(CGPoint.zero, animated: true)
            } else if sender.velocity(in: _inputAccessoryView).y <= 0 {
                // cancel touch at inside
                _updateKeyboardOffsetIfNeeded(CGPoint.zero, animated: true)
                _displayable?.ib_inputBar(self, showWithFrame: _frameInWindow)
            } else {
                // dismiss
                _updateInputMode(.none, animated: true)
                //_displayable?.ib_inputBar(self, hideWithFrame: _frameInWindow)
            }
            return
        }
        guard let window = self.window, sender.numberOfTouches != 0 else {
            return
        }
        // Must use the first touch to calculate the position
        let nheight = window.frame.height - sender.location(ofTouch: 0, in: window).y
        let kbheight = _keyboardSizeWithoutCache.height
        let iavheight = _inputAccessoryView.intrinsicContentSize.height
        let height = iavheight + kbheight
        let ty = height - min(max(nheight, iavheight), height)
        
        if _cacheKeyboardOffset.y != ty {
            // in editing(system keybaord), system automatic process
            if _inputMode.isSelecting {
                _updateKeyboardOffsetIfNeeded(CGPoint(x: 0, y: ty), animated: false)
            }
            _displayable?.ib_inputBar(self, didChangeOffset: CGPoint(x: 0, y: ty))
        }
        
        _cacheKeyboardOffset.y = ty
    }
    
    @objc func ntf_accessory(didChangeFrame sender: Notification) {
        _logger.info()
        
        _updateContentSizeIfNeeded(false)
        // update in advance, don't wait for willShow event, otherwise there will be a delay
        _displayable?.ib_inputBar(self, didChangeFrame: _frameInWindow)
    }
    
    // MARK: - Private Method
    
    private func _updateInputMode(_ newMode: SAInputMode, animated: Bool) {
        let oldMode = _inputMode
        _logger.trace("\(_inputMode) => \(newMode)")
        
        delegate?.inputBar?(willChangeMode: self)
        
        _inputMode = newMode
        _inputView.updateInputMode(newMode, oldMode: oldMode, animated: animated)
        // NOTE: must be updated `contentSize` before at `resignFirstResponder` 
        _updateKeyboardKeyboardWithInputMode(newMode, animated: animated) 
        _inputAccessoryView.updateInputMode(newMode, oldMode: oldMode, animated: animated)
        
        delegate?.inputBar?(didChangeMode: self)
    }
    private func _updateInputModeForResponder(_ newMode: SAInputMode,  animated: Bool) {
        let oldMode = _inputMode
        if newMode.isNone {
            if !oldMode.isEditing {
                return
            }
        } else {
            if oldMode.isEditing {
                return
            }
        }
        _logger.trace("\(_inputMode) => \(newMode)")
        
        delegate?.inputBar?(willChangeMode: self)
        
        _inputMode = newMode
        _inputView.updateInputMode(newMode, oldMode: oldMode, animated: animated)
        // unfortunately not update, because I don't know keyboardSize
        //_updateKeyboardKeyboardWithInputMode(newMode, animated: animated)
        
        delegate?.inputBar?(didChangeMode: self)
    }
    
    private func _updateContentSizeIfNeeded(_ animated: Bool) {
        let newContentSize = _contentSizeWithoutCache
        guard _cacheContentSize != newContentSize else {
            let newKeyboardSize = _keyboardSizeWithoutCache
            // 只处理同一次的事件
            if _cacheKeyboardSize?.width == newKeyboardSize.width &&
                _cacheKeyboardSize?.height != newKeyboardSize.height {
                let height = newKeyboardSize.height - (_cacheKeyboardSize?.height ?? 0)
                // 重置移动事件, 主要针对第三方输入法多次触发willShow的处理
                if let ani = _inputAccessoryView.layer.animation(forKey: "position")?.copy() as? CABasicAnimation {
                    // 系统键盘的大小改变了呢
                    let layer = _inputAccessoryView.layer
                    if let fm = layer.presentation()?.frame {
                        ani.fromValue = NSValue(cgPoint: CGPoint(x: 0, y: fm.minY  + height))
                    }
                    ani.duration = ani.duration - (ani.beginTime - CACurrentMediaTime())
                    if ani.duration > 0 {
                        _logger.trace("auto change offset: \(height)")
                        
                        //_backgroundView.layer.add(ani, forKey: "position")
                        //_inputView.layer.add(ani, forKey: "position")
                        //_inputAccessoryView.layer.add(ani, forKey: "position")
                        _backgroundView.layer.removeAllAnimations()
                        _inputView.layer.removeAnimation(forKey: "position")
                        _inputAccessoryView.layer.removeAnimation(forKey: "position")
                    }
                }
            }
            return // no change
        }
        _logger.trace(newContentSize)
        
        if animated {
            UIView.beginAnimations("SAIB-ANI-AC", context: nil)
            UIView.setAnimationDuration(_SAInputDefaultAnimateDuration)
            UIView.setAnimationCurve(_SAInputDefaultAnimateCurve)
        } 
        
        _inputView.setNeedsLayout()
        _inputAccessoryView.setNeedsLayout()
        _backgroundView.setNeedsLayout()
        _containerView?.layoutIfNeeded()
        
        if animated {
            UIView.commitAnimations()
        }
        
        invalidateIntrinsicContentSize()
        // 必须立即更新, 否则的话会导致生成多个动画
        // 必须在invalidate之后, 否则无效
        _cacheContentSize = newContentSize 
        
        // 关闭动画的更新, 主要是为了防止contentSize改变之后的动画效果
        UIView.performWithoutAnimation { 
            _containerView?.setNeedsLayout()
            superview?.setNeedsLayout()
            superview?.layoutIfNeeded()
            //_containerView?.layoutIfNeeded()
        }
        
        if animated {
            UIView.commitAnimations()
        }
        
        // 如果没有初始化, 那将他初始
        if !_cacheKeyboardIsInitialized {
            _cacheKeyboardIsInitialized = true
            _displayable?.ib_inputBar(self, initWithFrame: _frameInWindow)
        }
    }
    
    private func _updateKeyboardSizeIfNeeded(_ animated: Bool) {
        let vsize = _visableKeybaordSize
        if _inputAccessoryViewBottom?.constant != -vsize.height {
            _inputAccessoryViewBottom?.constant = -vsize.height
            _logger.trace()
        }
        _updateContentSizeIfNeeded(animated)
        _cacheKeyboardOffset = CGPoint.zero
        _cacheKeyboardSize = _keyboardSizeWithoutCache
    }
    private func _updateKeyboardOffsetIfNeeded(_ newPoint: CGPoint, animated: Bool) {
        let ny = _visableKeybaordSize.height - newPoint.y
        guard _inputAccessoryViewBottom?.constant != -ny else {
            return // no change
        }
        //_logger.trace(ny)
        
        if animated {
            UIView.beginAnimations("SAIB-ANI-AC", context: nil)
            UIView.setAnimationDuration(_SAInputDefaultAnimateDuration)
            UIView.setAnimationCurve(_SAInputDefaultAnimateCurve)
        }
        
        _inputAccessoryViewBottom?.constant = -ny
        _containerView?.layoutIfNeeded()
        
        if animated {
            UIView.commitAnimations()
        }
    }
    
    private func _updateCustomKeyboard(_ newSize: CGSize, animated: Bool) {
        _logger.trace(newSize)
        
        _cacheCustomKeyboardSize = newSize
        _updateKeyboardSizeIfNeeded(animated)
    }
    private func _updateSystemKeyboard(_ newSize: CGSize, animated: Bool) {
        _logger.trace(newSize)
        
        _cacheSystemKeyboardSize = newSize
        _updateKeyboardSizeIfNeeded(animated)
    }
    private func _updateKeyboardKeyboardWithInputMode(_ mode: SAInputMode, animated: Bool) {
        _logger.trace()
        
        _updateCustomKeyboard(_inputView.intrinsicContentSize, animated: animated)
    }
    
    private func _ntf_flatMap(_ ntf: Notification, handler: (CGRect, CGRect, TimeInterval, UIViewAnimationCurve) -> ()) {
        guard let u = (ntf as NSNotification).userInfo,
            let bf = (u[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let ef = (u[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let cv = (u[UIKeyboardAnimationCurveUserInfoKey] as? Int),
            let dr = (u[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval) else {
                return
        }
        let edg = UIEdgeInsetsMake(intrinsicContentSize.height, 0, 0, 0)
        
        // rect correction
        let bf1 = UIEdgeInsetsInsetRect(bf, edg)
        let ef1 = UIEdgeInsetsInsetRect(ef, edg)
        
        let cv1 = UIViewAnimationCurve(rawValue: cv) ?? _SAInputDefaultAnimateCurve
        
        handler(bf1, ef1, dr, cv1)
    }
    private func _ntf_animation(_ ntf: Notification, handler: (CGRect, CGRect) -> Void) {
        _ntf_flatMap(ntf) { bf, ef, dr, cv in
            guard dr != 0 else {
                handler(bf, ef)
                return
            }
            UIView.beginAnimations("SAIB-ANI-KB", context: nil)
            UIView.setAnimationDuration(dr)
            UIView.setAnimationCurve(cv)
            handler(bf, ef)
            UIView.commitAnimations()
        }
    }
    
    private func _addNotifications() {
        _logger.trace()
        
        let center = NotificationCenter.default
        
        // keyboard
        center.addObserver(self, selector:#selector(ntf_keyboard(willShow:)), name:NSNotification.Name.UIKeyboardWillShow, object:nil)
        center.addObserver(self, selector:#selector(ntf_keyboard(willHide:)), name:NSNotification.Name.UIKeyboardWillHide, object:nil)
        
        // accessory
        center.addObserver(self, selector: #selector(ntf_accessory(didChangeFrame:)), name: NSNotification.Name(rawValue: SAInputAccessoryDidChangeFrameNotification), object: nil)
    }
    private func _removeNotifications() {
        _logger.trace()
        
        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    private func _addComponents(toView view: UIView) {
        _logger.trace()
        
        _inputView.isHidden = false
        _inputAccessoryView.isHidden = false
        
        view.addSubview(_backgroundView)
        view.addSubview(_inputAccessoryView)
        view.addSubview(_inputView)
        
        // add the constraints
        _containerView = view
        _constraints = [
            
            _SAInputLayoutConstraintMake(_inputAccessoryView, .left, .equal, view, .left),
            _SAInputLayoutConstraintMake(_inputAccessoryView, .right, .equal, view, .right),
            //_SAInputLayoutConstraintMake(_inputAccessoryView, .Bottom, .Equal, view, .Bottom),
            _SAInputLayoutConstraintMake(_inputAccessoryView, .bottom, .equal, view, .bottom, output: &_inputAccessoryViewBottom),
            
            _SAInputLayoutConstraintMake(_inputView, .top, .equal, _inputAccessoryView, .bottom),
            _SAInputLayoutConstraintMake(_inputView, .left, .equal, view, .left),
            _SAInputLayoutConstraintMake(_inputView, .right, .equal, view, .right),
            //_SAInputLayoutConstraintMake(_inputView, .bottom, .equal, view, .bottom),
            
            _SAInputLayoutConstraintMake(_backgroundView, .top, .equal, _inputAccessoryView, .top),
            _SAInputLayoutConstraintMake(_backgroundView, .left, .equal, view, .left),
            _SAInputLayoutConstraintMake(_backgroundView, .right, .equal, view, .right),
            _SAInputLayoutConstraintMake(_backgroundView, .bottom, .equal, view, .bottom),
        ]
        view.addConstraints(_constraints)
    }
    private func _removeComponents(formView view: UIView?) {
        _logger.trace()
        
        // remove the constraints
        view?.removeConstraints(_constraints)
        _constraints = []
        
        _inputView.removeFromSuperview()
        _inputAccessoryView.removeFromSuperview()
    }
    
    private func _init() {
        _logger.trace()
        
        autoresizingMask = .flexibleHeight
        backgroundColor = .clear
        
        let color = UIColor(colorLiteralRed: 0xec / 0xff, green: 0xed / 0xff, blue: 0xf1 / 0xff, alpha: 1)
        
        //_inputView.backgroundColor = color
        //_inputView.clipsToBounds = true
        _inputView.backgroundColor = .clear
        _inputView.translatesAutoresizingMaskIntoConstraints = false
        
        _inputAccessoryView.delegate = self
        _inputAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        _inputAccessoryView.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        _inputAccessoryView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        //_inputAccessoryView.backgroundColor = color
        _inputAccessoryView.backgroundColor = .clear
        
        _backgroundView.translatesAutoresizingMaskIntoConstraints = false
        _backgroundView.setContentHuggingPriority(1, for: .vertical)
        _backgroundView.setContentCompressionResistancePriority(1, for: .vertical)
        _backgroundView.barTintColor = color
        _backgroundView.isTranslucent = false // 毛玻璃效果还有bug
        //_backgroundView.barStyle = .black
        
        _addComponents(toView: self)
        _addNotifications()
    }
    private func _deinit() {
        _logger.debug()
        
        _removeNotifications()
        _removeComponents(formView: self)
    }
    
    // MARK: - 
    
    private var _visableKeybaordSize: CGSize {
        if _inputMode.isSelecting {
            return _cacheCustomKeyboardSize
        }
        return CGSize.zero
    }
    private var _keyboardSizeWithoutCache: CGSize {
        if _inputMode.isSelecting {
            return _cacheCustomKeyboardSize
        }
        return _cacheSystemKeyboardSize
    }
    private var _contentSizeWithoutCache: CGSize {
        var size = _inputAccessoryView.intrinsicContentSize
        // Append the keyboard size
        if _inputMode.isSelecting {
            size.height += _cacheCustomKeyboardSize.height //_inputView.intrinsicContentSize.height
        }
        return size
    }
    private var _frameInWindow: CGRect {
        guard let window = window else {
            return CGRect.zero
        }
        let ivheight = _inputAccessoryView.intrinsicContentSize.height
        let height = ivheight + max(_keyboardSizeWithoutCache.height, 0)
        
        return CGRect(x: 0, y: window.frame.height - height, width: window.frame.width, height: height)
    }
    
    // MARK: - 
    
    private var _inputMode: SAInputMode = .none
    
    private var _inputViewBottom: NSLayoutConstraint?
    private var _inputAccessoryViewBottom: NSLayoutConstraint?
    
    private lazy var _inputView: SAInputView = SAInputView()
    private lazy var _inputAccessoryView: SAInputAccessoryView = SAInputAccessoryView()
    private lazy var _backgroundView: SAInputBackgroundView = SAInputBackgroundView()
    
    private lazy var _constraints: [NSLayoutConstraint] = []
    private lazy var _selectedItems: Set<SAInputItem> = []
    
    private weak var _containerView: UIView?
    private weak var _displayable: SAInputBarDisplayable?
    
    private var _cacheContentSize: CGSize?
    private var _cacheKeyboardSize: CGSize?
    private var _cacheKeyboardOffset: CGPoint = .zero
    
    private var _cacheSystemKeyboardSize: CGSize = .zero
    private var _cacheCustomKeyboardSize: CGSize = .zero
    
    private var _cacheKeyboardIsInitialized: Bool = false
    
    // MARK: - 
    
    public override class func initialize() {
        _ = _ib_inputBar_once
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    deinit {
        _deinit()
    }
}

// MARK: -

private extension UIResponder {
    
    @objc func ib_overrideInputAccessoryViewNextResponderWithResponder(_ arg1: UIResponder?) {
        ib_nextResponderOverride = arg1
        return ib_overrideInputAccessoryViewNextResponderWithResponder(arg1)
    }
    
    var ib_nextResponderOverride: UIResponder? {
        set { return objc_setAssociatedObject(self, &_SAInputUIResponderNextResponderOverride, newValue, .OBJC_ASSOCIATION_ASSIGN) }
        get { return objc_getAssociatedObject(self, &_SAInputUIResponderNextResponderOverride) as? UIResponder }
    }
}

// MARK: -

private extension UIScrollView {
    
    // gesture recognizer handler
    @objc private func ib_handlePan(_ sender: UIPanGestureRecognizer) {
        ib_handlePan(sender)
        guard let inputBar = inputAccessoryView as? SAInputBar else {
            return
        }
        if keyboardDismissMode == .onDrag {
            // is `OnDrag`
            guard inputBar.inputMode.isSelecting else {
                return
            }
            inputBar.setInputMode(.none, animated: true)
        } else if keyboardDismissMode == .interactive {
            // is `Interactive`
            inputBar.ntf_keyboard(didScroll: sender)
        }
    }
}

// MARK: -

private extension UIPresentationController {
    
    @objc func _preserveResponderAcrossWindows() -> Bool {
        // repair the iOS 8.1 bugs, if return true
        // system will invoke `_preserveInputViewsWithId:animated:reset:`
        // to save the input environment
        return true
    }
}

// MARK: -

internal func SAInputBarLoad() {
    
    // 解释一下为什么采用这个方法, 因为swift没有不能重写load方法, 
    // 如果写在initialize可能会被其他库覆盖掉
    // 采用这个方法安全一点
    _SAInputExchangeSelector(UIScrollView.self, "handlePan:", "ib_handlePan:")
    
    // 计划中止, 复杂度略高
    //_SAInputExchangeSelector(NSClassFromString("UIInputSetContainerView"), "snapshotViewAfterScreenUpdates:", "ib_snapshotViewAfterScreenUpdates:")
    
    // 解决iOS8中的bug
    _SAInputExchangeSelector(UIResponder.self, "_overrideInputAccessoryViewNextResponderWithResponder:", "ib_overrideInputAccessoryViewNextResponderWithResponder:")
}

private var _ib_inputBar_once: Bool = {
    
    SAInputBarLoad()
    SAInputBarDisplayableLoad()
    return true
    
}()

private var SAInputBarWillSnapshot = "SAInputBarWillSnapshot"
private var SAInputBarDidSnapshot = "SAInputBarDidSnapshot"

private var _SAInputUIResponderNextResponderOverride = "_SAInputUIResponderNextResponderOverride"

