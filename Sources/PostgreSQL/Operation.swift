#if os(macOS)
import LibpqMac
#else
import LibpqLinux
#endif

struct Operation {
	let resPointer: OpaquePointer

	public func scalar<T: ResultValue>() throws -> T? {
		guard PQgetisnull(resPointer, 0, 0) != 1 else { return nil }
		guard let value = PQgetvalue(resPointer, 0, 0) else { return nil }

		return T.init(pqValue: value, count: Int(PQgetlength(resPointer, 0, 0)))
	}

	public func resultSet() throws -> [[String: ResultValue]] {
		var result: [[String: ResultValue]] = []
		let rows = PQntuples(resPointer)
		for row in 0..<rows {
			result.append(ResultRow(resPointer: resPointer, row: row).columnValues())
		}
		return result
	}
}
