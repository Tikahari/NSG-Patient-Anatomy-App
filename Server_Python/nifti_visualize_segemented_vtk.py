import vtk
import sys

m_reader = vtk.vtkNIFTIImageReader()
m_reader.SetFileName(sys.argv[1])
m_reader.Update()
print('reader info', m_reader)

view = vtk.vtkImageViewer2()
view.SetInputConnection(m_reader.GetOutputPort())
view.Render()
# _extent = m_reader.GetDataExtent()
# ConstPixelDims = [_extent[1]-_extent[0]+1, _extent[3]-_extent[2]+1, _extent[5]-_extent[4]+1]
# ConstPixelSpacing = m_reader.GetPixelSpacing()

threshold = vtk.vtkImageThreshold ()
threshold.SetInputConnection(m_reader.GetOutputPort())
threshold.ThresholdByLower(1)  # remove all soft tissue
threshold.ReplaceInOn()
threshold.SetInValue(0)  # set all values below 400 to 0
threshold.ReplaceOutOn()
threshold.SetOutValue(1)  # set all values above 400 to 1
threshold.Update()

dmc = vtk.vtkDiscreteMarchingCubes()
dmc.SetInputConnection(threshold.GetOutputPort())
dmc.GenerateValues(1, 1, 1)
dmc.Update()

mapper = vtk.vtkPolyDataMapper()
mapper.SetInputConnection(dmc.GetOutputPort())

writer = vtk.vtkSTLWriter()
writer.SetInputConnection(dmc.GetOutputPort())
writer.SetFileTypeToBinary()
writer.SetFileName(sys.argv[2])
writer.Write()