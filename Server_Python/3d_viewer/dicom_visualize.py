import os
import numpy
import vtk
import sys
import time

def dicom_visualize(PathDicom):
    # declare dicom image reader and set it to read from appropriate directory
    reader = vtk.vtkDICOMImageReader()
    reader.SetDirectoryName(PathDicom)
    print('reader data\n', reader)
    
    threshold = vtk.vtkImageThreshold ()
    threshold.SetInputConnection(reader.GetOutputPort())
    threshold.ThresholdByLower(100)  # remove all soft tissue
    threshold.ReplaceInOn()
    threshold.SetInValue(0)  # set all values below 400 to 0
    threshold.ReplaceOutOn()
    threshold.SetOutValue(1)  # set all values above 400 to 1
    threshold.Update()

    extract_data = vtk.vtkContourFilter()
    extract_data.SetInputConnection(reader.GetOutputPort())
    extract_data.SetValue(0, 500)
    surface = vtk.vtkPolyDataNormals()
    surface.SetInputConnection(extract_data.GetOutputPort())
    surface.SetFeatureAngle(90.0)
    surfaceMapper = vtk.vtkPolyDataMapper()
    surfaceMapper.SetInputConnection(surface.GetOutputPort())
    surfaceMapper.ScalarVisibilityOff()
    data = vtk.vtkActor()
    data.SetMapper(surfaceMapper)

    aRenderer = vtk.vtkRenderer()
    renWin = vtk.vtkRenderWindow()
    renWin.AddRenderer(aRenderer)
    iren = vtk.vtkRenderWindowInteractor()
    iren.SetRenderWindow(renWin)
    aRenderer.AddActor(data)
    aRenderer.SetBackground(1, 1, 1)
    renWin.SetSize(640, 480)

    iren.Initialize()
    renWin.Render()
    iren.Start()

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Incorrect Usage\npython dicom_visualize.py <DICOM Folder>')
        sys.exit()
    dicom_visualize(sys.argv[1])