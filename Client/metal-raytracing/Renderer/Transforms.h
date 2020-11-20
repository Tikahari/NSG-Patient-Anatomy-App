/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for transformation matrix building functions
*/

#ifndef Transforms_h
#define Transforms_h

#import <simd/simd.h>

matrix_float4x4 matrix_translation(float tx, float ty, float tz);

matrix_float4x4 matrix_rotation(float radians, vector_float3 axis);

matrix_float4x4 matrix_scale(float sx, float sy, float sz);

matrix_float4x4 matrix_look_at(vector_float3 eye, vector_float3 center,
                               vector_float3 up);

matrix_float4x4 matrix_perspective(float fovyRadians, float aspect, float nearZ, float farZ);

matrix_float3x3 normalMatrix(matrix_float4x4 transform);

#endif
