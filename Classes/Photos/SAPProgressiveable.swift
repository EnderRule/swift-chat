//
//  SAPProgressiveable.swift
//  SAC
//
//  Created by sagesse on 10/13/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 可渐进显示协议
///
@objc public protocol SAPProgressiveable {
    
    ///
    /// 内容
    ///
    var content: Any? { set get }
    
    ///
    /// 添加监听者
    ///
    /// - Parameter observer: 监听者, 这是weak
    ///
    func addObserver(_ observer: SAPProgressiveableObserver)
    
    ///
    /// 移除监听者(如果有)
    ///
    /// - Parameter observer: 监听者
    ///
    func removeObserver(_ observer: SAPProgressiveableObserver)
}

///
/// 可渐进监听器
///
@objc public protocol SAPProgressiveableObserver: NSObjectProtocol {
    
    ///
    /// 内容发生改变
    ///
    func progressiveable(_ progressiveable: SAPProgressiveable, didChangeContent content: Any?)
}


@objc 
public protocol Progressiveable {
    
    ///
    /// Registers the observer object to receive KVO notifications for progressive value
    ///
    /// An object that calls this method must also eventually call either the 
    /// removeProgressiveObserver(_:forKeyPath:) method to unregister the observer when participating in KVO.
    ///
    /// - Parameters:
    ///   - observer: The object to register for KVO notifications. 
    ///   - identifier: The identifier
    ///
    func addProgressiveObserver(_ observer: ProgressiveObserver, forIdentifier identifier: String)
    ///
    /// Stops the observer object from receiving change notifications for progressive value.
    ///
    /// It is an error to call removeProgressiveObserver(_:forKeyPath:) for 
    /// an object that has not previously been registered as an observer.
    ///
    /// - Parameters:
    ///   - observer: The object to remove as an observer.
    ///   - identifier: The identifier
    ///
    func removeProgressiveObserver(_ observer: ProgressiveObserver, forIdentifier identifier: String)
}

@objc
public protocol ProgressiveObserver {
    
    ///
    /// Informs the observing object when the progressive value has changed.
    ///
    /// - Parameters:
    ///   - identifier: The identifier
    ///   - object: The source object of the key path keyPath.
    ///   - change: The dictionary is progressiveable content
    ///
    func observeProgressiveValue(forIdentifier identifier: String, of object: Progressiveable?, change: [NSKeyValueChangeKey : Any]?)
}


extension NSObject: ProgressiveObserver {
    
    // MARK: - KVC
    
    open dynamic func progressiveValue(forKey key: String) -> Progressiveable? {
        return _progressiveValues[key] as? Progressiveable
    }
    open dynamic func progressiveValue(forKeyPath keyPath: String) -> Progressiveable? {
        return _progressiveValues[keyPath] as? Progressiveable
    }
    
    open dynamic func setProgressiveValue(_ value: Progressiveable?, forKey key: String) {
        _progressiveValues[key] = value
    }
    open dynamic func setProgressiveValue(_ value: Progressiveable?, forKeyPath keyPath: String) {
        _progressiveValues[keyPath] = value
    }
    
    // MARK: - KVO
    
    ///
    /// Registers the observer object to receive KVO notifications for progressive value
    ///
    /// An object that calls this method must also eventually call either the 
    /// removeProgressiveObserver(_:forKeyPath:) method to unregister the observer when participating in KVO.
    ///
    /// - Parameters:
    ///   - observer: The object to register for KVO notifications. 
    ///   - identifier: The identifier
    ///
    open dynamic func addProgressiveObserver(_ observer: ProgressiveObserver, forIdentifier identifier: String) {
        _logger.trace(identifier)
    }
    ///
    /// Stops the observer object from receiving change notifications for progressive value.
    ///
    /// It is an error to call removeProgressiveObserver(_:forKeyPath:) for 
    /// an object that has not previously been registered as an observer.
    ///
    /// - Parameters:
    ///   - observer: The object to remove as an observer.
    ///   - identifier: The identifier
    ///
    open dynamic func removeProgressiveObserver(_ observer: ProgressiveObserver, forIdentifier identifier: String) {
        _logger.trace(identifier)
    }
    
    open dynamic func willChangeProgressiveValue(forKey key: String) {
        willChangeValue(forKey: "")
    }
    open dynamic func didChangeProgressiveValue(forKey key: String) {
        didChangeValue(forKey: "")
    }
    
    ///
    /// Informs the observing object when the progressive value has changed.
    ///
    /// - Parameters:
    ///   - identifier: The identifier
    ///   - object: The source object of the key path keyPath.
    ///   - change: The dictionary is progressiveable content
    ///
    open dynamic func observeProgressiveValue(forIdentifier identifier: String, of object: Progressiveable?, change: [NSKeyValueChangeKey : Any]?) {
        _logger.trace()
        
    }
    
    // MARK: - Ivar
    
    private static var _progressiveValuesKey: String = "_progressiveValuesKey"
    private var _progressiveValues: ProgressiveObserveDictionary {
        return objc_getAssociatedObject(self, &NSObject._progressiveValuesKey) as? ProgressiveObserveDictionary ?? {
            let dic = ProgressiveObserveDictionary(observer: self)
            objc_setAssociatedObject(self, &NSObject._progressiveValuesKey, dic, .OBJC_ASSOCIATION_RETAIN)
            return dic
        }()
    }
    
    private static var _progressiveObserversKey: String = "_progressiveObserversKey"
    private var _progressiveObservers: NSHashTable<ProgressiveObserver> {
        return objc_getAssociatedObject(self, &NSObject._progressiveValuesKey) as? NSHashTable<ProgressiveObserver> ?? {
            let dic = NSHashTable<ProgressiveObserver>.weakObjects()
            objc_setAssociatedObject(self, &NSObject._progressiveValuesKey, dic, .OBJC_ASSOCIATION_RETAIN)
            return dic
        }()
    }
}

private class ProgressiveObserveDictionary: NSObject {
    
    init(observer: ProgressiveObserver) {
        super.init()
        // forward to observer
        _observer = observer
    }
    deinit {
        // clear observer
        _imp.forEach { 
            guard let key = $0 as? String, let ob = $1 as? Progressiveable else {
                return
            }
            ob.removeProgressiveObserver(self, forIdentifier: key)
        }
    }
    
    subscript(key: String) -> AnyObject? {
        get {
            return _imp[key] as? AnyObject
        }
        set { 
            let oldValue = _imp[key] as? AnyObject
            // value is change?
            guard newValue !== oldValue else {
                return
            }
            if let ob = oldValue as? Progressiveable {
                ob.removeProgressiveObserver(self, forIdentifier: key)
            }
            if let ob = newValue as? Progressiveable {
                ob.addProgressiveObserver(self, forIdentifier: key)
            }
            return _imp[key] = newValue 
        }
    }
    
    override func observeProgressiveValue(forIdentifier keyPath: String, of object: Progressiveable?, change: [NSKeyValueChangeKey : Any]?) {
        _observer?.observeProgressiveValue(forIdentifier: keyPath, of: object, change: change)
    }
    
    private lazy var _imp: NSMutableDictionary = NSMutableDictionary()
    private weak var _observer: ProgressiveObserver?
}

