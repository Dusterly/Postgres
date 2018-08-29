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

extension BinaryFloatingPoint where Self: ResultValue, Self: BitPatternRepresentable {
	public init(pqValue bytes: UnsafeMutablePointer<Int8>, count: Int) {
		let bigEndian = bytes.withMemoryRebound(to: BitPattern.self, capacity: 1) { $0.pointee }
		self.init(bitPattern: BitPattern(bigEndian: bigEndian))
	}
}

extension Float: ResultValue {}
extension Double: ResultValue {}

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
