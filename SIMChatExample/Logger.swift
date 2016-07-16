//
//  Log.swift
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

///
/// Log Manager
///
public struct Log {
    
    /// trace level
    public static func trace(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("TRACE", message: message, function: function, file: file, line: line)
    }
    /// debug level
    public static func debug(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("DEBUG", message: message, function: function, file: file, line: line)
    }
    /// info level
    public static func info(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("INFO", message: message, function: function, file: file, line: line)
    }
    /// warning level
    public static func warning(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("WARN", message: message, function: function, file: file, line: line)
    }
    /// error level
    public static func error(
        var message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        if let error = message as? NSError {
            message = "\(error.domain) => \(error.localizedDescription)"
        }
        // Forwarding
        log("ERROR", message: message, function: function, file: file, line: line)
    }
    /// fatal level
    public static func fatal(
        message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("FATAL", message: message, function: function, file: file, line: line)
    }
    /// out
    public static func log(
        level: StaticString,
        message: Any,
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        let fname = ((file as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
        #if DEBUG
            objc_sync_enter(self.queue)
            
            //[%-5p](%d{yyyy-MM-dd HH:mm:ss}) %M - %m%n
            print("[\(level)] \(fname).\(function): \(message)")
            
            objc_sync_exit(self.queue)
        #else
            dispatch_async(self.queue) {
                //[%-5p](%d{yyyy-MM-dd HH:mm:ss}) %M - %m%n
                print("[\(level)] \(fname).\(function): \(message)")
            }
        #endif
    }
    
    private(set) static var queue = dispatch_queue_create("log.queue", nil)
}