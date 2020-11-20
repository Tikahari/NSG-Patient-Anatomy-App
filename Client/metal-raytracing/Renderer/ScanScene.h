/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for 3D object classes
*/

#ifndef SampleScene_h
#define SampleScene_h

#import "Scene.h"
#include <simd/simd.h>

// A simple static sphere object
@interface SphereSceneObject : SceneObject

// Initializer
- (instancetype)initWithRadius:(float)radius
            horizontalSegments:(NSUInteger)horizontalSegments
              verticalSegments:(NSUInteger)verticalSegments;

@end

// A representation of a nifti volume rendering
@interface ScanVolumeSceneObject : SceneObject

//Initializer
- (instancetype)initWithVertices:(float3 *)vertices
                           faces:(float3 *)faces
                         normals:(float3 *)normals
                             val:(float *)val;

@end


// An animated plane. The surface of the plane is transformed according to
// y = cos(x * frequency) * sin(z * frequency) * amplitude. This object demonstrates
// vertex animation. The cos and sin terms are shifted over time to generate the
// animation.
@interface PlaneSceneObject : SceneObject

// Initializer
- (instancetype)initWithLibrary:(id <MTLLibrary>)library
                           size:(float)size
                     resolution:(NSUInteger)resolution
                      frequency:(float)frequency
                      amplitude:(float)amplitude
                      timeScale:(float2)timeScale;

@end

// A sample scene containing animated spheres and an animated plane.
@interface SampleScene : Scene
//Initializer
//- (instancetype)initWithScan:(ScanVolumeSceneObject *)scan;
////- (void)updateWithVertices:(float3 *)vertices
////                           faces:(float3 *)faces
////                         normals:(float3 *)normals
////                             val:(float *)val;

- (void) addScan : (ScanVolumeSceneObject *)scan;

@end

#endif