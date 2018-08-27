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
		var rowData: [String: ResultValue] = [:]
		let columns = PQnfields(resPointer)
		for column in 0..<columns {
			guard PQgetisnull(resPointer, row, column) != 1 else { continue }
			guard let value = PQgetvalue(resPointer, row, column) else { continue }

			let name = String(cString: PQfname(resPointer, Int32(column)))
			let type = self.type(ofColumnAt: column)
			rowData[name] = type.init(pqValue: value, count: Int(PQgetlength(resPointer, row, column)))
		}

		return rowData
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
