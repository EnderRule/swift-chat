//
//  SAAudioView.swift
//  SIMChat
//
//  Created by sagesse on 9/16/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal protocol SAAudioViewDelegate: NSObjectProtocol {
    
    func audioView(_ audioView: SAAudioView, shouldStartRecord url: URL) -> Bool
    func audioView(_ audioView: SAAudioView, didStartRecord url: URL)
    
    func audioView(_ audioView: SAAudioView, didComplete url: URL, duration: TimeInterval)
    func audioView(_ audioView: SAAudioView, didFailure url: URL, duration: TimeInterval)
    
}

internal class SAAudioView: UICollectionViewCell {
    var audio: SAAudio?
    
    weak var delegate: SAAudioViewDelegate?
}
