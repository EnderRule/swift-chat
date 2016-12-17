//
//  BrowseVideoConsoleView.swift
//  Browser
//
//  Created by sagesse on 16/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


@objc protocol BrowseVideoConsoleViewDelegate {
    
    @objc optional func videoConsoleView(shouldPlay videoConsoleView: BrowseVideoConsoleView) -> Bool
    @objc optional func videoConsoleView(didPlay videoConsoleView: BrowseVideoConsoleView)
    
    @objc optional func videoConsoleView(shouldStop videoConsoleView: BrowseVideoConsoleView) -> Bool
    @objc optional func videoConsoleView(didStop videoConsoleView: BrowseVideoConsoleView)
}

class BrowseVideoConsoleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    weak var delegate: BrowseVideoConsoleViewDelegate?
    
    private(set) var isPlaying: Bool = false
    private(set) var isWaiting: Bool = false
    
    func play() {
        
        isPlaying = true
        isWaiting = false
        
        _indicatorView.removeFromSuperview()
        _operatorView.removeFromSuperview()
    }
    func wait() {
        
        isPlaying = false
        isWaiting = true
        
        _operatorView.removeFromSuperview()
        
        _indicatorView.frame = bounds
        _indicatorView.startAnimating()
        
        addSubview(_indicatorView)
    }
    func stop() {
        
        isPlaying = false
        isWaiting = false
        
        _indicatorView.stopAnimating()
        _indicatorView.removeFromSuperview()
        
        addSubview(_operatorView)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard _operatorView.superview == self else {
            return false
        }
        return super.point(inside: point, with: event)
    }
    
    func operatorHandler(_ sender: Any) {
        if isPlaying || isWaiting {
            // stop
            guard delegate?.videoConsoleView?(shouldStop: self) ?? true else {
                return
            }
            delegate?.videoConsoleView?(didStop: self)
        } else {
            // play
            guard delegate?.videoConsoleView?(shouldPlay: self) ?? true else {
                return
            }
            delegate?.videoConsoleView?(didPlay: self)
        }
    }
    
    private func _commonInit() {
        
        _operatorView.frame = bounds
        _operatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _operatorView.addTarget(self, action: #selector(operatorHandler(_:)), for: .touchUpInside)
        
        _operatorView.setImage(UIImage(named: "photo_button_play"), for: .normal)
        _operatorView.setImage(UIImage(named: "photo_button_play"), for: .highlighted)
        
        _indicatorView.frame = bounds
        _indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private lazy var _indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private lazy var _operatorView = BrowseVideoConsoleButton(frame: .zero)
}
