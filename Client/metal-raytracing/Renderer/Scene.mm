/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of scene creation functions
*/


#import "Scene.h"

@implementation SceneObject {
    NSUInteger _vertexCount;
}

- (instancetype)initWithVertexCount:(NSUInteger)vertexCount
                           animated:(BOOL)animated
{
    self = [super init];
    
    if (self) {
        _animated = animated;
        _vertexCount = vertexCount;
    }
    
    return self;
}

- (void)getVertices:(float3 *)vertices
            normals:(float3 *)normals
{
}

- (void)updateVerticesWithCommandBuffer:(id <MTLCommandBuffer>)commandBuffer
                           vertexBuffer:(id <MTLBuffer>)vertexBuffer
                           normalBuffer:(id <MTLBuffer>)normalBuffer
                           bufferOffset:(NSUInteger)bufferOffset
                                   time:(float)time
{
}

@end

@implementation SceneObjectInstance

- (instancetype)initWithObject:(SceneObject *)object
                     transform:(float4x4)transform
{
    self = [super init];
    
    if (self) {
        _object = object;
        _transform = transform;
    }
    
    return self;
}

@end

@implementation Scene {
    id <MTLBuffer> _instanceBuffer;
    
    // Acceleration structure rebuilds occur on the CPU timeline even when building
    // on the GPU, so you may have multiple builds in flight simultaneously. Similarly,
    // the CPU may be rebuilding an acceleration structure while the GPU is using it
    // for intersection. Therefore, you need one instance acceleration structure per
    // frame. In contrast, triangle acceleration structures are built once at startup
    // and are either static or only refit from frame to frame, so you only need one
    // triangle acceleration structure per object.
    //
    // Note that using an instance acceleration structure instead of directly intersecting
    // a triangle acceleration structure typically has a performance cost. If there is
    // only one object in the scene or if you can afford to pack the objects in the scene
    // into a single triangle acceleration structure it is typically preferable to use
    // a single triangle acceleration structure and intersect it directly.
    MPSInstanceAccelerationStructure *_instanceAccelerationStructures[maxFramesInFlight];
    
    dispatch_semaphore_t _encodeSemaphore;
    
    NSUInteger _frameIndex;
}

- (instancetype)initWithDevice:(id <MTLDevice>)device
                       library:(id <MTLLibrary>)library
                  commandQueue:(id <MTLCommandQueue>)commandQueue
{
    self = [super init];
    
    if (self) {
        _device = device;
        _library = library;
        _commandQueue = commandQueue;
        
        _sceneObjects = [NSMutableArray array];
        _sceneObjectInstances = [NSMutableArray array];
        
        _encodeSemaphore = dispatch_semaphore_create(1);
    }
    
    return self;
}

- (NSUInteger)instanceTransformsSize {
    NSUInteger instanceTransformsSize = _sceneObjectInstances.count * sizeof(float4x4);
    
    // Buffer offsets need to be aligned to 256 bytes on macOS, so align each buffer
    // range to 256 bytes.
    return (instanceTransformsSize + 255) & ~255;
}


- (NSUInteger)instanceTransformsBufferSize {
    // You need to allocate space in the buffer for each frame which can be
    // simultaneously in flight. This allows the CPU to write into one region of the
    // buffer while the GPU is reading from another region, which avoids stalling the
    // GPU.
    
    // Allocate one extra buffer range (maxFramesInFlight + 1) so that the previous
    // frame's transformation matrices will always be available even if the CPU has
    // started writing into the oldest frame's buffer range.

    return self.instanceTransformsSize * (maxFramesInFlight + 1);
}

- (NSUInteger)instanceNormalTransformsSize {
    NSUInteger instanceNormalTransformsSize = _sceneObjectInstances.count * sizeof(float3x3);
    return (instanceNormalTransformsSize + 255) & ~255;
}


- (NSUInteger)instanceNormalTransformsBufferSize {
    return self.instanceNormalTransformsSize * (maxFramesInFlight + 1);
}

- (NSUInteger)instanceBufferSize {
    NSUInteger instancesSize = _sceneObjectInstances.count * sizeof(uint32_t);
    NSUInteger alignedInstancesSize = (instancesSize + 255) & ~255;
    return alignedInstancesSize;
}

- (NSUInteger)instanceTransformBufferOffset {
    return self.instanceTransformsSize * (_frameIndex % (maxFramesInFlight + 1));
}

- (NSUInteger)previousInstanceTransformBufferOffset {
    NSUInteger index = _frameIndex % (maxFramesInFlight + 1);
    
    // Wrap around backwards if needed
    return self.instanceTransformsSize * (index ? index - 1 : maxFramesInFlight);
}

- (NSUInteger)instanceNormalTransformBufferOffset {
    return self.instanceNormalTransformsSize * (_frameIndex % (maxFramesInFlight + 1));
}

- (MPSInstanceAccelerationStructure *)accelerationStructure {
    return _instanceAccelerationStructures[_frameIndex % maxFramesInFlight];
}

// Create vertex buffers, instance buffer, etc.
- (void)createBuffers {
    // Vertex data should be stored in private or managed buffers on discrete GPU systems.
    // Private buffers are stored entirely in GPU memory and cannot be accessed by the CPU.
    // Managed buffers maintain a copy in CPU memory and a copy in GPU memory.
    MTLResourceOptions options = 0;
    
#if !TARGET_OS_IPHONE
    options = MTLResourceStorageModeManaged;
#else
    options = MTLResourceStorageModeShared;
#endif
    
    // Allocate buffers
    NSUInteger instanceTransformsBufferSize = self.instanceTransformsBufferSize;
    NSUInteger instanceNormalTransformsBufferSize = self.instanceNormalTransformsBufferSize;
    NSUInteger instanceBufferSize = self.instanceBufferSize;
    
    _instanceTransformBuffer = [_device newBufferWithLength:instanceTransformsBufferSize options:options];
    _instanceNormalTransformBuffer = [_device newBufferWithLength:instanceNormalTransformsBufferSize options:options];
    _instanceBuffer = [_device newBufferWithLength:instanceBufferSize options:options];
    
    // Write object ID into the instance buffer for each instance. This will be used by
    // the instance acceleration structure to index into the array of per-object
    // triangle acceleration structures.
    uint32_t *instances = (uint32_t *)_instanceBuffer.contents;
    
    NSUInteger i = 0;
    
    for (SceneObjectInstance *instance in _sceneObjectInstances)
        instances[i++] = (uint32_t)[_sceneObjects indexOfObject:instance.object];
    
    // When using managed buffers, you need to indicate that you modified the buffer
    // so that the GPU copy can be updated
#if !TARGET_OS_IPHONE
    [_instanceBuffer didModifyRange:NSMakeRange(0, _instanceBuffer.length)];
#endif
    
    NSUInteger vertexCount = 0;
    
    // Allocate buffers for vertex positions and normals. Note that these values
    // are float3's, which is a 16-byte aligned type. The vertices for all of the
    // objects must be packed into a single vertex buffer on argument buffer tier 1
    //devices. This will also perform better on argument buffer tier 2 devices. Each
    // object can still have a different vertex buffer offset.
    for (SceneObject *object in _sceneObjects)
        vertexCount += object.vertexCount;
    
    _vertexPositionBuffer = [_device newBufferWithLength:vertexCount * sizeof(float3) options:options];
    _previousVertexPositionBuffer = [_device newBufferWithLength:vertexCount * sizeof(float3) options:options];
    _vertexNormalBuffer = [_device newBufferWithLength:vertexCount * sizeof(float3) options:options];
    
    float3 *vertices = (float3 *)_vertexPositionBuffer.contents;
    float3 *normals = (float3 *)_vertexNormalBuffer.contents;
    
    vertexCount = 0;
    
    // Upload static vertex data to the vertex buffer
    for (SceneObject *object in _sceneObjects) {
        [object getVertices:&vertices[vertexCount]
                    normals:&normals[vertexCount]];
        
        vertexCount += object.vertexCount;
    }
    
#if !TARGET_OS_IPHONE
    [_vertexPositionBuffer didModifyRange:NSMakeRange(0, _vertexPositionBuffer.length)];
    [_vertexNormalBuffer didModifyRange:NSMakeRange(0, _vertexNormalBuffer.length)];
#endif
    
    // Copy the static vertex data to the other vertex buffer so that both buffers
    // contain a valid copy of the static data.
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    id <MTLBlitCommandEncoder> blit = [commandBuffer blitCommandEncoder];
    
    [blit copyFromBuffer:_vertexPositionBuffer
            sourceOffset:0
                toBuffer:_previousVertexPositionBuffer
       destinationOffset:0
                    size:_vertexPositionBuffer.length];
    
    [blit endEncoding];
    
    // Finally, update the dynamic vertex data for time=0. This vertex data
    // will be updated again when the first frame is rendered. However,
    // you need to have valid vertex data to build a triangle acceleration
    // structure for the object, since the sample builds the triangle
    // acceleration structures once when the app starts up and simply refits
    // it from frame to frame.
    [self updateVerticesWithCommandBuffer:commandBuffer time:0.0f];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}

// Create triangle and instance acceleration structures for the objects and
// instances in the scene
- (void)createAccelerationStructures {
    // Create an acceleration structure group. All of the acceleration
    // structures in an instance hierarchy must share the same group. This
    // allows these acceleration structures to pool certain resources internally.
    MPSAccelerationStructureGroup *group = [[MPSAccelerationStructureGroup alloc] initWithDevice:_device];
    
    NSUInteger vertexBufferOffset = 0;
    
    // Maintain an array of triangle acceleration structures. The instance
    // acceleration structure pulls triangle acceleration structures from this array.
    NSMutableArray *triangleAccelerationStructures = [NSMutableArray array];
    
    // Create a triangle acceleration structure for each object.
    for (SceneObject *object in _sceneObjects) {
        MPSTriangleAccelerationStructure *accelerationStructure = [[MPSTriangleAccelerationStructure alloc] initWithGroup:group];
        
        // Bind the vertex buffer with this object's vertex data offset and triangle count
        accelerationStructure.vertexBuffer = _vertexPositionBuffer;
        accelerationStructure.vertexBufferOffset = vertexBufferOffset * sizeof(float3);
        accelerationStructure.triangleCount = object.vertexCount / 3;
        
        // If the object is animated, you need to enable refitting. Note that
        // this option degrades the quality of the acceleration structure and
        // subsequently ray tracing performance, only use it for objects with
        // vertex animation. Rigid body animation should be handled by the
        // instance acceleration structure below.
        if (object.animated)
            accelerationStructure.usage = MPSAccelerationStructureUsageRefit;
        
        // Build the triangle acceleration structure. The sample only does this
        // once and reuses it from frame to frame, using a cheap refitting
        // operation when the vertex data changes.
        [accelerationStructure rebuild];
        
        object.accelerationStructure = accelerationStructure;
        
        vertexBufferOffset += object.vertexCount;
        
        [triangleAccelerationStructures addObject:accelerationStructure];
    }
    
    // Create an instance acceleration structure for each frame that could
    // simultaneously be in flight
    for (NSUInteger i = 0; i < maxFramesInFlight; i++) {
        MPSInstanceAccelerationStructure *instanceAccelerationStructure = [[MPSInstanceAccelerationStructure alloc] initWithGroup:group];
        
        // Number of instances in the scene
        instanceAccelerationStructure.instanceCount = _sceneObjectInstances.count;
        
        // Buffer containing the float4x4 transformation matrix for each instance
        instanceAccelerationStructure.transformBuffer = _instanceTransformBuffer;
        
        // Buffer containing one uint32_t index for each instance. This indexes
        // into the array of triangle acceleration structures.
        instanceAccelerationStructure.instanceBuffer = _instanceBuffer;
        
        // Array of triangle acceleration structures
        instanceAccelerationStructure.accelerationStructures = triangleAccelerationStructures;
        
        _instanceAccelerationStructures[i] = instanceAccelerationStructure;
        
        // The build is deferred until the frame actually begins rendering
        // so that objects can move around.
    }
}

- (void)finalize {
    [self createBuffers];
    [self createAccelerationStructures];
}

- (void)updateVerticesWithCommandBuffer:(id <MTLCommandBuffer>)commandBuffer
                                   time:(float)time
{
    NSUInteger vertexOffset = 0;
    
    // Simply update each animated object in turn
    for (SceneObject *object in _sceneObjects) {
        if (object.animated)
            [object updateVerticesWithCommandBuffer:commandBuffer
                                       vertexBuffer:_vertexPositionBuffer
                                       normalBuffer:_vertexNormalBuffer
                                       bufferOffset:vertexOffset * sizeof(float3)
                                               time:time];
        
        vertexOffset += object.vertexCount;
    }
}

// Update instance transformation matrix buffers in preparation for rebuilding
// this frame's instance acceleration structure
- (void)updateInstances
{
    NSUInteger instanceTransformsSize = self.instanceTransformsSize;
    NSUInteger instanceNormalTransformsSize = self.instanceNormalTransformsSize;
    
    NSUInteger instanceTransformBufferOffset = instanceTransformsSize * (_frameIndex % (maxFramesInFlight + 1));
    NSUInteger instanceNormalTransformBufferOffset = instanceNormalTransformsSize * (_frameIndex % (maxFramesInFlight + 1));
    
    MPSInstanceAccelerationStructure *accelerationStructure = _instanceAccelerationStructures[_frameIndex % maxFramesInFlight];
 
    // Update the instance acceleration structure to point to the current
    // frame's transformation matrices
    accelerationStructure.transformBufferOffset = instanceTransformBufferOffset;
    
    float4x4 *transforms = (float4x4 *)((char *)_instanceTransformBuffer.contents + instanceTransformBufferOffset);
    float3x3 *normalTransforms = (float3x3 *)((char *)_instanceNormalTransformBuffer.contents + instanceNormalTransformBufferOffset);
    
    NSUInteger i = 0;
    
    // Write the current transformation matrices into this frame's buffer ranges
    for (SceneObjectInstance *instance in _sceneObjectInstances) {
        transforms[i] = instance.transform;
        normalTransforms[i] = normalMatrix(instance.transform);
        
        i++;
    }
    
#if !TARGET_OS_IPHONE
    [_instanceTransformBuffer didModifyRange:NSMakeRange(instanceTransformBufferOffset, instanceTransformsSize)];
    [_instanceNormalTransformBuffer didModifyRange:NSMakeRange(instanceNormalTransformBufferOffset, instanceNormalTransformsSize)];
#endif
}

// Encode refitting for any animated triangle acceleration structures.
- (void)encodeRefittingToCommandBuffer:(id <MTLCommandBuffer>)commandBuffer
{
    // The vertex buffer bindings may be modified by another thread rebuilding the
    // instance acceleration structure, so you need to lock the buffer bindings
    // and change them to the current frame's vertex buffer.
    dispatch_semaphore_wait(_encodeSemaphore, DISPATCH_TIME_FOREVER);
    
    for (SceneObject *object in _sceneObjects) {
        MPSTriangleAccelerationStructure *accelerationStructure = object.accelerationStructure;
        
        accelerationStructure.vertexBuffer = self.vertexPositionBuffer;
        
        // Encode the refitting operation. This runs entirely on the GPU, so you
        // can safely encode this after updating the vertex data from a compute kernel.
        // Refitting preserves the existing tree structure in the acceleration structure
        // and simply snaps the bounding boxes for the tree nodes to the new geometry
        // positions.
        //
        // This results in a valid tree but the tree quality can degrade if the geometry
        // deforms too dramatically, which can reduce ray tracing performance. This is a
        // problem in extreme cases such as geometry collapsing to a point or teleporting
        // around the scene, but works quite well in cases such as skinned characters and
        // other typical vertex animation use cases. Note that refitting also does not
        // allow adding or removing triangles. Fortunately this is not typical for vertex
        // animation.
        if (object.animated)
            [accelerationStructure encodeRefitToCommandBuffer:commandBuffer];
    }
    
    dispatch_semaphore_signal(_encodeSemaphore);
}

- (void)updateWithCommandBuffer:(id <MTLCommandBuffer>)commandBuffer
                           time:(float)time
               completedHandler:(void (^)(MPSInstanceAccelerationStructure *))completedHandler
{
    // Write new vertex data into the vertex buffer
    [self updateVerticesWithCommandBuffer:commandBuffer
                                     time:time];
    
    // Refit the triangle acceleration structures to match the new vertex data
    [self encodeRefittingToCommandBuffer:commandBuffer];
    
    // Update the instance transformation matrices
    [self updateInstances];
    
    MPSInstanceAccelerationStructure *accelerationStructure = self.accelerationStructure;
    id <MTLBuffer> vertexPositionBuffer = self.vertexPositionBuffer;
    
    // Once the command buffer has completed, the updated vertex data will be in
    // the vertex buffer, the triangle acceleration structures will have finished
    // refitting, and the transformation matrix buffer will be up to date so you
    // can finally rebuild the instance acceleration structure. You can't build
    // the instance acceleration structure until this work has completed, so you
    // need to schedule it asynchronously.
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        // A refitting operation on another thread for a future frame may have changed
        // the vertex buffer bindings while you were waiting for the command buffer to
        // complete, so you need to lock the buffer bindings and change them back while
        // you build and use the acceleration structure.
        dispatch_semaphore_wait(self->_encodeSemaphore, DISPATCH_TIME_FOREVER);
        
        for (SceneObject *object in self->_sceneObjects)
            object.accelerationStructure.vertexBuffer = vertexPositionBuffer;
        
        // Finally, rebuild the instance acceleration structure.
        [accelerationStructure rebuild];
        
        // Once the accelerations structure has finished building, provide it
        // to the renderer to do intersection testing
        completedHandler(accelerationStructure);
        
        // Release the lock
        dispatch_semaphore_signal(self->_encodeSemaphore);
    }];
}

- (void)advanceFrame {
    _frameIndex++;
    
    // Swap the buffers so that the current frame's vertex buffer becomes the
    // previous frame's vertex buffer and vice versa.
    std::swap(_vertexPositionBuffer, _previousVertexPositionBuffer);
}

@end
