//
//  AxisTests.swift
//
//
//  Created by Christopher Fredregill on 3/18/22.
//

import XCTest
@testable import NumericalPDEKit
@testable import VisualizationKit

class AxisTests: XCTestCase {

    let solvedMesh: SolvedMesh = MeshFactory.make3DGrid(width: 5.0, height: 12.0, depth: 10.0, h: 0.1).applyInitialCondition { i, j, k in
        Double(i + j + k)
    }

    func testXDimensions() throws {
        let (width, height) = Axis.x.imageDimensions(solvedMesh)
        XCTAssertEqual(width, 120)
        XCTAssertEqual(height, 100)
    }

    func testXMaxDepth() throws {
        let depth = Axis.x.maxDepth(solvedMesh)
        XCTAssertEqual(depth, 50)
    }

    func testExtractX() throws {
        let x0Plane = Axis.x.extract(solvedMesh, level: 0)
        XCTAssertEqual(x0Plane.count, 121)
        for row in x0Plane {
            for point in row {
                XCTAssertEqual(point.location.x, 0.0)
                XCTAssertEqual(point.value, Double(point.indices.x + point.indices.y + point.indices.z))
            }
        }

        let x50Plane = Axis.x.extract(solvedMesh, level: 50)
        XCTAssertEqual(x50Plane.count, 121)
        for row in x50Plane {
            for point in row {
                XCTAssertEqual(point.location.x, 5.0)
                XCTAssertEqual(point.value, Double(point.indices.x + point.indices.y + point.indices.z))
            }
        }
    }

    func testYDimensions() throws {
        let (width, height) = Axis.y.imageDimensions(solvedMesh)
        XCTAssertEqual(width, 50)
        XCTAssertEqual(height, 100)
    }

    func testYMaxDepth() throws {
        let depth = Axis.y.maxDepth(solvedMesh)
        XCTAssertEqual(depth, 120)
    }

    func testExtractY() throws {
        let y0Plane = Axis.y.extract(solvedMesh, level: 0)
        XCTAssertEqual(y0Plane.count, 51)
        for row in y0Plane {
            for point in row {
                XCTAssertEqual(point.location.y, 0.0)
                XCTAssertEqual(point.value, Double(point.indices.x + point.indices.y + point.indices.z))
            }
        }

        let y100Plane = Axis.y.extract(solvedMesh, level: 120)
        XCTAssertEqual(y100Plane.count, 51)
        for row in y100Plane {
            for point in row {
                XCTAssertEqual(point.location.y, 12.0)
                XCTAssertEqual(point.value, Double(point.indices.x + point.indices.y + point.indices.z))
            }
        }
    }

    func testZDimensions() throws {
        let (width, height) = Axis.z.imageDimensions(solvedMesh)
        XCTAssertEqual(width, 50)
        XCTAssertEqual(height, 120)
    }

    func testZMaxDepth() throws {
        let depth = Axis.z.maxDepth(solvedMesh)
        XCTAssertEqual(depth, 100)
    }

    func testExtractZ() throws {
        let z0Plane = Axis.z.extract(solvedMesh, level: 0)
        XCTAssertEqual(z0Plane.count, 51)
        for row in z0Plane {
            for point in row {
                XCTAssertEqual(point.location.z, 0.0)
                XCTAssertEqual(point.value, Double(point.indices.x + point.indices.y + point.indices.z))
            }
        }

        let z100Plane = Axis.z.extract(solvedMesh, level: 100)
        XCTAssertEqual(z100Plane.count, 51)
        for row in z100Plane {
            for point in row {
                XCTAssertEqual(point.location.z, 10.0)
                XCTAssertEqual(point.value, Double(point.indices.x + point.indices.y + point.indices.z))
            }
        }
    }
}
