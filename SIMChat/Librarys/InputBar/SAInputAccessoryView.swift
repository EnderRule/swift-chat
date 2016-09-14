//
//  SAInputAccessoryView.swift
//  SAInputBar
//
//  Created by sagesse on 7/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAInputAccessoryView: UIView, UITextViewDelegate, SAInputItemViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var textField: SAInputTextField {
        return _textField
    }
    
    weak var delegate: (UITextViewDelegate & SAInputItemViewDelegate)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if _cacheBounds?.width != bounds.width {
            _cacheBounds = bounds
            _boundsDidChange()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return _textField.becomeFirstResponder()
    }
    override func resignFirstResponder() -> Bool {
        return _textField.resignFirstResponder()
    }
    
    override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        _cacheContentSize = nil
    }
    override var intrinsicContentSize: CGSize {
        if let size = _cacheContentSize, size.width == frame.width {
            return size
        }
        // Calculate intrinsicContentSize that will fit all the text
        let size = _contentSizeWithoutCache
        
        _logger.debug(size)
        _cacheContentSize = size
        return size
    }
    
    func barItems(atPosition position: SAInputItemPosition) -> [SAInputItem] {
        return _barItems(atPosition: position)
    }
    func setBarItems(_ barItems: [SAInputItem], atPosition position: SAInputItemPosition, animated: Bool) {
        _logger.trace()
        
        _setBarItems(barItems, atPosition: position)
        
        // if _cacheBoundsSize is nil, the layout is not initialize
        if _cacheBounds != nil {
            _collectionViewLayout.invalidateLayoutIfNeeded(atPosition: position)
            _updateBarItemsLayout(animated)
        }
    }
    
    func canSelectBarItem(_ barItem: SAInputItem) -> Bool {
        return !_selectedBarItems.contains(barItem)
    }
    func canDeselectBarItem(_ barItem: SAInputItem) -> Bool {
        return _selectedBarItems.contains(barItem)
    }
    
    func selectBarItem(_ barItem: SAInputItem, animated: Bool) {
        //_logger.trace()
        
        _selectedBarItems.insert(barItem)
        // need to be updated in the visible part of it
        _collectionView.visibleCells.forEach {
            guard let cell = ($0 as? SAInputItemView), cell.item === barItem else {
                return
            }
            cell.setSelected(true, animated: animated)
        }
    }
    func deselectBarItem(_ barItem: SAInputItem, animated: Bool) {
        //_logger.trace()
        
        _selectedBarItems.remove(barItem)
        // need to be updated in the visible part of it
        _collectionView.visibleCells.forEach {
            guard let cell = $0 as? SAInputItemView, cell.item === barItem else {
                return
            }
            cell.setSelected(false, animated: animated)
        }
    }
    
    func updateInputMode(_ newMode: SAInputMode, oldMode: SAInputMode, animated: Bool) {
        _logger.trace()
        
        if !newMode.isEditing && textField.isFirstResponder {
            _ = resignFirstResponder()
        }
        if newMode.isEditing && !textField.isFirstResponder {
            _ = becomeFirstResponder()
        }
    }
    
    // MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == _SAInputAccessoryViewCenterSection {
            return 1
        }
        return _barItems[section]?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell-\((indexPath as NSIndexPath).section)", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAInputItemView else {
            return
        }
        let item = _barItem(atIndexPath: indexPath)
        
        cell.delegate = self
        cell.item = item
        cell.setSelected(_selectedBarItems.contains(item), animated: false)
        
        cell.isHidden = (item == _textField.item)
    }
    
    
    // MARK: - UITextViewDelegate(Forwarding)
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.textViewShouldBeginEditing?(textView) ?? true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing?(textView)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing?(textView)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.textViewDidChangeSelection?(textView)
    }
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange?(textView)
        _updateContentSizeForTextChanged(true)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        return delegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange) ?? true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return delegate?.textView?(textView, shouldInteractWith: URL, in: characterRange) ?? true
    }
    
    // MARK: - SAInputItemDelegate(Forwarding)
    
    func barItem(shouldHighlight barItem: SAInputItem) -> Bool {
        return delegate?.barItem(shouldHighlight: barItem) ?? true
    }
    func barItem(shouldDeselect barItem: SAInputItem) -> Bool {
        return delegate?.barItem(shouldDeselect: barItem) ?? false
    }
    func barItem(shouldSelect barItem: SAInputItem) -> Bool {
        return delegate?.barItem(shouldSelect: barItem) ?? false
    }
    
    func barItem(didHighlight barItem: SAInputItem) {
        delegate?.barItem(didHighlight: barItem)
    }
    func barItem(didDeselect barItem: SAInputItem) {
        _selectedBarItems.remove(barItem)
        
        delegate?.barItem(didDeselect: barItem)
    }
    func barItem(didSelect barItem: SAInputItem) {
        _selectedBarItems.insert(barItem)
        
        delegate?.barItem(didSelect: barItem)
    }
    
    
    // MARK: - Private Method
    
    private func _barItems(atPosition position: SAInputItemPosition) -> [SAInputItem] {
        return _barItems[position.rawValue] ?? []
    }
    private func _setBarItems(_ barItems: [SAInputItem], atPosition position: SAInputItemPosition) {
        if position == .center {
            _centerBarItem = barItems.first ?? _textField.item
            _barItems[position.rawValue] = [_centerBarItem]
        } else {
            _barItems[position.rawValue] = barItems
        }
    }
    
    private func _barItem(atIndexPath indexPath: IndexPath) -> SAInputItem {
        if let items = _barItems[(indexPath as NSIndexPath).section], (indexPath as NSIndexPath).item < items.count {
            return items[(indexPath as NSIndexPath).item]
        }
        fatalError("barItem not found at \(indexPath)")
    }
    private func _barItemAlginment(at indexPath: IndexPath) -> SAInputItemAlignment {
        let item = _barItem(atIndexPath: indexPath)
        if item.alignment == .automatic {
            // in automatic mode, the section will have different performance
            switch (indexPath as NSIndexPath).section {
            case 0:  return .bottom
            case 1:  return .bottom
            case 2:  return .bottom
            default: return .center
            }
        }
        return item.alignment
    }
    
    private func _boundsDidChange() {
        _logger.trace()
        
        _textField.item.invalidateCache()
        _updateBarItemsLayout(false)
    }
    private func _contentDidChange() {
        _logger.trace()
        
        let center = NotificationCenter.default
        center.post(name: Notification.Name(rawValue: SAInputAccessoryDidChangeFrameNotification), object: nil)
    }
    
    private func _updateContentInsetsIfNeeded() {
        let contentInsets = _contentInsetsWithoutCache
        guard contentInsets != _cacheContentInsets else {
            return
        }
        _logger.trace(contentInsets)
        
        // update the constraints
        _textFieldTop.constant = contentInsets.top
        _textFieldLeft.constant = contentInsets.left
        _textFieldRight.constant = contentInsets.right
        _textFieldBottom.constant = contentInsets.bottom
        
        _cacheContentInsets = contentInsets
    }
    private func _updateContentSizeIfNeeded() {
        let contentSize = _contentSizeWithoutCache
        guard _cacheContentSize != contentSize else {
            return
        }
        _logger.trace()
        
        invalidateIntrinsicContentSize()
        _cacheContentSize = contentSize
        _contentDidChange()
    }
    private func _updateContentSizeForTextChanged(_ animated: Bool) {
        guard _textField.item.needsUpdateContent else {
            return
        }
        _logger.trace(_textField.contentSize)
        
        if animated {
            UIView.beginAnimations("SAIB-ANI-AC", context: nil)
            UIView.setAnimationDuration(_SAInputDefaultAnimateDuration)
            UIView.setAnimationCurve(_SAInputDefaultAnimateCurve)
        }
        
        _updateContentSizeInCollectionView()
        _updateContentSizeIfNeeded()
        
        // reset the offset, because offset in the text before the update has been made changes
        _textField.setContentOffset(CGPoint.zero, animated: true)
        
        if animated {
            UIView.commitAnimations()
        }
    }
    private func _updateContentSizeInCollectionView() {
        _logger.trace()
        _collectionView.reloadSections(IndexSet(integer: _SAInputAccessoryViewCenterSection))
    }
    
    private func _updateBarItemsInCollectionView() {
        _logger.trace()
        
        // add, remove, update
        (0 ..< numberOfSections(in: _collectionView)).forEach { section in
            
            let newItems = _barItems[section] ?? []
            let oldItems = _cacheBarItems[section] ?? []
            
            var addIdxs: Set<Int> = []
            var removeIdxs: Set<Int> = []
            var reloadIdxs: Set<Int> = []
            
            _diff(oldItems, newItems).forEach { 
                if $0.0 < 0 {
                    _logger.debug("-(\($0.1), \($0.2))")
                    
                    let idx = max($0.1, 0)
                    removeIdxs.insert(idx)
                }
                if $0.0 > 0 {
                    let idx = max($0.1, 0)
                    _logger.debug("+(\($0.1), \($0.2))")
                    if removeIdxs.contains(idx) {
                        _logger.debug("@(\($0.1), \($0.2))")
                        removeIdxs.remove(idx)
                        reloadIdxs.insert(idx)
                    } else {
                        addIdxs.insert($0.1 + addIdxs.count - removeIdxs.count + 1)
                    }
                }
            }
            
            _collectionView.reloadItems(at: reloadIdxs.map({ 
                IndexPath(item: $0, section: section)
            }))
            _collectionView.insertItems(at: addIdxs.map({ 
                IndexPath(item: $0, section: section)
            }))
            _collectionView.deleteItems(at: removeIdxs.map({ 
                IndexPath(item: $0, section: section)
            }))
            
            _cacheBarItems[section] = newItems
        }
    }
    private func _updateBarItemsLayout(_ animated: Bool) {
        _logger.trace()
        
        if animated {
            UIView.beginAnimations("SAIB-ANI-AC", context: nil)
            UIView.setAnimationDuration(_SAInputDefaultAnimateDuration)
            UIView.setAnimationCurve(_SAInputDefaultAnimateCurve)
        }
        
        // step 0: update the boundary
        _updateContentInsetsIfNeeded() 
        // step 1: update textField the size
        _textField.layoutIfNeeded() 
        // step 2: update cell
        _updateBarItemsIfNeeded(animated) 
        // step 3: update contentSize
        _updateContentSizeIfNeeded() 
        // step 4: update other
        if _centerBarItem != _textField.item {
            _textField.alpha = 0
            _textField.backgroundView.alpha = 0
        } else {
            _textField.alpha = 1
            _textField.backgroundView.alpha = 1
        }
        
        if animated {
            UIView.commitAnimations()
        }
    }
    private func _updateBarItemsIfNeeded(_ animated: Bool) {
        guard !_collectionView.indexPathsForVisibleItems.isEmpty else {
            // initialization is not complete
            _cacheBarItems = _barItems
            return
        }
        _collectionView.performBatchUpdates(_updateBarItemsInCollectionView, completion: nil)
    }
    
    private func _init() {
        _logger.trace()
        
        // configuration
        _textField.translatesAutoresizingMaskIntoConstraints = false
        _textField.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.setContentHuggingPriority(700, for: .horizontal)
        _collectionView.setContentHuggingPriority(700, for: .vertical)
        _collectionView.setContentCompressionResistancePriority(200, for: .horizontal)
        _collectionView.setContentCompressionResistancePriority(200, for: .vertical)
        
        // update center bar item
        _setBarItems([], atPosition: .center)
        
        // adds a child view
        addSubview(_collectionView)
        addSubview(_textField.backgroundView)
        addSubview(_textField)
        
        // adding constraints
        addConstraints([
            _SAInputLayoutConstraintMake(_collectionView, .top, .equal, self, .top),
            _SAInputLayoutConstraintMake(_collectionView, .left, .equal, self, .left),
            _SAInputLayoutConstraintMake(_collectionView, .right, .equal, self, .right),
            _SAInputLayoutConstraintMake(_collectionView, .bottom, .equal, self, .bottom),
            
            _SAInputLayoutConstraintMake(_textField.backgroundView, .top, .equal, _textField, .top),
            _SAInputLayoutConstraintMake(_textField.backgroundView, .left, .equal, _textField, .left),
            _SAInputLayoutConstraintMake(_textField.backgroundView, .right, .equal, _textField, .right),
            _SAInputLayoutConstraintMake(_textField.backgroundView, .bottom, .equal, _textField, .bottom),
            
            _textFieldTop,
            _textFieldLeft,
            _textFieldRight,
            _textFieldBottom,
        ])
        
        // init collection view
        (0 ..< numberOfSections(in: _collectionView)).forEach {
            _collectionView.register(SAInputItemView.self, forCellWithReuseIdentifier: "Cell-\($0)")
        }
    }
    private func _deinit() {
        _logger.trace()
    }
    
    // MARK: - 
    
    private var _contentSizeWithoutCache: CGSize {
        _logger.trace()
        
        let centerBarItemSize = _centerBarItem.size
        let height = _textFieldTop.constant + centerBarItemSize.height + _textFieldBottom.constant
        return CGSize(width: frame.width, height: height)
    }
    private var _contentInsetsWithoutCache: UIEdgeInsets {
        _logger.trace()
        
        var contentInsets = _collectionViewLayout.contentInsets
        // merge the top
        let topSize = _collectionViewLayout.sizeThatFits(bounds.size, atPosition: .top)
        if topSize.height != 0 {
            contentInsets.top += topSize.height + _collectionViewLayout.minimumLineSpacing
        }
        // merge the left
        let leftSize = _collectionViewLayout.sizeThatFits(bounds.size, atPosition: .left)
        if leftSize.width != 0 {
            contentInsets.left += leftSize.width + _collectionViewLayout.minimumInteritemSpacing
        }
        // merge the right
        let rightSize = _collectionViewLayout.sizeThatFits(bounds.size, atPosition: .right)
        if rightSize.width != 0 {
            contentInsets.right += rightSize.width + _collectionViewLayout.minimumInteritemSpacing
        }
        // merge the bottom
        let bottomSize = _collectionViewLayout.sizeThatFits(bounds.size, atPosition: .bottom)
        if bottomSize.height != 0 {
            contentInsets.bottom += bottomSize.height + _collectionViewLayout.minimumLineSpacing
        }
        return contentInsets
    }
    
    
    //  MARK: -
    
    private lazy var _centerBarItem: SAInputItem = self.textField.item
    
    private lazy var _barItems: [Int: [SAInputItem]] = [:]
    private lazy var _cacheBarItems: [Int: [SAInputItem]] = [:]
    private lazy var _selectedBarItems: Set<SAInputItem> = []
    
    private lazy var _textField: SAInputTextField = {
        let view = SAInputTextField()
        
        view.font = UIFont.systemFont(ofSize: 15)
        view.scrollsToTop = false
        view.returnKeyType = .send
        view.backgroundColor = UIColor.clear
        //view.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        view.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0)
        //view.enablesReturnKeyAutomatically = true
        view.delegate = self
        
        return view
    }()
    
    private lazy var _collectionViewLayout: SAInputAccessoryViewLayout = {
        let layout = SAInputAccessoryViewLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        return layout
    }()
    private lazy var _collectionView: UICollectionView = {
        let layout = self._collectionViewLayout
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor.clear
        //view.backgroundColor = UIColor.purpleColor().colorWithAlphaComponent(0.2)
        view.bounces = false
        view.scrollsToTop = false
        view.isScrollEnabled = false
        view.allowsSelection = false
        view.isMultipleTouchEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delaysContentTouches = false
        view.canCancelContentTouches = false
        
        return view
    }()
   
    private lazy var _textFieldTop: NSLayoutConstraint = {
        return _SAInputLayoutConstraintMake(self._textField, .top, .equal, self, .top)
    }()
    private lazy var _textFieldLeft: NSLayoutConstraint = {
        return _SAInputLayoutConstraintMake(self._textField, .left, .equal, self, .left)
    }()
    private lazy var _textFieldRight: NSLayoutConstraint = {
        return _SAInputLayoutConstraintMake(self, .right, .equal, self._textField, .right)
    }()
    private lazy var _textFieldBottom: NSLayoutConstraint = {
        return _SAInputLayoutConstraintMake(self, .bottom, .equal, self._textField, .bottom)
    }()
    
    private var _cacheBounds: CGRect?
    private var _cacheContentSize: CGSize?
    private var _cacheContentInsets: UIEdgeInsets?
    
    private var _cacheBarItemContainer: UICollectionViewCell?
    
    // MARK: - 
    
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

///
/// 比较数组差异
/// (+1, src.index, dest.index) // add
/// ( 0, src.index, dest.index) // equal
/// (-1, src.index, dest.index) // remove
///
private func _diff<T: Equatable>(_ src: Array<T>, _ dest: Array<T>) -> Array<(Int, Int, Int)> {
    
    let len1 = src.count
    let len2 = dest.count
    
    var c = [[Int]](repeating: [Int](repeating: 0, count: len2 + 1), count: len1 + 1)
    
    // lcs + 动态规划
    for i in 1 ..< len1 + 1 { 
        for j in 1 ..< len2 + 1 {
            if src[i - 1] == dest[j - 1] {
                c[i][j] = c[i - 1][j - 1] + 1
            } else {
                c[i][j] = max(c[i - 1][j], c[i][j - 1])
            }
        }
    }
    
    var r = [(Int, Int, Int)]()
    var i = len1
    var j = len2
    
    // create the optimal path
    repeat {
        guard i != 0 else {
            // the remaining is add
            while j > 0 {
                r.append((+1, i - 1, j - 1))
                j -= 1
            }
            break
        }
        guard j != 0 else {
            // the remaining is remove
            while i > 0 {
                r.append((-1, i - 1, j - 1))
                i -= 1
            }
            break
        }
        guard src[i - 1] != dest[j - 1]  else {
            // no change
            r.append((0, i - 1, j - 1))
            i -= 1
            j -= 1
            continue
        }
        // check the weight
        if c[i - 1][j] > c[i][j - 1] {
            // is remove
            r.append((-1, i - 1, j - 1))
            i -= 1
        } else {
            // is add
            r.append((+1, i - 1, j - 1))
            j -= 1
        }
    } while i > 0 || j > 0
    
    return r.reversed()
}

private let _SAInputAccessoryViewCenterSection = SAInputItemPosition.center.rawValue

public let SAInputAccessoryDidChangeFrameNotification = "SAInputAccessoryDidChangeFrameNotification"

