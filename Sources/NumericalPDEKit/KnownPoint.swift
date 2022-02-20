//
//  KnownPoint.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import simd

/// A mesh point with a known value, representing the numerical solution to a PDE at a point.
public struct KnownPoint: PDEMeshPoint, Codable {

    var indices: simd_int3

    public var location: simd_double3

    /// The known value of the mesh point.
    public let value: Double

    init<T: PDEMeshPoint>(_ point: T, value: Double) {
        self.indices = point.indices
        self.location = point.location
        self.value = value
    }

    init(indices: simd_int3, location: simd_double3, value: Double) {
        self.indices = indices
        self.location = location
        self.value = value
    }

    static var empty: KnownPoint {
        return KnownPoint(indices: .zero, location: .zero, value: 0.0)
    }
}
