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
                                       numVerts:(int)numVerts;

@end

// A representation of a nifti volume rendering, used to pass to ScanScene
//@interface ScanVolume : NSObject
//
////Initializer
//- (instancetype)initWithVertices:(NSArray*)vertices
//                           faces:(NSArray*)faces
//                         normals:(NSArray*)normals
//                             val:(NSArray*)val;

//@end

