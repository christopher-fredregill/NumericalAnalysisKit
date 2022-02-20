// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NumericalAnalysisKit",
    platforms: [.macOS(.v10_15), .iOS(.v15)],
    products: [
        .library(
            name: "NumericalPDEKit",
            targets: ["NumericalPDEKit"]),
        .library(
            name: "VisualizationKit",
            targets: ["VisualizationKit"]
        )
    ],
    targets: [
        .target(
            name: "NumericalPDEKit",
            dependencies: []),
        .testTarget(
            name: "NumericalPDEKitTests",
            dependencies: ["NumericalPDEKit"]),
        .target(
            name: "VisualizationKit",
            dependencies: ["NumericalPDEKit"]),
        .testTarget(
            name: "VisualizationKitTests",
            dependencies: ["VisualizationKit"])
    ]
)
