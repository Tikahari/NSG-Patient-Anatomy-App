from vtkplotter import load
import sys

vol = load(sys.argv[1]) #vtkVolume
vol.isosurface().show()
# or convert to vtk format:
vol.write('newfile.vti')