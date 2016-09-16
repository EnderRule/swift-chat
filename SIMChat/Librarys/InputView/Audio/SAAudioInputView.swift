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

open class SAAudioInputView: UIView {
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: 253)
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
        
        _contentView.register(SAAudioSimulateView.self, forCellWithReuseIdentifier: "Simulate")
        _contentView.register(SAAudioTalkbackView.self, forCellWithReuseIdentifier: "Talkback")
        _contentView.register(SAAudioRecordView.self, forCellWithReuseIdentifier: "Record")
        
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
        return 3
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Simulate", for: indexPath)
        case 1:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Talkback", for: indexPath)
        case 2:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Record", for: indexPath)
        default:
            fatalError()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = .random
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}
