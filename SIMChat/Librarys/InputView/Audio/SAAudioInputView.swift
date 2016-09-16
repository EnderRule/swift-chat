//
//  SAAudioInputView.swift
//  SIMChat
//
//  Created by sagesse on 9/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

// ## TODO
// [ ] SAAudioInputView - 变声
// [ ] SAAudioInputView - 对讲
// [ ] SAAudioInputView - 录音
// [ ] SAAudioInputView - 自定义
// [ ] SAAudioInputView - Mini模式
// [ ] SAAudioTalkbackView - 按住录音的同时按home会导致事件混乱(系统问题)

@objc
public protocol SAAudioInputViewDataSource: NSObjectProtocol {
    
    func numberOfItemsInAudio(_ audio: SAAudioInputView) -> Int
    func audio(_ audio: SAAudioInputView, itemAt index: Int) -> SAAudio
    
}

@objc 
public protocol SAAudioInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
    
}


open class SAAudioInputView: UIView {
    
    open weak var dataSource: SAAudioInputViewDataSource?
    open weak var delegate: SAAudioInputViewDelegate?
    
    open override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
    private func _init() {
        _logger.trace()
        
        backgroundColor = UIColor(colorLiteralRed: 0xec / 0xff, green: 0xed / 0xff, blue: 0xf1 / 0xff, alpha: 1)
        
        _contentViewLayout.scrollDirection = .horizontal
        _contentViewLayout.minimumLineSpacing = 0
        _contentViewLayout.minimumInteritemSpacing = 0
        
        _contentView.backgroundColor = .clear
        _contentView.isPagingEnabled = true
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.allowsSelection = false
        _contentView.allowsMultipleSelection = false
        //_contentView.delaysContentTouches = false
        
        _contentView.register(SAAudioSimulateView.self, forCellWithReuseIdentifier: "\(SAAudioType.simulate)")
        _contentView.register(SAAudioTalkbackView.self, forCellWithReuseIdentifier: "\(SAAudioType.talkback)")
        _contentView.register(SAAudioRecordView.self, forCellWithReuseIdentifier: "\(SAAudioType.record)")
        
        _contentView.delegate = self
        _contentView.dataSource = self
        
        // add subview 
        addSubview(_contentView)
        
        // add constraints
       
        addConstraint(_SALayoutConstraintMake(_contentView, .top, .equal, self, .top))
        addConstraint(_SALayoutConstraintMake(_contentView, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_contentView, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_contentView, .bottom, .equal, self, .bottom))
    }
    
    fileprivate lazy var _contentViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    fileprivate lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension SAAudioInputView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItemsInAudio(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let audio = dataSource?.audio(self, itemAt: indexPath.item) else {
            fatalError()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(audio.type)", for: indexPath)
        if let cell = cell as? SAAudioView {
            cell.audio = audio
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}
