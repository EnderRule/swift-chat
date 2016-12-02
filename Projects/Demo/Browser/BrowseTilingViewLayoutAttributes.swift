//
//  BrowseTilingViewLayoutAttributes.swift
//  Browser
//
//  Created by sagesse on 11/28/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseTilingViewLayoutAttributes: NSObject {
    
    init(forCellWith indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init()
    }
    
    var indexPath: IndexPath
    
    var frame: CGRect = .zero
    
    var fromFrame: CGRect = .zero
    
    override var description: String {
        return "<\(super.description), \(indexPath)>"
    }
    
    var version: Int = 0
}
