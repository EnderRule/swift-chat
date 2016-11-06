//
//  SAPBrowseableControlView.swift
//  SAPhotos
//
//  Created by sagesse on 06/11/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

internal enum SAPBrowseableControlState: Int {
   
    case playing
    case waiting
    case pauseing
    case stoped
}

internal class SAPBrowseableControlView: UIView {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
        _init()
    }
    
    var state: SAPBrowseableControlState {
        set { return setState(newValue, animated: false) }
        get { return _state }
    }
    
    func setState(_ state: SAPBrowseableControlState, animated: Bool) {
        _state = state
    }
    
    private func _init() {
        
        _playButton.frame = bounds
        _playButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _playButton.setImage(UIImage.sap_init(named: "photo_button_play"), for: .normal)
        
        addSubview(_playButton)
    }
    
    private var _state: SAPBrowseableControlState = .stoped
    
    private lazy var _playButton: UIButton = UIButton()
}
