//
//  BrowseVideoConsoleView.swift
//  Browser
//
//  Created by sagesse on 16/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseVideoConsoleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    func play() {
        
        indicatorView.removeFromSuperview()
        operatorView.removeFromSuperview()
    }
    func wait() {
        
        operatorView.removeFromSuperview()
        
        indicatorView.frame = bounds
        indicatorView.startAnimating()
        
        addSubview(indicatorView)
    }
    func stop() {
        
        indicatorView.stopAnimating()
        indicatorView.removeFromSuperview()
        
        operatorView.setImage(UIImage(named: "photo_button_play"), for: .normal)
        operatorView.setImage(UIImage(named: "photo_button_play"), for: .highlighted)
        
        addSubview(operatorView)
    }
    
//        let view = BrowseVisualEffectButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
//        
//        view.setImage(UIImage(named: "photo_button_play"), for: .normal)
//        view.setImage(UIImage(named: "photo_button_play"), for: .highlighted)
//        
    
    func playHandler(_ sender: Any) {
        wait()
    }
    
    private func _commonInit() {
        
        operatorView.frame = bounds
        operatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        operatorView.addTarget(self, action: #selector(playHandler(_:)), for: .touchUpInside)
        
        indicatorView.frame = bounds
        indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    //var playView: UIView?
    //var stopView: UIView?
    
    lazy var indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    lazy var operatorView = BrowseVisualEffectButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
}
