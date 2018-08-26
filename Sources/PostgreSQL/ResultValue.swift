public protocol ResultValue {
	init(value: UnsafeMutablePointer<Int8>)
}

extension Int: ResultValue {
	public init(value: UnsafeMutablePointer<Int8>) {
		let bigEndian = value.withMemoryRebound(to: Int.self, capacity: 1) { $0.pointee }
		self.init(bigEndian: bigEndian)
	}
}

extension String: ResultValue {
	public init(value: UnsafeMutablePointer<Int8>) {
		self.init(cString: value)
	}
}
