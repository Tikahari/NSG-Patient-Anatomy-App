/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of 3D object classes
*/


#import "ScanScene.h"

@implementation ScanVolumeSceneObject {
    float3 *_vertices;
    float3 *_faces;
    float3 *_normals;
    float *_val;
}
- (instancetype)initWithVertices:(float3 *)vertices
                           faces:(float3 *)faces
                         normals:(float3 *)normals
                             val:(float *)val
                            numVerts:(int)numVerts
{
    self = [super initWithVertexCount:numVerts
                             animated:NO];
    if (self) {
        _vertices = vertices;
        _faces = faces;
        _normals = normals;
        _val = val;
    }
    return self;
}

- (void)getVertices:(float3 *)vertices
            normals:(float3 *)normals
{
}



@end
//
//@implementation SphereSceneObject {
//    float _radius;
//    NSUInteger _horizontalSegments;
//    NSUInteger _verticalSegments;
//}
//
//- (instancetype)initWithRadius:(float)radius
//            horizontalSegments:(NSUInteger)horizontalSegments
//              verticalSegments:(NSUInteger)verticalSegments
//{
//    self = [super initWithVertexCount:horizontalSegments * verticalSegments * 6
//                             animated:NO];
//
//    if (self) {
//        _radius = radius;
//        _horizontalSegments = horizontalSegments;
//        _verticalSegments = verticalSegments;
//    }
//
//    return self;
//}
//
//void computeSphereVertex(float theta,
//                         float phi,
//                         float radius,
//                         float3 & vertex,
//                         float3 & normal)
//{
//    normal.x = sinf(phi) * cosf(theta);
//    normal.y = cosf(phi);
//    normal.z = sinf(phi) * sinf(theta);
//
//    vertex = radius * normal;
//}
//
//- (void)getVertices:(float3 *)vertices
//            normals:(float3 *)normals
//{
//    NSUInteger vertexIndex = 0;
//
//    for (NSUInteger y = 0; y < _verticalSegments; y++) {
//        for (NSUInteger x = 0; x < _horizontalSegments; x++) {
//            float phi0 = (y + 0) / (float)_verticalSegments * (float)M_PI;
//            float phi1 = (y + 1) / (float)_verticalSegments * (float)M_PI;
//
//            float theta0 = (x + 0) / (float)_horizontalSegments * 2.0f * (float)M_PI;
//            float theta1 = (x + 1) / (float)_horizontalSegments * 2.0f * (float)M_PI;
//
//            computeSphereVertex(theta0, phi0, _radius, vertices[vertexIndex + 0], normals[vertexIndex + 0]);
//            computeSphereVertex(theta0, phi1, _radius, vertices[vertexIndex + 1], normals[vertexIndex + 1]);
//            computeSphereVertex(theta1, phi1, _radius, vertices[vertexIndex + 2], normals[vertexIndex + 2]);
//
//            computeSphereVertex(theta0, phi0, _radius, vertices[vertexIndex + 3], normals[vertexIndex + 3]);
//            computeSphereVertex(theta1, phi1, _radius, vertices[vertexIndex + 4], normals[vertexIndex + 4]);
//            computeSphereVertex(theta1, phi0, _radius, vertices[vertexIndex + 5], normals[vertexIndex + 5]);
//
//            vertexIndex += 6;
//        }
//    }
//}
//
//@end

//@implementation PlaneSceneObject {
//    float _size;
//    NSUInteger _resolution;
//    float _frequency;
//    float _amplitude;
//    float2 _timeScale;
//
//    id <MTLComputePipelineState> _updateVerticesPipeline;
//}
//
//- (instancetype)initWithLibrary:(id <MTLLibrary>)library
//                           size:(float)size
//                     resolution:(NSUInteger)resolution
//                      frequency:(float)frequency
//                      amplitude:(float)amplitude
//                      timeScale:(float2)timeScale
//{
//    self = [super initWithVertexCount:resolution * resolution * 6
//                             animated:YES];
//
//    if (self) {
//        _size = size;
//        _resolution = resolution;
//        _frequency = frequency;
//        _amplitude = amplitude;
//        _timeScale = timeScale;
//
//        MTLComputePipelineDescriptor *descriptor = [[MTLComputePipelineDescriptor alloc] init];
//
//        descriptor.computeFunction = [library newFunctionWithName:@"updatePlaneVerticesKernel"];
//        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = YES;
//
//        NSError *error = nil;
//
//        _updateVerticesPipeline = [library.device newComputePipelineStateWithDescriptor:descriptor
//                                                                                options:0
//                                                                             reflection:nil
//                                                                                  error:&error];
//
//        if (!_updateVerticesPipeline)
//        NSLog(@"%@", error);
//    }
//
//    return self;
//}
//
//- (void)getVertices:(float3 *)vertices
//            normals:(float3 *)normals
//{
//}
//
//- (void)updateVerticesWithCommandBuffer:(id <MTLCommandBuffer>)commandBuffer
//                           vertexBuffer:(id <MTLBuffer>)vertexBuffer
//                           normalBuffer:(id <MTLBuffer>)normalBuffer
//                           bufferOffset:(NSUInteger)bufferOffset
//                                   time:(float)time
//{
//    PlaneParams params;
//
//    params.resolution = (uint32_t)_resolution;
//    params.invResolution = 1.0f / _resolution;
//    params.size = _size;
//    params.frequency = _frequency;
//    params.amplitude = _amplitude;
//    params.time = time;
//    params.timeScale = _timeScale;
//
//    id <MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];
//
//    [encoder setComputePipelineState:_updateVerticesPipeline];
//
//    [encoder setBytes:&params       length:sizeof(params) atIndex:0];
//    [encoder setBuffer:vertexBuffer offset:bufferOffset   atIndex:1];
//    [encoder setBuffer:normalBuffer offset:bufferOffset   atIndex:2];
//
//    MTLSize threadsPerThreadgroup = MTLSizeMake(8, 8, 1);
//    MTLSize threadgroups = MTLSizeMake((_resolution + threadsPerThreadgroup.width  - 1) / threadsPerThreadgroup.width,
//                                       (_resolution + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height,
//                                       1);
//
//    // Encode a compute kernel to update the vertices on the GPU
//    [encoder dispatchThreadgroups:threadgroups threadsPerThreadgroup:threadsPerThreadgroup];
//
//    [encoder endEncoding];
//}
//
//@end

@implementation ScanScene
 
- (instancetype)initWithDevice:device
                         library:library
                  commandQueue:commandQueue;
{
    self = [super initWithDevice:device
                         library:library
                    commandQueue:commandQueue];
    
    return self;
}

- (void)updateWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
                           time:(float)time
               completedHandler:(void (^)(MPSInstanceAccelerationStructure *))completedHandler
{
//This method may be used to update the view on swipe commands etc.
    
    [super updateWithCommandBuffer:commandBuffer
                              time:time
                  completedHandler:completedHandler];
}

- (void)addScanAndFinalize:(ScanVolumeSceneObject *)scan
{
    [self.sceneObjects addObject:scan];
    
    [self.sceneObjectInstances addObject:[[SceneObjectInstance alloc] initWithObject:scan transform:matrix_translation(0.0f, -1.0f, 0.0f)]];
    [self finalize];
}

@end
