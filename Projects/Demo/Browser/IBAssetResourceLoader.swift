//
//  IBAssetResourceLoader.swift
//  Browser
//
//  Created by sagesse on 22/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc open class IBAssetResourceLoader: NSObject {
    
    // The delegate object to use when handling resource requests.
    open var delegate: IBAssetResourceLoaderDelegate?
}

@objc public protocol IBAssetResourceLoaderDelegate: class {
    
    // MARK: Processing Resource Requests
    
    /// Asks the delegate if it wants to load the requested resource.
    @objc optional func resourceLoader(_ resourceLoader: IBAssetResourceLoader, shouldWaitForLoadingOfRequestedResource: IBAssetResourceLoadingRequest) -> Bool
    
    /// Invoked to inform the delegate that a prior loading request has been cancelled
    @objc optional func resourceLoader(_ resourceLoader: IBAssetResourceLoader, didCancel: IBAssetResourceLoadingRequest)
    
    /// Invoked when assistance is required of the application to renew a resource.
    @objc optional func resourceLoader(_ resourceLoader: IBAssetResourceLoader, shouldWaitForRenewalOfRequestedResource: IBAssetResourceLoadingRequest) -> Bool
    
    // MARK: Processing Authentication Challenges
    
    /// Informs the delegate that a prior authentication challenge has been cancelled.
    @objc optional func resourceLoader(_ resourceLoader: IBAssetResourceLoader, didCancel: URLAuthenticationChallenge)
    
    /// Invoked when assistance is required of the application to respond to an authentication challenge.
    @objc optional func resourceLoader(_ resourceLoader: IBAssetResourceLoader, shouldWaitForResponseTo: URLAuthenticationChallenge) -> Bool
}
