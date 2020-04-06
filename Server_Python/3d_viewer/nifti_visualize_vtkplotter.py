from vtkplotter import *
import sys

# vol1 = load(sys.argv[1]) #vtkVolume
# vol1.alpha([0,0,1,1,1,1,1])  # opacity transfer func on the scalar range
# vol1.color(['red','r', (1,0,1)])

# vol2 = load(sys.argv[2]) #vtkVolume
# vol2.alpha([0,0,0.0005,0.001,.003,.006,.009])  # opacity transfer func on the scalar range
# vol2.color(['green','g', (1,0,1)])

# vol3 = load(sys.argv[3]) #vtkVolume
# vol3.alpha([0,0,0.02,0.005,.008,.009,.08])  # opacity transfer func on the scalar range
# vol3.color(['yellow','y', (1,0,1)])

# vol4 = load(sys.argv[4]) #vtkVolume
# vol4.alpha([0,0,0.02,0.05,.08,.009,.01])  # opacity transfer func on the sca$
# vol4.color(['black','bb', (1,0,1)])

vol1 = load(sys.argv[1]) #vtkVolume
vol1.alpha([0,0,1,1,1,1,1])  # opacity transfer func on the scalar range
vol1.color(['red','r', (1,0,1)])

vol2 = load(sys.argv[2]) #vtkVolume
vol2.alpha([0,0,0.0005,0.001,.003,.006,.009])  # opacity transfer func on the scalar range
vol2.color(['green','g', (1,0,1)])

vol3 = load(sys.argv[3]) #vtkVolume
vol3.alpha([0,0,0.002,0.005,.008,.0009,.0008])  # opacity transfer func on the scalar range
vol3.color(['yellow','y', (1,0,1)])

vol4 = load(sys.argv[4]) #vtkVolume
vol4.alpha([0,0,0.0002,0.00005,.00008,.000009,.00001])  # opacity transfer func on the sca$
vol4.color(['black','bb', (1,0,1)])

# show(vol1, vol2, vol3, axes = 5, interactorStyle=2)
show(vol1, vol2, vol3, vol4)
#show(vol1)
0
