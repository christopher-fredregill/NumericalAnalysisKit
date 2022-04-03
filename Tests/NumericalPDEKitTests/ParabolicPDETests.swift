//
//  ParabolicPDETests.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import XCTest
import simd
@testable import NumericalPDEKit

final class ParabolicPDETests: XCTestCase {

    // shared physical constants
    let k = 0.13
    let c = 0.11
    let rho = 7.8

    func testHeatCoarse2DSquare() throws {
        let deltaTime: TimeInterval = 16.5
        let maxTime: TimeInterval = 49.5
        let h: Double = 5
        let r = k * deltaTime / (c * rho * (h * h))

        let mesh = MeshFactory.make2DGrid(width: 15, height: 15, h: h).applyInitialCondition { _, _, _ in 0.0 }

        let boundaryCondition: BoundaryCondition = { i, j, _ in
            if i == mesh.dimensions.x || j == mesh.dimensions.y {
                return 100
            } else if i == 0 || j == 0 {
                return 0
            } else {
                return nil
            }
        }

        let heatLHS: DiscretizedLHS = { (indices: simd_int3) in
            return [
                indices &+ simd_int3(x: 1, y: 0, z: 0) : -1,
                indices &+ simd_int3(x: 0, y: 1, z: 0) : -1,
                indices &- simd_int3(x: 1, y: 0, z: 0) : -1,
                indices &- simd_int3(x: 0, y: 1, z: 0) : -1,
                indices : (2 + 4 * r) / r
            ]
        }

        let heatRHS: DiscretizedRHS = { (indices: simd_int3) in
            return (
                0,
                [
                    indices &+ simd_int3(x: 1, y: 0, z: 0) : 1,
                    indices &+ simd_int3(x: 0, y: 1, z: 0) : 1,
                    indices &- simd_int3(x: 1, y: 0, z: 0) : 1,
                    indices &- simd_int3(x: 0, y: 1, z: 0) : 1,
                    indices : (2 - 4 * r) / r
                ]
            )
        }

        var pde = ParabolicPDE(lhs: heatLHS, rhs: heatRHS, initialMesh: mesh, boundaryCondition: boundaryCondition)
        var solvedMeshes = [SolvedMesh]()
        pde.solve(maxTime: maxTime, deltaTime: deltaTime) { solvedMesh in
            solvedMeshes.append(solvedMesh)
            print("t=\(solvedMesh.time) solved...")
        }

        XCTAssertEqual(solvedMeshes.count, 4)

        let allExpectedValues = [
            (
                0.0,
                [
                    simd_int3(x: 0,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 1,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 2,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 3,    z: 0) : 0.0,

                    simd_int3(x: 1,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 1,    y: 1,    z: 0) : 0.0,
                    simd_int3(x: 1,    y: 2,    z: 0) : 0.0,
                    simd_int3(x: 1,    y: 3,    z: 0) : 0.0,

                    simd_int3(x: 2,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 2,    y: 1,    z: 0) : 0.0,
                    simd_int3(x: 2,    y: 2,    z: 0) : 0.0,
                    simd_int3(x: 2,    y: 3,    z: 0) : 0.0,

                    simd_int3(x: 3,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 3,    y: 1,    z: 0) : 0.0,
                    simd_int3(x: 3,    y: 2,    z: 0) : 0.0,
                    simd_int3(x: 3,    y: 3,    z: 0) : 0.0,
                ]
            ),
            (
                16.5,
                [
                    simd_int3(x: 0,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 1,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 2,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 3,    z: 0) : 100.0,

                    simd_int3(x: 1,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 1,    y: 1,    z: 0) : 0.3787,
                    simd_int3(x: 1,    y: 2,    z: 0) : 4.5454,
                    simd_int3(x: 1,    y: 3,    z: 0) : 100.0,

                    simd_int3(x: 2,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 2,    y: 1,    z: 0) : 4.5454,
                    simd_int3(x: 2,    y: 2,    z: 0) : 8.7121,
                    simd_int3(x: 2,    y: 3,    z: 0) : 100.0,

                    simd_int3(x: 3,    y: 0,    z: 0) : 100.0,
                    simd_int3(x: 3,    y: 1,    z: 0) : 100.0,
                    simd_int3(x: 3,    y: 2,    z: 0) : 100.0,
                    simd_int3(x: 3,    y: 3,    z: 0) : 100.0,
                ]
            ),
            (
                33.0,
                [
                    simd_int3(x: 0,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 1,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 2,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 3,    z: 0) : 100.0,

                    simd_int3(x: 1,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 1,    y: 1,    z: 0) : 1.6988,
                    simd_int3(x: 1,    y: 2,    z: 0) : 12.8099,
                    simd_int3(x: 1,    y: 3,    z: 0) : 100.0,

                    simd_int3(x: 2,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 2,    y: 1,    z: 0) : 12.8099,
                    simd_int3(x: 2,    y: 2,    z: 0) : 23.9210,
                    simd_int3(x: 2,    y: 3,    z: 0) : 100.0,

                    simd_int3(x: 3,    y: 0,    z: 0) : 100.0,
                    simd_int3(x: 3,    y: 1,    z: 0) : 100.0,
                    simd_int3(x: 3,    y: 2,    z: 0) : 100.0,
                    simd_int3(x: 3,    y: 3,    z: 0) : 100.0,
                ]
            ),
            (
                49.5,
                [
                    simd_int3(x: 0,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 1,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 2,    z: 0) : 0.0,
                    simd_int3(x: 0,    y: 3,    z: 0) : 100.0,

                    simd_int3(x: 1,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 1,    y: 1,    z: 0) : 3.8310,
                    simd_int3(x: 1,    y: 2,    z: 0) : 19.5717,
                    simd_int3(x: 1,    y: 3,    z: 0) : 100.0,

                    simd_int3(x: 2,    y: 0,    z: 0) : 0.0,
                    simd_int3(x: 2,    y: 1,    z: 0) : 19.5717,
                    simd_int3(x: 2,    y: 2,    z: 0) : 35.3124,
                    simd_int3(x: 2,    y: 3,    z: 0) : 100.0,

                    simd_int3(x: 3,    y: 0,    z: 0) : 100.0,
                    simd_int3(x: 3,    y: 1,    z: 0) : 100.0,
                    simd_int3(x: 3,    y: 2,    z: 0) : 100.0,
                    simd_int3(x: 3,    y: 3,    z: 0) : 100.0,
                ]
            )
        ]

        for (index, solvedMesh) in solvedMeshes.enumerated() {
            let (expectedTime, expectedValues) = allExpectedValues[index]
            XCTAssertEqual(solvedMesh.time, expectedTime)

            for (location, expectedValue) in expectedValues {
                let (i, j, k) = location.ijk
                XCTAssertEqual(solvedMesh.knowns[i][j][k].value, expectedValue, accuracy: 0.0001)
                XCTAssertEqual(solvedMesh.knowns[i][j][k].location.x, Double(i) * h, accuracy: 0.0001)
                XCTAssertEqual(solvedMesh.knowns[i][j][k].location.y, Double(j) * h, accuracy: 0.0001)
                XCTAssertEqual(solvedMesh.knowns[i][j][k].location.z, Double(k) * h, accuracy: 0.0001)
                XCTAssertEqual(solvedMesh.knowns[i][j][k].indices.x, Int32(i))
                XCTAssertEqual(solvedMesh.knowns[i][j][k].indices.y, Int32(j))
                XCTAssertEqual(solvedMesh.knowns[i][j][k].indices.z, Int32(k))
            }
        }
    }

    func testHeatFine2DSquare() throws {
        let deltaTime: TimeInterval = 1
        let maxTime: TimeInterval = 100
        let h: Double = 0.1
        let r = k * deltaTime / (c * rho * (h * h))

        let mesh = MeshFactory.make2DGrid(width: 15, height: 15, h: h).applyInitialCondition { _, _, _ in 0.0 }

        let boundaryCondition: BoundaryCondition = { i, j, _ in
            if i == mesh.dimensions.x || j == mesh.dimensions.y {
                return 100
            } else if i == 0 || j == 0 {
                return 0
            } else {
                return nil
            }
        }

        let heatLHS: DiscretizedLHS = { (indices: simd_int3) in
            return [
                indices &+ simd_int3(x: 1, y: 0, z: 0) : -1,
                indices &+ simd_int3(x: 0, y: 1, z: 0) : -1,
                indices &- simd_int3(x: 1, y: 0, z: 0) : -1,
                indices &- simd_int3(x: 0, y: 1, z: 0) : -1,
                indices : (2 + 4 * r) / r
            ]
        }

        let heatRHS: DiscretizedRHS = { (indices: simd_int3) in
            return (
                0,
                [
                    indices &+ simd_int3(x: 1, y: 0, z: 0) : 1,
                    indices &+ simd_int3(x: 0, y: 1, z: 0) : 1,
                    indices &- simd_int3(x: 1, y: 0, z: 0) : 1,
                    indices &- simd_int3(x: 0, y: 1, z: 0) : 1,
                    indices : (2 - 4 * r) / r
                ]
            )
        }

        var pde = ParabolicPDE(lhs: heatLHS, rhs: heatRHS, initialMesh: mesh, boundaryCondition: boundaryCondition)
        var solvedMeshes = [SolvedMesh]()

        pde.solve(maxTime: maxTime, deltaTime: deltaTime) {
            solvedMesh in solvedMeshes.append(solvedMesh)
            print("t=\(solvedMesh.time) solved...")
        }
        XCTAssertEqual(solvedMeshes.count, 101)

        XCTAssertEqual(solvedMeshes[0].knowns[60][60][0].value, 0.0, accuracy: 0.0001)
        XCTAssertEqual(solvedMeshes[20].knowns[60][60][0].value, 0.0445, accuracy: 0.0001)
        XCTAssertEqual(solvedMeshes[40].knowns[60][60][0].value, 1.7474, accuracy: 0.0001)
        XCTAssertEqual(solvedMeshes[60].knowns[60][60][0].value, 5.9768, accuracy: 0.0001)
        XCTAssertEqual(solvedMeshes[80].knowns[60][60][0].value, 10.9276, accuracy: 0.0001)
        XCTAssertEqual(solvedMeshes[100].knowns[60][60][0].value, 15.5165, accuracy: 0.0001)
    }
}
