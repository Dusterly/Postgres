import Foundation
import PostgreSQL
import XCTest

class FireflyTests: XCTestCase {
	private let fireflyHost = EnvironmentVariable(name: "firefly_postgres_host")
	private let fireflyDatabase = EnvironmentVariable(name: "firefly_postgres_database")
	private let validCredentials = Credentials(username: "postgres")

	func testThrowsIfDatabaseDoesNotExist() {
		XCTAssertThrowsError(try Connection(host: fireflyHost.value, database: "doesn't exist", credentials: validCredentials))
	}

	func testConnectsToExistingDatabase() throws {
		XCTAssertNotNil(try Connection(host: fireflyHost.value, database: fireflyDatabase.value, credentials: validCredentials))
	}
}

extension FireflyTests {
	static let allTests = [
		("testThrowsIfDatabaseDoesNotExist", testThrowsIfDatabaseDoesNotExist),
		("testConnectsToExistingDatabase", testConnectsToExistingDatabase),
	]
}

private struct EnvironmentVariable {
	let name: String

	var value: String {
		guard let value = ProcessInfo.processInfo.environment[name] else {
			fatalError("Environment variable '\(name)' not set!")
		}
		return value
	}
}
