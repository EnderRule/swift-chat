//
//  SAEmotionPanel.swift
//  SIMChat
//
//  Created by sagesse on 9/6/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import CoreGraphics

// [ ] * - Version 2, 参考系统Emoji键盘
// [ ] * - 横屏支持
// [x] SAEmotionPanel - 小表情支持
// [x] SAEmotionPanel - 大表情支持
// [x] SAEmotionPanel - 自定义大小/间距/缩进
// [ ] SAEmotionPanel - 动态图片支持
// [x] SAEmotionPanel - Tabbar支持
// [x] SAEmotionPanel - 更新page
// [ ] SAEmotionPanel - 长按删除
// [ ] SAEmotionPanel - 发送/设置按钮
// [ ] SAEmotion - UIView支持
// [x] SAEmotion - UIImage支持
// [x] SAEmotion - NSString/NSAttributedString支持
// [x] SAEmotionPage - Add支持
// [ ] SAEmotionPage - Remove支持 - 暂无意义, 除非允许编辑表情位置
// [x] SAEmotionPage - 删除按钮
// [x] SAEmotionPage - 异步绘制
// [x] SAEmotionTabItemView - 选中
// [x] SAEmotionTabItemView - 选中高亮
// [x] SAEmotionPageView - 选中
// [ ] SAEmotionPageView - 选中高亮
// [x] SAEmotionPageView - 长按预览
// [ ] SAEmotionPageView - 横屏支持
// [ ] SAEmotionPageView - 长按删除

@objc open class SAEmotion: NSObject {
    
    /// 退格
    open static let backspace: SAEmotion = {
        let em = SAEmotion()
        em.contents = "⌫"
        return em
    }()
    
    open func draw(in rect: CGRect, in ctx: CGContext) {
        
        //ctx.setFillColor(UIColor.red.withAlphaComponent(0.2).cgColor)
        //ctx.fill(rect)
        
        switch contents {
        case let image as UIImage:
            var nrect = rect
            nrect.size = image.size
            nrect.origin.x = rect.minX + (rect.width - nrect.width) / 2
            nrect.origin.y = rect.minY + (rect.height - nrect.height) / 2
            image.draw(in: nrect)
            
        case let str as NSString:
            let cfg = [NSFontAttributeName: UIFont.systemFont(ofSize: 32)]
            let size = str.size(attributes: cfg)
            let nrect = CGRect(x: rect.minX + (rect.width - size.width + 3) / 2,
                              y: rect.minY + (rect.height - size.height) / 2,
                              width: size.width,
                              height: size.height)
            str.draw(in: nrect, withAttributes: cfg)
            
        case let str as NSAttributedString:
            str.draw(in: rect)
            
        default: 
            break
        }
    }
    
    open func show(in view: UIView) {
        let imageView = view.subviews.first as? UIImageView ?? {
            let imageView = UIImageView()
            view.subviews.forEach{
                $0.removeFromSuperview()
            }
            view.addSubview(imageView)
            return imageView
        }()
        
        if let image = contents as? UIImage {
            imageView.bounds = CGRect(origin: .zero, size: image.size)
            imageView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
            //imageView.frame =  UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetsMake(8, 8, 8, 8))
            imageView.image = contents as? UIImage
        }
    }
    
    // 目前只支持UIImage/NSString/NSAttributedString
    open var contents: Any?
}
@objc open class SAEmotionGroup: NSObject {
    
    open lazy var id: String = UUID().uuidString
    
    open var row: Int = 3
    open var column: Int = 7
    
    open var title: String?
    open var thumbnail: UIImage?
    
    open var type: SAEmotionType = .small
    open var emotions: [SAEmotion] = []
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        guard _size?.width != size.width else {
            return _size ?? .zero
        }
        let edg = _contentInset
        
        let width = size.width - edg.left - edg.right
        let height = size.height - edg.top - edg.bottom
        
        let row = CGFloat(self.row)
        let col = CGFloat(self.column)
        
        let tmp = CGSize(width: (width - 8 * col) / col, height: (height - 8 * row) / row)
        
        _size = tmp
        _minimumLineSpacing = (height / row) - tmp.height
        _minimumInteritemSpacing = (width / col) - tmp.width
        
        return tmp
    }
    
    fileprivate var _size: CGSize?
    fileprivate var _contentInset: UIEdgeInsets = UIEdgeInsetsMake(12, 10, 42, 10)
    fileprivate var _minimumLineSpacing: CGFloat = 0
    fileprivate var _minimumInteritemSpacing: CGFloat = 0
}

@objc public enum SAEmotionType: Int {
    
    case small = 0
    case large = 1
    
    public var isSmall: Bool { return self == .small }
    public var isLarge: Bool { return self == .large }
}

@objc public protocol SAEmotionPanelDataSource: NSObjectProtocol {
    
    func numberOfGroups(in emotion: SAEmotionPanel) -> Int
    func emotion(_ emotion: SAEmotionPanel, groupAt index: Int) -> SAEmotionGroup
}
@objc public protocol SAEmotionPanelDelegate: NSObjectProtocol {
    
    @objc optional func emotion(_ emotion: SAEmotionPanel, shouldSelectFor item: SAEmotion) -> Bool
    @objc optional func emotion(_ emotion: SAEmotionPanel, didSelectFor item: SAEmotion)
    
    @objc optional func emotion(_ emotion: SAEmotionPanel, shouldPreviewFor item: SAEmotion?) -> Bool
    @objc optional func emotion(_ emotion: SAEmotionPanel, didPreviewFor item: SAEmotion?)
    
}

@objc public class SAEmotionPanel: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SAEmotionDelegate {
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: 253)
    }
   
    public weak var dataSource: SAEmotionPanelDataSource?
    public weak var delegate: SAEmotionPanelDelegate?
    
    public var contentView: UICollectionView {
        return _contentView
    }
    
    // MARK: SAEmotionDelegate(Forwarding)
    
    public func emotion(shouldSelectFor emotion: SAEmotion) -> Bool {
        return delegate?.emotion?(self, shouldSelectFor: emotion) ?? true
    }
    public func emotion(shouldPreviewFor emotion: SAEmotion?) -> Bool {
        return delegate?.emotion?(self, shouldPreviewFor: emotion) ?? true
    }
    
    public func emotion(didSelectFor emotion: SAEmotion) {
        delegate?.emotion?(self, didSelectFor: emotion) 
    }
    public func emotion(didPreviewFor emotion: SAEmotion?) {
        delegate?.emotion?(self, didPreviewFor: emotion) 
    }
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView === _tabbar {
            return
        }
        if scrollView === _contentView {
            guard let idx = _contentView.indexPathForItem(at: targetContentOffset.move()) else {
                return
            }
            _updatePageNumber(at: idx)
        }
    }
    
    // MARK: UICollectionViewDataSource & UICollectionViewDelegate
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView === _tabbar {
            return 1
        }
        if collectionView === _contentView {
            return dataSource?.numberOfGroups(in: self) ?? 0
        }
        return 0
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === _tabbar {
            return dataSource?.numberOfGroups(in: self) ?? 0
        }
        if collectionView === _contentView {
            guard let ds = dataSource else {
                return 0
            }
            let pageCount = _contentViewLayout.numberOfPages(in: section) {
                ds.emotion(self, groupAt: section)
            }
            if !_contentViewIsInit {
                _contentViewIsInit = true
                _updatePageNumber(at: IndexPath(item: 0, section: 0))
            }
            return pageCount
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Page", for: indexPath)
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SAEmotionPageView {
            cell.page = _contentViewLayout.page(at: indexPath)
            cell.delegate = self
            cell.previewer = _previewer
            return
        } 
        if let cell = cell as? SAEmotionTabItemView {
            cell.group = dataSource?.emotion(self, groupAt: indexPath.item)
            cell.selectedBackgroundView?.backgroundColor = _color
            return
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === _tabbar {
            let nidx = IndexPath(item: 0, section: indexPath.item)
            guard _contentView.indexPathsForVisibleItems.first?.section != nidx.section else {
                return // no change
            }
            _contentView.scrollToItem(at: nidx, at: .left, animated: false)
            _updatePageNumber(at: nidx)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === _tabbar {
            return CGSize(width: 45, height: collectionView.frame.height)
        }
        if collectionView === _contentView {
            return collectionView.frame.size
        }
        return .zero
    }
    
    private func _updatePageNumber(at indexPath: IndexPath) {
        
        _pageControl.numberOfPages = _contentView.numberOfItems(inSection: indexPath.section)
        _pageControl.currentPage = indexPath.item
        
        let nidx = IndexPath(item: indexPath.section, section: 0)
        guard _tabbar.indexPathsForSelectedItems?.first?.item != nidx.item else {
            return
        }
        _tabbar.selectItem(at: nidx, animated: true, scrollPosition: .centeredHorizontally)
    }
    private func _init() {
        _logger.trace()
        
        _color = UIColor(colorLiteralRed: 0xec / 0xff, green: 0xed / 0xff, blue: 0xf1 / 0xff, alpha: 1)
        
        _pageControl.numberOfPages = 8
        _pageControl.hidesForSinglePage = true
        _pageControl.pageIndicatorTintColor = UIColor.gray
        _pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        _pageControl.translatesAutoresizingMaskIntoConstraints = false
        _pageControl.backgroundColor = .clear
        _pageControl.isUserInteractionEnabled = false
        //_pageControl.addTarget(self, action: #selector(onPageChanged(_:)), for: .valueChanged)
        
        _contentViewLayout.scrollDirection = .horizontal
        _contentViewLayout.minimumLineSpacing = 0
        _contentViewLayout.minimumInteritemSpacing = 0
        
        _contentView.delegate = self
        _contentView.dataSource = self
        _contentView.scrollsToTop = false
        _contentView.isPagingEnabled = true
        _contentView.delaysContentTouches = false
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.register(SAEmotionPageView.self, forCellWithReuseIdentifier: "Page")
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.backgroundColor = .clear
        
        _previewer.isHidden = true
        _previewer.isUserInteractionEnabled = false
        
        _tabbarLayout.scrollDirection = .horizontal
        _tabbarLayout.minimumLineSpacing = 0
        _tabbarLayout.minimumInteritemSpacing = 0
        
        _tabbar.register(SAEmotionTabItemView.self, forCellWithReuseIdentifier: "Page")
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        _tabbar.dataSource = self
        _tabbar.backgroundColor = .white
        _tabbar.contentInset = UIEdgeInsetsMake(0, 0, 0, 45)
        _tabbar.delegate = self
        _tabbar.scrollsToTop = false
        _tabbar.showsVerticalScrollIndicator = false
        _tabbar.showsHorizontalScrollIndicator = false
        //_tabbar.alwaysBounceHorizontal = true
        
        backgroundColor = _color
        
        addSubview(_contentView)
        addSubview(_tabbar)
        addSubview(_pageControl)
        addSubview(_previewer)
        
        addConstraints([
            
            _SALayoutConstraintMake(_contentView, .top, .equal, self, .top),
            _SALayoutConstraintMake(_contentView, .left, .equal, self, .left),
            _SALayoutConstraintMake(_contentView, .right, .equal, self, .right),
            
            _SALayoutConstraintMake(_pageControl, .left, .equal, self, .left),
            _SALayoutConstraintMake(_pageControl, .right, .equal, self, .right),
            _SALayoutConstraintMake(_pageControl, .bottom, .equal, _contentView, .bottom, -10),
            
            _SALayoutConstraintMake(_tabbar, .top, .equal, _contentView, .bottom),
            _SALayoutConstraintMake(_tabbar, .left, .equal, self, .left),
            _SALayoutConstraintMake(_tabbar, .right, .equal, self, .right),
            _SALayoutConstraintMake(_tabbar, .bottom, .equal, self, .bottom),
            
            _SALayoutConstraintMake(_tabbar, .height, .equal, nil, .notAnAttribute, 37),
            _SALayoutConstraintMake(_pageControl, .height, .equal, nil, .notAnAttribute, 20)
        ])
    }
    
    private var _color: UIColor?
    private var _contentViewIsInit: Bool = false
    
    private lazy var _pageControl: UIPageControl = UIPageControl()
    private lazy var _previewer: SAEmotionPreviewer = SAEmotionPreviewer()
    private lazy var _tabbar: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._tabbarLayout)
    private lazy var _tabbarLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    private lazy var _contentViewLayout: SAEmotionPanelLayout = SAEmotionPanelLayout()
    private lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

internal class SAEmotionPanelLayout: UICollectionViewFlowLayout {
    
    func page(at indexPath: IndexPath) -> SAEmotionPage {
        return _allPages[indexPath.section]![indexPath.row]
    }
    func pages(in section: Int, fetch: (Void) -> SAEmotionGroup) -> [SAEmotionPage] {
        if let pages = _allPages[section] {
            return pages
        }
        let pages = _makePages(in: section, with: fetch())
        _allPages[section] = pages
        return pages
    }
    
    func numberOfPages(in section: Int, fetch: (Void) -> SAEmotionGroup) -> Int {
        if let count = _allPages[section]?.count {
            return count
        }
        return pages(in: section, fetch: fetch).count
    }
    
    func _makePages(in section: Int, with group: SAEmotionGroup) -> [SAEmotionPage] {
        
        let itemType = group.type
        let itemSize = group.sizeThatFits(collectionView?.frame.size ?? .zero)
        
        let nlsp = group._minimumLineSpacing
        let nisp = group._minimumInteritemSpacing
        let inset = group._contentInset
        
        let bounds = collectionView?.bounds ?? .zero
        let rect = UIEdgeInsetsInsetRect(bounds, inset)
        
        return group.emotions.reduce([]) { 
            if let page = $0.last, page.addEmotion($1) {
                return $0
            }
            return $0 + [SAEmotionPage($1, itemSize, rect, bounds, nlsp, nisp, itemType)]
        }
    }
    
    lazy var _allPages: [Int: [SAEmotionPage]] = [:]
}

internal class SAEmotionLine {
    
    func draw(in ctx: CGContext) {
        _ = emotions.reduce(CGRect(origin: vaildRect.origin, size: itemSize)) { 
            $1.draw(in: $0, in: ctx)
            return $0.offsetBy(dx: $0.width + minimumInteritemSpacing, dy: 0)
        }
    }
    func rect(at index: Int) -> CGRect? {
        guard index < emotions.count else {
            return nil
        }
        let isp = minimumInteritemSpacing
        let nwidth = (itemSize.width + isp) * CGFloat(index)
        return CGRect(origin: CGPoint(x: vaildRect.minX + nwidth, y: vaildRect.minY), size: itemSize)
    }
    
    func addEmotion(_ emotion: SAEmotion) -> Bool {
        let isp = minimumInteritemSpacing
        let nwidth = visableSize.width + isp + itemSize.width
        let nwidthWithDelete = visableSize.width + (isp + itemSize.width) * 2
        let nheight = max(visableSize.height, itemSize.height)
        
        if floor(vaildRect.minX + nwidth) > floor(vaildRect.maxX) {
            return false
        }
        if itemType.isSmall && isLastLine && floor(vaildRect.minX + nwidthWithDelete) > floor(vaildRect.maxX) {
            return false
        }
        if floor(vaildRect.minY + nheight) > floor(vaildRect.maxY) {
            return false
        }
        if visableSize.height != nheight {
            _isLastLine = nil
        }
        
        visableSize.width = nwidth
        visableSize.height = nheight
        
        emotions.append(emotion)
        return true
    }
    
    var itemSize: CGSize
    
    var vaildRect: CGRect
    var visableSize: CGSize
    
    var itemType: SAEmotionType
    var isLastLine: Bool {
        if let isLastLine = _isLastLine {
            return isLastLine
        }
        let isLastLine = floor(vaildRect.minY + visableSize.height + minimumLineSpacing + itemSize.height) > floor(vaildRect.maxY)
        _isLastLine = isLastLine
        return isLastLine
    }
    
    var minimumLineSpacing: CGFloat
    var minimumInteritemSpacing: CGFloat
    
    var emotions: [SAEmotion] 
    
    var _isLastLine: Bool?
    
    init(_ first: SAEmotion, 
         _ itemSize: CGSize,
         _ rect: CGRect, 
         _ lineSpacing: CGFloat,
         _ interitemSpacing: CGFloat,
         _ itemType: SAEmotionType) {
        
        self.itemSize = itemSize
        self.itemType = itemType
        
        self.vaildRect = rect
        self.visableSize = itemSize
        
        minimumLineSpacing = lineSpacing
        minimumInteritemSpacing = interitemSpacing
        
        emotions = [first]
    }
}
internal class SAEmotionPage {
    
    func draw(in ctx: CGContext) {
        
        //ctx.setFillColor(UIColor.orange.withAlphaComponent(0.1).cgColor)
        //ctx.fill(bounds)
        //ctx.fill(visableRect)
        //ctx.fill(vaildRect)
        
        lines.forEach { 
            $0.draw(in: ctx)
        }
    }
    func contents(fetch: @escaping ((Any?) -> (Void))) {
        if let contents = _contents {
            fetch(contents.cgImage)
            return
        }
        SAEmotionPage.queue.async {
            
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
            
            if let ctx = UIGraphicsGetCurrentContext() {
                self.draw(in: ctx)
            }
            let img = UIGraphicsGetImageFromCurrentImageContext()
            self._contents = img
            
            UIGraphicsEndImageContext()
            
            fetch(img?.cgImage)
        }
    }
    
    func addEmotion(_ emotion: SAEmotion) -> Bool {
        guard let lastLine = lines.last else {
            return false
        }
        if lastLine.addEmotion(emotion) {
            visableSize.width = max(visableSize.width, lastLine.visableSize.width)
            visableSize.height = lastLine.vaildRect.minY - vaildRect.minY + lastLine.visableSize.height
            return true
        }
        let rect = UIEdgeInsetsInsetRect(vaildRect, UIEdgeInsetsMake(visableSize.height + minimumLineSpacing, 0, 0, 0))
        let line = SAEmotionLine(emotion, itemSize, rect, minimumLineSpacing, minimumInteritemSpacing, itemType)
        if floor(line.vaildRect.minY + line.visableSize.height) > floor(vaildRect.maxY) {
            return false
        }
        lines.append(line)
        return true
    }
    
    func emotion(at indexPath: IndexPath) -> SAEmotion? {
        guard indexPath.section < lines.count else {
            return nil
        }
        let line = lines[indexPath.section]
        guard indexPath.item < line.emotions.count else {
            return nil
        }
        return line.emotions[indexPath.item]
    }
    func rect(at indexPath: IndexPath) -> CGRect? {
        guard indexPath.section < lines.count else {
            return nil
        }
        return lines[indexPath.section].rect(at: indexPath.item)
    }
    
    var bounds: CGRect
    
    var vaildRect: CGRect
    var visableSize: CGSize
    var visableRect: CGRect
    
    var itemSize: CGSize
    var itemType: SAEmotionType
    
    var minimumLineSpacing: CGFloat
    var minimumInteritemSpacing: CGFloat
    
    var lines: [SAEmotionLine]
    
    private var _contents: UIImage?
    
    init(_ first: SAEmotion,
         _ itemSize: CGSize,
         _ rect: CGRect,
         _ bounds: CGRect,
         _ lineSpacing: CGFloat,
         _ interitemSpacing: CGFloat,
         _ itemType: SAEmotionType) {
        
        let nlsp = lineSpacing / 2
        let nisp = interitemSpacing / 2
        
        let nrect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(nlsp, nisp, nlsp, nisp))
        let line = SAEmotionLine(first, itemSize, nrect, lineSpacing, interitemSpacing, itemType)
        
        self.bounds = bounds
        self.itemSize = itemSize
        self.itemType = itemType
        
        self.vaildRect = nrect
        self.visableSize = line.visableSize
        self.visableRect = rect
        
        self.minimumLineSpacing = lineSpacing
        self.minimumInteritemSpacing = interitemSpacing
        
        self.lines = [line]
    }
    
    static var queue = DispatchQueue(label: "sa.emotion.background")
}
internal class SAEmotionPageView: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    weak var delegate: SAEmotionDelegate?
    weak var previewer: SAEmotionPreviewer?
    
    func setupBackspace() {
        _backspaceButton.isHidden = !(page?.itemType.isSmall ?? true)
        guard let page = self.page else {
            return
        }
        var nframe = CGRect(origin: .zero, size: page.itemSize)
        
        nframe.origin.x = page.vaildRect.maxX - nframe.width
        nframe.origin.y = page.vaildRect.maxY - nframe.height
        
        _backspaceButton.frame = nframe
        _backspaceButton.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        
        if _backspaceButton.superview == nil {
            addSubview(_backspaceButton)
        }
    }
    
    var page: SAEmotionPage? {
        didSet {
            let newValue = self.page
            guard newValue !== oldValue else {
                return
            }
            newValue?.contents { contents in
                guard self.page === newValue else {
                    return
                }
                let block = { () -> Void in
                    self.contentView.layer.contents = contents
                    self.setupBackspace()
                }
                
                guard !Thread.current.isMainThread else {
                    block()
                    return
                }
                DispatchQueue.main.async(execute: block)
            }
        }
    }
    
    func onPress(_ sender: UITapGestureRecognizer) {
        guard let idx = _index(at: sender.location(in: self)) else {
            
            return // no index
        }
        guard let emotion = page?.emotion(at: idx) else {
            return // outside
        }
        
        if delegate?.emotion(shouldSelectFor: emotion) ?? true {
            delegate?.emotion(didSelectFor: emotion)
        }
    }
    func onLongPress(_ sender: UITapGestureRecognizer) {
        guard let page = page else {
            return
        }
        
        var idx: IndexPath?
        var rect: CGRect?
        var emotion: SAEmotion?
        
        let isbegin = sender.state == .began || sender.state == .possible
        let isend = sender.state == .cancelled || sender.state == .failed || sender.state == .ended
        
        if isend {
            if let idx = _activedIndexPath, let emotion = page.emotion(at: idx) {
                //_logger.debug("\(emotion) is selected")
                if delegate?.emotion(shouldSelectFor: emotion) ?? true {
                    delegate?.emotion(didSelectFor: emotion)
                }
            }
            idx = nil
        } else {
            idx = _index(at: sender.location(in: self))
        }
        
        if let idx = idx {
            rect = page.rect(at: idx)
            emotion = page.emotion(at: idx)
        }
        // 并没有找到任何可用的表情
        if emotion == nil {
            idx = nil
        }
        // 检查没有改变
        guard _activedIndexPath != idx else {
            return
        }
        
        var canpreview = !isbegin && !isend
        
        if canpreview && !(delegate?.emotion(shouldPreviewFor: emotion) ?? true) {
            canpreview = false
            emotion = nil
            idx = nil
        }
        
        _activedIndexPath = idx
        previewer?.preview(emotion, page.itemType, in: rect ?? .zero)
        
        if isbegin || canpreview {
            delegate?.emotion(didPreviewFor: emotion)
        }
    }
    func onBackspace(_ sender: UIButton) {
        //_logger.trace()
        
        if delegate?.emotion(shouldSelectFor: SAEmotion.backspace) ?? true {
            delegate?.emotion(didSelectFor: SAEmotion.backspace)
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let idx = _index(at: gestureRecognizer.location(in: self)), let emotion = page?.emotion(at: idx) {
            return delegate?.emotion(shouldPreviewFor: emotion) ?? true
        }
        return false
    }
    
    
    private func _index(at point: CGPoint) -> IndexPath? {
        guard let page = page else {
            return nil
        }
        let rect = page.visableRect
        guard rect.contains(point) else {
            return nil
        }
        let x = point.x - rect.minX
        let y = point.y - rect.minY
        
        let col = Int(x / (page.itemSize.width + page.minimumInteritemSpacing))
        let row = Int(y / (page.itemSize.height + page.minimumLineSpacing))
        
        return IndexPath(item: col, section: row)
    }
    
    private func _init() {
        _logger.trace()
        
        _backspaceButton.tintColor = .gray
        _backspaceButton.setImage(_SAEmotionPanelBackspaceImage, for: .normal)
        _backspaceButton.addTarget(self, action: #selector(onBackspace(_:)), for: .touchUpInside)
        //_backspaceButton.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        
        let tapgr = UITapGestureRecognizer(target: self, action: #selector(onPress(_:)))
        let longtapgr = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        
        longtapgr.delegate = self
        longtapgr.minimumPressDuration = 0.25
        
        contentView.addGestureRecognizer(tapgr)
        contentView.addGestureRecognizer(longtapgr)
    }
    
    private var _activedIndexPath: IndexPath?
    
    private lazy var _backspaceButton: UIButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
internal class SAEmotionTabItemView: UICollectionViewCell {
    
    var group: SAEmotionGroup? {
        willSet {
            guard group !== newValue else {
                return
            }
            _imageView.image = newValue?.thumbnail
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        _imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        _line.frame = CGRect(x: bounds.maxX - 0.25, y: 8, width: 0.5, height: bounds.height - 16)
    }
    
    private func _init() {
        _logger.trace()
        
        _line.backgroundColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        
        _imageView.contentMode = .scaleAspectFit
        _imageView.bounds = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        contentView.addSubview(_imageView)
        contentView.layer.addSublayer(_line)
        
        selectedBackgroundView = UIView()
    }
    
    private lazy var _imageView: UIImageView = UIImageView()
    private lazy var _line: CALayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
internal class SAEmotionPreviewer: UIView {
    
    func preview(_ emotion: SAEmotion?, _ itemType: SAEmotionType, in rect: CGRect) {
        guard let emotion = emotion else {
            isHidden = true
            return
        }
        _type = itemType
        _popoverFrame = _popoverFrame(in: rect, and: _backgroundView.bounds(for: itemType))
        _presenterFrame = _presenterFrame(in: rect, and: _popoverFrame)
        
        frame = _popoverFrame
        isHidden = false
        
        _contentView.frame = _backgroundView.boundsOfContent(for: itemType)
        
        _backgroundView.popoverFrame = convert(_popoverFrame, from: superview)
        _backgroundView.presenterFrame = convert(_presenterFrame, from: superview)
        _backgroundView.updateBackgroundImages(with: itemType)
        _backgroundView.updateBackgroundLayouts()
        
        // update
        emotion.show(in: _contentView)
    }
    
    private func _popoverFrame(in frame: CGRect, and bounds: CGRect) -> CGRect {
        var nframe = bounds
        
        nframe.origin.x = frame.midX + bounds.minX - nframe.width / 2 
        nframe.origin.y = frame.minY + bounds.minY - nframe.height
        
        if let window = window, _type.isLarge {
            nframe.origin.x = max(nframe.minX, _inset.left)
            nframe.origin.x = min(nframe.minX, window.frame.maxX - bounds.width - _inset.right)
        }
        
        return nframe
    }
    private func _presenterFrame(in frame: CGRect, and bounds: CGRect) -> CGRect {
        return CGRect(x: frame.minX, 
                      y: frame.minY - bounds.height,
                      width: frame.width,
                      height: frame.height + bounds.height)
    }
    
    private func _init() {
        _logger.trace()
        
        addSubview(_backgroundView)
        addSubview(_contentView)
    }
    
    private var _type: SAEmotionType = .small
    private var _inset: UIEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4)
    private var _popoverFrame: CGRect = .zero
    private var _presenterFrame: CGRect = .zero
    
    private lazy var _contentView: UIView = UIView()
    private lazy var _backgroundView: SAEmotionBackgroundView = SAEmotionBackgroundView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
internal class SAEmotionBackgroundView: UIView {
    
    var popoverFrame: CGRect {
        set { return frame = newValue }
        get { return frame }
    }
    var presenterFrame: CGRect = .zero
    
    func boundsOfContent(for type: SAEmotionType) -> CGRect {
        let rect = bounds(for: type)
        
        switch type {
        case .small: return CGRect(x: 4, y: 4, width: rect.width - 4 * 2, height: rect.width - 4 * 2)
        case .large: return UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(8, 8, 8 + 12, 8))
        }
    }
   
    func bounds(for type: SAEmotionType) -> CGRect {
        var frame = CGRect.zero
        switch type {
        case .small:
            frame.origin.x = 0
            frame.origin.y = 39
            frame.size = _SAEmotionPanelPreviewBackgroundImageForSmall?.size ?? .zero
            
        case .large:
            frame.origin.x = 0
            frame.origin.y = 0
            frame.size.width = 170
            frame.size.height = 170
        }
        return frame
    }
    
    func updateBackgroundImages(with type: SAEmotionType) {
        guard _type != type else {
            return
        }
        //_logger.trace()
        
        switch type {
        case .small:
            _leftView.image = nil
            _rightView.image = nil
            _middleView.image = _SAEmotionPanelPreviewBackgroundImageForSmall
            
        case .large:
            _leftView.image = _SAEmotionPanelPreviewBackgroundImageForLargeOfLeft
            _rightView.image = _SAEmotionPanelPreviewBackgroundImageForLargeOfRight
            _middleView.image = _SAEmotionPanelPreviewBackgroundImageForLargeOfMiddle
        }
        _type = type
    }
    
    func updateBackgroundLayouts() {
        //_logger.trace(presenterFrame)
        
        var ty = CGFloat(0)
        if _type.isSmall {
            ty = (presenterFrame.height - popoverFrame.height - 34) / 2
        }
        
        _middleViewBottom?.constant = ty
        _middleViewCenterX?.constant = presenterFrame.midX
    }
    
    private func _init() {
        _logger.trace()
        
        isUserInteractionEnabled = false
        
        _leftView.translatesAutoresizingMaskIntoConstraints = false
        _rightView.translatesAutoresizingMaskIntoConstraints = false
        _middleView.translatesAutoresizingMaskIntoConstraints = false
        
        _middleView.image = _SAEmotionPanelPreviewBackgroundImageForSmall
        _middleView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        _middleView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        
        addSubview(_leftView)
        addSubview(_rightView)
        addSubview(_middleView)
        
        addConstraints([
            _SALayoutConstraintMake(_leftView, .top, .equal, self, .top),
            _SALayoutConstraintMake(_leftView, .left, .equal, self, .left, priority: 751),
            _SALayoutConstraintMake(_leftView, .right, .equal, _middleView, .left),
            _SALayoutConstraintMake(_leftView, .bottom, .equal, self, .bottom),
            
            _SALayoutConstraintMake(_middleView, .top, .equal, self, .top),
            _SALayoutConstraintMake(_middleView, .centerX, .equal, self, .left, output: &_middleViewCenterX),
            _SALayoutConstraintMake(_middleView, .bottom, .equal, self, .bottom, output: &_middleViewBottom),
            
            _SALayoutConstraintMake(_rightView, .top, .equal, self, .top),
            _SALayoutConstraintMake(_rightView, .left, .equal, _middleView, .right),
            _SALayoutConstraintMake(_rightView, .right, .equal, self, .right, priority: 751),
            _SALayoutConstraintMake(_rightView, .bottom, .equal, self, .bottom),
        ])
    }
    
    private var _type: SAEmotionType = .small
    private var _middleViewBottom: NSLayoutConstraint?
    private var _middleViewCenterX: NSLayoutConstraint?
    
    private lazy var _leftView: UIImageView = UIImageView()
    private lazy var _middleView: UIImageView = UIImageView()
    private lazy var _rightView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

internal protocol SAEmotionDelegate: class {
    
    func emotion(shouldSelectFor emotion: SAEmotion) -> Bool
    func emotion(didSelectFor emotion: SAEmotion)
    
    func emotion(shouldPreviewFor emotion: SAEmotion?) -> Bool
    func emotion(didPreviewFor emotion: SAEmotion?)
    
}

private var _SAEmotionPanelBackspaceImage: UIImage? = {
    let png = "iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAMAAAANIilAAAAAbFBMVEUAAACfn5+YmJibm5uYmJiYmJidnZ2Xl5eYmJiXl5eYmJiampqgoKCoqKiYmJiYmJiYmJiXl5eZmZmYmJiYmJiYmJiampqYmJidnZ2YmJiYmJiYmJiYmJiYmJiYmJiZmZmYmJiYmJiYmJiXl5dyF2b0AAAAI3RSTlMAFdQZ18kS86tmWiAKBeTbz7597OfhLicO+cS7tJtPPaaKco/AGfEAAAEUSURBVEjH7dXLroMgFAVQEHxUe321Vav31e7//8dOmuyYcjCYtCP2CHJcCcEDqJiYmM9kPMOZPD1s2uoCMYvxW9NgProrZY3Fa3WCdJKKWQ3fyqcWSSaXS6Ry8TijMUqOQS7bDpdK+QJIla9vnJ9WF3q1Ez2xYAucxue4QKJXu9hv4B+cBn5OzQnxq83/OCPgUMY3XGlJOPDgHtdfzohoZXynXWtaER+A0tmq1tIKuIS7Z7UFLK0b/yMfdmC2xxC8bDYmdciGsa3H0F9FvVAHNAmPY13taU8e5tCDQT1TBx9JNaVozK7LgFoIsZCshd1xAVInOvzq5d60WeilT22pX5+bTvljLMR0Rm3pRn5iY2Ji3pcHZE4k/ix2A/EAAAAASUVORK5CYII="
    return UIImage(base64Encoded: png, scale: 2)
}()
private var _SAEmotionPanelPreviewBackgroundImageForSmall: UIImage? = {
    let png = "iVBORw0KGgoAAAANSUhEUgAAAIQAAADYCAMAAAAd1rsZAAAA5FBMVEUAAAC3t7fDw8PGxsbGxsa6urq+vr7FxcXFxcXAwMDFxcXFxcXFxcXGxsbY2NjKysrFxcXIyMjw8PDIyMjKysrHx8fHx8fHx8fIyMjHx8fHx8fBwcHh4eHGxsa8vLzIyMjp6enFxcXU1NTNzc3Z2dnv7+/R0dHc3NzIyMjGxsbHx8fIyMjGxsbl5eXd3d3IyMjHx8fGxsbHx8fIyMjLy8vz8/PHx8fHx8fHx8fKysrw8PDHx8fHx8fGxsb5+fnNzc3g4ODHx8fIyMjIyMjGxsbr6+vLy8vIyMj////Gxsb8/Pz4+Phy2kwNAAAASHRSTlMAAhUoCQYIIxETDBsXHgYOJvL4Ie3OpPnu6Ssh7VEP9PFg6Ovn9eno58tpWTru6+Tfq55KSPm8dkQz+9PCcfnm5JiC1bTw7otHLmgdAAAFnElEQVR42u2d6VbaUBCABbPfLIQQ9h1kEQQU3LWtdhvD+79PA3S0GwrJTdL2zPdf/M7cuSMnmXEO/m5S3AkgIIqmKK0QQiKt8D9M3EdkIyBolqKqapoL/gcpliZsRHZUkDRL1ZnhyJlM5pAD/sfIjsF01dIk1HhDQdBU3ZAXj6fDgV144kLBHgxPHxeyoaua8JbGOgoqk2v5UqFdvVl6wAlvma22C6V8TWbqOhqvhcFcKYxcu5uFCMh2bXe00jD9X7U9DJZemV/YTYiMpn2xqOjWtmCsskFh5XyjCpFSbeTLTBHQ4jcH1Ri7PQ8ixuu5Y0NFi98daoMJxMBkUPujxdrhGLMhapr28dri10BIilGzzyEmzu2aoUgYCnQwLTYeNCE2moMxs8yfLFKippfdCcTIxC3rmpj66TBUJ9+GWGnnHfX7gWAg2LzhQax4jTlbhwIDIajyRRVipnohq8I6FBiIkQ2xY49+CIWfEbLbhNhpurKfFS9Xo2ZDAtg1vCC+RN3IdyEBunmj7kvgaZSykADZ0vN5pAR9XoBEKMx1IYV347ENidB+3NwPX8IyTquQCNVTw9pImIozzEIiZIeOYm4k/LxcQiIs/czcSEhqxvYgETw7o0ooUYCEKDxLpA+fICGeDtN/hYRAEiRBEiRBEiRBEiRBEiRBEj4kgZAEQhIISSAkgZAEQhIISSAkgZAEQhIISSAkgZAEQhIISSAkgZAEQhIISSAkgZAEQhLIfy+R+Qsk1AQlsNnLVOVGUm1vDZQQFXmWVAPgTFawH9O5S6oV8s6xvktoLJ9YUyh2bqcEvdWBROgc64KI3cqZZLpCl8VNXm6Sgp31IQEmecMSUULQr5K4pF5joT/P3KRMyzjrQux0/UCYvgOGIl0unUPMnJeu098DgVlxmYOY6VwyzAicfXI+xXwg/Qsct/nxQGYnECPN2XVaw0DgPJymXxVjTIvz4kL3HVACLers2I6tZC3te1Y30eHlQCTF+PrFg1jwcl8NRcLD+GU48KwTj0Uvj6OBfxiTrHzqQQz0PlXUVwZG5Ys2RE77LpPWto/OaunDYeTlojssb3PAi1q+7UOkTD6W8XJut7ieVSFCqrNrdNhqYWr6uPQZIuNzaaxr5pvT7RabF7MQEdninFkYh9diUWej4juIhHfFERbKrWDpZJc5DyLAy10yLJSvgqUTIqB3hoXyTYmDVdG6mwB3+nfylkK57aKWjoAzRyW8nLtasBbv2TDPbrGdHXDU/awNXGmf4Tj7LuDXvQHXAzkalPG79e4WGjvOAUdyx0zbwwHH3SvuCXDjxK2oex0GTje3chwD0dL3CgSWb6Vy2wRONG8rCpbrfbPiPXDi/f4ZgVmR4fWH7N36QcS+Ejhb/AG48AFnhfcPhYCpySMthf0DgY+RuDw7eXlcGeg8HJdL1TxynUCngc8WuSTFhzzejf3x69VlDzjQu/Qr1UEw/MwccakU70d+XgaWSC+4XI/cIh1cQlLHNnDAHqtSYAlTLReAA4WyaoaQkJ+AA09yCAmRn4QYXELhJaGQBEmQBEmQBEmQBEmQBEmQBEmQBEmQBEmQBEmQBFcJU6nwkagoZnCJeqXgQWi8RqUeXEKsG9MlhGY5NeohckJjwxsIzc0Q37kEfOvy0IfQ9B/wnUvAFx61HIQmV8PXHQHvqDPNQkiyM0cRw0ho+n0HQtK51wOnBP6//o8nEIqTW2xaCBGKq3D9Z0fFqzCBwNbdlp0N4WC33uxz26n/rFU8CXwWxRb2mIVgvWPl6mMnUDCyndsrpgghHXDbjHw/zfX32rjjLW/6X6b3sl7HHTIhLcz16p8Hd1p42pnC1H1YL/UROTi8LEFijrz7EqbVniWmq89blvhoSJuFVOkd2Syc4qeAGj6Sz67Lt0Qf/8eS31F2QBD/Mt8AXnEdKhLnOzIAAAAASUVORK5CYII="
    return UIImage(base64Encoded: png, scale: 2)
}()
private var _SAEmotionPanelPreviewBackgroundImageForLargeOfLeft: UIImage? = {
    let png = "iVBORw0KGgoAAAANSUhEUgAAADwAAAC0CAMAAAD/wb/1AAAAY1BMVEUAAADBwcHExMTNzc3Hx8fDw8Pj4+PGxsbIyMjCwsLLy8vIyMjJycnIyMjHx8e/v7/s7Ozf39/Y2NjJycnIyMjIyMjGxsbHx8fIyMjHx8fFxcX////Gxsb39/f6+vrx8fHr6+sc50oiAAAAG3RSTlMABycCHA38I/kW+O7YqlYS/vr468G9VUc8m5v7bzgfAAABEElEQVRo3u3aya7CMAyF4Zs6U0culNkUeP+npLtIBJXKlQxI5+w/ZZ/ff9ivj4jM272WI3SltSEUk3tJRxm607bp42VyuR2p3bd1tb7fBp5e/qyzh13lk5uPyayKNnqet8wem82VJZhM2dWeZ+/p3S7+sxCvjvVoRZhc0XiWYTK23bAUu0O8CjEZu/MsxW5fsRSbsvVSTCbUgxi7rmIxLk9rMTZ2e1+Am5sch35YgCPLcXEBBgYGBgYGBgYGBgYGBgYGBgYGBgYG/ggOcQnuB+0//VQT1DtGKijq7SZVI/1elUqZfqNLdVC/S6Yiqt9iUwXW7s95+VZq7vLan98ZnAV3BoILB+FtBYZhGIZhX7cHYMfPwx97p7cAAAAASUVORK5CYII="
    return UIImage(base64Encoded: png, scale: 2)?.resizableImage(withCapInsets: UIEdgeInsetsMake(16, 16, 32, 0))
}()
private var _SAEmotionPanelPreviewBackgroundImageForLargeOfMiddle: UIImage? = {
    let png = "iVBORw0KGgoAAAANSUhEUgAAADwAAAC0CAMAAAD/wb/1AAAAulBMVEUAAAC/v7/ExMTBwcG/v7/ExMTJycnGxsbCwsLa2trFxcXHx8fGxsbJycnm5ubq6urh4eHZ2dnPz8/V1dXMzMzKysrJycnIyMjIyMjIyMjIyMjGxsbFxcXCwsLc3NzIyMjIyMjIyMjHx8fHx8fHx8fJycnHx8fS0tLR0dHJycnHx8fIyMjJycnIyMjHx8fGxsbIyMjIyMjFxcXBwcHHx8fGxsbGxsb////Gxsb9/f35+fn19fXy8vLu7u7Y6pwTAAAAN3RSTlMACCcCBA32GBIGFTEiEP39+/n5+Pj47+i5UjcqHhv689nRhXVqSD/4+ODJwqSclX5iWyUdrauG/KKu2AAAAZpJREFUaN7t2seuglAUhWG86rEAVgQUsfdebpHi+7/WNUICuBFOwshk7fk3+bM4IwTcx1wuwwlfGU64ZTjhL8MBAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDfxy+edey+I3V8pH/h4Oot/lxWxc95f9bIRvjBq9tjAzZU4J3Bbmn1vlsXe3JBSF8+UK5yxwe67ButZAXojpXmnbsdGt3pqWcZyP6ul9ZqaFX+yu1D12Uts003NxKRc8SLa5ryba2Fqn1k5cXw3uSvQ/n5XCsaPLqiTlJoU9BaKor5kSx3sZSfs1KyNLk/Z/221V+96OhabTLePBmleMLiUV0T6vHrlILVkkv2OnQpdZlXRI6Llpp1rHjVklixUYzDy3r9fM/mF6sdC3pzZdV6qFVpkUzRo3IKkcGl/WfhoV6D61SXZQTQtOdnpkTrPJMVpmS/KjYfmjlmBaa7nS3tJ6hlzuyyvRo0ua508GGhObRolZ7hNZEHkt3Omeuy8jnz5t8xtiMOzR5jScT8s5y60qxWCGWWz9OwEXuHy5DclLKt/gsAAAAAElFTkSuQmCC"
    return UIImage(base64Encoded: png, scale: 2)?.resizableImage(withCapInsets: UIEdgeInsetsMake(16, 0, 32, 0))
}()
private var _SAEmotionPanelPreviewBackgroundImageForLargeOfRight: UIImage? = {
    let png = "iVBORw0KGgoAAAANSUhEUgAAADwAAAC0CAMAAAD/wb/1AAAAXVBMVEUAAADBwcHExMTHx8fFxcXGxsbj4+PJycnHx8fGxsbIyMjCwsLLy8vJycnIyMjt7e3f39/Y2NjIyMjHx8fHx8fGxsbBwcHJycnKysr////Gxsb39/f6+vrx8fHr6+urOgctAAAAGXRSTlMABycDDhr87lYi+RT42b/++vitqJtHKT0+uuTYmQAAAQdJREFUaN7t2skKwjAUhWHTTE06OA/Xqu//mLq7IFrtKUSE8+8/CFnmZMH+JvMxa9/iaryUfOOMeePPo+XY9bs6efeay3jD9bZq46Z+zeWLhtD2e+/sNKyFvD04YzEsl3V3bJ61fF2IteqpWJb5oadi1fHoLIoldAdnUSzrrTcwvuS9syiW0HsDY2lrZ2EcNt7AeIgJwnpuGK92DY5vvTcwvnYJx0OcgSVXM/CZmJiYmJiYmJiYmJiYmJiYmJiYmJiY+Dc4V8Vf1vVNv/SaoDtG4QVF76v4aqSnLr+U6UaHr4Pld8llPKkttMXqClx8f9blG9/c8bV/1j8D/IcD/reCMcYYY3/THaKymm1e6hXLAAAAAElFTkSuQmCC"
    return UIImage(base64Encoded: png, scale: 2)?.resizableImage(withCapInsets: UIEdgeInsetsMake(16, 0, 32, 16))
}()
