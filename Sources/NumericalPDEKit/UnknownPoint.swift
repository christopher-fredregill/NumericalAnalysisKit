//
//  UnknownPoint.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import simd

/// A mesh point without a known value; represents a value yet to be determined.
public struct UnknownPoint: PDEMeshPoint {

    var location: simd_double3

    var indices: simd_int3

    /// The integer ID of the `UnknownPoint` within the mesh.
    /// Corresponds to the index of the value in the solution vector `x` of the linear system `Ax = b`.
    var ordinal: Int32?

    init<T: PDEMeshPoint>(_ point: T, ordinal: Int32) {
        self.indices = point.indices
        self.location = point.location
        self.ordinal = ordinal
    }

    init(indices: simd_int3, location: simd_double3) {
        self.indices = indices
        self.location = location
    }

    static var empty: UnknownPoint {
        return UnknownPoint(indices: .zero, location: .zero)
    }
}
