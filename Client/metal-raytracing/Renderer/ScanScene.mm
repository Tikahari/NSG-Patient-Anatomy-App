/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of 3D object classes
*/


#import "ScanScene.h"

@implementation ScanVolumeSceneObject {
    float3 *_vertices;
    float3 *_normals;
    float *_val;
    int _numVerts;
}
- (instancetype)initWithVertices:(vector_float3 *)vertices
                         normals:(vector_float3 *)normals
                             val:(float *)val
                            numVerts:(int)numVerts
{
    self = [super initWithVertexCount:numVerts
                             animated:NO];
    if (self) {
        _vertices = vertices;
        _normals = normals;
        _val = val;
        _numVerts = numVerts;
        
        
    }
    return self;
}

- (void)getVertices:(float3 *)vertices
            normals:(float3 *)normals
{
    NSLog(@"%i", _numVerts);
    for (NSUInteger ii = 0; ii < _numVerts; ii++) {
        vertices[ii] = _vertices[ii];
        normals[ii] = _normals[ii];
//        NSLog(@"%.2f", vertices[ii].x);
//        NSLog(@"%.2f", vertices[ii].y);
//        NSLog(@"%.2f", vertices[ii].z);
    }
}





@end

@implementation SphereSceneObject {
    float _radius;
    NSUInteger _horizontalSegments;
    NSUInteger _verticalSegments;
}

- (instancetype)initWithRadius:(float)radius
            horizontalSegments:(NSUInteger)horizontalSegments
              verticalSegments:(NSUInteger)verticalSegments
{
    self = [super initWithVertexCount:horizontalSegments * verticalSegments * 6
                             animated:NO];

    if (self) {
        _radius = radius;
        _horizontalSegments = horizontalSegments;
        _verticalSegments = verticalSegments;
    }

    return self;
}

void computeSphereVertex(float theta,
                         float phi,
                         float radius,
                         float3 & vertex,
                         float3 & normal)
{
    normal.x = sinf(phi) * cosf(theta);
    normal.y = cosf(phi);
    normal.z = sinf(phi) * sinf(theta);
    vertex = radius * normal;
    NSLog(@"%.2f", vertex.x);
    NSLog(@"%.2f", vertex.y);
    NSLog(@"%.2f", vertex.z);
}

- (void)getVertices:(float3 *)vertices
            normals:(float3 *)normals
{
    NSUInteger vertexIndex = 0;

    for (NSUInteger y = 0; y < _verticalSegments; y++) {
        for (NSUInteger x = 0; x < _horizontalSegments; x++) {
            float phi0 = (y + 0) / (float)_verticalSegments * (float)M_PI;
            float phi1 = (y + 1) / (float)_verticalSegments * (float)M_PI;

            float theta0 = (x + 0) / (float)_horizontalSegments * 2.0f * (float)M_PI;
            float theta1 = (x + 1) / (float)_horizontalSegments * 2.0f * (float)M_PI;

            computeSphereVertex(theta0, phi0, _radius, vertices[vertexIndex + 0], normals[vertexIndex + 0]);
            computeSphereVertex(theta0, phi1, _radius, vertices[vertexIndex + 1], normals[vertexIndex + 1]);
            computeSphereVertex(theta1, phi1, _radius, vertices[vertexIndex + 2], normals[vertexIndex + 2]);

            computeSphereVertex(theta0, phi0, _radius, vertices[vertexIndex + 3], normals[vertexIndex + 3]);
            computeSphereVertex(theta1, phi1, _radius, vertices[vertexIndex + 4], normals[vertexIndex + 4]);
            computeSphereVertex(theta1, phi0, _radius, vertices[vertexIndex + 5], normals[vertexIndex + 5]);

            vertexIndex += 6;
        }
    }
}

@end


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

//
    [self.sceneObjectInstances addObject:[[SceneObjectInstance alloc] initWithObject:scan transform:matrix_identity_float4x4]];
    
//    SceneObject *sphere = [[SphereSceneObject alloc] initWithRadius:25.0f
//                                                 horizontalSegments:32
//                                                   verticalSegments:16];
//
//    [self.sceneObjects addObject:sphere];
//    [self.sceneObjectInstances addObject:[[SceneObjectInstance alloc] initWithObject:sphere transform:matrix_identity_float4x4]];
            

    [self finalize];
}

@end
