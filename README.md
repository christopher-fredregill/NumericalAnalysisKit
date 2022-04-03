# NumericalAnalysisKit
Numerical analysis toolkit for Swift
=======

This package contains libraries for performing various kinds of numerical analysis tasks.

## NumericalPDEKit

This library contains various numerical solvers for [partial differential equations](https://en.wikipedia.org/wiki/Partial_differential_equation) (soon to include [hyperbolic](https://en.wikipedia.org/wiki/Hyperbolic_partial_differential_equation) solvers, as well).

### EllipticalPDE

This `struct` uses [finite difference methods](https://en.wikipedia.org/wiki/Finite_difference_method) to solve [elliptical](https://en.wikipedia.org/wiki/Elliptic_partial_differential_equation) PDEs numerically.

For usage, please have a look at some of the examples in the [EllipticalPDETests](Tests/NumericalPDEKitTests/EllipticalPDETests.swift).

### ParabolicPDE

This `struct` implements the [Crank-Nicolson method](https://en.wikipedia.org/wiki/Crank–Nicolson_method) to solve  [parabolic](https://en.wikipedia.org/wiki/Parabolic_partial_differential_equation) PDEs numerically.

For usage, please have a look at some of the examples in the [ParabolicPDETests](Tests/NumericalPDEKitTests/ParabolicPDETests.swift).

### HyperbolicPDE (coming soon)

Not yet implemented, but this will provide solvers for [hyperbolic](https://en.wikipedia.org/wiki/Hyperbolic_partial_differential_equation) PDEs.

## VisualizationKit

This library provides utilities for generating various visualizations based on solutions to numerical analysis problems. Currently, this is limited to generating 2D images representing cross-sectional heat maps in any of the `x`-, `y`-, or `z`-directions.
