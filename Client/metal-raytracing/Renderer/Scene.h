/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for scene creation functions
*/

#ifndef Scene_h
#define Scene_h

#import <Metal/Metal.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import <MetalKit/MetalKit.h>

#include <simd/simd.h>

#import "Transforms.h"
#import "ShaderTypes.h"

using namespace simd;

// The maximum number of frames the CPU can encode ahead of the GPU. This is used
// to compute the sizes of various buffers used to stream data from the CPU to the
// GPU.
static const NSUInteger maxFramesInFlight = 3;

// Represents a unique object type in a scene. Each SceneObject has unique
// vertex data and an MPS triangle acceleration structure which is used to accelerate
// ray/triangle intersection tests against that vertex data. SceneObjects are
// inserted into the scene using SceneObjectInstances, which are copied of the
// scene object with their own transformation matrix. This reduces the amount of
// duplicate vertex data and also allows objects to move around the scene more
// cheaply because, rather than update a giant triangle acceleration structure, you
// can instead update a small instance acceleration structure.
@interface SceneObject : NSObject

// Number of vertices in the object
@property (nonatomic, readonly) NSUInteger vertexCount;

// Whether the vertices of the object are animated. If so, updateVerticesWithCommandBuffer
// will be called every frame to update the vertex data.
@property (nonatomic, readonly) BOOL animated;

// The triangle acceleration structure built from the vertex data used to
// accelerate ray/triangle intersection tests
@property (nonatomic) MPSTriangleAccelerationStructure *accelerationStructure;

// Initializer
- (instancetype)initWithVertexCount:(NSUInteger)vertexCount
                           animated:(BOOL)animated;

// Get the vertices and normals for the object. This is called once when the app
// launches. Static vertex data should be provided here. If the vertex data is
// animated, it can be provided by updateVerticesWithCommandBuffer instead.
- (void)getVertices:(float3 *)vertices
            normals:(float3 *)normals;

// Update animated vertex data. This should be done on the GPU using the provided
// command buffer. Updated vertices and normals should be written into the
// vertex and normal buffers at the given offset, animated to the given time.
- (void)updateVerticesWithCommandBuffer:(id <MTLCommandBuffer>)commandBuffer
                           vertexBuffer:(id <MTLBuffer>)vertexBuffer
                           normalBuffer:(id <MTLBuffer>)normalBuffer
                           bufferOffset:(NSUInteger)bufferOffset
                                   time:(float)time;

@end

// Represents an instance of a scene object. Each instance may have its own
// transformation matrix. This can be used to replicate and move objects more
// cheaply than rebuilding a giant triangle acceleration structure.
@interface SceneObjectInstance : NSObject

// The scene object this instance is an instance of
@property (nonatomic) SceneObject *object;

// The transformation matrix describing how to transform the object in the scene
@property (nonatomic) float4x4 transform;

// Initializer
- (instancetype)initWithObject:(SceneObject *)object
                     transform:(float4x4)transform;

@end

// Represents a scene containing unique object types and instances of those objects.
// Manages the creation of various buffers, animation of scene objects, and the
// creation of triangle and instance acceleration structures used for ray tracing.
@interface Scene : NSObject

@property (nonatomic, readonly) id <MTLDevice> device;
@property (nonatomic, readonly) id <MTLLibrary> library;
@property (nonatomic, readonly) id <MTLCommandQueue> commandQueue;

// Array of unique scene objects. Each scene object has unique vertex data and a
// corresponding triangle acceleration structure.
@property (nonatomic, readonly) NSMutableArray <SceneObject *> *sceneObjects;

// Array of scene object instances. Each instance references a scene object and a
// transformation matrix. The instances will be used to build an instance
// acceleration structure.
@property (nonatomic, readonly) NSMutableArray <SceneObjectInstance *> *sceneObjectInstances;

// A buffer containing the transformation matrices for all of the instances in the
// scene.
@property (nonatomic, readonly) id <MTLBuffer> instanceTransformBuffer;

// The current frame's offset into the instance transformation matrix buffer
@property (nonatomic, readonly) NSUInteger instanceTransformBufferOffset;

// The previous frame's offset into the instance transformation matrix buffer,
// used to compute motion vectors between the previous and current frame.
@property (nonatomic, readonly) NSUInteger previousInstanceTransformBufferOffset;

// The 3x3 transformation matrix used to transform normal vectors, derived from
// the instance transforms.
@property (nonatomic, readonly) id <MTLBuffer> instanceNormalTransformBuffer;

// The current frame's offset into the normal transformation matrix buffer
@property (nonatomic, readonly) NSUInteger instanceNormalTransformBufferOffset;

// The current frame's vertex buffer
@property (nonatomic, readonly) id <MTLBuffer> vertexPositionBuffer;

// The previous frame's vertex buffer, used to compute motion vectors between the
// previous and current frame.
@property (nonatomic, readonly) id <MTLBuffer> previousVertexPositionBuffer;

// The buffer containing normal vectors for each vertex.
@property (nonatomic, readonly) id <MTLBuffer> vertexNormalBuffer;

// The top-level instance acceleration structure for the scene
@property (nonatomic, readonly) MPSInstanceAccelerationStructure *accelerationStructure;

- (instancetype)init NS_UNAVAILABLE;

// Initializer
- (instancetype)initWithDevice:(id <MTLDevice>)device
                       library:(id <MTLLibrary>)library
                  commandQueue:(id <MTLCommandQueue>)commandQueue;

// Finish creating the buffers and other resources needed to use the scene. This
// should be called by scene subclasses after they have added objects and instances
// to the scene.
- (void)finalize;

// Update the scene for the given time. This must be called before accessing scene
// properties such as the acceleration structure, vertex buffer, etc.
- (void)updateWithCommandBuffer:(id <MTLCommandBuffer>)commandBuffer
                           time:(float)time
               completedHandler:(void (^)(MPSInstanceAccelerationStructure *))completedHandler;

// Advance the scene to the next frame. This must be called at the end of the frame
// after accessing scene properties for the current frame.
- (void)advanceFrame;

@end

#endif
