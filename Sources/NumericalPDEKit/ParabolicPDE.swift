//
//  ParabolicPDE.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import Foundation
import simd

/// A parabolic partial differential equation to be solved numerically.
public struct ParabolicPDE: DiscretizedPDE {

    public var lhs: DiscretizedLHS

    public var rhs: DiscretizedRHS

    /// The `SolvedMesh` consisting entirely of known values as of the initial time `t_0`.
    /// Initial values must be known at all spatial coordinates of the mesh in order to determine
    /// numerical values at all subsequent time-steps.
    public let initialMesh: SolvedMesh

    /// The boundary conditions constraining the solution to the parabolic PDE.
    /// These can be given in terms of functions of spatial coordinates around the boundaries of the mesh,
    /// or as derivative boundary conditions (involving finite difference approximations at boundary points).
    /// These boundary values must be known at all time-steps.
    public let boundaryCondition: BoundaryCondition

    /// Creates a new `ParabolicPDE` which can be solved numerically, over sequential time steps.
    /// - Parameters:
    ///   - lhs: The discretized "left-hand side" expression involving unknowns in the PDE mesh.
    ///   - rhs: The discretized "right-hand side" expression involving any functions of spatial coordinates in the PDE.
    ///   - initialMesh: The initial condition; a mesh of known values at all spatial coordinates, at time `t = 0`.
    ///   - boundaryCondition: The discretized Dirichlet boundary conditions to which the solution is subject.
    ///
    /// Derivative boundary conditions are supported through the `lhs` and `rhs` parameters.
    public init(
        lhs: @escaping DiscretizedLHS,
        rhs: @escaping DiscretizedRHS,
        initialMesh: SolvedMesh,
        boundaryCondition: @escaping BoundaryCondition
    ) {
        self.lhs = lhs
        self.rhs = rhs
        self.initialMesh = initialMesh
        self.boundaryCondition = boundaryCondition
    }

    /// A wrapper for a sparse system of linear equations to be solved numerically at each time-step.
    /// The linear system's left-hand side is determined by the `lhs` and `rhs` expressions, as well as the mesh.
    /// The right-hand side (the `b`-vector, in a linear system `Ax = b`) is determined by the `bVector` function.
    lazy var linearSystem: LinearSystem = {
        let unsolvedMesh = nextUnsolvedMesh(initialMesh)
        return LinearSystem.from(unsolvedMesh: unsolvedMesh, pde: self)
    }()

    /// Solves the `LinearSystem` with a sequence of `b`-vectors corresponding to the time-steps.
    /// - Parameters:
    ///   - maxTime: The `TimeInterval` through which to solve the time-dependent PDE.
    ///   - deltaTime: The size of the time-steps through which to iterate until the `maxTime` is reached.
    ///   - completion: A completion handler which allows the consumer to so something which each `SolvedMesh`.
    ///
    /// There will be one `SolvedMesh` for each time-step in the numerical solution to the PDE.
    public mutating func solve(maxTime: TimeInterval, deltaTime: TimeInterval, completion: (SolvedMesh) -> Void) {
        completion(initialMesh)
        let timeSteps = Int(maxTime / deltaTime)
        var (currentMesh, nextMesh) = (initialMesh, nextUnsolvedMesh(initialMesh))
        for timeStep in 1...timeSteps {
            var bValues = bVector(nextMesh, currentMesh: currentMesh)
            currentMesh = nextMesh.solve(&linearSystem, bValues: &bValues)
            currentMesh.time = deltaTime * TimeInterval(timeStep)
            completion(currentMesh)
            nextMesh = nextUnsolvedMesh(currentMesh)
        }
    }

    func contains(_ location: simd_int3) -> Bool {
        return initialMesh.contains(location)
    }

    /// Assembles the `b`-vector of a linear system `Ax = b` built from the problem description.
    /// - Parameter unsolvedMesh: The unsolved mesh from which the corresponding `LinearSystem` is constructed.
    /// - Parameter currentMesh: The solved mesh from the most recent time-step.
    /// - Returns: An array of values corresponding to linear combinations of the unknowns in the problem (one per row).
    ///
    /// Traverses over the unknown points within the unsolved mesh in `x`-, `y`-, and then `z`-order. At each unknown:
    /// * Computes a "left-hand side" linear combination involving the values at any adjacent known points in the mesh
    /// * Computes a "right-hand side" linear combination involving values at specific known points in the last mesh
    /// * Subtracts the "right-hand" from the "left-hand" value to produce a `b`-vector entry in the system `Ax = b`.
    private func bVector(_ unsolvedMesh: UnsolvedMesh, currentMesh: SolvedMesh) -> [Double] {
        var bValues = [Double]()
        for row in unsolvedMesh.unknowns {
            for column in row {
                for point in column where point.ordinal != nil {
                    let (value, coefficients) = rhs(point.indices)
                    let rhs = value + coefficients.reduce(0.0, coefficientReducer(currentMesh.knowns))
                    let lhs = lhs(point.indices).reduce(0.0, coefficientReducer(unsolvedMesh.knowns))
                    bValues.append(rhs - lhs)
                }
            }
        }
        return bValues
    }

    /// Produces the next unsolved mesh in the sequence.
    /// - Parameter solvedMesh: The most recent solved mesh in the sequence.
    /// - Returns: An unsolved mesh with the same dimensions as the last solved mesh.
    ///
    /// The new mesh has the same structure as the last solved mesh, but only contains known values
    /// per the boundary conditions; all other interior points are unknown.
    private func nextUnsolvedMesh(_ solvedMesh: SolvedMesh) -> UnsolvedMesh {
        return solvedMesh.applyBoundaryCondition(boundaryCondition)
    }
}
