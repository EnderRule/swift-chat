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
public protocol ProgressiveObserver: NSObjectProtocol {
    
    ///
    /// Informs the observing object when the progressive value has changed.
    ///
    /// - Parameters:
    ///   - identifier: The identifier
    ///   - object: The source object of the key path keyPath.
    ///
    func observeProgressiveValue(forIdentifier identifier: String, of object: Progressiveable?)
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
    
    open dynamic func willChangeProgressiveValue(forKey key: String) {
        guard let _ = self as? Progressiveable else {
            return
        }
    }
    open dynamic func didChangeProgressiveValue(forKey key: String) {
        guard let pv = self as? Progressiveable else {
            return
        }
        _progressiveObservers.forEach { 
            guard let ob = $0 as? ProgressiveObserverTarget else {
                return
            }
            guard let observer = ob.observer else {
                return
            }
            observer.observeProgressiveValue(forIdentifier: ob.identifier, of: pv)
        }
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
        guard let _ = self as? Progressiveable else {
            return
        }
        let index = _progressiveObservers.indexOfObject(options: .init(rawValue: 0)) { 
            guard let ob = $0.0 as? ProgressiveObserverTarget else {
                return false
            }
            guard ob.observer !== observer && ob.identifier == identifier else {
                return true // is added
            }
            return false
        }
        guard index == NSNotFound else {
            return // is added
        }
        _progressiveObservers.add(ProgressiveObserverTarget(observer, identifier))
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
        guard let _ = self as? Progressiveable else {
            return
        }
        let indexes = _progressiveObservers.indexesOfObjects(options: .init(rawValue: 0)) {
            guard let ob = $0.0 as? ProgressiveObserverTarget else {
                return false
            }
            guard ob.observer !== nil else {
                return true // is release
            }
            guard ob.observer !== observer && ob.identifier == identifier else {
                return true // is removed
            }
            return false
        }
        _progressiveObservers.removeObjects(at: indexes)
    }
    
    ///
    /// Informs the observing object when the progressive value has changed.
    ///
    /// - Parameters:
    ///   - identifier: The identifier
    ///   - object: The source object of the key path keyPath.
    ///   - change: The dictionary is progressiveable content
    ///
    open dynamic func observeProgressiveValue(forIdentifier identifier: String, of object: Progressiveable?) {
        _logger.trace(identifier)
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
    private var _progressiveObservers: NSMutableArray {
        return objc_getAssociatedObject(self, &NSObject._progressiveObserversKey) as? NSMutableArray ?? {
            let dic = NSMutableArray()
            objc_setAssociatedObject(self, &NSObject._progressiveObserversKey, dic, .OBJC_ASSOCIATION_RETAIN)
            return dic
        }()
    }
}

private class ProgressiveObserverTarget: NSObject {
    
    init(_ observer: ProgressiveObserver, _ identifier: String) {
        self.identifier = identifier
        super.init()
        self.observer = observer
    }
    
    var identifier: String
    weak var observer: ProgressiveObserver?
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
            _imp[key] = newValue 
            if let ob = newValue as? Progressiveable {
                ob.addProgressiveObserver(self, forIdentifier: key)
                // notifi on set
                observeProgressiveValue(forIdentifier: key, of: ob)
            }
        }
    }
    
    override func observeProgressiveValue(forIdentifier keyPath: String, of object: Progressiveable?) {
        _observer?.observeProgressiveValue(forIdentifier: keyPath, of: object)
    }
    
    private lazy var _imp: NSMutableDictionary = NSMutableDictionary()
    private weak var _observer: ProgressiveObserver?
}

