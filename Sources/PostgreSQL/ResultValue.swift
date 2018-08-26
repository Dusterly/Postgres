import Foundation

public protocol ResultValue {
	init(pqValue bytes: UnsafeMutablePointer<Int8>, count: Int)
}

extension FixedWidthInteger where Self: ResultValue {
	public init(pqValue bytes: UnsafeMutablePointer<Int8>, count: Int) {
		let bigEndian = bytes.withMemoryRebound(to: Self.self, capacity: 1) { $0.pointee }
		self.init(bigEndian: bigEndian)
	}
}

extension Int16: ResultValue {}
extension Int32: ResultValue {}
extension Int64: ResultValue {}
extension Int: ResultValue {}

extension Float: ResultValue {
	public init(pqValue bytes: UnsafeMutablePointer<Int8>, count: Int) {
		let bigEndian = bytes.withMemoryRebound(to: UInt32.self, capacity: 1) { $0.pointee }
		self.init(Float32(bitPattern: UInt32(bigEndian: bigEndian)))
	}
}

extension Double: ResultValue {
	public init(pqValue bytes: UnsafeMutablePointer<Int8>, count: Int) {
		let bigEndian = bytes.withMemoryRebound(to: UInt64.self, capacity: 1) { $0.pointee }
		self.init(Float64(bitPattern: UInt64(bigEndian: bigEndian)))
	}
}

extension String: ResultValue {
	public init(pqValue bytes: UnsafeMutablePointer<Int8>, count: Int) {
		self.init(cString: bytes)
	}
}

extension Data: ResultValue {
	public init(pqValue bytes: UnsafeMutablePointer<Int8>, count: Int) {
		self.init(bytes: bytes, count: count)
	}
}
