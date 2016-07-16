//
//  Log.swift
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation


public class Logger {
    public init() {
        _name = ""
    }
    public init(name: String) {
        _name = name
    }
    
    /// trace level
    public func trace(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("TRACE", message: message, function: function, file: file, line: line)
    }
    /// debug level
    public func debug(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("DEBUG", message: message, function: function, file: file, line: line)
    }
    /// info level
    public func info(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("INFO", message: message, function: function, file: file, line: line)
    }
    /// warning level
    public func warning(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("WARN", message: message, function: function, file: file, line: line)
    }
    /// error level
    public func error(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        var msg = message
        if let error = message as? NSError {
            msg = "\(error.domain) => \(error.localizedDescription)"
        }
        log("ERROR", message: msg, function: function, file: file, line: line)
    }
    /// fatal level
    public func fatal(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("FATAL", message: message, function: function, file: file, line: line)
    }
    /// out
    public func log(
        level: StaticString,
        message: Any,
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        #if DEBUG
            objc_sync_enter(Logger._queue)
            
            //[%-5p](%d{yyyy-MM-dd HH:mm:ss}) %M - %m%n
            print("[\(level)] \(_name).\(function): \(message)")
            
            objc_sync_exit(Logger._queue)
        #else
            dispatch_async(Logger._queue) {
                //[%-5p](%d{yyyy-MM-dd HH:mm:ss}) %M - %m%n
                print("[\(level)] \(self._name).\(function): \(message)")
            }
        #endif
    }
    
    private var _name: String
    private static var _queue = dispatch_queue_create("log.queue", nil)
}

extension NSObject {
    public var _logger: Logger {
        return objc_getAssociatedObject(self, &__LOGGER) as? Logger ?? {
            let logger = Logger(name: "\(self.dynamicType)")
            objc_setAssociatedObject(self, &__LOGGER, logger, .OBJC_ASSOCIATION_RETAIN)
            return logger
        }()
    }
    public var logger: Logger {
        return _logger
    }
}

private var __LOGGER = "_logger"