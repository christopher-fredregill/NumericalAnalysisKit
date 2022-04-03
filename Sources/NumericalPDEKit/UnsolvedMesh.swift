//
//  UnsolvedMesh.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import simd
import Foundation

/// A finite mesh consisting of at least some unknown values at various points in ℝ³, at a given point in time.
public struct UnsolvedMesh: BoundableMesh {

    var points: [[[UnknownPoint]]] {
        return unknowns
    }

    /// Known points within the overall unsolved mesh.
    /// Values are known at these points due to boundary conditions.
    let knowns: [[[KnownPoint]]]

    /// Unknown points within the overall unsolved mesh.
    /// Values will be assigned upon solution of the PDE.
    let unknowns: [[[UnknownPoint]]]

    public var dimensions: simd_int3

    /// Produces a `SolvedMesh` from this `UnsolvedMesh` by solving a corresponding `LinearSystem`.
    /// - Parameters:
    ///   - linearSystem: The `LinearSystem` representing the numerical scheme for approximating the solution.
    ///   - bValues: The `b`-vector of values in the corresponding system `Ax = b`.
    /// - Returns: The `SolvedMesh` all of whose values are known.
    func solve(_ linearSystem: inout LinearSystem, bValues: inout [Double]) -> SolvedMesh {
        let xValues: [Double] = linearSystem.solve(bValues: &bValues)
        var knownPoints: [[[KnownPoint]]] = KnownPoint.box(of: dimensions)

        for (i, row) in unknowns.enumerated() {
            for (j, column) in row.enumerated() {
                for (k, point) in column.enumerated() {
                    if let ordinal = point.ordinal {
                        knownPoints[i][j][k] = KnownPoint(unknowns[i][j][k], value: xValues[Int(ordinal)])
                    } else {
                        knownPoints[i][j][k] = knowns[i][j][k]
                    }
                }
            }
        }
        return SolvedMesh(knowns: knownPoints, dimensions: dimensions)
    }

    /// Applies an initial condition to this `UnsolvedMesh`; provides values for all mesh points at an initial time.
    /// - Parameter initialCondition: The condition specifying values at all spatial points at the initial time.
    /// - Returns: The `SolvedMesh` consisting entirely of known points (at time `t_0`).
    public func applyInitialCondition(_ initialCondition: InitialCondition) -> SolvedMesh {
        var tempKnowns = KnownPoint.box(of: dimensions)
        for (i, row) in unknowns.enumerated() {
            for (j, column) in row.enumerated() {
                for k in column.indices {
                    let unknown = unknowns[i][j][k]
                    let initialValue = initialCondition(i, j, k)
                    tempKnowns[i][j][k] = KnownPoint(unknown, value: initialValue)
                }
            }
        }
        return SolvedMesh(knowns: tempKnowns, dimensions: dimensions)
    }
}
