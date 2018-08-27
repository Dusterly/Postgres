#if os(macOS)
import LibpqMac
#else
import LibpqLinux
#endif
import Foundation

public struct Connection {
	let connPointer: OpaquePointer

	public init(host: String,
	            port: UInt16 = 5432,
	            database: String,
	            credentials: Credentials) throws {
		let connectionString = "host=\(host) " +
				"port=\(port) " +
				"dbname=\(database) " +
				"user=\(credentials.username) " +
				"password=\(credentials.password)"
		guard let conn = PQconnectdb(connectionString) else {
			throw PostgreSQLError.generic
		}
		guard PQstatus(conn) == CONNECTION_OK else {
			throw PostgreSQLError.message(lastErrorMessage(for: conn))
		}
		self.connPointer = conn
	}

	public func scalar<T: ResultValue>(executing query: String) throws -> T? {
		guard let res = PQexecParams(connPointer, query, 0, [], [], [], [], 1) else {
			throw PostgreSQLError.message(lastErrorMessage(for: connPointer))
		}

		guard PQgetisnull(res, 0, 0) != 1 else { return nil }
		guard let value = PQgetvalue(res, 0, 0) else { return nil }

		return T.init(pqValue: value, count: Int(PQgetlength(res, 0, 0)))
	}

	public func resultSet(executing query: String) throws -> [[String: ResultValue]] {
		guard let res = PQexecParams(connPointer, query, 0, [], [], [], [], 1) else {
			throw PostgreSQLError.message(lastErrorMessage(for: connPointer))
		}

		let rows = PQntuples(res)
		let columns = PQnfields(res)

		var result: [[String: ResultValue]] = []
		for row in 0..<rows {
			var rowData: [String: ResultValue] = [:]
			for column in 0..<columns {
				guard PQgetisnull(res, row, column) != 1 else { continue }
				guard let value = PQgetvalue(res, row, column) else { continue }

				let name = String(cString: PQfname(res, Int32(column)))
				let type = datatype(res: res, column: column)
				rowData[name] = type.init(pqValue: value, count: Int(PQgetlength(res, row, column)))
			}
			result.append(rowData)
		}
		return result
	}

	private func datatype(res: OpaquePointer, column: Int32) -> ResultValue.Type {
		switch PQftype(res, column) {
		case 20, 21, 23: return Int.self
		case 700: return Double.self
		case 25, 705: return String.self
		case 17: return Data.self
		case let type: fatalError("unsupported data type \(type)")
		}
	}
}

enum PostgreSQLError: Error {
	case generic
	case message(String)
}

private func lastErrorMessage(for cPointer: OpaquePointer) -> String {
	guard let cString = PQerrorMessage(cPointer) else {
		return ""
	}
	return String(cString: cString)
}
