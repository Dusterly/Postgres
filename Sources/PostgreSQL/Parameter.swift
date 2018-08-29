#if os(macOS)
import LibpqMac
#else
import LibpqLinux
#endif

import Foundation

public protocol Parameter {
	static var pqType: PQType { get }
	var format: Int32 { get }
	var bytes: [Int8] { get }
}

extension Parameter {
	public var format: Int32 { return 1 }
	public var pqType: PQType { return Self.pqType }
}

extension FixedWidthInteger {
	public var bytes: [Int8] {
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

extension Int16: Parameter {
	public static var pqType: PQType { return .int2 }
}
extension Int32: Parameter {
	public static var pqType: PQType { return .int4 }
}
extension Int64: Parameter {
	public static var pqType: PQType { return .int8 }
}
extension Int: Parameter {
	public static var pqType: PQType { return .int8 }
}

extension BinaryFloatingPoint where Self: Parameter, Self: BitPatternRepresentable {
	public var bytes: [Int8] { return bitPattern.bytes }
}

extension Float: Parameter {
	public static var pqType: PQType { return .float4 }
}
extension Double: Parameter {
	public static var pqType: PQType { return .float8 }
}

extension Data: Parameter {
	public static var pqType: PQType { return .byteArray }
	public var bytes: [Int8] {
		return Array(self).map { Int8(bitPattern: $0) }
	}
}

extension String: Parameter {
	public var format: Int32 { return 0 }
	public static var pqType: PQType { return .text }
	public var bytes: [Int8] {
		return Array(utf8CString)
	}
}
