/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation for transformation matrix building functions
*/

#import "Transforms.h"

matrix_float4x4 matrix_translation(float tx, float ty, float tz) {
    return (matrix_float4x4) {{
        { 1,   0,  0,  0 },
        { 0,   1,  0,  0 },
        { 0,   0,  1,  0 },
        { tx, ty, tz,  1 }
    }};
}

matrix_float4x4 matrix_rotation(float radians, vector_float3 axis) {
    axis = vector_normalize(axis);
    float ct = cosf(radians);
    float st = sinf(radians);
    float ci = 1 - ct;
    float x = axis.x, y = axis.y, z = axis.z;

    return (matrix_float4x4) {{
        { ct + x * x * ci,     y * x * ci + z * st, z * x * ci - y * st, 0},
        { x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0},
        { x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0},
        {                   0,                   0,                   0, 1}
    }};
}

matrix_float4x4 matrix_scale(float sx, float sy, float sz) {
    return (matrix_float4x4) {{
        { sx,  0,  0,  0 },
        { 0,  sy,  0,  0 },
        { 0,   0, sz,  0 },
        { 0,   0,  0,  1 }
    }};
}

matrix_float4x4 matrix_look_at(vector_float3 eye, vector_float3 center,
                               vector_float3 up)
{
    vector_float3 z = vector_normalize(center - eye);
    vector_float3 x = vector_normalize(vector_cross(z, up));
    vector_float3 y = vector_cross(x, z);
    vector_float3 t = (vector_float3){ -vector_dot(x, eye), -vector_dot(y, eye), -vector_dot(z, eye) };
    
    return (matrix_float4x4) {{
        { x.x, y.x, z.x, 0 },
        { x.y, y.y, z.y, 0 },
        { x.z, y.z, z.z, 0 },
        { t.x, t.y, t.z, 1 }
    }};
}

matrix_float4x4 matrix_perspective(float fovyRadians, float aspect, float nearZ, float farZ) {
    float ys = 1 / tanf(fovyRadians * 0.5);
    float xs = ys / aspect;
    float zs = farZ / (farZ - nearZ);
    return (matrix_float4x4) {{
        { xs, 0, 0, 0 },
        { 0, ys, 0, 0 },
        { 0, 0, zs, 1 },
        { 0, 0, -nearZ * zs, 0 }
    }};
}

matrix_float3x3 normalMatrix(matrix_float4x4 transform) {
    matrix_float3x3 upperLeft = {
        .columns[0] = transform.columns[0].xyz,
        .columns[1] = transform.columns[1].xyz,
        .columns[2] = transform.columns[2].xyz
    };
    
    return matrix_transpose(matrix_invert(upperLeft));
}
