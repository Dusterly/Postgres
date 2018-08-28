#if os(macOS)
import LibpqMac
#else
import LibpqLinux
#endif

import Foundation

public protocol Parameter {
	var format: Int32 { get }
	var oid: Oid { get }
	var bytes: [Int8] { get }
}

extension Int: Parameter {
	public var format: Int32 { return 1 }
	public var oid: Oid { return 20 }
	public var bytes: [Int8] {
		let size = MemoryLayout<Int>.size
		var value = bigEndian
		let buffer = withUnsafePointer(to: &value) { valuePointer in
			return valuePointer.withMemoryRebound(to: Int8.self, capacity: size) { bytePointer in
				return UnsafeBufferPointer(start: bytePointer, count: size)
			}
		}
		return Array(buffer)
	}
}

extension Double: Parameter {
	public var format: Int32 { return 1 }
	public var oid: Oid { return 701 }
	public var bytes: [Int8] {
		let size = MemoryLayout<Int>.size
		var value = bitPattern.bigEndian
		let buffer = withUnsafePointer(to: &value) { valuePointer in
			return valuePointer.withMemoryRebound(to: Int8.self, capacity: size) { bytePointer in
				return UnsafeBufferPointer(start: bytePointer, count: size)
			}
		}
		return Array(buffer)
	}
}

extension Data: Parameter {
	public var format: Int32 { return 1 }
	public var oid: Oid { return 17 }
	public var bytes: [Int8] {
		return Array(self).map { Int8(bitPattern: $0) }
	}
}

extension String: Parameter {
	public var format: Int32 { return 0 }
	public var oid: Oid { return 0 }
	public var bytes: [Int8] {
		return Array(utf8CString)
	}
}
