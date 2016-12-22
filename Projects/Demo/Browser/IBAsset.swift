//
//  IBAsset.swift
//  Browser
//
//  Created by sagesse on 22/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


@objc open class IBAsset: NSObject {
    
    public override init() {
        self.resourceLoader = IBAssetResourceLoader()
        super.init()
    }
    
    open func statusOfValue(for options: IBAssetValueOptions, error outError: NSErrorPointer) -> IBAssetValueStatus {
        return .unknown
    }
    open func loadValuesAsynchronously(for options: IBAssetValueOptions, completionHandler handler: ((Any?, Error?) -> Swift.Void)? = nil) {
        
    }
    
    /// Cancels the loading of all values for all observers.
    open func cancelLoading() {
    }
    
    /// A asset resource loader
    open var resourceLoader: IBAssetResourceLoader
}
