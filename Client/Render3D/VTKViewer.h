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

  // Type declarations
  typedef vtkIOSRenderWindow *vtkIOSRenderWindowRef;
  typedef vtkIOSRenderWindowInteractor *vtkIOSRenderWindowInteractorRef;
#else
  // Type declarations
  typedef void *vtkIOSRenderWindowRef;
  typedef void *vtkIOSRenderWindowInteractorRef;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface VTKViewer : GLKViewController{
    @private
    vtkIOSRenderWindowRef _myVTKRenderWindow;
}

@property (nonatomic, strong) UIWindow *window;

- (vtkIOSRenderWindowRef)getVTKRenderWindow;
- (void)setVTKRenderWindow:(vtkIOSRenderWindowRef)theVTKRenderWindow;

- (vtkIOSRenderWindowInteractorRef)getInteractor;

- (void)setupPipeline;

@end

NS_ASSUME_NONNULL_END
