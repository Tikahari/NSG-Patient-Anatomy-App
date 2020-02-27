from vtkplotter import *
import sys

vol1 = load(sys.argv[1]) #vtkVolume
vol1.alpha([0,0,0.05,0.1,.3,.6,.9])  # opacity transfer func on the scalar range
vol1.color(['blue','b', (1,0,1)])

vol2 = load(sys.argv[2]) #vtkVolume
vol2.alpha([0,0,0.05,0.1,.3,.6,.9])  # opacity transfer func on the scalar range
vol2.color(['green','g', (1,0,1)])

vol3 = load(sys.argv[3]) #vtkVolume
vol3.alpha([0,0,0.002,0.005,.008,.009,.01])  # opacity transfer func on the scalar range
vol3.color(['red','r', (1,0,1)])

show(vol1, vol2, vol3, axes = 5, interactorStyle=2)

