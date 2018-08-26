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

	func testHandlesBlob() throws {
		let result: Data? = try connection.scalar(executing: "select data from TestData where data is not null")

		XCTAssertEqual(result.flatMap { String(data: $0, encoding: .ascii) }, "data_only")
	}

	func testHandlesReal() throws {
		let result: Double? = try connection.scalar(executing: "select cast(3.0 as double precision)")

		XCTAssertEqual(result, 3.0)
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
