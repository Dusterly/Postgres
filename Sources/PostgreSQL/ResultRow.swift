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

	func columnValues() throws -> [String: ResultValue] {
		return Dictionary(uniqueKeysWithValues: try columnValuePairs().compactMap {
			guard let value = $1 else { return nil }
			return ($0, value)
		})
	}

	func columnValuePairs() throws -> [(String, ResultValue?)] {
		let columns = PQnfields(resPointer)
		return try (0..<columns).map { column in
			return (name(ofColumnAt: column), try value(at: column))
		}
	}

	private func value(at column: Int32) throws -> ResultValue? {
		guard PQgetisnull(resPointer, row, column) != 1 else { return nil }
		guard let pqValue = PQgetvalue(resPointer, row, column) else { return nil }

		let type = try self.columnType(ofColumnAt: column)
		let length = Int(PQgetlength(resPointer, row, column))
		return type.init(pqValue: pqValue, count: length)
	}

	private func name(ofColumnAt column: Int32) -> String {
		return String(cString: PQfname(resPointer, Int32(column)))
	}

	private func columnType(ofColumnAt column: Int32) throws -> ResultValue.Type {
		let pqType = try columnType(at: column)
		return type(with: pqType)
	}

	private func columnType(at column: Int32) throws -> PQType {
		let oid = PQftype(resPointer, column)
		guard let pqType = PQType(rawValue: oid) else {
			throw PostgreSQLError.message("unsupported OID data type \(oid)")
		}
		return pqType
	}

	func type(with pqType: PQType) -> ResultValue.Type {
		let supportedTypes: [ResultValue.Type] = [
			Int.self, Int16.self, Int32.self, Int64.self,
			Float.self, Double.self,
			String.self, Data.self
		]

		return supportedTypes.first { $0.pqType == pqType }!
	}
}
