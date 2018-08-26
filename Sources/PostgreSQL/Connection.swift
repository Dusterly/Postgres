#if os(macOS)
import LibpqMac
#else
import LibpqLinux
#endif

public struct Connection {
	public init(host: String, database: String) throws {
		let connectionString = "host=\(host) port=\(5432) dbname=\(database) user=postgres"
		guard let conn = PQconnectdb(connectionString) else {
			throw PostgreSQLError.generic
		}
		guard PQstatus(conn) == CONNECTION_OK else {
			throw PostgreSQLError.message(lastErrorMessage(for: conn))
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
