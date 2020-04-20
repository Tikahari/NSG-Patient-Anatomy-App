//
//  viewer.m
//  Render3D
//
//  Created by Jonas Pena on 4/20/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//


//  Viewer.m
//  Render3D
//
//  Created by Tikahari Khanal on 4/10/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

#import "Viewer.h"
#include "vtkIOSRenderWindow.h"
#include "vtkIOSRenderWindowInteractor.h"
#include "vtkRenderingOpenGL2ObjectFactory.h"
#include "vtkNIFTIImageReader.h"
#include "vtkNew.h"

#include "vtkNrrdReader.h"
#include "vtkImageCast.h"
#include "vtkRTAnalyticSource.h"
#include "vtkOpenGLGPUVolumeRayCastMapper.h"
#include "vtkVolumeProperty.h"
#include "vtkColorTransferFunction.h"
#include "vtkPiecewiseFunction.h"
#include "vtkVolume.h"
#include "vtkActor.h"
#include "vtkCamera.h"
#include "vtkConeSource.h"
#include "vtkDebugLeaks.h"
#include "vtkGlyph3D.h"
#include "vtkPolyData.h"
#include "vtkPolyDataMapper.h"
#include "vtkRenderWindow.h"
#include "vtkRenderer.h"
#include "vtkSphereSource.h"
#include "vtkTextActor.h"
#include "vtkTextProperty.h"
#include "vtkImageData.h"
#include "vtkPointData.h"
#include "vtkSmartPointer.h"

#include "vtkActor.h"
#include "vtkActor2D.h"
#include "vtkCamera.h"
#include "vtkCommand.h"
#include "vtkInteractorStyleMultiTouchCamera.h"
#include "vtkMath.h"
#include "vtkPoints.h"
#include "vtkPolyDataMapper.h"
#include "vtkRenderer.h"
#include "vtkTextMapper.h"
#include "vtkTextProperty.h"

#include <deque>

/* 2 or 3 -- needs to match VTK version */
#define GL_ES_VERSION 3

@interface Viewer (){
    NSString* titleText;
    NSString* filename;
}

 @property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) EAGLContext *context;
- (void)tearDownGL;
@end

@implementation Viewer

//----------------------------------------------------------------------------
- (vtkIOSRenderWindow *)getVTKRenderWindow
{
    return _myVTKRenderWindow;
}

//----------------------------------------------------------------------------
- (void)setVTKRenderWindow:(vtkIOSRenderWindow *)theVTKRenderWindow
{
    _myVTKRenderWindow = theVTKRenderWindow;
}

//----------------------------------------------------------------------------
- (vtkIOSRenderWindowInteractor *)getInteractor
{
    if (_myVTKRenderWindow)
    {
        return (vtkIOSRenderWindowInteractor *)_myVTKRenderWindow->GetInteractor();
    }
    else
    {
        return NULL;
    }
}

- (void)setVTKRenderer:(vtkRendererRef)theRenderer
{
    _myRenderer = theRenderer;
}

-(vtkRenderer *)getVTKRenderer
{
  return _myRenderer;
}

- (NSArray *)recursivePathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)directoryPath{

    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];

    NSString *filePath;

    while ((filePath = [enumerator nextObject]) != nil){
        NSLog(@"filePath %@", filePath);
        if (!type || [[filePath pathExtension] isEqualToString:type]){
            NSLog(@"correct type");
            [filePaths addObject:[directoryPath stringByAppendingPathComponent:filePath]];
        }
    }

    return filePaths;
}

- (void)addToRenderer:(NSString*)filename {
    vtkNew<vtkOpenGLGPUVolumeRayCastMapper> volumeMapper;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    NSString *getPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filename]];

    std::string fname([basePath UTF8String]);
    NSLog(filename);
    NSString *path =  [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    // from path
    fname = ([getPath UTF8String]);
    // from array
//    fname = ([filename UTF8String]);
    NSLog(@"file to be used %s", fname.c_str());
    //    fname = "/Users/Khanal/Desktop/Tikahari/Downloads/freesurfer_outputs/mri/aparc.a2009s+aseg.nii";
    //    vtkNew<vtkNrrdReader> mi;
    vtkNew<vtkNIFTIImageReader> mi;
    mi->SetFileName(fname.c_str());
    mi->Update();
    
    double range[2];
    mi->GetOutput()->GetPointData()->GetScalars()->GetRange(range);
    
    volumeMapper->SetInputConnection(mi->GetOutputPort());
    
    
    
    volumeMapper->SetAutoAdjustSampleDistances(1);
       volumeMapper->SetSampleDistance(0.5);
       
       vtkNew<vtkVolumeProperty> volumeProperty;
       volumeProperty->SetShade(1);
       volumeProperty->SetInterpolationTypeToLinear();
       
       vtkNew<vtkColorTransferFunction> ctf;
       // ctf->AddRGBPoint(90, 0.2, 0.29, 1);
       // ctf->AddRGBPoint(157.091, 0.87, 0.87, 0.87);
       // ctf->AddRGBPoint(250, 0.7, 0.015, 0.15);
       
//       ctf->AddRGBPoint(0, 0, 0, 0);
//       ctf->AddRGBPoint(255*67.0106/3150.0, 0.54902, 0.25098, 0.14902);
//       ctf->AddRGBPoint(255*251.105/3150.0, 0.882353, 0.603922, 0.290196);
//       ctf->AddRGBPoint(255*439.291/3150.0, 1, 0.937033, 0.954531);
//       ctf->AddRGBPoint(255*3071/3150.0, 0.827451, 0.658824, 1);
       
       
       // vtkNew<vtkPiecewiseFunction> pwf;
       // pwf->AddPoint(0, 0.0);
       // pwf->AddPoint(7000, 1.0);
       
       double tweak = 80.0;
       vtkNew<vtkPiecewiseFunction> pwf;
       pwf->AddPoint(0, 0);
       pwf->AddPoint(255*(67.0106+tweak)/3150.0, 0);
       pwf->AddPoint(255*(251.105+tweak)/3150.0, 0.3);
       pwf->AddPoint(255*(439.291+tweak)/3150.0, 0.5);
       pwf->AddPoint(255*3071/3150.0, 0.616071);
//
//       volumeProperty->SetColor(ctf.GetPointer());
       volumeProperty->SetScalarOpacity(pwf.GetPointer());
       
       vtkNew<vtkVolume> volume;
       volume->SetMapper(volumeMapper.GetPointer());
       volume->SetProperty(volumeProperty.GetPointer());
       
     vtkRenderer* myRenderer = [self getVTKRenderer];
       myRenderer->SetBackground2(0.2,0.3,0.4);
       myRenderer->SetBackground(0.1,0.1,0.1);
       myRenderer->GradientBackgroundOn();
       myRenderer->AddVolume(volume.GetPointer());
       myRenderer->ResetCamera();
    myRenderer->GetActiveCamera()->Zoom(0.7);
    
}
- (void)setupPipeline
{
    // Register GL2 objects
    vtkObjectFactory::RegisterFactory(vtkRenderingOpenGL2ObjectFactory::New());
    
    vtkIOSRenderWindow *renWin = vtkIOSRenderWindow::New();
    //renWin->DebugOn();
    [self setVTKRenderWindow:renWin];
    
    // this example uses VTK's built in interaction but you could choose
    // to use your own instead.
    vtkRenderWindowInteractor *iren = vtkRenderWindowInteractor::New();
    vtkNew<vtkInteractorStyleMultiTouchCamera> ismt;
    ismt->DebugOn();
    iren->SetInteractorStyle(ismt.Get());
    iren->SetRenderWindow(renWin);
    
    vtkNew<vtkRenderer> renderer;
    renWin->AddRenderer(renderer.Get());
    [self setVTKRenderer:renderer.Get()];
    //get .nii.gz paths
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSLog(@" resource paths%@", resourcePath);
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];
    NSLog(@"files %@", files);
    NSArray * files_found = [self recursivePathsForResourcesOfType:@"nii" inDirectory:resourcePath];
    NSLog(@"files found %@", files_found);
    
    printf("completed file paths\n");
    

    [self addToRenderer:filename];
//    //add multiple volumes
//    NSInteger count = 0;
//    for(NSString *nii in files_found){
//        if (count < 10) {
//        [self addToRenderer: nii];
//        }
//        count++;
//    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.titleLabel.text = self->titleText;
    
    
#if GL_ES_VERSION == 2
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
#else
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
#endif
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    //view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    // setup the vis pipeline
    [self setupPipeline];
    
    [EAGLContext setCurrentContext:self.context];
    [self resizeView];
    [self getVTKRenderWindow]->Render();
}


- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // free GL resources
    // ...
}

-(void) resizeView
{
    double scale = self.view.contentScaleFactor;
    double newWidth = scale * self.view.bounds.size.width;
    double newHeight = scale * self.view.bounds.size.height;
    [self getVTKRenderWindow]->SetSize(newWidth, newHeight);
}

- (void)viewWillLayoutSubviews
{
    [self resizeView];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //std::cout << [self getVTKRenderWindow]->ReportCapabilities() << std::endl;
    [self getVTKRenderWindow]->Render();
}



//=================================================================
// this example uses VTK's built in interaction but you could choose
// to use your own instead. The remaining methods forward touch events
// to VTKs interactor.

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    vtkIOSRenderWindowInteractor *interactor = [self getInteractor];
    if (!interactor)
    {
        return;
    }
    
    vtkIOSRenderWindow *renWin = [self getVTKRenderWindow];
    if (!renWin)
    {
        return;
    }
    
    CGRect bounds = [self.view bounds];
    double scale = self.view.contentScaleFactor;
    
    // set the position for all contacts
    NSSet *myTouches = [event touchesForView:self.view];
    for (UITouch *touch in myTouches)
    {
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
        CGPoint location = [touch locationInView:self.view];
        location.y = bounds.size.height - location.y;
        
        // Account for the content scaling factor
        location.x *= scale;
        location.y *= scale;
        
        int index = interactor->GetPointerIndexForContact((size_t)(__bridge void *)touch);
        if (index < VTKI_MAX_POINTERS)
        {
            interactor->SetEventInformation((int)round(location.x),
                                            (int)round(location.y),
                                            0, 0,
                                            0, 0, 0, index);
        }
    }
    
    // handle begin events
    for (UITouch *touch in touches)
    {
        int index = interactor->GetPointerIndexForContact((size_t)(__bridge void *)touch);
        vtkGenericWarningMacro("down touch  " << (size_t)(__bridge void *)touch << " index " << index);
        interactor->SetPointerIndex(index);
        interactor->InvokeEvent(vtkCommand::LeftButtonPressEvent,NULL);
        //NSLog(@"Starting left mouse");
    }
    
    // Display the buffer
    [(GLKView *)self.view display];
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    vtkIOSRenderWindowInteractor *interactor = [self getInteractor];
    if (!interactor)
    {
        return;
    }
    
    vtkIOSRenderWindow *renWin = [self getVTKRenderWindow];
    if (!renWin)
    {
        return;
    }
    
    CGRect bounds = [self.view bounds];
    double scale = self.view.contentScaleFactor;
    
    // set the position for all contacts
    int index;
    NSSet *myTouches = [event touchesForView:self.view];
    for (UITouch *touch in myTouches)
    {
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
        CGPoint location = [touch locationInView:self.view];
        location.y = bounds.size.height - location.y;
        
        // Account for the content scaling factor
        location.x *= scale;
        location.y *= scale;
        
        index = interactor->GetPointerIndexForContact((size_t)(__bridge void *)touch);
        if (index < VTKI_MAX_POINTERS)
        {
            interactor->SetEventInformation((int)round(location.x),
                                            (int)round(location.y),
                                            0, 0,
                                            0, 0, 0, index);
        }
    }
    
    // fire move event on last index
    interactor->SetPointerIndex(index);
    interactor->InvokeEvent(vtkCommand::MouseMoveEvent,NULL);
    NSLog(@"Moved left mouse");
    
    // Display the buffer
    [(GLKView *)self.view display];
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    vtkIOSRenderWindowInteractor *interactor = [self getInteractor];
    if (!interactor)
    {
        return;
    }
    
    vtkIOSRenderWindow *renWin = [self getVTKRenderWindow];
    if (!renWin)
    {
        return;
    }
    
    CGRect bounds = [self.view bounds];
    double scale = self.view.contentScaleFactor;
    
    // set the position for all contacts
    NSSet *myTouches = [event touchesForView:self.view];
    for (UITouch *touch in myTouches)
    {
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
        CGPoint location = [touch locationInView:self.view];
        location.y = bounds.size.height - location.y;
        
        // Account for the content scaling factor
        location.x *= scale;
        location.y *= scale;
        
        int index = interactor->GetPointerIndexForContact((size_t)(__bridge void *)touch);
        if (index < VTKI_MAX_POINTERS)
        {
            interactor->SetEventInformation((int)round(location.x),
                                            (int)round(location.y),
                                            0, 0,
                                            0, 0, 0, index);
        }
    }
    
    // handle begin events
    for (UITouch *touch in touches)
    {
        int index = interactor->GetPointerIndexForContact((size_t)(__bridge void *)touch);
        vtkGenericWarningMacro("up touch  " << (size_t)(__bridge void *)touch << " index " << index);
        interactor->SetPointerIndex(index);
        interactor->InvokeEvent(vtkCommand::LeftButtonReleaseEvent,NULL);
        interactor->ClearContact((size_t)(__bridge void *)touch);
        // NSLog(@"lifting left mouse");
    }
    
    // Display the buffer
    [(GLKView *)self.view display];
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    vtkIOSRenderWindowInteractor *interactor = [self getInteractor];
    if (!interactor)
    {
        return;
    }
    
    vtkIOSRenderWindow *renWin = [self getVTKRenderWindow];
    if (!renWin)
    {
        return;
    }
    
    CGRect bounds = [self.view bounds];
    double scale = self.view.contentScaleFactor;
    
    UITouch* touch = [[event touchesForView:self.view] anyObject];
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    CGPoint location = [touch locationInView:self.view];
    location.y = bounds.size.height - location.y;
    
    // Account for the content scaling factor
    location.x *= scale;
    location.y *= scale;
    
    interactor->SetEventInformation((int)round(location.x),
                                    (int)round(location.y),
                                    0, 0,
                                    0, 0);
    interactor->InvokeEvent(vtkCommand::LeftButtonReleaseEvent, NULL);
    // NSLog(@"Ended left mouse");
    
    // Display the buffer
    [(GLKView *)self.view display];
}

@end
