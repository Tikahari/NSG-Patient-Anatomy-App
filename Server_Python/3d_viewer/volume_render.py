import os
import numpy
import vtk
import sys
import time

def render_volume(PathDicom):
    # declare dicom image reader and set it to read from appropriate directory
    reader = vtk.vtkDICOMImageReader()
    reader.SetDirectoryName(PathDicom)
    print('reader data\n', reader)
    
    # castFilter
    castFilter = vtk.vtkImageCast()
    castFilter.SetInputConnection(reader.GetOutputPort())
    castFilter.SetOutputScalarTypeToUnsignedShort()
    castFilter.Update()

    imdataBrainSeg = castFilter.GetOutputPort()

    print('image data\n', imdataBrainSeg)
    propVolume = vtk.vtkVolumeProperty()
    propVolume.ShadeOff()
    propVolume.SetInterpolationTypeToLinear()

    volumeMapper = vtk.vtkGPUVolumeRayCastMapper()
    volumeMapper.SetInputConnection(reader.GetOutputPort())

    print('mapper data\n', volumeMapper)
    actorVolume = vtk.vtkVolume()
    actorVolume.SetMapper(volumeMapper)
    print('actor data\n', actorVolume)

    renderer = vtk.vtkRenderer()
    renderer.ResetCamera()

    renderWindow = vtk.vtkRenderWindow()
    renderWindow.AddRenderer(renderer)
    renderWindow.SetSize(800, 800)

    renderWindowInteractor = vtk.vtkRenderWindowInteractor()
    renderWindowInteractor.SetRenderWindow(renderWindow)

    renderer.AddVolume(actorVolume)
    renderer.SetBackground(1, 1, 1)

    renderWindowInteractor.Initialize()
    renderWindow.Render()
    renderWindowInteractor.Start()

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Incorrect Usage\npython volume_render <DICOM Folder>')
        sys.exit()
    render_volume(sys.argv[1])