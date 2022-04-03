//
//  PDEMesh.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import Foundation
import simd

protocol PDEMesh {

    /// The spatial dimensions of the grid (mesh) on which to solve a PDE.
    var dimensions: simd_int3 { get }

    /// A helper function used to determine whether a candidate grid location `(i, j, k)` is contained within the mesh.
    /// - Parameter location: The candidate grid location to test for.
    ///
    /// - Returns: `true` if the location is part of the mesh on which the equation is being solved; `false`, otherwise.
    func contains(_ location: simd_int3) -> Bool
}

protocol BoundableMesh: PDEMesh {

    associatedtype PointType: PDEMeshPoint

    /// The `PDEMeshPoint`s to consider when applying a `BoundaryCondition` on this mesh.
    var points: [[[PointType]]] { get }

    /// Initializes a mesh of this type with values determined by the boundary conditions given in the problem.
    /// - Parameter boundaryCondition: The boundary conditions for the problem.
    /// - Returns: The `UnsolvedMesh` whose structure is identical to this mesh, but with known boundary values.
    func applyBoundaryCondition(_ boundaryCondition: BoundaryCondition) -> UnsolvedMesh
}

extension PDEMesh {

    func contains(_ location: simd_int3) -> Bool {
        let (i, j, k) = location.ijk
        return 0 <= i && i <= dimensions.x
            && 0 <= j && j <= dimensions.y
            && 0 <= k && k <= dimensions.z
    }
}

extension BoundableMesh {

    func applyBoundaryCondition(_ boundaryCondition: BoundaryCondition) -> UnsolvedMesh {
        var (tempKnowns, tempUnknowns) = (KnownPoint.box(of: dimensions), UnknownPoint.box(of: dimensions))
        var ordinal: Int32 = 0

        for (i, row) in points.enumerated() {
            for (j, column) in row.enumerated() {
                for (k, point) in column.enumerated() {
                    if let boundaryValue = boundaryCondition(i, j, k) {
                        tempKnowns[i][j][k] = KnownPoint(point, value: boundaryValue)
                    } else {
                        tempUnknowns[i][j][k] = UnknownPoint(point, ordinal: ordinal)
                        ordinal += 1
                    }
                }
            }
        }
        return UnsolvedMesh(knowns: tempKnowns, unknowns: tempUnknowns, dimensions: dimensions)
    }
}

public struct MeshFactory {

    /// Factory for constructing 2D meshes with given height and width, based on a given spatial step size `h`.
    /// - Parameters:
    ///   - width: The width of the 2D mesh.
    ///   - height: The height of the 2D mesh.
    ///   - h: The spatial step size of the 2D mesh (assuming a common step size `h = ∆x = ∆y`).
    /// - Returns: The 2D mesh with the given dimensions and spatial step size.
    ///
    /// The `UnsolvedMesh` still technically corresponds to a 3D grid, but the `depth` of the grid is exactly 1.
    public static func make2DGrid(width: Double, height: Double, h: Double) -> UnsolvedMesh {
        return Self.make3DGrid(width: width, height: height, depth: 0.0, h: h)
    }

    /// Factory for constructing 3D meshes with given height, width and depth, based on a given spatial step size `h`.
    /// - Parameters:
    ///   - width: The width of the 3D mesh.
    ///   - height: The height of the 3D mesh.
    ///   - depth: The depth of the 3D mesh.
    ///   - h: The spatial step size of the 2D mesh (assuming a common step size `h = ∆x = ∆y = ∆z`).
    /// - Returns: The 3D mesh with the given dimensions and spatial step size.
    ///
    /// The `UnsolvedMesh` contains a 3D array of `UnknownPoint`s indexed in the `x`-, `y`-, and then `z`-directions.
    public static func make3DGrid(width: Double, height: Double, depth: Double, h: Double) -> UnsolvedMesh {
        var meshPoints = [[[UnknownPoint]]]()
        let (maxI, maxJ, maxK) = (Int(width / h), Int(height / h), Int(depth / h))
        for i in 0...maxI {
            var rowI = [[UnknownPoint]]()
            for j in 0...maxJ {
                var columnJ = [UnknownPoint]()
                for k in 0...maxK {
                    let location = simd_double3(x: h * Double(i), y: h * Double(j), z: h * Double(k))
                    columnJ.append(UnknownPoint(indices: simd_int3.of(i: i, j: j, k: k), location: location))
                }
                rowI.append(columnJ)
            }
            meshPoints.append(rowI)
        }
        return UnsolvedMesh(knowns: [[[]]], unknowns: meshPoints, dimensions: simd_int3.of(i: maxI, j: maxJ, k: maxK))
    }
}
