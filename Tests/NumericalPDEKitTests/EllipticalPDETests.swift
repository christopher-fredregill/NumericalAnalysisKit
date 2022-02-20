//
//  EllipticalPDETests.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import XCTest
import simd
@testable import NumericalPDEKit

final class EllipticalPDETests: XCTestCase {

    func testLaplace2DRectangle() throws {

        let h: Double = 2.5

        let mesh = MeshFactory.make2DGrid(width: 20, height: 10, h: h)

        let boundaryCondition: BoundaryCondition = { i, j, _ in
            if i == mesh.dimensions.x {
                return 100
            } else if i == 0 || j == 0 || j == mesh.dimensions.y {
                return 0
            } else {
                return nil
            }
        }

        /*
         Left- and right-hand sides here represent Laplace's equation (∇²u = 0) in 2 spatial dimensions:

         ∂²u/∂x² + ∂²u/∂y² = 0

         LHS expression here represents the 5-point "pictorial operator" for the discretized PDE:

                          1
                          ⋮
           (1/h²) {  1 ⋯ -4 ⋯ 1  } u_ij = 0
                          ⋮
                          1

         (the RHS is simply 0)
         */

        let lapaceLHS: DiscretizedLHS = { (indices: simd_int3) in
            return [
                indices &+ simd_int3(x: 1, y: 0, z: 0) : 1,
                indices &+ simd_int3(x: 0, y: 1, z: 0) : 1,
                indices &- simd_int3(x: 1, y: 0, z: 0) : 1,
                indices &- simd_int3(x: 0, y: 1, z: 0) : 1,
                indices : -4
            ]
        }

        let laplaceRHS: DiscretizedRHS = { _ in (0.0, [:]) }

        var pde = EllipticalPDE(lhs: lapaceLHS, rhs: laplaceRHS, mesh: mesh, boundaryCondition: boundaryCondition)
        let solvedMesh = pde.solve()

        let expectedValues = [
            simd_int3(x: 0,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 1,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 2,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 3,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 4,    z: 0) : 0.0,

            simd_int3(x: 1,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 1,    y: 1,    z: 0) : 0.3530,
            simd_int3(x: 1,    y: 2,    z: 0) : 0.4988,
            simd_int3(x: 1,    y: 3,    z: 0) : 0.3530,
            simd_int3(x: 1,    y: 4,    z: 0) : 0.0,

            simd_int3(x: 2,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 2,    y: 1,    z: 0) : 0.9132,
            simd_int3(x: 2,    y: 2,    z: 0) : 1.2894,
            simd_int3(x: 2,    y: 3,    z: 0) : 0.9132,
            simd_int3(x: 2,    y: 4,    z: 0) : 0.0,

            simd_int3(x: 3,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 3,    y: 1,    z: 0) : 2.0103,
            simd_int3(x: 3,    y: 2,    z: 0) : 2.8323,
            simd_int3(x: 3,    y: 3,    z: 0) : 2.0103,
            simd_int3(x: 3,    y: 4,    z: 0) : 0.0,

            simd_int3(x: 4,   y: 0,    z: 0) : 0.0,
            simd_int3(x: 4,   y: 1,    z: 0) : 4.2957,
            simd_int3(x: 4,   y: 2,    z: 0) : 6.0193,
            simd_int3(x: 4,   y: 3,    z: 0) : 4.2957,
            simd_int3(x: 4,   y: 4,    z: 0) : 0.0,

            simd_int3(x: 5,   y: 0,    z: 0) : 0.0,
            simd_int3(x: 5,   y: 1,    z: 0) : 9.1531,
            simd_int3(x: 5,   y: 2,    z: 0) : 12.6537,
            simd_int3(x: 5,   y: 3,    z: 0) : 9.1531,
            simd_int3(x: 5,   y: 4,    z: 0) : 0.0,

            simd_int3(x: 6,   y: 0,    z: 0) : 0.0,
            simd_int3(x: 6,   y: 1,    z: 0) : 19.6631,
            simd_int3(x: 6,   y: 2,    z: 0) : 26.2893,
            simd_int3(x: 6,   y: 3,    z: 0) : 19.6631,
            simd_int3(x: 6,   y: 4,    z: 0) : 0.0,

            simd_int3(x: 7,   y: 0,    z: 0) : 0.0,
            simd_int3(x: 7,   y: 1,    z: 0) : 43.2101,
            simd_int3(x: 7,   y: 2,    z: 0) : 53.1774,
            simd_int3(x: 7,   y: 3,    z: 0) : 43.2101,
            simd_int3(x: 7,   y: 4,    z: 0) : 0.0
        ]

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

    func testLaplaceCoarse3DBox() throws {

        let h: Double = 5

        let mesh = MeshFactory.make3DGrid(width: 15, height: 15, depth: 15, h: h)

        let boundaryCondition: BoundaryCondition = { i, j, k in
            if i == 0 || j == 0 || k == 0 {
                return 100
            } else if i == mesh.dimensions.x || j == mesh.dimensions.y || k == mesh.dimensions.z {
                return 0
            } else {
                return nil
            }
        }

        /*
         Left- and right-hand sides here represent Laplace's equation (∇²u = 0) in 3 spatial dimensions:

         ∂²u/∂x² + ∂²u/∂y² + ∂²u/∂z² = 0

         LHS expression here represents the 7-point "pictorial operator" for the discretized PDE:

                           1   1
                           ⋮ ⋰
           (1/h²) {  1  ⋯ -6  ⋯ 1  } u_ijk = 0
                        ⋰  ⋮
                      1    1

         (the RHS is simply 0)
         */

        let lapaceLHS: DiscretizedLHS = { (indices: simd_int3) in
            return [
                indices &+ simd_int3(x: 1, y: 0, z: 0) : 1,
                indices &+ simd_int3(x: 0, y: 1, z: 0) : 1,
                indices &+ simd_int3(x: 0, y: 0, z: 1) : 1,
                indices &- simd_int3(x: 1, y: 0, z: 0) : 1,
                indices &- simd_int3(x: 0, y: 1, z: 0) : 1,
                indices &- simd_int3(x: 0, y: 0, z: 1) : 1,
                indices : -6
            ]
        }

        let laplaceRHS: DiscretizedRHS = { _ in (0.0, [:]) }

        var pde = EllipticalPDE(lhs: lapaceLHS, rhs: laplaceRHS, mesh: mesh, boundaryCondition: boundaryCondition)
        let solvedMesh = pde.solve()

        let expectedValues = [
            simd_int3(x: 0,    y: 0,    z: 0) : 100.0,
            simd_int3(x: 0,    y: 1,    z: 0) : 100.0,
            simd_int3(x: 0,    y: 2,    z: 0) : 100.0,
            simd_int3(x: 0,    y: 3,    z: 0) : 100.0,

            simd_int3(x: 1,    y: 0,    z: 0) : 100.0,
            simd_int3(x: 1,    y: 1,    z: 0) : 100.0,
            simd_int3(x: 1,    y: 2,    z: 0) : 100.0,
            simd_int3(x: 1,    y: 3,    z: 0) : 100.0,

            simd_int3(x: 2,    y: 0,    z: 0) : 100.0,
            simd_int3(x: 2,    y: 1,    z: 0) : 100.0,
            simd_int3(x: 2,    y: 2,    z: 0) : 100.0,
            simd_int3(x: 2,    y: 3,    z: 0) : 100.0,

            simd_int3(x: 3,    y: 0,    z: 0) : 100.0,
            simd_int3(x: 3,    y: 1,    z: 0) : 100.0,
            simd_int3(x: 3,    y: 2,    z: 0) : 100.0,
            simd_int3(x: 3,    y: 3,    z: 0) : 100.0,

            simd_int3(x: 0,    y: 0,    z: 1) : 100.0,
            simd_int3(x: 0,    y: 1,    z: 1) : 100.0,
            simd_int3(x: 0,    y: 2,    z: 1) : 100.0,
            simd_int3(x: 0,    y: 3,    z: 1) : 100.0,

            simd_int3(x: 1,    y: 0,    z: 1) : 100.0,
            simd_int3(x: 1,    y: 1,    z: 1) : 79.9999,
            simd_int3(x: 1,    y: 2,    z: 1) : 60.0000,
            simd_int3(x: 1,    y: 3,    z: 1) : 0.0,

            simd_int3(x: 2,    y: 0,    z: 1) : 100.0,
            simd_int3(x: 2,    y: 1,    z: 1) : 59.9999,
            simd_int3(x: 2,    y: 2,    z: 1) : 39.9999,
            simd_int3(x: 2,    y: 3,    z: 1) : 0.0,

            simd_int3(x: 3,    y: 0,    z: 1) : 100.0,
            simd_int3(x: 3,    y: 1,    z: 1) : 0.0,
            simd_int3(x: 3,    y: 2,    z: 1) : 0.0,
            simd_int3(x: 3,    y: 3,    z: 1) : 0.0,

            simd_int3(x: 0,    y: 0,    z: 2) : 100.0,
            simd_int3(x: 0,    y: 1,    z: 2) : 100.0,
            simd_int3(x: 0,    y: 2,    z: 2) : 100.0,
            simd_int3(x: 0,    y: 3,    z: 2) : 100.0,

            simd_int3(x: 1,    y: 0,    z: 2) : 100.0,
            simd_int3(x: 1,    y: 1,    z: 2) : 60.0000,
            simd_int3(x: 1,    y: 2,    z: 2) : 40.0000,
            simd_int3(x: 1,    y: 3,    z: 2) : 0.0,

            simd_int3(x: 2,    y: 0,    z: 2) : 100.0,
            simd_int3(x: 2,    y: 1,    z: 2) : 39.9999,
            simd_int3(x: 2,    y: 2,    z: 2) : 19.9999,
            simd_int3(x: 2,    y: 3,    z: 2) : 0.0,

            simd_int3(x: 3,    y: 0,    z: 2) : 100.0,
            simd_int3(x: 3,    y: 1,    z: 2) : 0.0,
            simd_int3(x: 3,    y: 2,    z: 2) : 0.0,
            simd_int3(x: 3,    y: 3,    z: 2) : 0.0,

            simd_int3(x: 0,    y: 0,    z: 3) : 100.0,
            simd_int3(x: 0,    y: 1,    z: 3) : 100.0,
            simd_int3(x: 0,    y: 2,    z: 3) : 100.0,
            simd_int3(x: 0,    y: 3,    z: 3) : 100.0,

            simd_int3(x: 1,    y: 0,    z: 3) : 100.0,
            simd_int3(x: 1,    y: 1,    z: 3) : 0.0,
            simd_int3(x: 1,    y: 2,    z: 3) : 0.0,
            simd_int3(x: 1,    y: 3,    z: 3) : 0.0,

            simd_int3(x: 2,    y: 0,    z: 3) : 100.0,
            simd_int3(x: 2,    y: 1,    z: 3) : 0.0,
            simd_int3(x: 2,    y: 2,    z: 3) : 0.0,
            simd_int3(x: 2,    y: 3,    z: 3) : 0.0,

            simd_int3(x: 3,    y: 0,    z: 3) : 100.0,
            simd_int3(x: 3,    y: 1,    z: 3) : 0.0,
            simd_int3(x: 3,    y: 2,    z: 3) : 0.0,
            simd_int3(x: 3,    y: 3,    z: 3) : 0.0
        ]

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

    func testPoissonCoarse2DRectangle() throws {

        let h: Double = 1

        let mesh = MeshFactory.make2DGrid(width: 6, height: 8, h: h)

        let boundaryCondition: BoundaryCondition = { i, j, _ in
            if i == 0 || j == 0 || i == mesh.dimensions.x || j == mesh.dimensions.y {
                return 0
            } else {
                return nil
            }
        }

        /*
         Left- and right-hand sides here represent Poisson's equation (∇²ϕ + f = 0) in 2 spatial dimensions.

         The LHS expression here is the same as that of the 5-point pictorial operator for Laplace's equation in 2 spatial dimensions.
         In this example, f(x,y) = 2 everywhere, so the RHS is simply -2 (moving the "2" over to the right-hand side).
         */

        let poissonLHS: DiscretizedLHS = { (indices: simd_int3) in
            return [
                indices &+ simd_int3(x: 1, y: 0, z: 0) : 1,
                indices &+ simd_int3(x: 0, y: 1, z: 0) : 1,
                indices &- simd_int3(x: 1, y: 0, z: 0) : 1,
                indices &- simd_int3(x: 0, y: 1, z: 0) : 1,
                indices : -4
            ]
        }

        let poissonRHS: DiscretizedRHS = { _ in (-2.0, [:]) }

        var pde = EllipticalPDE(lhs: poissonLHS, rhs: poissonRHS, mesh: mesh, boundaryCondition: boundaryCondition)
        let solvedMesh = pde.solve()

        let expectedValues = [
            simd_int3(x: 0,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 1,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 2,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 3,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 4,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 5,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 6,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 7,    z: 0) : 0.0,
            simd_int3(x: 0,    y: 8,    z: 0) : 0.0,

            simd_int3(x: 1,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 1,    y: 1,    z: 0) : 2.043,
            simd_int3(x: 1,    y: 2,    z: 0) : 3.124,
            simd_int3(x: 1,    y: 3,    z: 0) : 3.657,
            simd_int3(x: 1,    y: 4,    z: 0) : 3.818,
            simd_int3(x: 1,    y: 5,    z: 0) : 3.657,
            simd_int3(x: 1,    y: 6,    z: 0) : 3.123,
            simd_int3(x: 1,    y: 7,    z: 0) : 2.043,
            simd_int3(x: 1,    y: 8,    z: 0) : 0.0,

            simd_int3(x: 2,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 2,    y: 1,    z: 0) : 3.048,
            simd_int3(x: 2,    y: 2,    z: 0) : 4.794,
            simd_int3(x: 2,    y: 3,    z: 0) : 5.686,
            simd_int3(x: 2,    y: 4,    z: 0) : 5.960,
            simd_int3(x: 2,    y: 5,    z: 0) : 5.686,
            simd_int3(x: 2,    y: 6,    z: 0) : 4.794,
            simd_int3(x: 2,    y: 7,    z: 0) : 3.047,
            simd_int3(x: 2,    y: 8,    z: 0) : 0.0,

            simd_int3(x: 3,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 3,    y: 1,    z: 0) : 3.354,
            simd_int3(x: 3,    y: 2,    z: 0) : 5.319,
            simd_int3(x: 3,    y: 3,    z: 0) : 6.335,
            simd_int3(x: 3,    y: 4,    z: 0) : 6.647,
            simd_int3(x: 3,    y: 5,    z: 0) : 6.335,
            simd_int3(x: 3,    y: 6,    z: 0) : 5.319,
            simd_int3(x: 3,    y: 7,    z: 0) : 3.353,
            simd_int3(x: 3,    y: 8,    z: 0) : 0.0,

            simd_int3(x: 4,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 4,    y: 1,    z: 0) : 3.048,
            simd_int3(x: 4,    y: 2,    z: 0) : 4.794,
            simd_int3(x: 4,    y: 3,    z: 0) : 5.686,
            simd_int3(x: 4,    y: 4,    z: 0) : 5.960,
            simd_int3(x: 4,    y: 5,    z: 0) : 5.686,
            simd_int3(x: 4,    y: 6,    z: 0) : 4.794,
            simd_int3(x: 4,    y: 7,    z: 0) : 3.047,
            simd_int3(x: 4,    y: 8,    z: 0) : 0.0,

            simd_int3(x: 5,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 5,    y: 1,    z: 0) : 2.043,
            simd_int3(x: 5,    y: 2,    z: 0) : 3.124,
            simd_int3(x: 5,    y: 3,    z: 0) : 3.657,
            simd_int3(x: 5,    y: 4,    z: 0) : 3.818,
            simd_int3(x: 5,    y: 5,    z: 0) : 3.657,
            simd_int3(x: 5,    y: 6,    z: 0) : 3.123,
            simd_int3(x: 5,    y: 7,    z: 0) : 2.043,
            simd_int3(x: 5,    y: 8,    z: 0) : 0.0,

            simd_int3(x: 6,    y: 0,    z: 0) : 0.0,
            simd_int3(x: 6,    y: 1,    z: 0) : 0.0,
            simd_int3(x: 6,    y: 2,    z: 0) : 0.0,
            simd_int3(x: 6,    y: 3,    z: 0) : 0.0,
            simd_int3(x: 6,    y: 4,    z: 0) : 0.0,
            simd_int3(x: 6,    y: 5,    z: 0) : 0.0,
            simd_int3(x: 6,    y: 6,    z: 0) : 0.0,
            simd_int3(x: 6,    y: 7,    z: 0) : 0.0,
            simd_int3(x: 6,    y: 8,    z: 0) : 0.0
        ]

        for (location, expectedValue) in expectedValues {
            let (i, j, k) = location.ijk
            XCTAssertEqual(solvedMesh.knowns[i][j][k].value, expectedValue, accuracy: 0.001)
            XCTAssertEqual(solvedMesh.knowns[i][j][k].location.x, Double(i) * h, accuracy: 0.0001)
            XCTAssertEqual(solvedMesh.knowns[i][j][k].location.y, Double(j) * h, accuracy: 0.0001)
            XCTAssertEqual(solvedMesh.knowns[i][j][k].location.z, Double(k) * h, accuracy: 0.0001)
            XCTAssertEqual(solvedMesh.knowns[i][j][k].indices.x, Int32(i))
            XCTAssertEqual(solvedMesh.knowns[i][j][k].indices.y, Int32(j))
            XCTAssertEqual(solvedMesh.knowns[i][j][k].indices.z, Int32(k))
        }
    }

    func testPoissonCoarse2DRectangleDerviativeBoundaryConditions() throws {

        let q: Double = 5
        let k: Double = 0.16
        let h: Double = 1

        let mesh = MeshFactory.make2DGrid(width: 8, height: 4, h: h)

        /*
         Left- and right-hand sides here represent Poisson's equation (∇²ϕ + f = 0) in 2 spatial dimensions.

         The LHS and RHS in are adapted to include derivative boundary conditions of the following form:

         a * u - b * ∂u/∂x = c (where a, b, and c are constants)

         The pictorial operator changes on the left and right edges, depending on these derivative boundary conditions.
         It does not change in the j-direction; top and bottom edges are held constant (Dirichlet boundary conditions).
         */

        let boundaryCondition: BoundaryCondition = { i, j, _ in
            if j == 0 || j == mesh.dimensions.y {
                return 20
            } else {
                return nil
            }
        }

        let poissonLHS: DiscretizedLHS = { (indices: simd_int3) in
            func derivativeLRCoefficients(_ index: Int) -> (Double, Double) {
                if index == 0 {
                    // on the left edge, weight 0 left, and 2 right
                    return (0, 2)
                } else if index == mesh.dimensions.x {
                    // on the right edge, weight 2 left, and 0 right
                    return (2, 0)
                } else {
                    // everywhere else, use standard 5-point operator coefficients on both sides
                    return (1, 1)
                }
            }
            let (i, _, _) = indices.ijk
            let (l, r) = derivativeLRCoefficients(i)

            return [
                indices &+ simd_int3(x: 1, y: 0, z: 0) : r,
                indices &+ simd_int3(x: 0, y: 1, z: 0) : 1,
                indices &- simd_int3(x: 1, y: 0, z: 0) : l,
                indices &- simd_int3(x: 0, y: 1, z: 0) : 1,
                indices : -4
            ]
        }

        let poissonRHS: DiscretizedRHS = { (indices: simd_int3) in
            func derivativeBoundary(_ location: simd_int3) -> Double {
                let (i, _, _) = location.ijk
                // ∂u/∂x = 15 on the left and right edges of the sheet
                let gradient: Double = 15
                if i == 0 || i == mesh.dimensions.x {
                    return 2 * gradient / h
                } else {
                    return 0.0
                }
            }
            // if the RHS is evaluated at an interior point, its value is simply -q/k
            // if it is evaluated on the left or right edge, a term based on ∂u/∂x will appear as well
            return (
                (derivativeBoundary(indices) - (q/k)) * (h * h),
                [:]
            )
        }

        var pde = EllipticalPDE(lhs: poissonLHS, rhs: poissonRHS, mesh: mesh, boundaryCondition: boundaryCondition)
        let solvedMesh = pde.solve()

        let expectedValues = [
            simd_int3(x: 0,    y: 0,    z: 0) : 20.0,
            simd_int3(x: 0,    y: 1,    z: 0) : 50.30,
            simd_int3(x: 0,    y: 2,    z: 0) : 61.53,
            simd_int3(x: 0,    y: 3,    z: 0) : 50.30,
            simd_int3(x: 0,    y: 4,    z: 0) : 20.0,

            simd_int3(x: 1,    y: 0,    z: 0) : 20.0,
            simd_int3(x: 1,    y: 1,    z: 0) : 59.21,
            simd_int3(x: 1,    y: 2,    z: 0) : 72.13,
            simd_int3(x: 1,    y: 3,    z: 0) : 59.21,
            simd_int3(x: 1,    y: 4,    z: 0) : 20.0,

            simd_int3(x: 2,    y: 0,    z: 0) : 20.0,
            simd_int3(x: 2,    y: 1,    z: 0) : 63.16,
            simd_int3(x: 2,    y: 2,    z: 0) : 77.33,
            simd_int3(x: 2,    y: 3,    z: 0) : 63.16,
            simd_int3(x: 2,    y: 4,    z: 0) : 20.0,

            simd_int3(x: 3,    y: 0,    z: 0) : 20.0,
            simd_int3(x: 3,    y: 1,    z: 0) : 64.83,
            simd_int3(x: 3,    y: 2,    z: 0) : 79.63,
            simd_int3(x: 3,    y: 3,    z: 0) : 64.83,
            simd_int3(x: 3,    y: 4,    z: 0) : 20.0,

            simd_int3(x: 4,    y: 0,    z: 0) : 20.0,
            simd_int3(x: 4,    y: 1,    z: 0) : 65.30,
            simd_int3(x: 4,    y: 2,    z: 0) : 80.28,
            simd_int3(x: 4,    y: 3,    z: 0) : 65.30,
            simd_int3(x: 4,    y: 4,    z: 0) : 20.0,

            simd_int3(x: 5,    y: 0,    z: 0) : 20.0,
            simd_int3(x: 5,    y: 1,    z: 0) : 64.83,
            simd_int3(x: 5,    y: 2,    z: 0) : 79.63,
            simd_int3(x: 5,    y: 3,    z: 0) : 64.83,
            simd_int3(x: 5,    y: 4,    z: 0) : 20.0,

            simd_int3(x: 6,    y: 0,    z: 0) : 20.0,
            simd_int3(x: 6,    y: 1,    z: 0) : 63.16,
            simd_int3(x: 6,    y: 2,    z: 0) : 77.33,
            simd_int3(x: 6,    y: 3,    z: 0) : 63.16,
            simd_int3(x: 6,    y: 4,    z: 0) : 20.0,

            simd_int3(x: 7,    y: 0,    z: 0) : 20.0,
            simd_int3(x: 7,    y: 1,    z: 0) : 59.21,
            simd_int3(x: 7,    y: 2,    z: 0) : 72.13,
            simd_int3(x: 7,    y: 3,    z: 0) : 59.21,
            simd_int3(x: 7,    y: 4,    z: 0) : 20.0,

            simd_int3(x: 8,    y: 0,    z: 0) : 20.0,
            simd_int3(x: 8,    y: 1,    z: 0) : 50.30,
            simd_int3(x: 8,    y: 2,    z: 0) : 61.53,
            simd_int3(x: 8,    y: 3,    z: 0) : 50.30,
            simd_int3(x: 8,    y: 4,    z: 0) : 20.0,
        ]

        for (location, expectedValue) in expectedValues {
            let (i, j, k) = location.ijk
            XCTAssertEqual(solvedMesh.knowns[i][j][k].value, expectedValue, accuracy: 0.01)
            XCTAssertEqual(solvedMesh.knowns[i][j][k].location.x, Double(i) * h, accuracy: 0.0001)
            XCTAssertEqual(solvedMesh.knowns[i][j][k].location.y, Double(j) * h, accuracy: 0.0001)
            XCTAssertEqual(solvedMesh.knowns[i][j][k].location.z, Double(k) * h, accuracy: 0.0001)
            XCTAssertEqual(solvedMesh.knowns[i][j][k].indices.x, Int32(i))
            XCTAssertEqual(solvedMesh.knowns[i][j][k].indices.y, Int32(j))
            XCTAssertEqual(solvedMesh.knowns[i][j][k].indices.z, Int32(k))
        }
    }
}
