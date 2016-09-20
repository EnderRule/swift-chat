//
//  SAAudioInputView.swift
//  SIMChat
//
//  Created by sagesse on 9/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

// ## TODO
// [x] SAAudioInputView - 横屏支持
// [x] SAAudioInputView - 变声模式支持 - 99%, 算法没有实现(soundtouch?)
// [x] SAAudioInputView - 对讲模式支持
// [x] SAAudioInputView - 录音模式支持
// [x] SAAudioInputView - 添加MaskView
// [ ] SAAudioInputView - 检查录音时间
// [ ] SAAudioInputView - Mini模式支持
// [x] SAAudioInputView - 更换图标
// [x] SAAudioInputView - Tabbar支持
// [x] SAAudioInputView - 初始化时在中心
// [x] SAAudioTalkbackView - 长按录音
// [x] SAAudioTalkbackView - 回放
// [x] SAAudioTalkbackView - 频谱显示
// [x] SAAudioRecordView - 点击录音
// [x] SAAudioRecordView - 回放
// [x] SAAudioRecordView - 频谱显示
// [x] SAAudioSimulateView - 长按录音
// [x] SAAudioSimulateView - 回放
// [x] SAAudioSimulateView - 频谱显示(录音)
// [x] SAAudioSimulateView - 频谱显示(回放)
// [ ] SAAudioSimulateView - 各种效果支持(6) - 50%, 主要是算法没有实现
// [x] SAAudioSpectrumView - 显示波形
// [ ] SAAudioSpectrumView - 优化(主要是算法)
// [x] SAAudioTabbar - Index设置
// [x] SAAudioTabbar - 点击事件
// [x] SAAudioTabbar - 颜色

@objc
public enum SAAudioType: Int, CustomStringConvertible {
    
    case simulate = 0   // 变声
    case talkback = 1   // 对讲
    case record = 2     // 录音
    
    public var description: String { 
        switch self {
        case .talkback: return "Talkback"
        case .simulate: return "Simulate"
        case .record:   return "Record"
        }
    }
}

@objc
public protocol SAAudioInputViewDataSource: NSObjectProtocol {
    
    func numberOfItemsInAudio(_ audio: SAAudioInputView) -> Int
    func audio(_ audio: SAAudioInputView, itemAt index: Int) -> SAAudioType
    
}

@objc 
public protocol SAAudioInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
    
    @objc optional func audio(_ audio: SAAudioInputView, shouldStartRecord url: URL) -> Bool
    @objc optional func audio(_ audio: SAAudioInputView, didStartRecord url: URL)
    
    @objc optional func audio(_ audio: SAAudioInputView, didRecordComplete url: URL, duration: TimeInterval)
    @objc optional func audio(_ audio: SAAudioInputView, didRecordFailure url: URL, duration: TimeInterval)
}


open class SAAudioInputView: UIView {
    
    open weak var dataSource: SAAudioInputViewDataSource?
    open weak var delegate: SAAudioInputViewDelegate?
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if _cacheBounds?.width != bounds.width {
            _cacheBounds = bounds
            
            if let idx = _contentViewLayout.lastIndexPath {
                _restoreContentOffset(at: idx)
                _tabbar.index = CGFloat(idx.item) + 0.5
            } else {
            let count = _contentView.numberOfItems(inSection: 0)
                let idx = max(((count + 1) / 2) - 1, 0)
                _contentView.contentOffset = CGPoint(x: _contentView.frame.width * CGFloat(idx), y: 0)
                _tabbar.index = CGFloat(idx) + 0.5
            }
        }
    }
    open override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
    private func _restoreContentOffset(at indexPath: IndexPath) {
        _logger.trace(indexPath)
        
        let count = _contentView.numberOfItems(inSection: indexPath.section)
        let item = min(indexPath.item, count - 1)
        
        let x = CGFloat(item) * _contentView.frame.width
        
        _contentView.contentOffset = CGPoint(x: x, y: 0)
    }
    
    private func _init() {
        _logger.trace()
        
        backgroundColor = UIColor(colorLiteralRed: 0xec / 0xff, green: 0xed / 0xff, blue: 0xf1 / 0xff, alpha: 1)
        
        _tabbar.delegate = self
        _tabbar.indicatorColor = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
        _tabbar.textHighlightedColor = _tabbar.indicatorColor
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        
        _maskView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        _maskView.translatesAutoresizingMaskIntoConstraints = false
        
        _contentView.backgroundColor = .clear
        _contentView.isPagingEnabled = true
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.allowsSelection = false
        _contentView.allowsMultipleSelection = false
        _contentView.alwaysBounceHorizontal = true
        //_contentView.delaysContentTouches = false
        
        _contentView.register(SAAudioSimulateView.self, forCellWithReuseIdentifier: "\(SAAudioType.simulate)")
        _contentView.register(SAAudioTalkbackView.self, forCellWithReuseIdentifier: "\(SAAudioType.talkback)")
        _contentView.register(SAAudioRecordView.self, forCellWithReuseIdentifier: "\(SAAudioType.record)")
        
        _contentView.delegate = self
        _contentView.dataSource = self
        
        // add subview 
        addSubview(_contentView)
        addSubview(_tabbar)
        
        // add constraints
       
        addConstraint(_SALayoutConstraintMake(_contentView, .top, .equal, self, .top))
        addConstraint(_SALayoutConstraintMake(_contentView, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_contentView, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_contentView, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_tabbar, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_tabbar, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_tabbar, .bottom, .equal, self, .bottom, -16))
    }
    
    private var _cacheBounds: CGRect?
    
    fileprivate lazy var _tabbar: SAAudioTabbar = SAAudioTabbar()
    
    fileprivate lazy var _contentViewLayout: SAAudioInputViewLayout = SAAudioInputViewLayout()
    fileprivate lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
    
    fileprivate lazy var _maskView: UIView = UIView()
    fileprivate lazy var _maskViewLayout: [NSLayoutConstraint] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension SAAudioInputView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = _contentView.indexPathsForVisibleItems.first {
            _tabbar.index = (scrollView.contentOffset.x / scrollView.bounds.width) + 0.5
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItemsInAudio(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = dataSource?.audio(self, itemAt: indexPath.item) else {
            fatalError()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(type)", for: indexPath)
        if let cell = cell as? SAAudioView {
            cell.audioType = type
            cell.delegate = self
        }
        return cell
    }
}

// MARK: - SAAudioViewDelegate(Forwarding)

extension SAAudioInputView: SAAudioViewDelegate {
    
    func audioView(_ audioView: SAAudioView, shouldStartRecord url: URL) -> Bool {
        return delegate?.audio?(self, shouldStartRecord: url) ?? true
    }
    func audioView(_ audioView: SAAudioView, didStartRecord url: URL) {
        addMaskView()
        delegate?.audio?(self, didStartRecord: url)
    }
    
    func audioView(_ audioView: SAAudioView, didComplete url: URL, duration: TimeInterval) {
        removeMaskView()
        delegate?.audio?(self, didRecordComplete: url, duration: duration)
    }
    func audioView(_ audioView: SAAudioView, didFailure url: URL, duration: TimeInterval) {
        removeMaskView()
        delegate?.audio?(self, didRecordFailure: url, duration: duration)
    }
    
    func addMaskView() {
        guard let window = window, _maskView.superview == nil else {
            return
        }
        _logger.trace()
        
        window.addSubview(_maskView)
        _maskViewLayout = [
            _SALayoutConstraintMake(_maskView, .top, .equal, window, .top),
            _SALayoutConstraintMake(_maskView, .left, .equal, window, .left),
            _SALayoutConstraintMake(_maskView, .right, .equal, window, .right),
            _SALayoutConstraintMake(_maskView, .bottom, .equal, self, .top),
        ]
        window.addConstraints(_maskViewLayout)
        
        self._maskView.alpha = 0
        self._tabbar.transform = .identity
        UIView.animate(withDuration: 0.25, animations: {
            self._maskView.alpha = 1
            self._tabbar.transform = CGAffineTransform(translationX: 0, y: self._tabbar.frame.height + 16)
        }, completion: { _ in
            self._tabbar.isHidden = true
        })
        _contentView.isScrollEnabled = false
        _contentView.panGestureRecognizer.isEnabled = false
    }
    func removeMaskView() {
        guard _maskView.superview != nil else {
            return
        }
        _logger.trace()
        
        UIView.animate(withDuration: 0.25, delay: 0.2, options: .curveEaseInOut, animations: {
            self._tabbar.transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, animations: {
            self._maskView.alpha = 0
        }, completion: { _ in
            self._maskView.superview?.removeConstraints(self._maskViewLayout)
            self._maskView.removeFromSuperview()
            self._maskViewLayout = []
        })
        
        _tabbar.isHidden = false
        _contentView.isScrollEnabled = true
        _contentView.panGestureRecognizer.isEnabled = true
    }
}

// MARK: - SAAudioTabbarDelegate

extension SAAudioInputView: SAAudioTabbarDelegate {
    
    func numberOfItemsInTabbar(_ tabbar: SAAudioTabbar) -> Int {
        return dataSource?.numberOfItemsInAudio(self) ?? 0
    }
    func tabbar(_ tabbar: SAAudioTabbar, titleAt index: Int) -> String {
        guard let type = dataSource?.audio(self, itemAt: index) else {
            fatalError()
        }
        switch type {
        case .record: return "录音"
        case .talkback: return "对讲"
        case .simulate: return "变声"
        }
    }
    
    func tabbar(_ tabbar: SAAudioTabbar, shouldSelectItemAt index: Int) -> Bool {
        return true
    }
    func tabbar(_ tabbar: SAAudioTabbar, didSelectItemAt index: Int) {
        _contentView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
}
