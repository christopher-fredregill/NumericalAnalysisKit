//
//  LinearSystem.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import Accelerate
import simd

@available(macOS 10.15, *)
struct LinearSystem {

    /// The non-zero entries of an `n` x `n` sparse matrix `A`, as part of a system `Ax = b`.
    private var entries: [Double]

    /// The array of indicies in the `entries` array at which new columns begin.
    /// Terminated by a final entry representing the overall number of non-zero entries in the matrix.
    private var columnStarts: [Int]

    /// The array giving the indices of the rows to which each of the `entries` correspond.
    /// See the docs on `SparseMatrixStructure` for more information.
    private var rowIndices: [Int32]

    /// The overall number of rows (and columns) in the matrix `A`, as part of the system `Ax = b`.
    private var rowCount: Int32

    /// The `SparseMatrixStructure` of the sparse matrix `A`, as part of the system `Ax = b`.
    /// The `attributes.transpose = true` setting is used to transpose the `entries`, since
    /// they are provided in row-major order, but the `SparseMatrixStructure` expects them
    /// to be supplied in column-major order.
    private lazy var matrixStructure: SparseMatrixStructure = {
        return rowIndices.withUnsafeMutableBufferPointer { rowIndicesPtr in
            columnStarts.withUnsafeMutableBufferPointer { columnStartsPtr in
                var attributes = SparseAttributes_t()
                attributes.kind = SparseOrdinary
                attributes.transpose = true

                return SparseMatrixStructure(
                    rowCount: rowCount,
                    columnCount: rowCount,
                    columnStarts: columnStartsPtr.baseAddress!,
                    rowIndices: rowIndicesPtr.baseAddress!,
                    attributes: attributes,
                    blockSize: 1
                )
            }
        }
    }()

    /// The `QR` factorization of the matrix `A` in the linear system `Ax = b`.
    /// Once computed, allows for rapid computation of solutions `x` to the factored system `Rx = Q⁻¹b`.
    /// Used repeatedly in time-dependent PDEs where the `A` matrix does not change with time, but the `b` values do.
    private lazy var qrFactorization: SparseOpaqueFactorization_Double = {
        var matrixEntries = self.entries
        return matrixEntries.withUnsafeMutableBufferPointer { valuesPtr in
            let matrix = SparseMatrix_Double(structure: matrixStructure, data: valuesPtr.baseAddress!)
            return SparseFactor(SparseFactorizationQR, matrix)
        }
    }()

    /// Solves the sytem for a given `b`-vector.
    /// - Parameter bValues: The `b`-vector in the system `Ax = b`.
    /// - Returns: The solution vector `x`.
    mutating func solve(bValues: inout [Double]) -> [Double] {
        var xValues = [Double](repeating: 0.0, count: Int(self.rowCount))
        bValues.withUnsafeMutableBufferPointer { bPtr in
            xValues.withUnsafeMutableBufferPointer { xPtr in
                let bVector = DenseVector_Double(count: rowCount, data: bPtr.baseAddress!)
                let xVector = DenseVector_Double(count: rowCount, data: xPtr.baseAddress!)
                SparseSolve(qrFactorization, bVector, xVector)
            }
        }
        return xValues
    }
}

extension LinearSystem {

    /// A factory method for constructing a `LinearSystem` from a given PDE on an unsolved mesh.
    /// - Parameters:
    ///   - unsolvedMesh: The `UnsolvedMesh` in the problem description.
    ///   - pde: The PDE from which to generate the system of linear equations.
    /// - Returns: The `LinearSystem` whose `A` matrix appears in the discretized PDE system `Ax = b`.
    ///
    /// Traverses the unknowns in the unsolved mesh in the `x`-, `y`-, and then `z`-directions.
    /// Note that matrix entries are assembled in row-major order, but the `SparseMatrixStructure` gives a column-major
    /// representation of the matrix structure; the entries are transposed via `attributes.transpose = true`.
    static func from(unsolvedMesh: UnsolvedMesh, pde: DiscretizedPDE) -> LinearSystem {
        var (entries, columnStarts, rowIndices) = ([Double](), [Int](), [Int32]())
        var (entryCounter, columnStart, rowCount) = (0, 0, Int32(0))
        for row in unsolvedMesh.unknowns {
            for column in row {
                for point in column where point.ordinal != nil {
                    let coefficients = pde.getAdjacentCoefficients(unknown: point, unknowns: unsolvedMesh.unknowns)
                    columnStarts.append(columnStart) ; rowCount += 1
                    for (ordinal, coefficient) in coefficients where ordinal >= 0 {
                        rowIndices.append(ordinal) ; columnStart += 1
                        entries.append(coefficient) ; entryCounter += 1
                    }
                }
            }
        }
        columnStarts.append(entryCounter)

        return LinearSystem(
            entries: entries,
            columnStarts: columnStarts,
            rowIndices: rowIndices,
            rowCount: rowCount
        )
    }
}
