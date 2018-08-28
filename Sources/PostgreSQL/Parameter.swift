#if os(macOS)
import LibpqMac
#else
import LibpqLinux
#endif

import Foundation

protocol Parameter {
	var oid: Oid { get }
	var bytes: [Int8] { get }
}

extension FixedWidthInteger where Self: Parameter {
	var oid: Oid { return 20 }
	var bytes: [Int8] {
		let size = MemoryLayout<Self>.size
		var value = bigEndian
		let buffer = withUnsafePointer(to: &value) { valuePointer in
			return valuePointer.withMemoryRebound(to: Int8.self, capacity: size) { bytePointer in
				return UnsafeBufferPointer(start: bytePointer, count: size)
			}
		}
		return Array(buffer)
	}
}

extension Int: Parameter {}
