import XCTest
@testable import CodingChallenges

final class RateLimiterTests: XCTestCase {
    func testTokenBucket() throws {
        let bucket = TokenBucket(1)
        XCTAssertTrue(bucket.consume())
        XCTAssertFalse(bucket.consume())
        sleep(1)
        XCTAssertTrue(bucket.consume())
        XCTAssertFalse(bucket.consume())
    }
    
    func testFixedWindow() throws {
        let bucket = FixedWindow(windowSizeInSeconds: 1, maxRequestPerWindow: 1) // 1 TPS
        XCTAssertTrue(bucket.consume())
        XCTAssertFalse(bucket.consume())
        sleep(1)
        XCTAssertTrue(bucket.consume())
        XCTAssertFalse(bucket.consume())
    }
    
    func testSlidingWindow() throws {
        let bucket = SlidingWindow(windowSizeInSeconds: 2, maxRequestsPerWindow: 2) // 1 TPS
        XCTAssertTrue(bucket.consume())
        XCTAssertTrue(bucket.consume())
        XCTAssertFalse(bucket.consume())
        sleep(1)
        XCTAssertFalse(bucket.consume())
        sleep(1)
        XCTAssertTrue(bucket.consume())
        sleep(1)
        XCTAssertTrue(bucket.consume())
    }
}
