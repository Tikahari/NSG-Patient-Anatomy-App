import os
import numpy
import vtk
import sys
import time

def ply_writer(PathDicom):
    print('path', PathDicom)
    # declare dicom image reader and set it to read from appropriate directory
    reader = vtk.vtkDICOMImageReader()
    reader.SetDirectoryName(PathDicom)
    print('reader data\n', reader)
    reader.Update()

    dmc = vtk.vtkDiscreteMarchingCubes()
    dmc.SetInputConnection(reader.GetOutputPort())
    dmc.GenerateValues(1, 1, 1)
    dmc.Update()

    mapper = vtk.vtkPolyDataMapper()
    mapper.SetInputConnection(dmc.GetOutputPort())

    #write data to ply
    plywrite = vtk.vtkPLYWriter()
    plywrite.SetFileName("a.ply")
    plywrite.SetInputConnection(dmc.GetOutputPort())
    plywrite.Write()

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Incorrect Usage\npython volume_render <DICOM Folder>')
        sys.exit()
    ply_writer(sys.argv[1])