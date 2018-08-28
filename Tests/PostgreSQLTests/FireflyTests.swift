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

	func testHandlesRealDouble() throws {
		guard let result: Double = try connection.scalar(executing: "select cast(3.0 as double precision)") else {
			return XCTFail("No result")
		}

		XCTAssertEqual(result, 3.0, accuracy: 1e-5)
	}

	func testHandlesRealFloat() throws {
		guard let result: Float = try connection.scalar(executing: "select cast(3.0 as real)") else {
			return XCTFail("No result")
		}

		XCTAssertEqual(result, 3.0, accuracy: 1e-5)
	}

	func testHandlesInt16() throws {
		let result: Int16? = try connection.scalar(executing: "select cast(3 as smallint)")

		XCTAssertEqual(result, 3)
	}

	func testHandlesInt32() throws {
		let result: Int32? = try connection.scalar(executing: "select cast(3 as int)")

		XCTAssertEqual(result, 3)
	}

	func testHandlesInt64() throws {
		let result: Int64? = try connection.scalar(executing: "select count(*) from Crew")

		XCTAssertEqual(result, 8)
	}

	func testHandlesNull() throws {
		XCTAssertNil(try connection.scalar(executing: "select null") as Int?)
		XCTAssertNil(try connection.scalar(executing: "select null") as Double?)
		XCTAssertNil(try connection.scalar(executing: "select null") as String?)
		XCTAssertNil(try connection.scalar(executing: "select null") as Data?)
	}

	func testCanReturnRows() throws {
		let result = try connection.resultSet(executing: "select name, role from Crew")

		XCTAssertEqual(result.count, 8)
		XCTAssertEqual(result.first as? [String: String], ["name": "Mal", "role": "Captain"])
	}

	func testHandlesIntegerParameters() throws {
		let result: Int? = try connection.scalar(executing: "select $1", 4)

		XCTAssertEqual(result, 4)
	}

	func testHandlesIntegerParameters_2() throws {
		let result = try connection.resultSet(executing: "select name, role from Crew where id = $1", 4)

		XCTAssertEqual(result as? [[String: String]], [["name": "Kaylee", "role": "Mechanic"]])
	}
}

extension FireflyTests {
	static let allTests = [
		("testThrowsIfDatabaseDoesNotExist", testThrowsIfDatabaseDoesNotExist),
		("testConnectsToExistingDatabase", testConnectsToExistingDatabase),
		("testThrowsIfIncorrectPassword", testThrowsIfIncorrectPassword),
		("testFindsTheCrew", testFindsTheCrew),
		("testHandlesText", testHandlesText),
		("testHandlesBlob", testHandlesBlob),
		("testHandlesRealDouble", testHandlesRealDouble),
		("testHandlesRealFloat", testHandlesRealFloat),
		("testHandlesInt16", testHandlesInt16),
		("testHandlesInt32", testHandlesInt32),
		("testHandlesInt64", testHandlesInt64),
		("testHandlesNull", testHandlesNull),
		("testCanReturnRows", testCanReturnRows),
		("testHandlesIntegerParameters", testHandlesIntegerParameters),
		("testHandlesIntegerParameters_2", testHandlesIntegerParameters_2),
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
