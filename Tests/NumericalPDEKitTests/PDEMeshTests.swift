//
//  PDEMeshTests.swift
//  
//
//  Created by Christopher Fredregill on 3/13/22.
//

import XCTest
import simd
@testable import NumericalPDEKit

final class PDEMeshTests: XCTestCase {

    func testSquare2DMesh() throws {
        let mesh = MeshFactory.make2DGrid(width: 15.0, height: 15.0, h: 5.0)
        let meshPoints: [[[UnknownPoint]]] = mesh.unknowns

        XCTAssertEqual(meshPoints.count, 4)
        for row in meshPoints {
            XCTAssertEqual(row.count, 4)
            for column in row {
                XCTAssertEqual(column.count, 1)
            }
        }

        XCTAssertEqual(mesh.unknowns[0][0][0].location, simd.simd_double3(x: 0.0, y: 0.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[0][1][0].location, simd.simd_double3(x: 0.0, y: 5.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[0][2][0].location, simd.simd_double3(x: 0.0, y: 10.0, z: 0.0))
        XCTAssertEqual(mesh.unknowns[0][3][0].location, simd.simd_double3(x: 0.0, y: 15.0, z: 0.0))

        XCTAssertEqual(mesh.unknowns[1][0][0].location, simd.simd_double3(x: 5.0, y: 0.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[1][1][0].location, simd.simd_double3(x: 5.0, y: 5.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[1][2][0].location, simd.simd_double3(x: 5.0, y: 10.0, z: 0.0))
        XCTAssertEqual(mesh.unknowns[1][3][0].location, simd.simd_double3(x: 5.0, y: 15.0, z: 0.0))

        XCTAssertEqual(mesh.unknowns[2][0][0].location, simd.simd_double3(x: 10.0, y: 0.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[2][1][0].location, simd.simd_double3(x: 10.0, y: 5.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[2][2][0].location, simd.simd_double3(x: 10.0, y: 10.0, z: 0.0))
        XCTAssertEqual(mesh.unknowns[2][3][0].location, simd.simd_double3(x: 10.0, y: 15.0, z: 0.0))

        XCTAssertEqual(mesh.unknowns[3][0][0].location, simd.simd_double3(x: 15.0, y: 0.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[3][1][0].location, simd.simd_double3(x: 15.0, y: 5.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[3][2][0].location, simd.simd_double3(x: 15.0, y: 10.0, z: 0.0))
        XCTAssertEqual(mesh.unknowns[3][3][0].location, simd.simd_double3(x: 15.0, y: 15.0, z: 0.0))
    }

    func testRectangular3DMesh() throws {
        let mesh = MeshFactory.make3DGrid(width: 15.0, height: 15.0, depth: 5.0, h: 5.0)
        let meshPoints: [[[UnknownPoint]]] = mesh.unknowns

        XCTAssertEqual(meshPoints.count, 4)
        for row in meshPoints {
            XCTAssertEqual(row.count, 4)
            for column in row {
                XCTAssertEqual(column.count, 2)
            }
        }

        // z=0

        XCTAssertEqual(mesh.unknowns[0][0][0].location, simd.simd_double3(x: 0.0, y: 0.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[0][1][0].location, simd.simd_double3(x: 0.0, y: 5.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[0][2][0].location, simd.simd_double3(x: 0.0, y: 10.0, z: 0.0))
        XCTAssertEqual(mesh.unknowns[0][3][0].location, simd.simd_double3(x: 0.0, y: 15.0, z: 0.0))

        XCTAssertEqual(mesh.unknowns[1][0][0].location, simd.simd_double3(x: 5.0, y: 0.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[1][1][0].location, simd.simd_double3(x: 5.0, y: 5.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[1][2][0].location, simd.simd_double3(x: 5.0, y: 10.0, z: 0.0))
        XCTAssertEqual(mesh.unknowns[1][3][0].location, simd.simd_double3(x: 5.0, y: 15.0, z: 0.0))

        XCTAssertEqual(mesh.unknowns[2][0][0].location, simd.simd_double3(x: 10.0, y: 0.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[2][1][0].location, simd.simd_double3(x: 10.0, y: 5.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[2][2][0].location, simd.simd_double3(x: 10.0, y: 10.0, z: 0.0))
        XCTAssertEqual(mesh.unknowns[2][3][0].location, simd.simd_double3(x: 10.0, y: 15.0, z: 0.0))

        XCTAssertEqual(mesh.unknowns[3][0][0].location, simd.simd_double3(x: 15.0, y: 0.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[3][1][0].location, simd.simd_double3(x: 15.0, y: 5.0,  z: 0.0))
        XCTAssertEqual(mesh.unknowns[3][2][0].location, simd.simd_double3(x: 15.0, y: 10.0, z: 0.0))
        XCTAssertEqual(mesh.unknowns[3][3][0].location, simd.simd_double3(x: 15.0, y: 15.0, z: 0.0))

        // z=5

        XCTAssertEqual(mesh.unknowns[0][0][1].location, simd.simd_double3(x: 0.0, y: 0.0,  z: 5.0))
        XCTAssertEqual(mesh.unknowns[0][1][1].location, simd.simd_double3(x: 0.0, y: 5.0,  z: 5.0))
        XCTAssertEqual(mesh.unknowns[0][2][1].location, simd.simd_double3(x: 0.0, y: 10.0, z: 5.0))
        XCTAssertEqual(mesh.unknowns[0][3][1].location, simd.simd_double3(x: 0.0, y: 15.0, z: 5.0))

        XCTAssertEqual(mesh.unknowns[1][0][1].location, simd.simd_double3(x: 5.0, y: 0.0,  z: 5.0))
        XCTAssertEqual(mesh.unknowns[1][1][1].location, simd.simd_double3(x: 5.0, y: 5.0,  z: 5.0))
        XCTAssertEqual(mesh.unknowns[1][2][1].location, simd.simd_double3(x: 5.0, y: 10.0, z: 5.0))
        XCTAssertEqual(mesh.unknowns[1][3][1].location, simd.simd_double3(x: 5.0, y: 15.0, z: 5.0))

        XCTAssertEqual(mesh.unknowns[2][0][1].location, simd.simd_double3(x: 10.0, y: 0.0,  z: 5.0))
        XCTAssertEqual(mesh.unknowns[2][1][1].location, simd.simd_double3(x: 10.0, y: 5.0,  z: 5.0))
        XCTAssertEqual(mesh.unknowns[2][2][1].location, simd.simd_double3(x: 10.0, y: 10.0, z: 5.0))
        XCTAssertEqual(mesh.unknowns[2][3][1].location, simd.simd_double3(x: 10.0, y: 15.0, z: 5.0))

        XCTAssertEqual(mesh.unknowns[3][0][1].location, simd.simd_double3(x: 15.0, y: 0.0,  z: 5.0))
        XCTAssertEqual(mesh.unknowns[3][1][1].location, simd.simd_double3(x: 15.0, y: 5.0,  z: 5.0))
        XCTAssertEqual(mesh.unknowns[3][2][1].location, simd.simd_double3(x: 15.0, y: 10.0, z: 5.0))
        XCTAssertEqual(mesh.unknowns[3][3][1].location, simd.simd_double3(x: 15.0, y: 15.0, z: 5.0))
    }
}
