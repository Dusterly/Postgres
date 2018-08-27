import Foundation

#if os(macOS)
import LibpqMac
#else
import LibpqLinux
#endif
import Foundation

struct ResultRow {
	let resPointer: OpaquePointer
	let row: Int32

	func columnValues() -> [String: ResultValue] {
		return Dictionary(uniqueKeysWithValues: columnValuePairs().compactMap {
			guard let value = $1 else { return nil }
			return ($0, value)
		})
	}

	func columnValuePairs() -> [(String, ResultValue?)] {
		let columns = PQnfields(resPointer)
		return (0..<columns).map { column in
			return (name(ofColumnAt: column), value(at: column))
		}
	}

	private func value(at column: Int32) -> ResultValue? {
		guard PQgetisnull(resPointer, row, column) != 1 else { return nil }
		guard let pqValue = PQgetvalue(resPointer, row, column) else { return nil }

		let type = self.type(ofColumnAt: column)
		let length = Int(PQgetlength(resPointer, row, column))
		return type.init(pqValue: pqValue, count: length)
	}

	private func name(ofColumnAt column: Int32) -> String {
		return String(cString: PQfname(resPointer, Int32(column)))
	}

	private func type(ofColumnAt column: Int32) -> ResultValue.Type {
		switch PQftype(resPointer, column) {
		case 20, 21, 23: return Int.self
		case 700: return Double.self
		case 25, 705: return String.self
		case 17: return Data.self
		case let type: fatalError("unsupported data type \(type)")
		}
	}
}
