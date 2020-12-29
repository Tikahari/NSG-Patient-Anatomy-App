/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for platform independent renderer class
*/

#import <MetalKit/MetalKit.h>

// The platform-independent renderer class.   Implements the MTKViewDelegate protocol which
//   allows it to accept per-frame update and drawable resize callbacks.
@interface Renderer : NSObject <MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view
                                   vertices:(nonnull vector_float3 *)vertices
                                    normals:(nonnull vector_float3 *)normals
                                        val:(nonnull float *)val
                                   numVerts:(int)numVerts
                             cameraPosition:(vector_float3)position;

- (void)updateCameraWithPosition:(vector_float3 )position;

@end


