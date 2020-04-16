//
//  VTKViewer.m
//  Render3D
//
//  Created by Tikahari Khanal on 4/10/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

#import "VTKViewer.h"
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
#include <unordered_map>
#include <tuple>
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <deque>
#include <vector>
/* 2 or 3 -- needs to match VTK version */
#define GL_ES_VERSION 3

vtkSmartPointer<vtkPiecewiseFunction> pwf = vtkSmartPointer<vtkPiecewiseFunction>::New();

@interface VTKViewer (){
    NSString* titleText;
}
@property (strong, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UITextField *segmentNumber;

@property (strong, nonatomic) NSString* LUTPATH;


@property (strong, nonatomic) EAGLContext *context;
- (void)tearDownGL;
@end

@implementation VTKViewer

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
- (IBAction)setOpacitySlider:(id)sender {
    if([self.segmentNumber.text isEqual:@""]){
        NSLog(@"empty segment");
        return;
    }
    float myseg = [self.segmentNumber.text floatValue];
    NSLog(@"segment number is %d", myseg);
    NSLog(@"Get segment");
    NSLog(@"opacity value %d", self.slider.value);
    pwf->RemoveAllPoints();
    pwf->AddPoint(0, 0);
    pwf->AddPoint(1,.02);
    pwf->AddPoint(myseg-1,0,0.9999,0);
    pwf->AddPoint(myseg, self.slider.value,0,1);
    pwf->AddPoint(myseg+1,0.02,0,0);
    [self.segmentNumber resignFirstResponder];
}

- (IBAction)reset:(id)sender {
    NSLog(@"Reset volume");
    // whole volume visible
    pwf->RemoveAllPoints();
    pwf->AddPoint(0,0);
    pwf->AddPoint(1,0.5,0,1);
    pwf->AddPoint(999999,0.5);
    self.segmentNumber.text = nil;
    [self.segmentNumber resignFirstResponder];
}

- (IBAction)showRegion1:(id)sender {
    if([self.segmentNumber.text isEqual:@""]){
        NSLog(@"empty segment");
        return;
    }
    float myseg = [self.segmentNumber.text floatValue];
    NSLog(@"segment number is %d", myseg);
    NSLog(@"Get segment");
    pwf->RemoveAllPoints();
    pwf->AddPoint(0, 0);
    pwf->AddPoint(1,.02);
    pwf->AddPoint(myseg-1,0,0.9999,0);
    pwf->AddPoint(myseg, 0.2,0,1);
    pwf->AddPoint(myseg+1,0.02,0,0);
    [self.segmentNumber resignFirstResponder];
}


- (std::unordered_map<std::string, std::tuple<int,int,int,int>>)processLUT{
    NSString *lutP = [[NSBundle mainBundle] pathForResource:@"FreeSurferColorLUT" ofType:@"txt"];
    std::string lut([lutP UTF8String]);
    std::ifstream file(lut);
    std::string str;
    std::unordered_map<std::string, std::tuple<int,int,int,int>> colorMap;
    while (std::getline(file, str)) {
        int label, red, green, blue;
        std::string name;
        std::stringstream ss(str);
        ss >> label >> name >> red >> green >> blue;
        colorMap.emplace(name,std::make_tuple(label,red,green,blue) );
    }
    return colorMap;
}


- (void)addToRenderer {
    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"aparc.DKTatlas+aseg" ofType:@"nii"];
    NSLog(@"file path %@", filepath);
    
    // from path
    std::string fname([filepath UTF8String]);
    vtkNew<vtkNIFTIImageReader> mi;
    // read from file
    mi->SetFileName(fname.c_str());
    mi->Update();
    double range[2];
    mi->GetOutput()->GetPointData()->GetScalars()->GetRange(range);
    
    vtkNew<vtkOpenGLGPUVolumeRayCastMapper> volumeMapper;
    volumeMapper->SetInputConnection(mi->GetOutputPort());
    volumeMapper->SetAutoAdjustSampleDistances(1);
    volumeMapper->SetSampleDistance(0.5);
    
    vtkNew<vtkVolumeProperty> volumeProperty;
    volumeProperty->SetShade(1);
    volumeProperty->SetInterpolationTypeToLinear();
    
    vtkSmartPointer<vtkColorTransferFunction> ctf = vtkSmartPointer<vtkColorTransferFunction>::New();
//    vtkSmartPointer<vtkPiecewiseFunction> pwf = vtkSmartPointer<vtkPiecewiseFunction>::New();
    // whole volume visible
    pwf->AddPoint(0,0);
    pwf->AddPoint(1,0.5,0,1);
    pwf->AddPoint(999999,0.5);
    ctf->SetColorSpaceToRGB();
    // assign colors
    std::unordered_map<std::string, std::tuple<int,int,int,int>> colorMap = [self processLUT];
    for (std::pair<std::string,std::tuple<int,int,int,int>> element : colorMap)
    {
        std::tuple<int,int,int,int> color = element.second;
        if(std::get<0>(color) < 16000)
        {
            if(std::get<0>(color) == 2 || std::get<0>(color) == 41)
                continue;
            std::cout << element.first << "\t" << std::get<0>(color) << "\t" << std::get<1>(color) << "\t" << std::get<2>(color) << "\t" << std::get<3>(color) << "\t" << endl;
            ctf->AddRGBPoint(std::get<0>(color),std::get<1>(color)/255.0,std::get<2>(color)/255.0,std::get<3>(color)/255.0);
        }
    }
    
    volumeProperty->SetColor(ctf.GetPointer());
    volumeProperty->SetScalarOpacity(pwf.GetPointer());
    //  set volume
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
    
    //set color map
    std::unordered_map<std::string, std::tuple<int,int,int,int>> colorMap = [self processLUT];
    [self addToRenderer];
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

- (BOOL)textFieldShouldReturn:(UITextField *)text{
    [text resignFirstResponder];
    return YES;
}

@end
