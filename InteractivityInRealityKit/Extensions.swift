//
//  Extensions.swift
//  InteractivityInRealityKit
//
//  Created by Mark Horgan on 26/05/2022.
//

import simd

extension simd_float4x4 {
    public var position: simd_float3 {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
}
