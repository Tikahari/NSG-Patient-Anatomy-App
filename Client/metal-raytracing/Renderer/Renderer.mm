/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of platform independent renderer class
*/

#import "Renderer.h"
#import "ScanScene.h"


@implementation Renderer
{
    MTKView *_view;
    id <MTLDevice> _device;
    id <MTLCommandQueue> _queue;
    id <MTLLibrary> _library;
    
    id <MTLComputePipelineState> _shadowPipeline;
    id <MTLComputePipelineState> _compositePipeline;
    id <MTLRenderPipelineState> _copyPipeline;
    id <MTLRenderPipelineState> _renderPipeline;
    
    id <MTLTexture> _previousTexture;
    id <MTLTexture> _previousDepthNormalTexture;
    id <MTLTexture> _shadowRayTexture;
    id <MTLTexture> _intersectionTexture;
    id <MTLTexture> _randomTexture;
    
    id <MTLDepthStencilState> _depthStencilState;
    
    MPSRayIntersector *_intersector;
    
    dispatch_semaphore_t _frameSemaphore;
    
    CGSize _size;
    
    MPSSVGFDefaultTextureAllocator *_textureAllocator;
    MPSTemporalAA *_TAA;
    MPSSVGFDenoiser *_denoiser;
    
    Uniforms _uniforms;
    Uniforms _prevUniforms;

    unsigned int _frameIndex;
    NSDate *_startTime;
    
    SampleScene *_scene;
    ScanVolumeSceneObject *_scan;
}

// Initializer
-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view
                                   vertices:(vector_float3 *)vertices
                                      faces:(vector_float3 *)faces
                                    normals:(vector_float3 *)normals
                                        val:(float *)val;
{
    self = [super init];

    if (self)
    {
        _view = view;
        _device = view.device;
        
        NSLog(@"Metal device: %@", _device.name);

        _frameSemaphore = dispatch_semaphore_create(maxFramesInFlight);
        
        [self loadMetal];
        [self loadMPSSVGF];
        [self createPipelines];
        [self createIntersector];
        
        _scan = [[ScanVolumeSceneObject alloc] initWithVertices:vertices faces:faces normals:normals val:val];
        
        
//        _scene = [[SampleScene alloc] initWithDevice:_device
//                                             library:_library
//                                        commandQueue:_queue
//                                                scan:_scan];
        _scene = [[SampleScene alloc] initWithDevice:_device
                                             library:_library
                                        commandQueue:_queue];
        [_scene addScan:_scan];
        _startTime = [NSDate date];
    }

    return self;
}

// Configure Metal
- (void)loadMetal
{
    // Configure view
    _view.colorPixelFormat = MTLPixelFormatRGBA16Float;
    _view.sampleCount = 1;
    _view.drawableSize = _view.frame.size;

    _library = [_device newDefaultLibrary];
    _queue = [_device newCommandQueue];
    
    // Create a depth/stencil state which will be used by the rasterization pipeline
    MTLDepthStencilDescriptor *depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
    
    depthStencilDescriptor.depthWriteEnabled = YES;
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    
    _depthStencilState = [_device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
}

// Initialize the MPS SVGF denoiser and temporal antialiasing filters
- (void)loadMPSSVGF {
    // Create an object which allocates and caches intermediate textures
    // throughout and across frames
    _textureAllocator = [[MPSSVGFDefaultTextureAllocator alloc] initWithDevice:_device];
    
    // Create an MPSSVGF object. This object encodes the low-level
    // kernels used by the MPSSVGFDenoiser object and allows the app
    // to fine-tune the denoising process.
    MPSSVGF *svgf = [[MPSSVGF alloc] initWithDevice:_device];
    
    // The app only denoises shadows which only have a single-channel,
    // so set the channel count to 1. This is faster then denoising
    // all 3 channels on an RGB image.
    svgf.channelCount = 1;
    
    // The app integrates samples over time while limiting ghosting artifacts,
    // so set the temporal weighting to an exponential moving average and
    // reduce the temporal blending factor
    svgf.temporalWeighting = MPSTemporalWeightingExponentialMovingAverage;
    svgf.temporalReprojectionBlendFactor = 0.1f;
    
    // Create the MPSSVGFDenoiser convenience object. Although you
    // could call the low-level denoising kernels directly on the MPSSVGF
    // object, for simplicity this sample lets the MPSSVGFDenoiser object
    // take care of it.
    _denoiser = [[MPSSVGFDenoiser alloc] initWithSVGF:svgf textureAllocator:_textureAllocator];
    
    // Adjust the number of bilateral filter iterations used by the denoising
    // process. More iterations will tend to produce better quality at the cost
    // of performance, while fewer iterations will perform better but have
    // lower quality. Five iterations is a good starting point. The best way to
    // improve quality is to reduce the amount of noise in the denoiser's input
    // image using techniques such as importance sampling and low-discrepancy
    // random sequences.
    _denoiser.bilateralFilterIterations = 5;
    
    // Create the temporal antialiasing object
    _TAA = [[MPSTemporalAA alloc] initWithDevice:_device];
}

// Create render pipeline and compute pipeline states
- (void)createPipelines
{
    NSError *error = NULL;
    
    MTLComputePipelineDescriptor *computeDescriptor = [[MTLComputePipelineDescriptor alloc] init];

    // Set to YES to allow compiler to make certain optimizations
    computeDescriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = YES;
    
    // This function consumes shadow ray intersection tests to update the
    // shadow mask image
    computeDescriptor.computeFunction = [_library newFunctionWithName:@"shadowKernel"];
    
    _shadowPipeline = [_device newComputePipelineStateWithDescriptor:computeDescriptor
                                                             options:0
                                                          reflection:nil
                                                               error:&error];
    
    if (!_shadowPipeline)
        NSLog(@"Failed to create pipeline state: %@", error);

    // Thie function composites the shaded image and the
    //denoised shadow mask image
    computeDescriptor.computeFunction = [_library newFunctionWithName:@"compositeKernel"];
    
    _compositePipeline = [_device newComputePipelineStateWithDescriptor:computeDescriptor
                                                                options:0
                                                             reflection:nil
                                                                  error:&error];
    
    if (!_compositePipeline)
        NSLog(@"Failed to create pipeline state: %@", error);

    // This render pipeline copies the rendered scene into the MTKView
    MTLRenderPipelineDescriptor *renderDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    renderDescriptor.sampleCount = _view.sampleCount;
    renderDescriptor.vertexFunction = [_library newFunctionWithName:@"copyVertex"];
    renderDescriptor.fragmentFunction = [_library newFunctionWithName:@"copyFragment"];
    renderDescriptor.colorAttachments[0].pixelFormat = _view.colorPixelFormat;

    _copyPipeline = [_device newRenderPipelineStateWithDescriptor:renderDescriptor error:&error];
    
    if (!_copyPipeline)
        NSLog(@"Failed to create pipeline state, error %@", error);
    
    // This render pipeline rasterizes triangle geometry and outputs color, depth,
    // normals, motion vectors, and shadow rays
    renderDescriptor.sampleCount = 1;
    renderDescriptor.vertexFunction = [_library newFunctionWithName:@"vertexFunction"];
    renderDescriptor.fragmentFunction = [_library newFunctionWithName:@"fragmentFunction"];
    
    renderDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatRGBA16Float;
    renderDescriptor.colorAttachments[1].pixelFormat = MTLPixelFormatRGBA16Float;
    renderDescriptor.colorAttachments[2].pixelFormat = MTLPixelFormatRG16Float;
    renderDescriptor.colorAttachments[3].pixelFormat = MTLPixelFormatRGBA32Float;
    renderDescriptor.colorAttachments[4].pixelFormat = MTLPixelFormatRGBA32Float;
    
    renderDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
              _renderPipeline = [_device newRenderPipelineStateWithDescriptor:renderDescriptor
                                                              error:&error];
    
    if (!_renderPipeline)
        NSLog(@"Failed to create pipeline state: %@", error);
}

// Initialize the MPS ray intersector
- (void)createIntersector
{
    // Create a ray intersector.
    _intersector = [[MPSRayIntersector alloc] initWithDevice:_device];
    
    // Use the max distance field of the ray struct to ignore shadow
    // rays for pixels that do not have any geometry
    _intersector.rayDataType = MPSRayDataTypeOriginMinDistanceDirectionMaxDistance;
    
    // You only need to know whether or not a ray hit anything on the way
    // to the light source for shadow rays. You don't need to know the
    // triangle index, barycentric coordinates, etc.
    // So you can use the simple distance-only intersection data type.
    // This distance will be less than zero if the ray did not hit anything,
    // meaning that the origin was not in shadow.
    _intersector.intersectionDataType = MPSIntersectionDataTypeDistance;
}

// Handle the view changing size
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    _size = size;
    
    // Release any textures the denoiser is holding on to, then release
    // everything from the texture allocators.
    [_denoiser releaseTemporaryTextures];
    [_textureAllocator reset];
    
    // Initialize the previous frame's textures
    _previousDepthNormalTexture = [_textureAllocator textureWithPixelFormat:MTLPixelFormatRGBA16Float width:_size.width height:_size.height];
    
    _previousTexture = [_textureAllocator textureWithPixelFormat:MTLPixelFormatRGBA16Float width:_size.width height:_size.height];
    
    MTLTextureDescriptor *renderTargetDescriptor = [[MTLTextureDescriptor alloc] init];
    
    renderTargetDescriptor.width = size.width;
    renderTargetDescriptor.height = size.height;
    
    // Generate a 2xRGBA32Float 2D array texture to contain shadow ray origins,
    // min distances, directions, and max distances.
    renderTargetDescriptor.textureType = MTLTextureType2DArray;
    renderTargetDescriptor.pixelFormat = MTLPixelFormatRGBA32Float;
    renderTargetDescriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    renderTargetDescriptor.storageMode = MTLStorageModePrivate;
    renderTargetDescriptor.arrayLength = 2;
    
    _shadowRayTexture = [_device newTextureWithDescriptor:renderTargetDescriptor];
    
    // Generate a 1xR32Float 2D array texture to contain the corresponding
    // intersection distance.
    renderTargetDescriptor.usage = MTLTextureUsageShaderWrite | MTLTextureUsageShaderRead;
    renderTargetDescriptor.arrayLength = 1;
    renderTargetDescriptor.pixelFormat = MTLPixelFormatR32Float;
    
    _intersectionTexture = [_device newTextureWithDescriptor:renderTargetDescriptor];
    
    // Finally, allocate a 2D R32UInt texture to contain random values for each
    // pixel. This value is used to decorrelate pixels while drawing pseudorandom
    // numbers from a Halton sequence while generating shadow rays.
    renderTargetDescriptor.textureType = MTLTextureType2D;
    renderTargetDescriptor.pixelFormat = MTLPixelFormatR8Uint;
    renderTargetDescriptor.usage = MTLTextureUsageShaderRead;
    renderTargetDescriptor.arrayLength = 1;
#if !TARGET_OS_IPHONE
    renderTargetDescriptor.storageMode = MTLStorageModeManaged;
#else
    renderTargetDescriptor.storageMode = MTLStorageModeShared;
#endif
    
    _randomTexture = [_device newTextureWithDescriptor:renderTargetDescriptor];
    
    uint8_t *randomValues = (uint8_t *)malloc(sizeof(uint8_t) * size.width * size.height);
    
    for (NSUInteger i = 0; i < size.width * size.height; i++)
        randomValues[i] = (uint8_t)(rand() % 16);
    
    [_randomTexture replaceRegion:MTLRegionMake2D(0, 0, size.width, size.height)
                      mipmapLevel:0
                        withBytes:randomValues
                      bytesPerRow:sizeof(uint8_t) * size.width];
    
    free(randomValues);
    
    // Reset the frame counter so the renderer doesn't try to reproject
    // uninitialized textures into the current frame.
    _frameIndex = 0;
}

// Update uniform values that are passed to the GPU.
- (void)updateUniforms {
    // Store the previous frame's uniforms before overwriting them
    _prevUniforms = _uniforms;

    // Compute the camera position and forward, right, and up vectors.
    float3 position = vector3(-8.0f, 8.0f, 20.0f);
    float3 target = vector3(0.0f, 0.0f, 0.0f);
    
    float3 forward = normalize(target - position);
    
    float3 up = vector3(0.0f, 1.0f, 0.0f);
    float3 right = normalize(cross(forward, up));
    up = cross(right, forward);
    
    // Compute the view matrix
    matrix_float4x4 viewMatrix = matrix_look_at(position, target, up);

    // Compute other projection matrix parameters
    float fieldOfView = 45.0f * (M_PI / 180.0f);
    float aspectRatio = (float)_size.width / (float)_size.height;
    
    // Compute the projection matrix
    matrix_float4x4 projectionMatrix = matrix_perspective(fieldOfView, aspectRatio, 0.1f, 1000.0f);
    
    // Shear the projection matrix by plus or minus half a pixel for temporal
    // antialiasing. This will have the result of sampling a different point
    // within each pixel every frame. The sample uses a Halton sequence rather
    // than purely random numbers to generate the sample positions to ensure good
    // pixel coverage.
    float2 jitter = (haltonSamples[_frameIndex % 16] * 2.0f - 1.0f) / vector2((float)_size.width, (float)_size.height);
    
    // Store the amount of jitter so that the shader can "unjitter" it
    // when computing motion vectors.
    _uniforms.jitter = jitter * vector2(0.5f, -0.5f);
    
    projectionMatrix.columns[2][0] += jitter.x;
    projectionMatrix.columns[2][1] += jitter.y;

    // Finally, compute the combined view/projection matrix
    matrix_float4x4 viewProjectionMatrix = matrix_multiply(projectionMatrix, viewMatrix);
    
    _uniforms.viewMatrix = viewMatrix;
    _uniforms.viewProjectionMatrix = viewProjectionMatrix;
    
    _uniforms.width = (unsigned int)_size.width;
    _uniforms.height = (unsigned int)_size.height;

    _uniforms.frameIndex = _frameIndex;
}

// Uses the rasterizer to draw the scene geometry. Outputs:
//   - Shaded color/lighting
//   - Depth and normals
//   - Motion vectors describing how far each pixel has moved since the previous frame
//   - Shadow ray origins and directions which will be used to generate ray traced soft shadows
- (void)encodeRasterizationToCommandBuffer:(id <MTLCommandBuffer>)commandBuffer
                              colorTexture:(id <MTLTexture> *)colorTexture
                        depthNormalTexture:(id <MTLTexture> *)depthNormalTexture
                       motionVectorTexture:(id <MTLTexture> *)motionVectorTexture
{
    *colorTexture = [_textureAllocator textureWithPixelFormat:MTLPixelFormatRGBA16Float width:_size.width height:_size.height];
    *depthNormalTexture = [_textureAllocator textureWithPixelFormat:MTLPixelFormatRGBA16Float width:_size.width height:_size.height];
    *motionVectorTexture = [_textureAllocator textureWithPixelFormat:MTLPixelFormatRG16Float width:_size.width height:_size.height];
    id <MTLTexture> depthTexture = [_textureAllocator textureWithPixelFormat:MTLPixelFormatDepth32Float width:_size.width height:_size.height];
    
    // Bind the output textures using a render pass descriptor. This also
    // clears the textures to some predetermined values.
    MTLRenderPassDescriptor *renderPass = [[MTLRenderPassDescriptor alloc] init];
    
    renderPass.colorAttachments[0].texture = *colorTexture;
    renderPass.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    renderPass.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    renderPass.colorAttachments[1].texture = *depthNormalTexture;
    renderPass.colorAttachments[1].loadAction = MTLLoadActionClear;
    renderPass.colorAttachments[1].clearColor = MTLClearColorMake(1000.0, 0.0, 0.0, 0.0);
    renderPass.colorAttachments[1].storeAction = MTLStoreActionStore;
    
    renderPass.colorAttachments[2].texture = *motionVectorTexture;
    renderPass.colorAttachments[2].loadAction = MTLLoadActionClear;
    renderPass.colorAttachments[2].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0);
    renderPass.colorAttachments[2].storeAction = MTLStoreActionStore;
    
    renderPass.colorAttachments[3].texture = _shadowRayTexture;
    renderPass.colorAttachments[3].slice = 0;
    renderPass.colorAttachments[3].loadAction = MTLLoadActionClear;
    renderPass.colorAttachments[3].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0);
    renderPass.colorAttachments[3].storeAction = MTLStoreActionStore;
    
    renderPass.colorAttachments[4].texture = _shadowRayTexture;
    renderPass.colorAttachments[4].slice = 1;
    renderPass.colorAttachments[4].loadAction = MTLLoadActionClear;
    // This clears the "max distance" field to -1 so the ray intersector
    // will exit immediately for pixels which are not covered by any geometry
    renderPass.colorAttachments[4].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, -1.0);
    renderPass.colorAttachments[4].storeAction = MTLStoreActionStore;
    
    renderPass.depthAttachment.texture = depthTexture;
    renderPass.depthAttachment.loadAction = MTLLoadActionClear;
    renderPass.depthAttachment.clearDepth = 1.0f;
    renderPass.depthAttachment.storeAction = MTLStoreActionDontCare;
    
    id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPass];
    
    // Provide current frame and previous frame's uniform data so that
    // the renderer can compute motion vectors.
    [renderEncoder setVertexBytes:&_uniforms     length:sizeof(_uniforms)     atIndex:0];
    [renderEncoder setVertexBytes:&_prevUniforms length:sizeof(_prevUniforms) atIndex:1];
    
    // Provide current frame and previous frame's instance transformation matrices
    [renderEncoder setVertexBuffer:_scene.instanceTransformBuffer       offset:_scene.instanceTransformBufferOffset atIndex:5];
    [renderEncoder setVertexBuffer:_scene.instanceTransformBuffer       offset:_scene.previousInstanceTransformBufferOffset atIndex:6];
    [renderEncoder setVertexBuffer:_scene.instanceNormalTransformBuffer offset:_scene.instanceNormalTransformBufferOffset atIndex:7];
    
    [renderEncoder setFragmentBytes:&_uniforms     length:sizeof(_uniforms)     atIndex:0];
    [renderEncoder setFragmentBytes:&_prevUniforms length:sizeof(_prevUniforms) atIndex:1];
    
    [renderEncoder setFragmentTexture:_randomTexture atIndex:0];
    
    [renderEncoder setRenderPipelineState:_renderPipeline];
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    
    uint32_t instanceIndex = 0;
    
    // Draw each object instance in the scene in turn
    for (SceneObjectInstance *instance in _scene.sceneObjectInstances) {
        SceneObject *object = instance.object;
        
        // All of the objects are packed into one set of vertex buffers,
        // so you need to bind them at this object's offset. Provide both
        // the current frame and previous frame's vertex data.
        [renderEncoder setVertexBuffer:_scene.vertexPositionBuffer         offset:object.accelerationStructure.vertexBufferOffset atIndex:2];
        [renderEncoder setVertexBuffer:_scene.previousVertexPositionBuffer offset:object.accelerationStructure.vertexBufferOffset atIndex:3];
        [renderEncoder setVertexBuffer:_scene.vertexNormalBuffer           offset:object.accelerationStructure.vertexBufferOffset atIndex:4];
        
        // Provide the instance index which will be used by the shader to look
        // up the transformation matrix.
        [renderEncoder setVertexBytes:&instanceIndex length:sizeof(instanceIndex) atIndex:8];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:object.vertexCount];
        
        instanceIndex++;
    }
    
    [renderEncoder endEncoding];
    
    [_textureAllocator returnTexture:depthTexture];
}

// Generates a shadow mask texture (0.0 = in shadow, 1.0 = not in shadow) from
// the intersection texture output by the ray intersector. This image will be
// noisy so it is then fed into the denoiser which  will result in a soft
// shadow effect.
- (id <MTLTexture>)encodeShadowsToCommandBuffer:(id <MTLCommandBuffer>)commandBuffer
{
    id <MTLTexture> shadowTexture = [_textureAllocator textureWithPixelFormat:MTLPixelFormatR16Float width:_shadowRayTexture.width height:_shadowRayTexture.height];
    
    id <MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    
    [computeEncoder setBytes:&_uniforms length:sizeof(_uniforms) atIndex:0];
    
    [computeEncoder setTexture:_shadowRayTexture    atIndex:0];
    [computeEncoder setTexture:_intersectionTexture atIndex:1];
    [computeEncoder setTexture:shadowTexture        atIndex:2];
    
    [computeEncoder setComputePipelineState:_shadowPipeline];
    
    MTLSize threadsPerThreadgroup = MTLSizeMake(8, 8, 1);
    MTLSize threadgroups = MTLSizeMake((_size.width  + threadsPerThreadgroup.width  - 1) / threadsPerThreadgroup.width,
                                       (_size.height + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height,
                                       1);
    
    [computeEncoder dispatchThreadgroups:threadgroups threadsPerThreadgroup:threadsPerThreadgroup];
    
    [computeEncoder endEncoding];
    
    return shadowTexture;
}

// Combines the shadow mask texture and shaded color texture and performs
// tone mapping. This image is then fed into temporal antialiasing.
- (id <MTLTexture>)encodeCompositeToCommandBuffer:(id <MTLCommandBuffer>)commandBuffer
                                     colorTexture:(id <MTLTexture>)colorTexture
                                    shadowTexture:(id <MTLTexture>)shadowTexture
{
    id <MTLTexture> compositeTexture = [_textureAllocator textureWithPixelFormat:MTLPixelFormatRGBA16Float width:_shadowRayTexture.width height:_shadowRayTexture.height];
    
    id <MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    
    [computeEncoder setBytes:&_uniforms length:sizeof(_uniforms) atIndex:0];
    
    [computeEncoder setTexture:colorTexture     atIndex:0];
    [computeEncoder setTexture:shadowTexture    atIndex:1];
    [computeEncoder setTexture:compositeTexture atIndex:2];
    
    [computeEncoder setComputePipelineState:_compositePipeline];
    
    MTLSize threadsPerThreadgroup = MTLSizeMake(8, 8, 1);
    MTLSize threadgroups = MTLSizeMake((_size.width  + threadsPerThreadgroup.width  - 1) / threadsPerThreadgroup.width,
                                       (_size.height + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height,
                                       1);
    
    [computeEncoder dispatchThreadgroups:threadgroups threadsPerThreadgroup:threadsPerThreadgroup];
    
    [computeEncoder endEncoding];
    
    return compositeTexture;
}

// Copy an image to the view using the graphics pipeline since you can't write
// directly to it with a compute kernel.
- (void)presentTexture:(id <MTLTexture>)texture
         commandBuffer:(id <MTLCommandBuffer>)commandBuffer
{
     // Delay getting the current render pass descriptor as long as possible to
    // avoid stalling until the GPU/compositor release a drawable.
    MTLRenderPassDescriptor* renderPassDescriptor = _view.currentRenderPassDescriptor;
    
    // The render pass descriptor may be nil if the window has moved off screen.
    if (renderPassDescriptor != nil) {
        // Create a render encoder
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        [renderEncoder setRenderPipelineState:_copyPipeline];
        
        [renderEncoder setFragmentTexture:texture atIndex:0];
        
        // Draw a quad which fills the screen
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
        
        [renderEncoder endEncoding];
        
        // Present the drawable to the screen
        [commandBuffer presentDrawable:_view.currentDrawable];
    }
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    // The sample uses triple buffering to stream data to the GPU, so
    // you need to wait until the oldest frame has finished running on
    // the GPU before you can reuse that space in the buffer(s).
    dispatch_semaphore_wait(_frameSemaphore, DISPATCH_TIME_FOREVER);
    
    // Compute the current time
    float time = -(float)[_startTime timeIntervalSinceNow];

    // Update the uniform data
    [self updateUniforms];
    
    // If this is the first frame or the window has been resized, throw
    // away the temporal history in the denoiser to avoid artifacts.
    if (_frameIndex == 0)
        [_denoiser clearTemporalHistory];
    
    // Encode the work into four command buffers. This is complicated by the
    // fact that you need to rebuild an acceleration structure asynchronously
    // in the middle of the frame and you can't encode ray/triangle intersection
    // testing until the acceleration structure has finished building. Start by
    // creating the four command buffers.
    id <MTLCommandBuffer> updateCommandBuffer = [_queue commandBuffer];
    id <MTLCommandBuffer> shadingCommandBuffer = [_queue commandBuffer];
    id <MTLCommandBuffer> intersectionCommandBuffer = [_queue commandBuffer];
    id <MTLCommandBuffer> postprocessingCommandBuffer = [_queue commandBuffer];

    // Next, enqueue the command buffers so they run in the correct order. The
    // GPU will start working on them as soon as they are committed, even if
    // they are committed from another thread as in this example.
    [updateCommandBuffer enqueue];
    [shadingCommandBuffer enqueue];
    [intersectionCommandBuffer enqueue];
    [postprocessingCommandBuffer enqueue];
    
    id <MTLTexture> shadowRayTexture = _shadowRayTexture;
    id <MTLTexture> intersectionTexture = _intersectionTexture;
    
    // Start by updating the scene using the 'update' command buffer. This
    // updates the vertex buffers, refit triangle acceleration structures, and
    // finally rebuild the instance acceleration structure. Once the instance
    // acceleration structure is done building, encode ray/triangle intersection
    // testing.
    [_scene updateWithCommandBuffer:updateCommandBuffer
                               time:time
                   completedHandler:^(MPSInstanceAccelerationStructure *accelerationStructure)
    {
        // Encode ray/triangle intersection testing. The shading kernel below
        // will have written shadow rays in the ray texture by the time this
        // runs. The intersector then determines whether there was an intersection
        // for each ray and write the result into the intersection texture.
        //
        // You only need to know whether the shadows rays hit anything on the way
        // to the light source, not which triangle was intersected. Therefore, you
        // can use the "any" intersection type to end the intersection search as
        // soon as any intersection is found. This is typically much faster than
        // finding the nearest intersection. You can also use
        // MPSIntersectionDataTypeDistance, because you don't need the triangle
        // index and barycentric coordinates.
        [self->_intersector encodeIntersectionToCommandBuffer:intersectionCommandBuffer
                                             intersectionType:MPSIntersectionTypeAny
                                                   rayTexture:shadowRayTexture
                                          intersectionTexture:intersectionTexture
                                        accelerationStructure:accelerationStructure];
        
        // Finally, commit the intersection command buffer so the GPU can start
        // working on intersection testing. Once it is finished the subsequent
        // post-processing work will begin.
        [intersectionCommandBuffer commit];
    }];
    
    // Commit the update command buffer so that the GPU can start working on
    // updating vertex data and rebuilding the instance acceleration structure.
    [updateCommandBuffer commit];
    
    id <MTLTexture> colorTexture, depthNormalTexture, motionVectorTexture;
    
    // In the meantime, you can start working on the initial shading pass.
    // This render pipeline computes lighting/color, depth, normals, motion
    // vectors, and the origins and directions of the shadow rays that you
    // will intersect with the acceleration structure.
    [self encodeRasterizationToCommandBuffer:shadingCommandBuffer
                                colorTexture:&colorTexture
                          depthNormalTexture:&depthNormalTexture
                         motionVectorTexture:&motionVectorTexture];
    
    // Commit the shading command buffer. The GPU will start working on
    // shading as soon as it finishes updating the scene and the acceleration
    //structure will be rebuilt simultaneously. This allows the shading work to
    // hide some or all of the latency of rebuilding the acceleration structure.
    [shadingCommandBuffer commit];
    
    // Finally, launch a kernel which writes the color computed by the shading
    // kernel into the output image, but only if the corresponding shadow ray
    // does not intersect anything on the way to the light. If the shadow ray
    // intersects a triangle before reaching the light source, the original
    // intersection point was in shadow. This command buffer starts as soon as
    // the intersection testing ends.
    id <MTLTexture> shadowTexture = [self encodeShadowsToCommandBuffer:postprocessingCommandBuffer];
    
    // Next, work on denoising. Encode the denoising work to the post-processing command buffer
    id <MTLTexture> denoisedTexture = [_denoiser encodeToCommandBuffer:postprocessingCommandBuffer
                                                         sourceTexture:shadowTexture
                                                   motionVectorTexture:motionVectorTexture
                                                    depthNormalTexture:depthNormalTexture
                                            previousDepthNormalTexture:_previousDepthNormalTexture];
    
    // Return the noisy shadow texture back to the texture allocator
    [_textureAllocator returnTexture:shadowTexture];
    
    // Finally, composite the shadow image and the shaded image together
    id <MTLTexture> compositeTexture = [self encodeCompositeToCommandBuffer:postprocessingCommandBuffer
                                                               colorTexture:colorTexture
                                                              shadowTexture:denoisedTexture];
    
    // You no longer need the shadow or shaded textures.
    [_textureAllocator returnTexture:colorTexture];
    [_textureAllocator returnTexture:denoisedTexture];
    
    id <MTLTexture> AATexture = compositeTexture;
    
    // You can't stochastically sample the scene geometry for antialiasing
    // when using the MPSSVGF denoiser because it requires a clean depth and
    // normal texture. Instead, you can use post-process temporal antialiasing
    // using the existing motion vectors. You need to wait until you have
    // rendered at least one frame so that the temporal reprojection step will
    // not read an uninitialized texture.
    if (_frameIndex > 0) {
        AATexture = [_textureAllocator textureWithPixelFormat:MTLPixelFormatRGBA16Float width:_size.width height:_size.height];
    
        [_TAA encodeToCommandBuffer:postprocessingCommandBuffer
                      sourceTexture:compositeTexture
                    previousTexture:_previousTexture
                 destinationTexture:AATexture
                motionVectorTexture:motionVectorTexture
                       depthTexture:depthNormalTexture];
        
        [_textureAllocator returnTexture:compositeTexture];
    }
    
    // Finally, return this frame's 'previous' textures to the texture allocator
    // and make the current frame's depth/normal texture and output texture the
    // next frame's 'previous' textures.
    [_textureAllocator returnTexture:_previousDepthNormalTexture];
    _previousDepthNormalTexture = depthNormalTexture;
    
    [_textureAllocator returnTexture:motionVectorTexture];
    
    [_textureAllocator returnTexture:_previousTexture];
    _previousTexture = AATexture;

    // Last, present the result to the display.
    [self presentTexture:AATexture commandBuffer:postprocessingCommandBuffer];
    
    // When the frame has finished, signal that the uniform buffer space from
    // this frame can be reused. Note that the contents of completion handlers
    // should be as fast as possible as the GPU driver may have other work scheduled
    // on the underlying dispatch queue.
    [postprocessingCommandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        dispatch_semaphore_signal(self->_frameSemaphore);
    }];

    // Finally, commit the command buffer.
    [postprocessingCommandBuffer commit];
    
    _frameIndex++;
    
    [_scene advanceFrame];
}

@end
