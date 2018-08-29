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

	public func execute(_ statement: String, _ parameters: Parameter...) throws {
		do {
			_ = try resPointer(executing: statement, parameters: parameters)
		} catch {
			print(error)
			throw error
		}
	}

	public func scalar<T: ResultValue>(executing query: String, _ parameters: Parameter...) throws -> T? {
		let res = try resPointer(executing: query, parameters: parameters)

		return try Operation(resPointer: res).scalar()
	}

	public func scalar(executing query: String, _ parameters: Parameter...) throws -> ResultValue? {
		let res = try resPointer(executing: query, parameters: parameters)

		return try Operation(resPointer: res).scalar()
	}

	public func resultSet(executing query: String, _ parameters: Parameter...) throws -> [[String: ResultValue]] {
		let res = try resPointer(executing: query, parameters: parameters)

		return try Operation(resPointer: res).resultSet()
	}

	private func resPointer(executing statement: String, parameters: [Parameter]) throws -> OpaquePointer {
		let byteArrays = parameters.map { $0.bytes }
		guard let res = PQexecParams(
				connPointer, statement,
				Int32(parameters.count),
				parameters.map { $0.oid },
				byteArrays.map { UnsafePointer<Int8>($0) },
				byteArrays.map { Int32($0.count) },
				parameters.map { $0.format },
				1
		), [PGRES_TUPLES_OK, PGRES_COMMAND_OK].contains(PQresultStatus(res))
				else {
			throw PostgreSQLError.message(lastErrorMessage(for: connPointer))
		}

		return res
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
