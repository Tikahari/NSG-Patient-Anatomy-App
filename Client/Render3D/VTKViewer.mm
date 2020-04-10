//
//  VTKViewer.m
//  Render3D
//
//  Created by Harihar Khanal on 4/10/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

#import "VTKViewer.h"
#include <vtkActor.h>
#include <vtkNIFTIImageReader.h>
#include <vtkSmartVolumeMapper.h>
#include <vtkColorTransferFunction.h>
#include <vtkPiecewiseFunction.h>
#include <vtkRenderer.h>
#include <vtkRenderWindow.h>
#include <vtkRenderWindowInteractor.h>
#include <vtkVolumeProperty.h>

@interface VTKViewer ()

@end

@implementation VTKViewer

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
