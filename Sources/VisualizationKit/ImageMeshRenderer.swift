//
//  ImageMeshRenderer.swift
//
//
//  Created by Christopher Fredregill on 3/13/22.
//

import NumericalPDEKit
import Accelerate

/// A renderer which produces static 2D images of a given `SolvedMesh`, along the `x`-, `y`-, or `z`-axes.
@available(macOS 10.15, *)
public struct ImageMeshRenderer: MeshRenderer {

    /// The global minimum value in the `SolvedMesh` to be visualized.
    public var minValue: Double

    /// The global maximum value in the `SolvedMesh` to be visualized.
    public var maxValue: Double

    /// Creates a new `ImageMeshRenderer` with the given global minimum and maximum values of the mesh to be rendered.
    /// - Parameters:
    ///   - minValue: The global minimum value of function defined on the mesh to be rendered.
    ///   - maxValue: The global maximum value of function defined on the mesh to be rendered.
    ///
    /// Dark blue pixels are rendered for values closer to the global minimum value.
    /// Bright red pixels are rendered for values closer to the global maximum value.
    ///
    /// If a sequence of meshes is to be rendered (e.g., when animating solutions to time-dependent PDEs), the min/max
    /// values specified here must correspond to the _global_ minimum and maximum values of the solution to be rendered,
    /// across _all_ time steps. Any mesh values below the minimum or above the maximum cannot be rendered.
    public init(minValue: Double, maxValue: Double) {
        self.minValue = minValue
        self.maxValue = maxValue
    }

    /// Renders a sequence of `CGImage` for each of the cross-sectional level sets along a given `Axis`.
    /// - Parameters:
    ///   - mesh: The `SolvedMesh` to be rendered as slices (heat maps) along the given `Axis`.
    ///   - axis: The `Axis` along which to render 2D images.
    ///   - completion: The completion handler providing indexed cross-sectional `CGImage`s along the given `Axis`.
    public func render(_ mesh: SolvedMesh, axis: Axis, completion: (CGImage, Int) throws -> Void) throws {
        for depth in 0...axis.maxDepth(mesh) {
            let sheet = axis.extract(mesh, level: depth)
            let (width, height) = axis.imageDimensions(mesh)
            let image = try renderImage(sheet, width: width, height: height)
            try completion(image, depth)
        }
    }

    /// Produces a `UInt32` representing an RGB color.
    /// - Parameter value: The raw value to which a color `UInt32` will be assigned (if possible).
    /// - Throws: `MeshRenderError.invalidValue` when a value outside the defined min/max range is  supplied.
    /// - Returns: The `UInt32` color corresponding to the raw value given.
    ///
    /// Low raw values are mapped to deep blues; high raw values are mapped to deep reds.
    private func getColor(for value: Double) throws -> UInt32 {
        let (red, green, blue) = try getColorComponents(value)
        let packedColor: UInt32 = (blue << 24) + (green << 16) + (red << 8) + 0xFF
        return packedColor
    }

    /// Produces the RGB color components for a given raw value.
    /// - Parameter value: The raw value for which color components are needed.
    /// - Returns: The tuple of RGB color components, represented by `UInt32`s.
    ///
    /// Red, green, and blue `UInt32` color components are provided in that order.
    /// Raw values are first mapped to "normalized" values which belong to one of four possible edges of an RGB cube.
    private func getColorComponents(_ value: Double) throws -> (UInt32, UInt32, UInt32) {
        let normalized = normalize(value)
        guard let rgbCubeEdge = RGBCubeEdge.getEdge(value: normalized) else {
            throw MeshRenderError.invalidValue("Unable to determine RGB components for value \(value)")
        }
        return rgbCubeEdge.components(normalized)
    }

    /// Maps a given raw value to a "normalized" value, relative to the global min and max values to be rendered.
    /// - Parameter value: The raw value to be normalized.
    /// - Returns: The normalized value.
    ///
    /// Normalized values start at a minimum value of 0 (corresponding to the global minimum)
    /// and increase linearly until a maximum value of 100 (corresponding to the global maximum).
    private func normalize(_ value: Double) -> Double {
        return (value - minValue) * 100 / (maxValue - minValue)
    }

    /// Produces a `CGImage` from the contents of a 2D cross-section of points within a `SolvedMesh`.
    /// - Parameters:
    ///   - sheet: The 2D cross-section of known points extracted from a `SolvedMesh`.
    ///   - width: The width of the image to be produced, in pixels.
    ///   - height: The height of the image to be produces, in pixels.
    /// - Returns: The `CGImage` with pixels colored as per the known values in the given cross-section.
    ///
    /// Pixel data are assigned starting at the upper-left corner (x=0, y=height, in the image's reference frame).
    /// Traversal moves left-to-right along each row in the image, and fills in rows from top-to-bottom.
    private func renderImage(_ sheet: [[KnownPoint]], width: Int, height: Int) throws -> CGImage {
        var pixelData = [UInt32](repeating: 0x000000FF, count: (width + 1) * (height + 1))
        var pixelIndex = 0
        for j in 0...height {
            for i in 0...width {
                let point = sheet[i][height - j]
                pixelData[pixelIndex] = try getColor(for: point.value)
                pixelIndex += 1
            }
        }
        return try makeImage(&pixelData, width: width, height: height)
    }

    /// - Parameters:
    ///   - pixelData: The array of colors (as `UInt32`) with which to color each of the pixels in the output image.
    ///   - width: The width of the image, in pixels.
    ///   - height: The height of the image, in pixels.
    /// - Returns: The `CGImage` from the given array of pixel data, with the given dimensions.
    private func makeImage(_ pixelData: inout [UInt32], width: Int, height: Int) throws -> CGImage {
        return try pixelData.withUnsafeMutableBytes { ptr in
            let buffer = vImage_Buffer(
                data: ptr.baseAddress!,
                height: UInt(height + 1),
                width: UInt(width + 1),
                rowBytes: 4 * (width + 1)
            )
            if let imageFormat = getImageFormat() {
                return try buffer.createCGImage(format: imageFormat)
            } else {
                throw MeshRenderError.invalidImageFormat("Unable to get image format.")
            }
        }
    }

    /// - Returns: The `vImage_CGImageFormat` to use in rendering the `CGImage`s produced by this renderer.
    ///
    /// The image format uses an RGB color space with alpha info in the most significant bits.
    private func getImageFormat() -> vImage_CGImageFormat? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitMapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue)
        return vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: colorSpace,
            bitmapInfo: bitMapInfo
        )
    }
}
