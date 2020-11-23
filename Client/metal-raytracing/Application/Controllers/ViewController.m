/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of the cross-platform view controller
*/

#import "ViewController.h"
#import "Renderer.h"

@implementation ViewController
{
    MTKView *_view;

    Renderer *_renderer;
    
    vector_float3 *_vertices;
    vector_float3 *_faces;
    vector_float3 *_normals;
    float *_val;
    int _size;
}

- (void)addDataModelWithVertices:(vector_float3 *)vertices
                         normals:(vector_float3 *)normals
                             val:(float *)val
                            size:(int)size
{
    _vertices = (vector_float3*)malloc(size * sizeof(vector_float3));
    _vertices = vertices;
    _normals = (vector_float3*)malloc(size * sizeof(vector_float3));
    _normals = normals;
    _val = val;
    _size = size;
    
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _view = (MTKView *)self.view;


#if TARGET_MACOS
    // Set color space of view to SRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceLinearSRGB);
    _view.colorspace = colorSpace;
    CGColorSpaceRelease(colorSpace);

    // Lookup high power GPU if this is a discrete GPU system
    NSArray<id <MTLDevice>> *devices = MTLCopyAllDevices();

    id <MTLDevice> device = devices[0];
    for (id <MTLDevice> potentialDevice in devices) {
        if (!potentialDevice.lowPower) {
            device = potentialDevice;
            break;
        }
    }
#else
    id <MTLDevice> device = MTLCreateSystemDefaultDevice();

    _view.backgroundColor = UIColor.clearColor;
#endif
    _view.device = device;

    if(!_view.device)
    {
        NSLog(@"Metal is not supported on this device");
#if TARGET_MACOS
        self.view = [[NSView alloc] initWithFrame:self.view.frame];
#else
        self.view = [[UIView alloc] initWithFrame:self.view.frame];
#endif
        return;
    }
    
    _renderer = [[Renderer alloc] initWithMetalKitView:_view
                                              vertices:(_vertices)
                                               normals:(_normals)
                                                   val:(_val)
                                                  numVerts:(_size)];

    [_renderer mtkView:_view drawableSizeWillChange:_view.bounds.size];

    _view.delegate = _renderer;
}

@end
