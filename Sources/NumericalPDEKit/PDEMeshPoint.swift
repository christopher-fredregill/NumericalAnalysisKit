//
//  PDEMeshPoint.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import simd

protocol PDEMeshPoint {

    associatedtype PointType: PDEMeshPoint

    /// The grid indices `(i, j, k)` of the point.
    var indices: simd_int3 { get }

    /// The spatial location of the point in ℝ³.
    var location: simd_double3 { get }

    /// An uninitialized mesh point of the given type.
    static var empty: PointType { get }

    /// Factory for nested 3D arrays of `PDEMeshPoint`s of the given type.
    /// - Parameter dimensions: The dimensions of the 3D array to produce.
    /// - Returns: The 3D array of `PDEMeshPoint`s.
    static func box(of dimensions: simd_int3) -> [[[PointType]]]
}

extension PDEMeshPoint {

    static func box(of dimensions: simd_int3) -> [[[PointType]]] {
        let (i, j, k) = dimensions.ijk
        let points = [PointType](repeating: self.empty, count: k + 1)
        let columns = [[PointType]](repeating: points, count: j + 1)
        let rows = [[[PointType]]](repeating: columns, count: i + 1)

        return rows
    }
}

extension simd_int3 {

    public var ijk: (Int, Int, Int) {
        return (Int(x), Int(y), Int(z))
    }

    static func of(i: Int, j: Int, k: Int) -> simd_int3 {
        return simd_int3.init(x: Int32(i), y: Int32(j), z: Int32(k))
    }
}
