/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for the cross-platform view controller
*/

#if defined(TARGET_IOS)
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "Renderer.h"
#include <simd/simd.h>
#import <simd/simd.h>

// Cross Platform View Controller
#if defined(TARGET_IOS)
@interface ViewController : UIViewController

- (void)addDataModelWithVertices:(vector_float3 *)vertices
                         normals:(vector_float3 *)normals
                           faces:(vector_float3 *)faces
                             val:(float *)val;

#else
@interface ViewController : NSViewController
#endif

@end
