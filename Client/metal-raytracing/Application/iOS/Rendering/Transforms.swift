//
//  Transforms.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 11/11/20.
//

import Foundation
import simd

struct Transforms {

    static func matrix_translation(tx: Float, ty: Float, tz: Float) -> simd_float4x4{
        var translation_matrix = [SIMD4<Float>]()
        translation_matrix.append(SIMD4<Float>(1, 0, 0, 0))
        translation_matrix.append(SIMD4<Float>(0, 1, 0, 0))
        translation_matrix.append(SIMD4<Float>(0, 0, 1, 0))
        translation_matrix.append(SIMD4<Float>(tx, ty, tz, 1))
        return matrix_float4x4(translation_matrix)
    }

    static func matrix_rotation(radians: Float, axis: simd_float3) -> matrix_float4x4 {
        let norm_axis = simd_normalize(axis);
        let ct = cosf(radians);
        let st = sinf(radians);
        let ci = 1 - ct;
        let x = norm_axis.x, y = norm_axis.y, z = norm_axis.z;
        
        var rotation_matrix = [SIMD4<Float>]()
        rotation_matrix.append(SIMD4<Float>(    ct + x * x * ci,     y * x * ci + z * st, z * x * ci - y * st, 0))
        rotation_matrix.append(SIMD4<Float>(x * y * ci - z * st,         ct + y * y * ci, z * y * ci + x * st, 0))
        rotation_matrix.append(SIMD4<Float>(x * z * ci + y * st,     y * z * ci - x * st,     ct + z * z * ci, 0))
        rotation_matrix.append(SIMD4<Float>(                  0,                   0,                   0,     1))
        return matrix_float4x4(rotation_matrix)
    }

    static func matrix_scale(sx: Float,  sy: Float,  sz: Float) -> matrix_float4x4 {
        return matrix_float4x4(diagonal: SIMD4<Float>(sx, sy, sz, 1))
    }

    static func matrix_look_at( eye: simd_float3,  center: simd_float3,  up: simd_float3) -> matrix_float4x4 {
        let z = simd_normalize(center - eye);
        let x = simd_normalize(simd_cross(z, up));
        let y = cross(z, x);
        let t: simd_float3 =  simd_float3([-simd_dot(x, eye), -simd_dot(y, eye), -simd_dot(z, eye)])
        
        var look_at_matrix = [SIMD4<Float>]()
        look_at_matrix.append(SIMD4<Float>(x.x, y.x, z.x, 0))
        look_at_matrix.append(SIMD4<Float>(x.y, y.y, z.y, 0))
        look_at_matrix.append(SIMD4<Float>(x.z, y.z, z.z, 0))
        look_at_matrix.append(SIMD4<Float>(t.x, t.y, t.z, 1))
        return matrix_float4x4(look_at_matrix)
        
    }

    static func matrix_perspective(fovyRadians: Float, aspect: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
        let ys = 1 / tanf(fovyRadians * 0.5)
        let xs = ys / aspect
        let zs = farZ / (farZ - nearZ)
        
        var perspectice_matrix = [SIMD4<Float>]()
        perspectice_matrix.append(SIMD4<Float>(xs,  0,  0,            0))
        perspectice_matrix.append(SIMD4<Float>(0,   ys, 0,            0))
        perspectice_matrix.append(SIMD4<Float>(0,   0,  zs,           0))
        perspectice_matrix.append(SIMD4<Float>(0,   0,  nearZ * zs,   0))
        return matrix_float4x4(perspectice_matrix)
        

    }

    static func normalMatrix(transform: matrix_float4x4) -> matrix_float3x3 {
        
        var upperLeft = [SIMD3<Float>]()
        upperLeft.append(SIMD3<Float>([transform.columns.0.x, transform.columns.0.y, transform.columns.0.z]))
        upperLeft.append(SIMD3<Float>([transform.columns.1.x, transform.columns.1.y, transform.columns.1.z]))
        upperLeft.append(SIMD3<Float>([transform.columns.2.x, transform.columns.2.y, transform.columns.2.z]))
        return simd_transpose(simd_inverse(matrix_float3x3(upperLeft)))
    }

}

