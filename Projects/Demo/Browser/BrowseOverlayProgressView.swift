//
//  BrowseOverlayProgressView.swift
//  Browser
//
//  Created by sagesse on 12/9/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


open class BrowseOverlayProgressView: UIView {
   
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    open var radius: CGFloat = 3 {
        didSet {
            _layer.radius = radius
            let ani = CABasicAnimation(keyPath: "radius")
            ani.toValue = radius 
            _layer.add(ani, forKey: "radius")
            
            //_label.font = _label.font?.withSize(radius * 2)
            //_label.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
            //_label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        }
    }
    
    open var progress: Double {
        set { return setProgress(newValue, animated: false) }
        get { return _layer.progress }
    }
    
    open func setProgress(_ progress: Double, animated: Bool) {
        _layer.progress = progress
        guard !animated else {
            return
        }
        let ani = CABasicAnimation(keyPath: "progress")
        ani.toValue = progress
        _layer.add(ani, forKey: "progress")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        
        
    }
    
    open override class var layerClass: AnyClass { 
        return BrowseOverlayProgressLayer.self
    }
    
    private func _commonInit() {
        
        backgroundColor = .clear
        
//        _layer.backgroundColor = UIColor.clear.cgColor
//        _layer.fillColor = UIColor.clear.cgColor
//        _layer.strokeColor = UIColor.lightGray.cgColor
        
        
        //CTFontCreatePathForGlyph
        
        _layer.lineWidth = 1 / UIScreen.main.scale
        _layer.radius = 3
        
       // _label.text = "!"
       // _label.font = UIFont(name: "Georgia", size: _layer.radius * 2)
       // _label.textColor = UIColor.white
       // _label.textAlignment = .center
       // _label.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
       // 
       // _label.shadowColor = UIColor.random
       // _label.shadowOffset = CGSize(width: 0, height: 0)
//@prop//erty(nullable, nonatomic,strong) UIColor            *shadowColor;     // default is nil (no shadow)
//@prop//erty(nonatomic)        CGSize             shadowOffset;    // default is CGSizeMake(0, -1) -- a top shadow
       // 
       // addSubview(_label)
    }
    
    //private lazy var _label: UILabel = UILabel()
    private lazy var _layer: BrowseOverlayProgressLayer = {
        return self.layer as! BrowseOverlayProgressLayer
    }()
}

