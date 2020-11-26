import numpy as np
import nibabel as nib
import open3d as o3d
import matplotlib.pyplot as plt

from mpl_toolkits.mplot3d.art3d import Poly3DCollection 
from skimage import measure
from skimage.draw import ellipsoid



# # Generate a level set about zero of two identical ellipsoids in 3D
# ellip_base = ellipsoid(6, 10, 16, levelset=True)
# ellip_double = np.concatenate((ellip_base[:-1, ...],
#                                ellip_base[2:, ...]), axis=0)

# # Use marching cubes to obtain the surface mesh of these ellipsoids
# verts, faces, normals, values = measure.marching_cubes_lewiner(ellip_double, 0)


# Use marching cubes to obtain the surface mesh of scan
img = nib.load("/Users/daniel/Desktop/NSG/results/example.nii.gz")

point_cloud= np.loadtxt("/Users/daniel/Desktop/NSG/results/pc_sample/sample.xyz",skiprows=1)
print(point_cloud)
pcd = o3d.geometry.PointCloud()
print(pcd)
pcd.points = o3d.utility.Vector3dVector(point_cloud[:,:3])
print(pcd.points)
pcd.colors = o3d.utility.Vector3dVector(point_cloud[:,3:6]/255)
o3d.visualization.draw_geometries([pcd])


np_img = np.array(img.dataobj).astype(np.float64)

# verts, faces, normals, val = measure.marching_cubes(np_img)
# print("faces:")
# print(faces)
# print("Verts[Faces]:")
# print(verts[faces])
# # Display resulting triangular mesh using Matplotlib. This can also be done
# # with mayavi (see skimage.measure.marching_cubes_lewiner docstring).
# fig = plt.figure(figsize=(10, 10))
# ax = fig.add_subplot(111, projection='3d')

# # Fancy indexing: `verts[faces]` to generate a collection of triangles
# mesh = Poly3DCollection(verts[faces])
# mesh.set_edgecolor('k')
# ax.add_collection3d(mesh)

# ax.set_xlabel("x-axis: a = 6 per ellipsoid")
# ax.set_ylabel("y-axis: b = 10")
# ax.set_zlabel("z-axis: c = 16")

# ax.set_xlim(0, 300)  # a = 6 (times two for 2nd ellipsoid)
# ax.set_ylim(0, 300)  # b = 10
# ax.set_zlim(0, 300)  # c = 16

# plt.tight_layout()
# plt.show()