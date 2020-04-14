import os
import numpy as np
import nibabel as nib

data_path = '/home/michael/freesurfer/subjects/test2/mri/'#change for path
ourfile = os.path.join(data_path, 'aseg.nii')
img = nib.load(ourfile)


data = img.get_fdata()
hdr = img.header
mapCoords = dict()# hashmap to contain lists of 3-tuples
#data is 3d array, probably should add checks to ensure that is the case
# this aseg is (255,255,255), but should change to get the range from the array

for x in range(0,256):
    for y in range(0,256):
        for z in range(0,256):
            temp = data[x,y,z]
            if temp != 0:
                if temp in mapCoords:
                    mapCoords[temp].append((x,y,z))# add coord to list
                else:
                    mapCoords[temp] = list() #make list, it doesn't exist

for key in mapCoords:
    tList = mapCoords[key]
    tData = np.zeros((255,255,255))#generate zeros
    s = str(key) + '_label.nii.gz'
    save_loc = '/home/michael/results/test2/'#change for save location
    save_path = os.path.join(save_loc,s)
    for coord in tList:
        tData[coord[0],coord[1],coord[2]] = key #fix the coords to the correct value for this 'label'
    tImg = nib.Nifti1Image(tData,None,hdr)
    nib.save(tImg,save_path)
    
