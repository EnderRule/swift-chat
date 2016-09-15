//
//  SAEmotionPageView.swift
//  SIMChatDev
//
//  Created by sagesse on 9/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

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
        
        if let nframe = rect, page.itemType.isLarge {
            _backgroundLayer.frame = nframe
            _backgroundLayer.isHidden = false
            _backgroundLayer.removeAllAnimations()
        } else {
            _backgroundLayer.isHidden = true
        }
        
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
        //_logger.trace()
        
        _backgroundLayer.backgroundColor = UIColor(white: 0, alpha: 0.2).cgColor
        _backgroundLayer.masksToBounds = true
        _backgroundLayer.cornerRadius = 4
        
        _backspaceButton.tintColor = .gray
        _backspaceButton.setImage(_SAEmotionPanelBackspaceImage, for: .normal)
        _backspaceButton.addTarget(self, action: #selector(onBackspace(_:)), for: .touchUpInside)
        //_backspaceButton.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        
        let tapgr = UITapGestureRecognizer(target: self, action: #selector(onPress(_:)))
        let longtapgr = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        
        longtapgr.delegate = self
        longtapgr.minimumPressDuration = 0.25
        
        layer.addSublayer(_backgroundLayer)
        
        contentView.addGestureRecognizer(tapgr)
        contentView.addGestureRecognizer(longtapgr)
    }
    
    private var _activedIndexPath: IndexPath?
    
    private lazy var _backgroundLayer: CALayer = CALayer()
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

private var _SAEmotionPanelBackspaceImage: UIImage? = {
    let png = "iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAMAAAANIilAAAAAbFBMVEUAAACfn5+YmJibm5uYmJiYmJidnZ2Xl5eYmJiXl5eYmJiampqgoKCoqKiYmJiYmJiYmJiXl5eZmZmYmJiYmJiYmJiampqYmJidnZ2YmJiYmJiYmJiYmJiYmJiYmJiZmZmYmJiYmJiYmJiXl5dyF2b0AAAAI3RSTlMAFdQZ18kS86tmWiAKBeTbz7597OfhLicO+cS7tJtPPaaKco/AGfEAAAEUSURBVEjH7dXLroMgFAVQEHxUe321Vav31e7//8dOmuyYcjCYtCP2CHJcCcEDqJiYmM9kPMOZPD1s2uoCMYvxW9NgProrZY3Fa3WCdJKKWQ3fyqcWSSaXS6Ry8TijMUqOQS7bDpdK+QJIla9vnJ9WF3q1Ez2xYAucxue4QKJXu9hv4B+cBn5OzQnxq83/OCPgUMY3XGlJOPDgHtdfzohoZXynXWtaER+A0tmq1tIKuIS7Z7UFLK0b/yMfdmC2xxC8bDYmdciGsa3H0F9FvVAHNAmPY13taU8e5tCDQT1TBx9JNaVozK7LgFoIsZCshd1xAVInOvzq5d60WeilT22pX5+bTvljLMR0Rm3pRn5iY2Ji3pcHZE4k/ix2A/EAAAAASUVORK5CYII="
    return UIImage(base64Encoded: png, scale: 2)
}()
