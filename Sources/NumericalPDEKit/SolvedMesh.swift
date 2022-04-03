//
//  SolvedMesh.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import Foundation
import simd

/// A finite mesh consisting of known values at various points in ℝ³, at a given point in time.
public struct SolvedMesh: BoundableMesh, Codable {

    var points: [[[KnownPoint]]] {
        return knowns
    }

    /// The time-step represented by the mesh (0 by default, or when the solution is not time-dependent).
    public var time: TimeInterval = 0

    /// The 3D array of mesh points describing the numerical solution to a PDE at a given point in time.
    public let knowns: [[[KnownPoint]]]

    /// The grid dimensions; the number of entries in each of the nested arrays of points within the mesh.
    public let dimensions: simd_int3
}
