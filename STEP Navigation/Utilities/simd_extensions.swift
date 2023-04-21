//
//  simd_extensions.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/14/23.
//

import Foundation
import ARKit

extension simd_float4x4 {
    public var translation: simd_float3 {
        return simd_float3(columns.3.x,
                           columns.3.y,
                           columns.3.z)
    }
    
    public init?(fromColumnMajorArray a: [Double]) {
        guard a.count == 16 else {
            return nil
        }
        let b = a.map({Float($0)})
        self = simd_float4x4(columns: (simd_float4(b[0], b[1], b[2], b[3]),
                                       simd_float4(b[4], b[5], b[6], b[7]),
                                       simd_float4(b[8], b[9], b[10], b[11]),
                                       simd_float4(b[12], b[13], b[14], b[15])))
    }
    
    public init(translation: simd_float3, rotation: simd_quatf) {
        self = simd_float4x4(rotation)
        self.columns.3.x = translation.x
        self.columns.3.y = translation.y
        self.columns.3.z = translation.z
    }
    
    public func toColumnMajor()->[Float] {
        return [self[0,0], self[0,1], self[0,2], self[0,3], self[1,0], self[1,1], self[1,2], self[1,3], self[2,0], self[2,1], self[2,2], self[2,3], self[3,0], self[3,1], self[3,2], self[3,3]]
    }
    
    func alignY(allowNegativeY: Bool = false)->float4x4 {
        let yAxisVal = !allowNegativeY || simd_quatf(self).axis.y >= 0 ? Float(1.0) : Float(-1.0)
        return float4x4(translation: self.translation, rotation: simd_quatf(from: columns.1.inhomogeneous, to: simd_float3(0, yAxisVal, 0))*simd_quatf(self))
    }
}

extension simd_float4 {
    var inhomogeneous: simd_float3 {
        return simd_float3(x, y, z)
    }
}
