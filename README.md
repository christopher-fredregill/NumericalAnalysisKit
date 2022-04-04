[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchristopher-fredregill%2FNumericalAnalysisKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/christopher-fredregill/NumericalAnalysisKit)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchristopher-fredregill%2FNumericalAnalysisKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/christopher-fredregill/NumericalAnalysisKit)

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

### Examples

#### Laplace Equation in 2 Spatial Dimensions

Use the framework to generate heat maps indicating scalar values at various points in space. For example, the below rendering shows what a solution to [Laplace's equation](https://en.wikipedia.org/wiki/Laplace%27s_equation) on a fine rectangular mesh would look like, subject to certain [Dirichlet boundary conditions](https://en.wikipedia.org/wiki/Dirichlet_boundary_condition) (in this example, a thin sheet is held at 100ºC on one edge, and 0ºC on the other three; interior temperatures are pictured, with cooler temperatures indicated in blue, gradually increasing towards hotter temperatures in red):

![Laplace Equation 2D](http://www.inamona.com/assets/laplace_equation_rectangular_mesh.png)

#### Heat Equation in 2 Spatial Dimensions

Using the same physical conditions as in the above exampe, we can similarly render a time-dependent (unsteady-state) solution to the [Heat Equation](https://en.wikipedia.org/wiki/Heat_equation) for a sequence of discrete time steps (in this case, stitched together into an animated GIF):

![Heat Equation](http://www.inamona.com/assets/heat_equation_rectangular_mesh.gif)

#### Laplace Equation in 3 Spatial Dimensions

This last example illustrates how heat maps can be used to visualize solutions `u(x,y,z)` over 3D rectangular regions in space. Laplace's equation is solved on a 15cm `x` 15cm `x` 15cm cube, with spatial step size `h` = 0.5 cm; each face is held at a different temperature, starting with 0ºC, and stepping upward in 20º-increments, up through 100ºC. Temperatures `u` are known at all grid points within the 3D mesh. Each of the following images represent a specific 2D cross-sectional heat map, taken from a specific location along the `x-`, `y-`, or `z-`axis.

* Cross-sectional heat map at `x = 11`: ![Laplace Equation 3D - x slice](http://www.inamona.com/assets/x_22.png)
* Cross-sectional heat map at `y = 11`: ![Laplace Equation 3D - y slice](http://www.inamona.com/assets/y_22.png)
* Cross-sectional heat map at `z = 11`: ![Laplace Equation 3D - z slice](http://www.inamona.com/assets/z_22.png)
