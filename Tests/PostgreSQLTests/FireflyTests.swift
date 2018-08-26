import Foundation
import PostgreSQL
import XCTest

class FireflyTests: XCTestCase {
	private let fireflyHost = EnvironmentVariable(name: "firefly_postgres_host")
	private let fireflyDatabase = EnvironmentVariable(name: "firefly_postgres_database")
	private let validCredentials = Credentials(username: "postgres", password: "allowme")

	private var connection: Connection {
		return try! Connection(host: fireflyHost.value, database: fireflyDatabase.value, credentials: validCredentials)
	}

	func testThrowsIfDatabaseDoesNotExist() {
		XCTAssertThrowsError(try Connection(host: fireflyHost.value, database: "doesn't exist", credentials: validCredentials))
	}

	func testConnectsToExistingDatabase() throws {
		XCTAssertNotNil(try Connection(host: fireflyHost.value, database: fireflyDatabase.value, credentials: validCredentials))
	}

	func testThrowsIfIncorrectPassword() {
		XCTAssertThrowsError(try Connection(host: fireflyHost.value, database: fireflyDatabase.value, credentials: Credentials(username: "postgres", password: "invalid")))
	}

	func testFindsTheCrew() throws {

		let result: Int? = try connection.scalar(executing: "select count(*) from Crew")

		XCTAssertEqual(result, 8)
	}

	func testHandlesText() throws {
		let result: String? = try connection.scalar(executing: "select 'Hey, Kaylee'")

		XCTAssertEqual(result, "Hey, Kaylee")
	}

}

extension FireflyTests {
	static let allTests = [
		("testThrowsIfDatabaseDoesNotExist", testThrowsIfDatabaseDoesNotExist),
		("testConnectsToExistingDatabase", testConnectsToExistingDatabase),
		("testThrowsIfIncorrectPassword", testThrowsIfIncorrectPassword),
		("testFindsTheCrew", testFindsTheCrew),
		("testHandlesText", testHandlesText),
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
