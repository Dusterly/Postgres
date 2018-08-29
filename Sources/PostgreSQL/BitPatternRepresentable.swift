public protocol BitPatternRepresentable {
	associatedtype BitPattern: FixedWidthInteger

	var bitPattern: BitPattern { get }
	init(bitPattern: BitPattern)
}

extension Float: BitPatternRepresentable {}
extension Double: BitPatternRepresentable {}
