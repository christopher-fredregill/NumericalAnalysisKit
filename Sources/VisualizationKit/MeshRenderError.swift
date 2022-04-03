//
//  MeshRenderError.swift
//
//
//  Created by Christopher Fredregill on 3/18/22.
//

import Foundation

/// Errors that can occur when attempting to render images from solved PDE meshes.
public enum MeshRenderError: Error {
    case invalidValue(String)
    case invalidImageFormat(String)
}
