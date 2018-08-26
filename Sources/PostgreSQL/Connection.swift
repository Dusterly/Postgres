#if os(macOS)
import LibpqMac
#else
import LibpqLinux
#endif

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

	public func scalar<T: ResultValue>(executing statement: String) throws -> T? {
		guard let res = PQexecParams(connPointer, statement, 0, [], [], [], [], 1) else {
			throw PostgreSQLError.message(lastErrorMessage(for: connPointer))
		}

		guard let value = PQgetvalue(res, 0, 0) else { return nil }

		return T.init(value: value)
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
