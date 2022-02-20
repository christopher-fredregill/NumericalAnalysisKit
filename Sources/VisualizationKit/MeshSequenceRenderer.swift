//
//  MeshSequenceRenderer.swift
//
//
//  Created by Christopher Fredregill on 3/18/22.
//

import Foundation

protocol MeshSequenceRenderer: MeshRenderer {

    func renderSequence(frameCount: Int, perspective: Axis) throws
}
