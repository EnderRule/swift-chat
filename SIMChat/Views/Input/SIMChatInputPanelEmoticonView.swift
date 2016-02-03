//
//  SIMChatInputPanelEmoticonView.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

// TODO: 暂未支持横屏

///
/// 表情
///
public protocol SIMChatEmoticon: class {
    ///
    /// 表情码
    ///
    var code: String { get }
    ///
    /// 关联的静态图
    ///
    var png: String? { get }
    ///
    /// 关联的动态图
    ///
    var gif: String? { get }
}

///
/// 一组表情
///
public protocol SIMChatEmoticonGroup: class {
    
    ///
    /// 唯一id
    ///
    var identifier: String { get }
    
    ///
    /// 该组表情所有的表情
    ///
    var emoticons: Array<SIMChatEmoticon> { get }
}

//@objc public protocol SIMChatInputPanelDelegateFace: SIMChatInputPanelDelegate {
//    
//    optional func inputPanel(inputPanel: UIView, shouldSelectFace face: String) -> Bool
//    optional func inputPanel(inputPanel: UIView, didSelectFace face: String)
//    
//    optional func inputPanelShouldReturn(inputPanel: UIView) -> Bool
//    optional func inputPanelShouldSelectBackspace(inputPanel: UIView) -> Bool
//}


///
/// 表情面板代理
///
internal protocol SIMChatInputPanelEmoticonViewDelegate: SIMChatInputPanelDelegate {
    ///
    /// 获取表情组数量
    ///
    func numberOfGroupsInInputPanelEmoticon(inputPanel: UIView) -> Int
    ///
    /// 获取一个表情组
    ///
    func inputPanel(inputPanel: UIView, emoticonGroupAtIndex index: Int) -> SIMChatEmoticonGroup?
}

///
/// 表情面板
///
internal class SIMChatInputPanelEmoticonView: UIView, SIMChatInputPanelProtocol {
    /// 代理
    weak var delegate: SIMChatInputPanelDelegate?
    /// 创建面板
    static func inputPanel() -> UIView {
        return self.init()
    }
    /// 获取对应的Item
    static func inputPanelItem() -> SIMChatInputItem {
        let R = { (name: String) -> UIImage? in
            return UIImage(named: name)
        }
        let item = SIMChatInputBaseItem("kb:emoticon", R("chat_bottom_smile_nor"), R("chat_bottom_smile_press"))
        SIMChatInputPanelContainer.registerClass(self.self, byItem: item)
        return item
    }
    
    /// 初始化
    @inline(__always) private func build() {
        
        // add view
        addSubview(_contentView)
        addSubview(_pageControl)
        addSubview(_tabBar)
        addSubview(_sendButton)
        addSubview(_preview)
        
        // add layout
        
        SIMChatLayout.make(_contentView)
            .top.equ(self).top
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(_tabBar).top
            .submit()
        
        SIMChatLayout.make(_pageControl)
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(_contentView).bottom(5)
            .submit()
        
        SIMChatLayout.make(_tabBar)
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(self).bottom
            .submit()
        
        SIMChatLayout.make(_sendButton)
            .top.equ(_tabBar).top
            .right.equ(_tabBar).right
            .bottom.equ(_tabBar).bottom
            .submit()
        
//        _pageControl.currentPage = 8
//        _pageControl.numberOfPages = _pages.count
        
        dispatch_async(dispatch_get_main_queue()) {
            dispatch_async(dispatch_get_main_queue()) {
                if let group = self._builtInGroups.first as? SIMChatEmoticonGroupOfClassic {
                    let idx = NSIndexPath(forItem: group.defaultPage, inSection: 0)
                    self._pageControl.currentPage = NSIndexPath(forItem: 0, inSection: 1)
                    self._contentView.scrollToItemAtIndexPath(idx,
                        atScrollPosition: .None,
                        animated: false)
                }
            }
        }
    }
    
    private lazy var _tabBar: SIMChatInputPanelTabBar = {
        let view = SIMChatInputPanelTabBar()
        view.backgroundColor = UIColor(rgb: 0xF8F8F8)
//        view.delegate = self
//        view.dataSource = self
        return view
    }()
    private lazy var _preview: SIMChatInputPanelEmoticonPreview = {
        let view = SIMChatInputPanelEmoticonPreview()
        view.frame = CGRectMake(0, 0, 80, 80)
        view.hidden = true
        return view
    }()
    private lazy var _sendButton: UIButton = {
        let view = UIButton(type: .System)
        view.tintColor = UIColor.whiteColor()
        view.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16)
        view.setTitle("发送", forState: .Normal)
        view.setBackgroundImage(UIImage(named: "tabwithinpage_cursor"), forState: .Normal)
        view.addTarget(self, action: "classicShouldSelectReturn:", forControlEvents: .TouchUpInside)
        return view
    }()
    private lazy var _pageControl: SIMChatInputPanelPageControl = {
        let view = SIMChatInputPanelPageControl()
        view.delegate = self
//        view.numberOfPages = 20
//        view.pageIndicatorTintColor = UIColor.grayColor()
//        view.currentPageIndicatorTintColor = UIColor.darkGrayColor()
//        view.hidesForSinglePage = true
        view.userInteractionEnabled = false
        return view
    }()
    private lazy var _contentView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.pagingEnabled = true
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = UIColor.whiteColor()
        
        view.registerClass(SIMChatInputPanelEmoticonCell.self, forCellWithReuseIdentifier: "Emoticon")
        
        return view
    }()
    
    private var _pages: Dictionary<String, Array<SIMChatInputPanelEmoticonPage>> = [:]
    private lazy var _builtInGroups: [SIMChatEmoticonGroup] = [
        SIMChatEmoticonGroupOfClassic()
    ]
    
//    private lazy var _pages: [AnyObject] = Model.Classic.emojis().reverse() + Model.Classic.faces()
    //private lazy var _pages: [AnyObject] = Model.Classic.emojis()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
}


///
/// 底部菜单栏
///
internal class SIMChatInputPanelTabBar: UICollectionView {
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSizeMake(50, 37)
        super.init(frame: CGRectZero, collectionViewLayout: layout)
        registerClass(SIMChatInputPanelTabBarItem.self, forCellWithReuseIdentifier: "Item")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(bounds.width, 37)
    }
}

///
/// 底部菜单项
///
internal class SIMChatInputPanelTabBarItem: UICollectionViewCell {
    var image: UIImage? {
        set { return imageView.image = newValue }
        get { return imageView.image }
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.frame = self.contentView.bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.contentMode = .Center
        self.contentView.addSubview(view)
        return view
    }()
}

///
/// 页面控制视图
///
internal class SIMChatInputPanelPageControl: UIView {
    
    var hidesForSinglePage: Bool = false
    
    var pageIndicatorTintColor: UIColor? = UIColor.grayColor()
    var currentPageIndicatorTintColor: UIColor? = UIColor.darkGrayColor()
    
    var currentPage: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0) {
        didSet {
            guard oldValue.row != currentPage.row || oldValue.section != currentPage.section else {
                return
            }
            if oldValue.section != currentPage.section {
                reloadPages()
            } else {
                if oldValue.row < _pages.count {
                    _pages[oldValue.row].backgroundColor = pageIndicatorTintColor
                }
                if currentPage.row < _pages.count {
                    _pages[currentPage.row].backgroundColor = currentPageIndicatorTintColor
                }
            }
        }
    }
    
    var _groups: Array<UIImageView> = []
    var _pages: Array<UIView> = []
    
    var _pageGap: CGFloat = 4
    var _pageWH: CGFloat = 7
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var width = CGFloat(_pages.count) * (_pageWH + _pageGap) - _pageGap
        var height = CGFloat(_pageWH)
        _groups.enumerate().forEach {
            width += ($0.element.image?.size.width ?? 0) + _pageGap
            height = max($0.element.image?.size.height ?? 0, height)
        }
        return CGSizeMake(width - _pageGap, height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func reloadData() {
        reloadSections()
    }
    
    func reloadPages() {
        let count = delegate?.pageControl(self, numberOfPagesInSection: currentPage.section) ?? 0
        var tmp = _pages
        _pages.removeAll()
        (0 ..< count).forEach {
            let view = tmp.popLast() ?? UIView()
            view.layer.cornerRadius = _pageWH / 2
            view.layer.masksToBounds = true
            if currentPage.row == $0 {
                view.backgroundColor = currentPageIndicatorTintColor
            } else {
                view.backgroundColor = pageIndicatorTintColor
            }
            _pages.append(view)
            addSubview(view)
        }
        tmp.forEach {
            $0.removeFromSuperview()
        }
        
        updateLayout()
    }
    func reloadSections() {
        // 更新组
        if let count = delegate?.numberOfSectionsInPageControl(self) where count > 1 {
            var tmp = _groups
            _groups.removeAll()
            (0 ..< count).forEach {
                let view = tmp.popLast() ?? UIImageView()
                view.image = delegate?.pageControl(self, imageOfSection: $0)
                _groups.append(view)
                addSubview(view)
            }
            tmp.forEach {
                $0.removeFromSuperview()
            }
        } else {
            _groups.forEach {
                $0.removeFromSuperview()
            }
            _groups.removeAll()
        }
        
        reloadPages()
    }
    
    func updateLayout() {
        let width = sizeThatFits(CGSizeZero).width
        var x = (bounds.width - width) / 2
        
        if _groups.isEmpty {
            _pages.forEach {
                let size = CGSizeMake(_pageWH, _pageWH)
                $0.frame = CGRectMake(x, (bounds.height - size.height) / 2, size.width, size.height)
                x += size.width + _pageGap
            }
        } else {
            _groups.enumerate().forEach {
                let size = $0.element.image?.size ?? CGSizeZero
                $0.element.frame = CGRectMake(x, (bounds.height - size.height) / 2, size.width, size.height)
                if $0.index == currentPage.section {
                    _pages.forEach {
                        let size = CGSizeMake(_pageWH, _pageWH)
                        $0.frame = CGRectMake(x, (bounds.height - size.height) / 2, size.width, size.height)
                        x += size.width + _pageGap
                    }
                    $0.element.hidden = true
                } else {
                    x += size.width + _pageGap
                    $0.element.hidden = false
                }
            }
        }
    }
    
    weak var delegate: SIMChatInputPanelPageControlDelegate?
  
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(bounds.width, 25)
    }
}

///
/// 页面控制视图代理
///
internal protocol SIMChatInputPanelPageControlDelegate: class {
    func numberOfSectionsInPageControl(pageControl: SIMChatInputPanelPageControl) -> Int
    func pageControl(pageControl: SIMChatInputPanelPageControl, numberOfPagesInSection section: Int) -> Int
    func pageControl(pageControl: SIMChatInputPanelPageControl, imageOfSection section: Int) -> UIImage?
}

///
/// 表情预览视图
///
internal class SIMChatInputPanelEmoticonPreview: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
    private func build() {
        layer.contents = SIMChatImageManager.images_face_preview?.CGImage
    }
    
    var value: String? {
        didSet {
            guard value != oldValue else {
                return
            }
            if let value: NSString = value {
                if value.length <= 2 {
                    label.text = value as String
                    label.frame = bounds
                    label.sizeToFit()
                    label.frame = CGRectMake(
                        (bounds.width - label.bounds.width) / 2,
                        (bounds.height - label.bounds.height) / 2 - 4,
                        label.bounds.width,
                        label.bounds.height)
                    if label.superview != self {
                        addSubview(label)
                    }
                    imageView.removeFromSuperview()
                } else if value.hasPrefix("qq:") {
                    guard let image = UIImage(named: "SIMChat.bundle/Face/\(value.substringFromIndex(3))") else {
                        return
                    }
                    imageView.image = image
                    imageView.frame = CGRectMake(
                        (bounds.width - image.size.width) / 2,
                        (bounds.height - image.size.height) / 2 - 4,
                        image.size.width,
                        image.size.height)
                    if imageView.superview != self {
                        addSubview(imageView)
                    }
                    label.removeFromSuperview()
                }
                
            } else {
                label.removeFromSuperview()
                imageView.removeFromSuperview()
            }
        }
    }
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFontOfSize(32)
        return view
    }()
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
}

///
/// 表情面板中的每一个表情视图
///
internal class SIMChatInputPanelEmoticonCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    var page: SIMChatInputPanelEmoticonPage? {
        didSet {
            guard let page = self.page where oldValue !== page else {
                return
            }
            dispatch_async(dispatch_get_global_queue(0, 0)) {
                let image = self.drawToImage()
                dispatch_async(dispatch_get_main_queue()) {
                    guard self.page === page else {
                        return
                    }
                    self.contentView.layer.contents = image?.CGImage
                }
            }
        }
    }
    
    
    @inline(__always) func build() {
        let tap = UITapGestureRecognizer(target: self, action: "onItemPress:")
        tap.delegate = self
        gestureRecognizer.delegate = self
        
        contentView.addGestureRecognizer(tap)
        contentView.addGestureRecognizer(gestureRecognizer)
    }
//
//        /// 代理
//        weak var delegate: SIMChatInputPanelDelegateFaceOfClassic?
//        /// 对应的模型
//        var model: SIMChatInputPanelContainer.Face.Model.Classic? {
//            didSet {
//                guard model !== oldValue else {
//                    return
//                }
//                gestureRecognizer.enabled = !(model?.value.isEmpty ?? true)
//                dispatch_async(dispatch_get_global_queue(0, 0)) {
//                    self.displayIfNeeded()
//                }
//            }
//        }
//        
    var maximumItemCount: Int = 7
    var maximumLineCount: Int = 3
    var contentInset: UIEdgeInsets = UIEdgeInsetsMake(12, 10, 42, 10)
    
//        weak var preview: SIMChatInputPanelContainer.Face.ClassicPreview?
    
    /// 布局发生改变
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = itemSize
        var frame = CGRectZero
        
        frame.origin.x = contentInset.left + CGFloat(maximumItemCount - 1) * size.width
        frame.origin.y = contentInset.top + CGFloat(maximumLineCount - 1) * size.height
        frame.size.width = size.width
        frame.size.height = size.height
        
        backspaceButton.frame = frame
        
        if backspaceButton.superview != contentView {
            contentView.addSubview(backspaceButton)
        }
    }
    
    // 绘制为图片
    @inline(__always) func drawToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        defer { UIGraphicsEndImageContext() }
        
        let size = itemSize
        let config = [
            NSFontAttributeName: UIFont.systemFontOfSize(32)
        ]
        page?.emoticons.enumerate().forEach {
            let row = $0.index / maximumItemCount
            let col = $0.index % maximumItemCount
            
            if let png = $0.element.png where !png.isEmpty {
                guard let image = SIMChatBundle.imageWithResource("Emoticons/\(png)") else {
                    return
                }
                var frame = CGRectZero
                
                frame.origin.x = contentInset.left + CGFloat(col) * size.width
                frame.origin.y = contentInset.top + CGFloat(row) * size.height
                
                frame.size = image.size
                frame.origin.x += (size.width - frame.size.width) / 2
                frame.origin.y += (size.height - frame.size.height) / 2
                
                image.drawInRect(frame)
            } else {
                let value = $0.element.code as NSString
                var frame = CGRectZero
                
                frame.origin.x = contentInset.left + CGFloat(col) * size.width
                frame.origin.y = contentInset.top + CGFloat(row) * size.height
                
                frame.size = value.sizeWithAttributes(config)
                frame.origin.x += (size.width - frame.size.width) / 2
                frame.origin.y += (size.height - frame.size.height) / 2
                
                value.drawInRect(frame, withAttributes: config)
            }
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
//
//        func displayIfNeeded() {
//            guard let model = model else {
//                return
//            }
//            let o = UIDevice.currentDevice().orientation
//            let path = NSTemporaryDirectory() + "\(model.identifier)-\(o.rawValue)"
//            if NSFileManager.defaultManager().fileExistsAtPath(path) {
//                SIMLog.debug("hit cache: \(model.identifier) -> \(o.rawValue)")
//                let image = UIImage(contentsOfFile: path)
//                // update
//                dispatch_async(dispatch_get_main_queue()) {
//                    if self.model === model {
//                        self.layer.contents = image?.CGImage
//                    }
//                }
//            } else {
//                SIMLog.debug("make cache: \(model.identifier) -> \(o.rawValue)")
//                // update
//                dispatch_async(dispatch_get_main_queue()) {
//                    if self.model === model {
//                        self.layer.contents = image?.CGImage
//                    }
//                }
//                if image != nil {
//                    UIImagePNGRepresentation(image)?.writeToFile(path, atomically: true)
//                }
//            }
//        }
//        
//        func indexAtPoint(pt: CGPoint) -> Int? {
//            let x = pt.x - contentInset.left
//            let y = pt.y - contentInset.right
//            let width = bounds.width - contentInset.left - contentInset.right
//            let height = bounds.height - contentInset.top - contentInset.bottom
//            let size = itemSize
//            guard x >= 0 && x <= width && y >= 0 && y <= height else {
//                return nil
//            }
//            let row = Int(y / size.height)
//            let column = Int(x / size.width)
//            return row * maximumItemCount + column
//        }
//        
        /// 点击事件
        dynamic func onItemPress(sender: UITapGestureRecognizer) {
//            guard sender.state == .Ended else {
//                return
//            }
//            guard let index = indexAtPoint(sender.locationInView(self)) where index < model?.value.count else {
//                return
//            }
//            guard let item = model?.value[index] else {
//                return
//            }
//            SIMLog.trace("index: \(index), value: \(item)")
//            if delegate?.classic?(self, shouldSelectItem: item) ?? true {
//                delegate?.classic?(self, didSelectItem: item)
//            }
        }
        /// 长按事件
        dynamic func onItemLongPress(sender: UILongPressGestureRecognizer) {
//            guard let preview = self.preview else {
//                return
//            }
//            let pt = sender.locationInView(self)
//            // 开始的时候, 计算一下选择的是那一个.
//            if sender.state == .Began {
//                guard let index = indexAtPoint(pt) where index < model?.value.count else {
//                    return
//                }
//                guard let item = model?.value[index] else {
//                    return
//                }
//                
//                let size = itemSize
//                let row = index / maximumItemCount
//                let column = index % maximumItemCount
//                
//                SIMLog.trace("index: \(index), value: \(item)")
//                
//                selectedPoint = CGPointMake(
//                    contentInset.left + CGFloat(column) * size.width,
//                    contentInset.top + CGFloat(row) * size.height)
//                
//                preview.value = model?.value[index]
//                preview.hidden = false
//            }
//            /// 事件结束的时候检查区域
//            if sender.state == .Ended || sender.state == .Cancelled || sender.state == .Failed {
//                guard let selected = selectedPoint else {
//                    return
//                }
//                guard let item = preview.value, let index = model?.value.indexOf(item) else {
//                    preview.hidden = true
//                    return
//                }
//                
//                // 计算距离, sqr(x^2 + y^2)
//                let distance = fabs(sqrt(pow(preview.frame.midX - selected.x, 2) + pow(preview.frame.maxY - selected.y, 2)))
//                let size = itemSize
//                
//                SIMLog.trace("index: \(index), value: \(item), distance: \(Int(distance))")
//                // 只有正常结束的时候少有效
//                if sender.state == .Ended && CGRectMake(selected.x, selected.y, size.width, size.height).contains(pt) {
//                    if delegate?.classic?(self, shouldSelectItem: item) ?? true {
//                        delegate?.classic?(self, didSelectItem: item)
//                    }
//                }
//                
//                UIView.animateWithDuration(0.25 * max(Double(distance / 100), 1),
//                    animations: {
//                        var frame = preview.frame
//                        frame.origin.x = (selected.x + size.width / 2) - frame.width / 2
//                        frame.origin.y = (selected.y + 12) - frame.height
//                        preview.frame = frame
//                    },
//                    completion: { b in
//                        preview.hidden = true
//                    })
//                selectedPoint = nil
//            }
//            if selectedPoint != nil {
//                var frame = preview.frame
//                frame.origin.x = pt.x - frame.width / 2
//                frame.origin.y = pt.y - frame.height
//                preview.frame = frame
//            }
//            //UIDevice.currentDevice().orientation.rawValue
        }
        /// 删除事件
        dynamic func onBackspacePress(sender: AnyObject) {
//            SIMLog.trace()
//            if delegate?.classicShouldSelectBackspace?(self) ?? true {
//                delegate?.classicDidSelectBackspace?(self)
//            }
        }
    
    @objc override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pt = gestureRecognizer.locationInView(contentView)
        // 在区域内
        let x = contentInset.left
        let y = contentInset.right
        let width = bounds.width - contentInset.left - contentInset.right
        let height = bounds.height - contentInset.top - contentInset.bottom
        if !CGRectMake(x, y, width, height).contains(pt) {
            return false
        }
        return !backspaceButton.frame.contains(pt)
    }

    var selectedPoint: CGPoint?
    var itemSize: CGSize {
        let width = bounds.width - contentInset.left - contentInset.right
        let height = bounds.height - contentInset.top - contentInset.bottom
        return CGSizeMake(width / CGFloat(maximumItemCount), height / CGFloat(maximumLineCount))
    }
    lazy var backspaceButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: "onBackspacePress:", forControlEvents: .TouchUpInside)
        
        view.setImage(SIMChatImageManager.images_face_delete_nor, forState: .Normal)
        view.setImage(SIMChatImageManager.images_face_delete_press, forState: .Highlighted)
        return view
    }()
    private lazy var gestureRecognizer: UIGestureRecognizer = {
        let recognzer = UILongPressGestureRecognizer(target: self, action: "onItemLongPress:")
        recognzer.minimumPressDuration = 0.25
        return recognzer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
}

///
/// 一页表情(为提高速度, 整页生成)
///
internal class SIMChatInputPanelEmoticonPage {
    ///
    /// 把Group转为Page
    ///
    static func makeWithGroup(group: SIMChatEmoticonGroup) -> Array<SIMChatInputPanelEmoticonPage> {
        if let group = group as? SIMChatEmoticonGroupOfClassic {
            return makeWithGroup(group)
        }
        return makeWithEmoticons(group.emoticons).map {
            $0.group = group
            return $0
        }
    }
    ///
    /// 把Group转为Page(特化)
    ///
    static func makeWithGroup(group: SIMChatEmoticonGroupOfClassic) -> Array<SIMChatInputPanelEmoticonPage>  {
        let p1: [SIMChatInputPanelEmoticonPage] = makeWithEmoticons(group.emojis).map {
            $0.group = group
            return $0
        }.reverse()
        let p2: [SIMChatInputPanelEmoticonPage] = makeWithEmoticons(group.faces).map {
            $0.group = group
            return $0
        }
        group.defaultPage = p1.count
        return p1 + p2
    }
    ///
    /// 使用表情
    ///
    static func makeWithEmoticons(emoticons: Array<SIMChatEmoticon>) -> Array<SIMChatInputPanelEmoticonPage> {
        let count = emoticons.count
        let maxCount = (3 * 7) - 1
        
        return (0 ..< (emoticons.count + maxCount - 1) / maxCount).map {
            let beg = $0 * maxCount
            let end = min(($0 + 1) * maxCount, count)
            let page = SIMChatInputPanelEmoticonPage()
            page.emoticons = Array(emoticons[beg ..< end])
            return page
        }
    }
    
    var group: SIMChatEmoticonGroup?
    lazy var emoticons: Array<SIMChatEmoticon> = []
}

//internal class SIMChatInputPanelEmoticonView

//extension SIMChatInputPanelContainer.Face {
//    private class ContentView: UICollectionView {
//        init() {
//            let layout = UICollectionViewFlowLayout()
//            layout.scrollDirection = .Horizontal
//            layout.sectionInset = UIEdgeInsetsZero
//            layout.minimumLineSpacing = 0
//            layout.minimumInteritemSpacing = 0
//            super.init(frame: CGRectZero, collectionViewLayout: layout)
//            
//            registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Unknow")
//        }
//        required init?(coder aDecoder: NSCoder) {
//            super.init(coder: aDecoder)
//        }
//        
//        override func registerClass(cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
//            super.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
//            cellClasses[identifier] = cellClass
//        }
//        
//        private var cellClasses: [String: AnyClass] = [:]
//    }
//}
//
//// MARK: - Content Page -> Classic
//
//extension SIMChatInputPanelContainer.Face.Page {
//    /// 经典类型
//    private class Classic: UICollectionViewCell, UIGestureRecognizerDelegate {
//    }
//}
//
//// MARK: - Content Model
//extension SIMChatInputPanelContainer.Face.Model {
//    /// 经典类型
//    private class Classic {
//        init(_ value: [String], identifier: String = NSUUID().UUIDString) {
//            self.value = value
//            self.identifier = identifier
//        }
//        
//        var value: Array<String>
//        var identifier: String
//        
//        static func faces() -> [Classic] {
//            guard let path = SIMChatBundle.resourcePath("Preferences/face.plist") else {
//                fatalError("Must add \"SIMChat.bundle\" file")
//            }
//            guard let dic = NSDictionary(contentsOfFile: path) else {
//                fatalError("file \"SIMChat.bundle/Preferences/face.plist\" load fail!")
//            }
//            
//            // 生成列表
//            let emojis = dic
//                .sort { ($0.value as? Int) > ($1.value as? Int) }
//                .map { Int($0.key as! String)! }
//            
//            // 生成page
//            var pages = [Classic]()
//            let maxEle = (3 * 7) - 1
//            for i in 0 ..< (emojis.count + maxEle - 1) / maxEle {
//                let beg = i * maxEle
//                let end = min((i + 1) * maxEle, emojis.count)
//                let page = Classic(emojis[beg ..< end].map({ String(format: "qq:%03d", $0) }), identifier: "inputpanel-face-\(i)")
//                pages.append(page)
//            }
//            return pages
//        }
//        
//        static func emojis() -> [Classic] {
//            // 生成emoij函数
//            let emoji = { (x:UInt32) -> String in
//                var idx = ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24)
//                return withUnsafePointer(&idx) {
//                    return NSString(bytes: $0, length: sizeof(idx.dynamicType), encoding: NSUTF8StringEncoding) as! String
//                }
//            }
//            var emojis = [String]()
//            for i:UInt32 in 0x1F600 ..< 0x1F64F {
//                if i < 0x1F641 || i > 0x1F644 {
//                    emojis.append(emoji(i))
//                }
//            }
//            for i:UInt32 in 0x1F680 ..< 0x1F6A4 {
//                emojis.append(emoji(i))
//            }
//            for i:UInt32 in 0x1F6A5 ..< 0x1F6C5 {
//                emojis.append(emoji(i))
//            }
//            
//            var pages = [Classic]()
//            let maxEle = (3 * 7) - 1
//            for i in 0 ..< (emojis.count + maxEle - 1) / maxEle {
//                let beg = i * maxEle
//                let end = min((i + 1) * maxEle, emojis.count)
//                let page = Classic(Array(emojis[beg ..< end]), identifier: "inputpanel-emoji-\(i)")
//                pages.append(page)
//            }
//            return pages
//        }
//    }
//}
//
//// MARK: - Private Method
//
//extension SIMChatInputPanelContainer.Face {
//    public override func updateConstraints() {
//        super.updateConstraints()
//        
//        _tabBar.contentInset = UIEdgeInsetsMake(0, 0, 0, _sendButton.frame.width)
//    }
//}
//
////// MARK: - SIMChatInputPanelDelegateFaceOfClassic
////
////extension SIMChatInputPanelContainer.Face: SIMChatInputPanelDelegateFaceOfClassic {
////    /// 选择
////    @objc private func classic(classic: UIView, shouldSelectItem item: String) -> Bool {
////        return delegate?.inputPanel?(self, shouldSelectFace: item) ?? true
////    }
////    @objc private func classic(classic: UIView, didSelectItem item: String) {
////        delegate?.inputPanel?(self, didSelectFace: item)
////    }
////    /// 删除
////    @objc private func classicShouldSelectBackspace(classic: UIView) -> Bool {
////        return delegate?.inputPanelShouldSelectBackspace?(self) ?? true
////    }
////    /// 发送
////    @objc private func classicShouldSelectReturn(sender: AnyObject) {
////        delegate?.inputPanelShouldReturn?(self)
////    }
////}
//

extension SIMChatInputPanelEmoticonView: SIMChatInputPanelPageControlDelegate {
    
    func numberOfSectionsInPageControl(pageControl: SIMChatInputPanelPageControl) -> Int {
        if groupAtIndex(pageControl.tag) is SIMChatEmoticonGroupOfClassic {
            return 2
        }
        return 1
    }
    
    func pageControl(pageControl: SIMChatInputPanelPageControl, numberOfPagesInSection section: Int) -> Int {
        guard let group = groupAtIndex(pageControl.tag) else {
            return 0
        }
        if let classic = group as? SIMChatEmoticonGroupOfClassic {
            if section == 0 {
                return classic.defaultPage
            }
            let count = _pages[group.identifier]?.count ?? 0
            return count - classic.defaultPage
        }
        return _pages[group.identifier]?.count ?? 0
    }
    
    func pageControl(pageControl: SIMChatInputPanelPageControl, imageOfSection section: Int) -> UIImage? {
        if section == 0 {
            return UIImage(named: "qvip_emoji_pagecontrol_emoji")
        }
        if section == 1 {
            return UIImage(named: "qvip_emoji_pagecontrol_qq")
        }
        return nil
    }
}

extension SIMChatInputPanelEmoticonView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// 获取一组表情
    @inline(__always) func groupAtIndex(index: Int) -> SIMChatEmoticonGroup? {
        if index < _builtInGroups.count {
            return _builtInGroups[index]
        }
        return (delegate as? SIMChatInputPanelEmoticonViewDelegate)?.inputPanel(self, emoticonGroupAtIndex: index - _builtInGroups.count)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if let indexPath = _contentView.indexPathsForVisibleItems().first {
            let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
            if let group = groupAtIndex(indexPath.section) as? SIMChatEmoticonGroupOfClassic {
                if page < group.defaultPage {
                    _pageControl.currentPage = NSIndexPath(forItem: page, inSection: 0)
                } else {
                    _pageControl.currentPage = NSIndexPath(forItem: page - group.defaultPage, inSection: 1)
                }
            } else {
                _pageControl.currentPage = NSIndexPath(forItem: page, inSection: 0)
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let count = (delegate as? SIMChatInputPanelEmoticonViewDelegate)?.numberOfGroupsInInputPanelEmoticon(self) ?? 0
        return _builtInGroups.count + count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let group = groupAtIndex(section) else {
            return 0
        }
        defer {
            _pageControl.tag = section
            _pageControl.reloadData()
        }
        return _pages[group.identifier]?.count ?? {
            // 转化为page
            let pages = SIMChatInputPanelEmoticonPage.makeWithGroup(group)
            _pages[group.identifier] = pages
            return pages.count
        }()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == _contentView {
            return collectionView.bounds.size
        }
        if collectionView == _tabBar {
            return CGSizeMake(50, collectionView.bounds.height)
        }
        fatalError()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        if collectionView == _contentView {
//            let page = _pages[indexPath.item]
//            var identifier = NSStringFromClass(page.dynamicType)
//            if _contentView.cellClasses[identifier] == nil {
//                identifier = "Unknow"
//            }
            return collectionView.dequeueReusableCellWithReuseIdentifier("Emoticon", forIndexPath: indexPath)
//        }
//        if collectionView == _tabBar {
//            return collectionView.dequeueReusableCellWithReuseIdentifier("Item", forIndexPath: indexPath)
//        }
//        fatalError()
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let group = groupAtIndex(indexPath.section) else {
            return
        }
        if let cell = cell as? SIMChatInputPanelEmoticonCell {
            cell.page = _pages[group.identifier]?[indexPath.row]
        }
//        if indexPath.section < _builtInGroups.count {
//            _currentGroup = _builtInGroups[indexPath.section]
//        } else {
//            let index = indexPath.section - _builtInGroups.count
//            _currentGroup = (delegate as? SIMChatInputPanelEmoticonViewDelegate)?.inputPanel(self, emoticonGroupAtIndex: index)
//        }
        
//        if collectionView == _contentView {
//            if let cell = cell as? Page.Classic, page = _pages[indexPath.item] as? Model.Classic {
//                // 经典类型
//                cell.model = page
//                cell.preview = _preview
////                cell.delegate = self
//            }
////            cell.backgroundColor = collectionView.backgroundColor
//        } else if collectionView == _tabBar {
//            if let item = cell as? TabBarItem {
//                item.image = UIImage(named: "qvip_emoji_tab_classic_5_9_5")
//            }
//            cell.backgroundColor = UIColor(rgb: 0xe4e4e4)
//        }
    }
}

//
//// MARK: - Internal Delegate
//
//@objc private protocol SIMChatInputPanelDelegateFaceOfClassic: NSObjectProtocol {
//    
//    optional func classic(classic: UIView, shouldSelectItem item: String) -> Bool
//    optional func classic(classic: UIView, didSelectItem item: String)
//    
//    optional func classicShouldSelectBackspace(classic: UIView) -> Bool
//    optional func classicDidSelectBackspace(classic: UIView)
//}
//

///
/// 经典类型的表情
///
internal class SIMChatEmoticonGroupOfClassic: SIMChatEmoticonGroup {
    class Classic: SIMChatEmoticon {
        init(id: String) {
            self.code = id
            self.png = String(format: "Default/%03d.png", Int(id) ?? 0)
        }
        init(code: String) {
            self.code = code
        }
        var code: String
        var png: String?
        var gif: String?
    }
    /// 创建组
    init() {
        guard let path = SIMChatBundle.resourcePath("Preferences/face.plist") else {
            fatalError("Must add \"SIMChat.bundle\" file")
        }
        guard let dic1 = NSDictionary(contentsOfFile: path) else {
            fatalError("file \"SIMChat.bundle/Preferences/face.plist\" load fail!")
        }
        
        // 生成列表
        var faces = Array<SIMChatEmoticon>()
        var emojis = Array<SIMChatEmoticon>()
        var emoticons = Array<SIMChatEmoticon>()
        
        // 生成emoij
        let emoji = { (x:UInt32) -> SIMChatEmoticon in
            var idx = ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24)
            return withUnsafePointer(&idx) {
                let str = NSString(
                    bytes: $0,
                    length: sizeof(idx.dynamicType),
                    encoding: NSUTF8StringEncoding) as! String
                return Classic(code: str)
            }
        }
        for i:UInt32 in 0x1F600 ..< 0x1F64F where i < 0x1F641 || i > 0x1F644 {
            let e = emoji(i)
            emojis.append(e)
            emoticons.append(e)
        }
        for i:UInt32 in 0x1F680 ..< 0x1F6A4 {
            let e = emoji(i)
            emojis.append(e)
            emoticons.append(e)
        }
        for i:UInt32 in 0x1F6A5 ..< 0x1F6C5 {
            let e = emoji(i)
            emojis.append(e)
            emoticons.append(e)
        }
        
        // 生成face
        dic1.sort { ($0.value as? Int) > ($1.value as? Int) }
            .map { Classic(id: $0.key as! String) }
            .forEach {
                faces.append($0)
                emoticons.append($0)
            }
        
        self.faces = faces
        self.emojis = emojis
        self.emoticons = emoticons
        self.identifier = NSUUID().UUIDString
    }
    
    var identifier: String
    /// 该组表情所有的表情
    var emoticons: Array<SIMChatEmoticon>
    var emojis: Array<SIMChatEmoticon>
    var faces: Array<SIMChatEmoticon>
    
    /// 默认停留的页面
    var defaultPage: Int = 0
}
