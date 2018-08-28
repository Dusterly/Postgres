#if os(macOS)
import LibpqMac
#else
import LibpqLinux
#endif

import Foundation

public protocol Parameter {
	var oid: Oid { get }
	var bytes: [Int8] { get }
}

extension Int: Parameter {
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
