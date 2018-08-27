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

	public func scalar<T: ResultValue>(executing query: String, _ parameters: Int...) throws -> T? {
		let byteArrays = parameters.map { (v: Int) -> [Int8] in
			var value = v.bigEndian
			let buffer = withUnsafePointer(to: &value) { valuePointer in
				return valuePointer.withMemoryRebound(to: Int8.self, capacity: 8) { bytePointer in
					return UnsafeBufferPointer(start: bytePointer, count: 8)
				}
			}
			return Array(buffer)
		}
		guard let res = PQexecParams(
				connPointer, query,
				Int32(byteArrays.count),
				byteArrays.map { _ in 20 },
				byteArrays.map { UnsafePointer<Int8>($0) },
				byteArrays.map { _ in 8 },
				byteArrays.map { _ in 1 },
				1
		)
				else {
			throw PostgreSQLError.message(lastErrorMessage(for: connPointer))
		}

		return try Operation(resPointer: res).scalar()
	}

	public func resultSet(executing query: String) throws -> [[String: ResultValue]] {
		guard let res = PQexecParams(connPointer, query, 0, [], [], [], [], 1) else {
			throw PostgreSQLError.message(lastErrorMessage(for: connPointer))
		}

		return try Operation(resPointer: res).resultSet()
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
