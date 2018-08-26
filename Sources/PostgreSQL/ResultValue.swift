import Foundation

public protocol ResultValue {
	init(pqValue bytes: UnsafeMutablePointer<Int8>, count: Int)
}

extension Int: ResultValue {
	public init(pqValue bytes: UnsafeMutablePointer<Int8>, count: Int) {
		let bigEndian = bytes.withMemoryRebound(to: Int.self, capacity: 1) { $0.pointee }
		self.init(bigEndian: bigEndian)
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
		print("Data bytes, count: \(count)")
		self.init(bytes: bytes, count: count)
	}
}
