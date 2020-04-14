import os
import numpy as np
import nibabel as nib

def loop_access(n,m,data,tpl):
    if n >m:
        return loop_access(n,m+1,data[tpl[m]],tpl)
    else:
        return data[tpl[m]]

def loop_rec(n,m,mapCoords,dims,data,tple):
    if n >= m:
        for x in range(dims[m]):
            loop_rec(n,m+1,mapCoords,dims,data,(tple+(x,)))
    else:
        temp = loop_access(len(dims)-1,0,data,tple)#recurse to find array element
        print(temp)
        if temp in mapCoords:
            mapCoords[temp].append(tple)# add coord to list
        else:
            mapCoords[temp] = list() #make list, it doesn't exiss:

def transform(dataFile,save_path):
    img = nib.load(dataFile)
    data = img.get_fdata()
    hdr = img.header
    mapCoords = dict()# hashmap to contain lists of 3-tuples

    #use specially design loop_rec function to go through data, Im not sure of another way
    # to set up something that could possible variable n array
    #first arguement is the number elements in data.shape() - 1, start at m=0 for second arg,
    #mapcoords is passed to store the values to, dims in the shape of the data, data is passed
    # () is an empty tuple, this is added to during each recursion 
    dims = data.shape()
    loop_rec(len(dims)-1,0,mapCoords,dims,data,()) 

    for key in mapCoords:
        tList = mapCoords[key]
        tData = np.zeros(dims)#generate zeros
        s = str(key) + '_label.nii.gz'
        save_loc = os.path.join(save_path,s)
        for coord in tList:
            tData[coord[0],coord[1],coord[2]] = key #fix the coords to the correct value for this 'label'
        tImg = nib.Nifti1Image(tData,None,hdr)
        nib.save(tImg,save_loc)
    
