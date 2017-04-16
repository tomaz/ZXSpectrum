//
//  Created by Tomaz Kragelj on 11.06.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

private let MarkerPrefix = "---------- "

enum LogVerbosity: Int {
	case None
	case Error
	case Warning
	case Info
	case Verbose
	case Debug
}

func >= (left: LogVerbosity, right: LogVerbosity) -> Bool {
	return left.rawValue >= right.rawValue
}

class Logger {

	private static var loggingVerbosity: Int {
		return UserDefaults.standard.integer(forKey: "LoggingVerbosity")
	}
	
	private static var loggingOnBackgroundThread: Bool {
		return UserDefaults.standard.bool(forKey: "LoggingOnBackgroundThread")
	}
	
	// MARK: - Initialization
	
	static func initialize() {
		var verbosity = LogVerbosity(rawValue: loggingVerbosity)!
		
		if ProcessInfo.processInfo.environment["TESTING"] != nil {
			verbosity = .Debug
		}
		
		if verbosity >= LogVerbosity.Error {
			Logger.error = LogChannel(name: "ERROR  ")
		}
		
		if verbosity >= LogVerbosity.Warning {
			Logger.warning = LogChannel(name: "WARNING")
		}
		
		if verbosity >= LogVerbosity.Info {
			Logger.info = LogChannel(name: "INFO   ")
		}
		
		if verbosity >= LogVerbosity.Verbose {
			Logger.verbose = LogChannel(name: "VERBOSE")
		}
		
		if verbosity >= LogVerbosity.Debug {
			Logger.debug = LogChannel(name: "DEBUG  ")
		}
		
		handler = loggingOnBackgroundThread ? LogBackThreadHandler() : LogSameThreadHandler()
	}
	
	// MARK: - Properties
	
	static fileprivate let timestampFormatter: DateFormatter = {
		let result = DateFormatter()
		result.dateFormat = "HH:mm:ss.SSS"
		return result
	}()
	
	static fileprivate var handler: LogHandling!

	// MARK: - Channels
	
	static fileprivate var error: LogChannel?
	static fileprivate var warning: LogChannel?
	static fileprivate var info: LogChannel?
	static fileprivate var verbose: LogChannel?
	static fileprivate var debug: LogChannel?
}

// MARK: - Log handling

private protocol LogHandling {
	func log(block: @escaping () -> Void)
}

private class LogSameThreadHandler: LogHandling {
	
	internal func log(block: @escaping () -> Void) {
		block()
	}
	
}

private class LogBackThreadHandler: LogHandling {
	
	init() {
		queue = OperationQueue()
		queue.name = "com.gentlebytes.Logger"
		queue.maxConcurrentOperationCount = 1
	}
	
	internal func log(block: @escaping () -> Void) {
		queue.addOperation(block)
	}
	
	private var queue: OperationQueue
}

// MARK: - Log channel

private class LogChannel {
	
	init(name: String) {
		self.name = name
	}
	
	func message(_ message: String, function: String, filename: String, line: Int) {
		Logger.handler.log {
			let time = Logger.timestampFormatter.string(from: Date())
			let file = (filename as NSString).lastPathComponent
			print("\(time) [\(self.name)] \(file):\(line) | \(message)")
		}
	}
	
	private var name: String
	
}

// MARK: - Logging functions

func gerror(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.error?.message(message(), function: function, filename: filename, line: line)
}

func gwarn(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.warning?.message(message(), function: function, filename: filename, line: line)
}

func ginfo(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.info?.message(message(), function: function, filename: filename, line: line)
}

func gverbose(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.verbose?.message(message(), function: function, filename: filename, line: line)
}

func gdebug(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.debug?.message(message(), function: function, filename: filename, line: line)
}

func gmarker(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.debug?.message("\(MarkerPrefix)\(message())", function: function, filename: filename, line: line)
}
