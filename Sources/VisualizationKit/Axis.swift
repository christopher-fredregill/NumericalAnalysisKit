//
//  Axis.swift
//
//
//  Created by Christopher Fredregill on 3/17/22.
//

import Foundation
import NumericalPDEKit

/// An axis along which cross-sectional images can be rendered.
public enum Axis: String {
    case z, y, x

    /// The number of cross-sectional slices along this axis of the provided mesh.
    /// - Parameter mesh: The `SolvedMesh` to be sliced along this `Axis`.
    /// - Returns: The number of slices in this axis within the mesh.
    func maxDepth(_ mesh: SolvedMesh) -> Int {
        switch self {
        case .x:
            return Int(mesh.dimensions.x)
        case .y:
            return Int(mesh.dimensions.y)
        case .z:
            return Int(mesh.dimensions.z)
        }
    }

    /// The dimensions of the cross-sectional images along this axis of the provided mesh.
    /// - Parameter mesh: The `SolvedMesh` to be sliced along this `Axis`.
    /// - Returns: The number of rows and columns within the cross-sections along this `Axis`.
    func imageDimensions(_ mesh: SolvedMesh) -> (Int, Int) {
        switch self {
        case .x:
            return (Int(mesh.dimensions.y), Int(mesh.dimensions.z))
        case .y:
            return (Int(mesh.dimensions.x), Int(mesh.dimensions.z))
        case .z:
            return (Int(mesh.dimensions.x), Int(mesh.dimensions.y))
        }
    }

    /// Produces a cross-section of a given mesh along this axis, at the provided depth (level).
    /// - Parameters:
    ///   - mesh: The `SolvedMesh` to be sliced along this `Axis`.
    ///   - level: The depth (level) at which to extract a cross-sectional 2D array of known points.
    /// - Returns: The cross-sectional 2D array of known points at the given level.
    func extract(_ mesh: SolvedMesh, level: Int) -> [[KnownPoint]] {
        switch self {
        case .x:
            return extractYZ(mesh, level: level)
        case .y:
            return extractXZ(mesh, level: level)
        case .z:
            return extractXY(mesh, level: level)
        }
    }

    /// Extracts a 2D cross-section (an `xy`-plane) at a given depth along the `z`-axis.
    /// - Parameters:
    ///   - mesh: The `SolvedMesh` to be sliced along this `Axis`.
    ///   - level: The depth (level) at which to extract a cross-sectional 2D array of known points.
    /// - Returns: The cross-sectional 2D array of known points at the given level along the `z`-axis.
    private func extractXY(_ mesh: SolvedMesh, level: Int) -> [[KnownPoint]] {
        var results = [[KnownPoint]]()
        for row in mesh.knowns {
            var yLevel = [KnownPoint]()
            for column in row {
                yLevel.append(column[level])
            }
            results.append(yLevel)
        }
        return results
    }

    /// Extracts a 2D cross-section (an `xz`-plane) at a given depth along the `y`-axis.
    /// - Parameters:
    ///   - mesh: The `SolvedMesh` to be sliced along this `Axis`.
    ///   - level: The depth (level) at which to extract a cross-sectional 2D array of known points.
    /// - Returns: The cross-sectional 2D array of known points at the given level along the `y`-axis.
    private func extractXZ(_ mesh: SolvedMesh, level: Int) -> [[KnownPoint]] {
        var results = [[KnownPoint]]()
        for row in mesh.knowns {
            var zLevel = [KnownPoint]()
            for point in row[level] {
                zLevel.append(point)
            }
            results.append(zLevel)
        }
        return results
    }

    /// Extracts a 2D cross-section (an `yz`-plane) at a given depth along the `x`-axis.
    /// - Parameters:
    ///   - mesh: The `SolvedMesh` to be sliced along this `Axis`.
    ///   - level: The depth (level) at which to extract a cross-sectional 2D array of known points.
    /// - Returns: The cross-sectional 2D array of known points at the given level along the `x`-axis.
    private func extractYZ(_ mesh: SolvedMesh, level: Int) -> [[KnownPoint]] {
        return mesh.knowns[level]
    }
}
