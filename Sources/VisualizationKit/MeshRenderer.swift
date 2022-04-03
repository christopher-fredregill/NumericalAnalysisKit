//
//  MeshRenderer.swift
//
//
//  Created by Christopher Fredregill on 3/17/22.
//

import Foundation

protocol MeshRenderer {

    associatedtype MeshType

    associatedtype RenderType

    func render(_ mesh: MeshType, axis: Axis, completion: (RenderType, Int) throws -> Void) throws
}
