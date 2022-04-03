//
//  DiscretizedPDE.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import simd

protocol DiscretizedPDE {

    /// A "left-hand side" expression used to determine a linear combination in the unknown points in the mesh.
    var lhs: DiscretizedLHS { get }

    /// A "right-hand side" expression used to determine scalar values to which the `lhs` linear combinations equate.
    var rhs: DiscretizedRHS { get }

    /// A helper function used to determine whether a candidate grid location `(i, j, k)` is contained within the mesh.
    /// - Parameter location: The candidate grid location to test for.
    ///
    /// - Returns: `true` if the location is part of the mesh on which the equation is being solved; `false`, otherwise.
    func contains(_ location: simd_int3) -> Bool

    /// Assembles an array of coefficients corresponding to points adjacent to a given unknown point.
    ///
    /// - Parameter unknown: The unknown mesh point whose adjacent points are to be determined.
    /// - Parameter unknowns: The overall collection of unknown points in the mesh from which to select adjacent points.
    ///
    /// - Returns: An array of ordinal-coefficient pairs, represented by tuples (`Int32`, `Double`).
    ///
    /// Coefficients are paired with ordinals (`Int32` identifiers) corresponding to other unknowns in the mesh.
    /// These coefficients are used to construct the left-hand side of a linear equation in the unknowns of the mesh.
    func getAdjacentCoefficients(unknown: UnknownPoint, unknowns: [[[UnknownPoint]]]) -> [(Int32, Double)]

    /// Produces a function which, in turn, produces a linear combination of known values from a mesh.
    ///
    /// - Parameter knowns: The overall collection of known points in the mesh.
    ///
    /// - Returns: A function which computes a linear combination of known values from within a mesh.
    ///
    /// The resultant function is used to compute corresponding right-hand sides of linear equations in the unknowns.
    func coefficientReducer(_ knowns: [[[KnownPoint]]]) -> CoefficientReducer
}

extension DiscretizedPDE {

    func getAdjacentCoefficients(unknown: UnknownPoint, unknowns: [[[UnknownPoint]]]) -> [(Int32, Double)] {
        let coefficients = lhs(unknown.indices)
        var adjacentCoefficients = [(Int32, Double)]()
        for (location, coefficient) in coefficients {
            if contains(location) {
                let (i, j, k) = location.ijk
                if let ordinal = unknowns[i][j][k].ordinal {
                    adjacentCoefficients.append((ordinal, coefficient))
                }
            }
        }
        return adjacentCoefficients.sorted { $0.0 < $1.0 }
    }

    func getNextKnownValue(location: simd_int3, knowns: [[[KnownPoint]]]) -> Double {
        if contains(location) {
            let (i, j, k) = location.ijk
            return knowns[i][j][k].value
        } else {
            return 0.0
        }
    }

    func coefficientReducer(_ knowns: [[[KnownPoint]]]) -> CoefficientReducer {
        return { result, next in
            let (location, coefficient) = next
            let value = getNextKnownValue(location: location, knowns: knowns)
            return result + coefficient * value
        }
    }
}
