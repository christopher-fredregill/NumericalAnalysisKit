//
//  TypeAliases.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import simd

/// Supplies certain boundary points (at grid indices `(i, j, k)`) with a value; not time-dependent.
public typealias BoundaryCondition = (Int, Int, Int) -> Double?

/// Supplies known values to all points (at grid indices `(i, j, k)`) with a value (at time-step `t_0`).
public typealias InitialCondition = (Int, Int, Int) -> Double

/// Supplies weights (coefficients) used to create "left-hand side" linear combinations of unknowns.
public typealias DiscretizedLHS = (simd_int3) -> [simd_int3: Double]

/// Supplies weights (coefficients) used to create "right-hand side" linear combinations of knowns.
public typealias DiscretizedRHS = (simd_int3) -> (Double, [simd_int3: Double])

/// Supplies the resultant value of a linear combination of known values from a mesh.
typealias CoefficientReducer = (Double, Dictionary<simd_int3, Double>.Element) -> Double
