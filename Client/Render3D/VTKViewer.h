//
//  VTKViewer.h
//  Render3D
//
//  Created by Tikahari Khanal on 4/10/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
  // Forward declarations
  class vtkIOSRenderWindow;
  class vtkIOSRenderWindowInteractor;
  class vtkRenderer;
  // Type declarations
  typedef vtkIOSRenderWindow *vtkIOSRenderWindowRef;
  typedef vtkIOSRenderWindowInteractor *vtkIOSRenderWindowInteractorRef;
    typedef vtkRenderer *vtkRendererRef;
#else
  // Type declarations
  typedef void *vtkIOSRenderWindowRef;
  typedef void *vtkIOSRenderWindowInteractorRef;
    typedef void *vtkRendererRef;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface VTKViewer : GLKViewController{
    @private
    vtkIOSRenderWindowRef _myVTKRenderWindow;
    vtkRendererRef _myRenderer;
}
@property (nonatomic, strong) UIWindow *window;

- (vtkIOSRenderWindowRef)getVTKRenderWindow;
- (void)setVTKRenderWindow:(vtkIOSRenderWindowRef)theVTKRenderWindow;

-(vtkRendererRef)getVTKRenderer;
-(void)setVTKRenderer:(vtkRendererRef) theRenderer;

- (vtkIOSRenderWindowInteractorRef)getInteractor;

- (void)setupPipeline;

- (void)addToRenderer:(NSString*)filename;

@end

NS_ASSUME_NONNULL_END
