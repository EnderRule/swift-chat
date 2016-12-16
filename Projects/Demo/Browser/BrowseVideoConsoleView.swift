//
//  BrowseVideoConsoleView.swift
//  Browser
//
//  Created by sagesse on 16/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

protocol BrowseVideoConsoleViewDelegate: class {
    
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
    
    
    func play() {
    }
    func wait() {
    }
    func stop() {
    }
    
//        let view = BrowseVisualEffectButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
//        
//        view.setImage(UIImage(named: "photo_button_play"), for: .normal)
//        view.setImage(UIImage(named: "photo_button_play"), for: .highlighted)
//        
//        view.addTarget(self, action: #selector(playHandler(_:)), for: .touchUpInside)
    
    private func _commonInit() {
        
        let view = BrowseVisualEffectButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        
        view.setImage(UIImage(named: "photo_button_play"), for: .normal)
        view.setImage(UIImage(named: "photo_button_play"), for: .highlighted)
        
        addSubview(view)
        
//        indicatorView.frame = bounds
//        indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        indicatorView.startAnimating()
//        
//        addSubview(indicatorView)
    }
    
    //var playView: UIView?
    //var stopView: UIView?
    
    var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
}
