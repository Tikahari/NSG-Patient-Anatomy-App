import nibabel as nib
import numpy as np
import sys
from vtkplotter import *

img = nib.load(sys.argv[1])
print(img.header)
# get raw pixel data
raw = img.get_fdata()
# convert to 3d array
shaped = np.squeeze(raw, axis=3)
print(shaped.shape)
# Volume(shaped).show(bg="black")

# threshold
threshold = 182
shaped[shaped > 145] = 0
shaped[(shaped <= 145) & (shaped >= 120)] = 128
shaped[shaped < 120] = 0
# shaped[(shaped < 55) & (shaped > 20)] = 100
# Volume(shaped).show(bg="black")
# save = input("Save \(y/n\)\n")
# if save == 'y':
# name = input("Name\n")
img2 = nib.Nifti1Image(shaped, np.eye(4))
nib.save(img2, "f.nii")
