//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// dispatch/time.h
// DISPATCH_TIME_NOW: ok
// DISPATCH_TIME_FOREVER: ok

import CDispatch

public struct DispatchTime : Comparable {
	public let rawValue: dispatch_time_t

	public static func now() -> DispatchTime {
		let t = CDispatch.dispatch_time(0, 0)
		return DispatchTime(rawValue: t)
	}

	public static let distantFuture = DispatchTime(rawValue: ~0)

	fileprivate init(rawValue: dispatch_time_t) { 
		self.rawValue = rawValue
	}

	/// Creates a `DispatchTime` relative to the system clock that
	/// ticks since boot.
	///
	/// - Parameters:
	///   - uptimeNanoseconds: The number of nanoseconds since boot, excluding
	///                        time the system spent asleep
	/// - Returns: A new `DispatchTime`
	/// - Discussion: This clock is the same as the value returned by
	///               `mach_absolute_time` when converted into nanoseconds.
	///               Note that `DispatchTime(uptimeNanoseconds: 0)` is
	///               equivalent to `DispatchTime.now()`, that is, its value
	///               represents the number of nanoseconds since boot (excluding
	///               system sleep time), not zero nanoseconds since boot.
	public init(uptimeNanoseconds: UInt64) {
		self.rawValue = dispatch_time_t(uptimeNanoseconds)
	}

	public var uptimeNanoseconds: UInt64 {
		return UInt64(self.rawValue)
	}
}

public func <(a: DispatchTime, b: DispatchTime) -> Bool {
	if a.rawValue == ~0 || b.rawValue == ~0 { return false }
	return a.rawValue < b.rawValue
}

public func ==(a: DispatchTime, b: DispatchTime) -> Bool {
	return a.rawValue == b.rawValue
}

public struct DispatchWallTime : Comparable {
	public let rawValue: dispatch_time_t

	public static func now() -> DispatchWallTime {
		return DispatchWallTime(rawValue: CDispatch.dispatch_walltime(nil, 0))
	}

	public static let distantFuture = DispatchWallTime(rawValue: ~0)

	fileprivate init(rawValue: dispatch_time_t) {
		self.rawValue = rawValue
	}

	public init(timespec: timespec) {
		var t = timespec
		self.rawValue = CDispatch.dispatch_walltime(&t, 0)
	}
}

public func <(a: DispatchWallTime, b: DispatchWallTime) -> Bool {
	if a.rawValue == ~0 || b.rawValue == ~0 { return false }
	return -Int64(a.rawValue) < -Int64(b.rawValue)
}

public func ==(a: DispatchWallTime, b: DispatchWallTime) -> Bool {
	return a.rawValue == b.rawValue
}

public enum DispatchTimeInterval {
	case seconds(Int)
	case milliseconds(Int)
	case microseconds(Int)
	case nanoseconds(Int)

	internal var rawValue: Int64 {
		switch self {
		case .seconds(let s): return Int64(s) * Int64(NSEC_PER_SEC)
		case .milliseconds(let ms): return Int64(ms) * Int64(NSEC_PER_MSEC)
		case .microseconds(let us): return Int64(us) * Int64(NSEC_PER_USEC)
		case .nanoseconds(let ns): return Int64(ns)
		}
	}
}

public func +(time: DispatchTime, interval: DispatchTimeInterval) -> DispatchTime {
	let t = CDispatch.dispatch_time(time.rawValue, interval.rawValue)
	return DispatchTime(rawValue: t)
}

public func -(time: DispatchTime, interval: DispatchTimeInterval) -> DispatchTime {
	let t = CDispatch.dispatch_time(time.rawValue, -interval.rawValue)
	return DispatchTime(rawValue: t)
}

public func +(time: DispatchTime, seconds: Double) -> DispatchTime {
	let interval = seconds * Double(NSEC_PER_SEC)
	let t = CDispatch.dispatch_time(time.rawValue,
		interval.isInfinite || interval.isNaN ? Int64.max : Int64(interval))
	return DispatchTime(rawValue: t)
}

public func -(time: DispatchTime, seconds: Double) -> DispatchTime {
	let interval = -seconds * Double(NSEC_PER_SEC)
	let t = CDispatch.dispatch_time(time.rawValue,
		interval.isInfinite || interval.isNaN ? Int64.min : Int64(interval))
	return DispatchTime(rawValue: t)
}

public func +(time: DispatchWallTime, interval: DispatchTimeInterval) -> DispatchWallTime {
	let t = CDispatch.dispatch_time(time.rawValue, interval.rawValue)
	return DispatchWallTime(rawValue: t)
}

public func -(time: DispatchWallTime, interval: DispatchTimeInterval) -> DispatchWallTime {
	let t = CDispatch.dispatch_time(time.rawValue, -interval.rawValue)
	return DispatchWallTime(rawValue: t)
}

public func +(time: DispatchWallTime, seconds: Double) -> DispatchWallTime {
	let interval = seconds * Double(NSEC_PER_SEC)
	let t = CDispatch.dispatch_time(time.rawValue,
		interval.isInfinite || interval.isNaN ? Int64.max : Int64(interval))
	return DispatchWallTime(rawValue: t)
}

public func -(time: DispatchWallTime, seconds: Double) -> DispatchWallTime {
	let interval = seconds * Double(NSEC_PER_SEC)
	let t = CDispatch.dispatch_time(time.rawValue,
		interval.isInfinite || interval.isNaN ? Int64.min : Int64(interval))
	return DispatchWallTime(rawValue: t)
}
