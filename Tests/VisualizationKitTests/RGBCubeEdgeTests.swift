//
//  RGBCubeEdgeTests.swift
//
//
//  Created by Christopher Fredregill on 3/18/22.
//

import XCTest
@testable import VisualizationKit

class RGBCubeEdgeTests: XCTestCase {

    func testErrorTooLow() throws {
        XCTAssertNil(RGBCubeEdge.getEdge(value: -1))
    }

    func testBlueToTealLowEnd() throws {
        XCTAssertEqual(RGBCubeEdge.blueToTeal, RGBCubeEdge.getEdge(value: 0))
    }

    func testBlueToTealHighEnd() throws {
        XCTAssertEqual(RGBCubeEdge.blueToTeal, RGBCubeEdge.getEdge(value: 25))
    }

    func testTealToGreenLowEnd() throws {
        XCTAssertEqual(RGBCubeEdge.tealToGreen, RGBCubeEdge.getEdge(value: 25.1))
    }

    func testTealToGreenHighEnd() throws {
        XCTAssertEqual(RGBCubeEdge.tealToGreen, RGBCubeEdge.getEdge(value: 50))
    }

    func testGreenToYellowLowEnd() throws {
        XCTAssertEqual(RGBCubeEdge.greenToYellow, RGBCubeEdge.getEdge(value: 50.1))
    }

    func testGreenToYellowHighEnd() throws {
        XCTAssertEqual(RGBCubeEdge.greenToYellow, RGBCubeEdge.getEdge(value: 75))
    }

    func testYellowToRedLowEnd() throws {
        XCTAssertEqual(RGBCubeEdge.yellowToRed, RGBCubeEdge.getEdge(value: 75.1))
    }

    func testYellowToRedHighEnd() throws {
        XCTAssertEqual(RGBCubeEdge.yellowToRed, RGBCubeEdge.getEdge(value: 100))
    }

    func testErrorTooHigh() throws {
        XCTAssertNil(RGBCubeEdge.getEdge(value: 100.1))
    }

    func testBlueToTealMinComponents() throws {
        let (r, g, b) = RGBCubeEdge.blueToTeal.components(0.0)
        XCTAssertEqual(r, UInt32(0))
        XCTAssertEqual(g, UInt32(0))
        XCTAssertEqual(b, UInt32(255))
    }

    func testBlueToTealMidComponents() throws {
        let (r, g, b) = RGBCubeEdge.blueToTeal.components(12.5)
        XCTAssertEqual(r, UInt32(0))
        XCTAssertEqual(g, UInt32(127))
        XCTAssertEqual(b, UInt32(255))
    }

    func testBlueToTealMaxComponents() throws {
        let (r, g, b) = RGBCubeEdge.blueToTeal.components(25.0)
        XCTAssertEqual(r, UInt32(0))
        XCTAssertEqual(g, UInt32(255))
        XCTAssertEqual(b, UInt32(255))
    }

    func testTealToGreenMinComponents() throws {
        let (r, g, b) = RGBCubeEdge.tealToGreen.components(25.1)
        XCTAssertEqual(r, UInt32(0))
        XCTAssertEqual(g, UInt32(255))
        XCTAssertEqual(b, UInt32(254))
    }

    func testTealToGreenMidComponents() throws {
        let (r, g, b) = RGBCubeEdge.tealToGreen.components(37.5)
        XCTAssertEqual(r, UInt32(0))
        XCTAssertEqual(g, UInt32(255))
        XCTAssertEqual(b, UInt32(128))
    }

    func testTealToGreenMaxComponents() throws {
        let (r, g, b) = RGBCubeEdge.tealToGreen.components(50.0)
        XCTAssertEqual(r, UInt32(0))
        XCTAssertEqual(g, UInt32(255))
        XCTAssertEqual(b, UInt32(0))
    }

    func testGreenToYellowMinComponents() throws {
        let (r, g, b) = RGBCubeEdge.greenToYellow.components(50.1)
        XCTAssertEqual(r, UInt32(1))
        XCTAssertEqual(g, UInt32(255))
        XCTAssertEqual(b, UInt32(0))
    }

    func testGreenToYellowMidComponents() throws {
        let (r, g, b) = RGBCubeEdge.greenToYellow.components(62.5)
        XCTAssertEqual(r, UInt32(127))
        XCTAssertEqual(g, UInt32(255))
        XCTAssertEqual(b, UInt32(0))
    }

    func testGreenToYellowMaxComponents() throws {
        let (r, g, b) = RGBCubeEdge.greenToYellow.components(75.0)
        XCTAssertEqual(r, UInt32(255))
        XCTAssertEqual(g, UInt32(255))
        XCTAssertEqual(b, UInt32(0))
    }

    func testYellowToRedMinComponents() throws {
        let (r, g, b) = RGBCubeEdge.yellowToRed.components(75.1)
        XCTAssertEqual(r, UInt32(255))
        XCTAssertEqual(g, UInt32(254))
        XCTAssertEqual(b, UInt32(0))
    }

    func testYellowToRedMidComponents() throws {
        let (r, g, b) = RGBCubeEdge.yellowToRed.components(87.5)
        XCTAssertEqual(r, UInt32(255))
        XCTAssertEqual(g, UInt32(128))
        XCTAssertEqual(b, UInt32(0))
    }

    func testYellowToRedMaxComponents() throws {
        let (r, g, b) = RGBCubeEdge.yellowToRed.components(100.0)
        XCTAssertEqual(r, UInt32(255))
        XCTAssertEqual(g, UInt32(0))
        XCTAssertEqual(b, UInt32(0))
    }
}
