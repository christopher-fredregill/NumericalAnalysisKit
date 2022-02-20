//
//  RGBCubeEdge.swift
//
//
//  Created by Christopher Fredregill on 3/17/22.
//

import Foundation

/// Represents an RGB color cube.
/// Colors are determined by traversing along each of four edges of the color cube, in ascending order from blue to red.
enum RGBCubeEdge: Int, CaseIterable {

    case blueToTeal = 1, tealToGreen, greenToYellow, yellowToRed

    private static var edgeLength: Double {
        return 25.0
    }

    /// Attempts to map a normalized value (between 0.0 and 100.0) to an edge of the RGB color cube.
    /// - Parameter value: the normalized value.
    /// - Returns: The `RGBCubeEdge` along which to look up corresponding color components (if possible).
    ///
    /// Normalized values below 0.0 or above 100.0 are not defined, and hence are mapped to `nil`.
    static func getEdge(value: Double) -> RGBCubeEdge? {
        guard value >= 0 else { return nil }
        for possibleSegment in RGBCubeEdge.allCases {
            if value <= Double(possibleSegment.rawValue) * edgeLength {
                return possibleSegment
            }
        }
        return nil
    }

    /// Produces `UInt32` RGB color components by traversing the `RGBCubeEdge` corresponding to the given value.
    /// - Parameter value: The normalized value (between 0.0 and 100.0).
    /// - Returns: The `UInt32` RGB color components for the given value.
    func components(_ value: Double) -> (UInt32, UInt32, UInt32) {
        switch self {
        case .blueToTeal:
            return (0, UInt32(value * 255.0 / Self.edgeLength), 255)
        case .tealToGreen:
            return (0, 255, 255 - UInt32((value - Self.edgeLength) * 255.0 / Self.edgeLength))
        case .greenToYellow:
            return (UInt32((value - 2 * Self.edgeLength) * 255.0 / Self.edgeLength), 255, 0)
        case .yellowToRed:
            return (255, 255 - UInt32((value - 3 * Self.edgeLength) * 255.0 / Self.edgeLength), 0)
        }
    }
}
