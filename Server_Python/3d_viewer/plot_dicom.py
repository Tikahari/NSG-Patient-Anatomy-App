import time
import glob
import pydicom
import numpy as np
from vtkplotter import Volume
import sys, os

def main(folderPath):
    st = time.time()
    my_glob = glob.glob1(folderPath, "*")
    numFiles = 0
    rejected = 0

    # return if empty directory
    if len(my_glob) == 0:
        return False

    # get all readable dicom files in  array
    tem = []
    for file in list(my_glob):
        try:
            data_item = pydicom.dcmread(os.path.join(folderPath, file))
            if hasattr(data_item, 'SliceLocation'):
                tem.append(data_item)
                numFiles += 1
            else:
                rejected += 1
                print(file)
        except Exception as e:
            pass
    print("read done %s | %d files | %d rejected" % (time.time() - st, numFiles, rejected))
    if len(tem) <= 0:
        return False

    tem.sort(key=lambda x: x.InstanceNumber)

    # make 3d np array from all slices
    unset = True
    print('number of items: ', len(tem))
    for i in range(len(tem)):
        arr = tem[i].pixel_array.astype(np.float32)
        # print('item', i,'pixel array is',tem[i].pixel_array)
        # print('unset', unset)

        if unset:
        #     print('\nunset\n\n', tem[i])
            imShape = (arr.shape[0], arr.shape[1], len(tem))
            print('\nimShape\n\n', imShape)
            scaledIm = np.zeros(imShape)
            pix_spacing = tem[i].PixelSpacing
        #     dist = 0
        #     for j in range(2):
        #         cs = [float(q) for q in tem[j].ImageOrientationPatient]
        #         ipp = [float(q) for q in tem[j].ImagePositionPatient]
        #         parity = pow(-1, j)
        #         dist += parity*(cs[1]*cs[5] - cs[2]*cs[4])*ipp[0]
        #         dist += parity*(cs[2]*cs[3] - cs[0]*cs[5])*ipp[1]
        #         dist += parity*(cs[0]*cs[4] - cs[1]*cs[3])*ipp[2]
        #     z_spacing = abs(dist)
            slope = tem[i].RescaleSlope
            intercept = tem[i].RescaleIntercept
            unset = False
        scaledIm[:, :, i] = arr
    # print('scaledIm\n', scaledIm)
    # print('num entries', len(scaledIm[0][0]), len(scaledIm[0][1]), len(scaledIm[1][0]))

    # convert to hounsfield units
    scaledIm = slope*scaledIm + intercept
    z_spacing =1
    print('z_spacing',z_spacing)
    pix_spacing.append(z_spacing)
    print(tem[0].pixel_array)
    threshold = 200

    windowed = np.zeros(imShape, dtype=np.uint8)
    # set color as a function of distance
    # k = np.logical_and(scaledIm > (wl-0.5-(ww-1)/2.0), scaledIm <= (wl-0.5+(ww-1)/2.0))
    # print('k is', k)
    # windowed[k] = ((scaledIm[k] - (wl-0.5))/(ww-1)+0.5)*255
    # print('window at k is', ((scaledIm[k] - (wl-0.5))/(ww-1)+0.5)*255)

    # threshold
    windowed[scaledIm > threshold] = 255

    # windowed image (in 2D) is correct i checked visually in other DICOM viewers
    print("arrays made %s" % (time.time() - st))


    # Volume(scaledIm, spacing=pix_spacing).show(bg="black")
    Volume(windowed, spacing=pix_spacing).show(bg="black")

    X, Y, Z = np.mgrid[:30, :30, :30]
    scalar_field = ((X-15)**2 + (Y-15)**2 + (Z-15)**2)/225
    Volume(scalar_field, spacing=pix_spacing).show(bg="black")      # looks good on this example


if __name__ == '__main__':
    folder = sys.argv[1]
    main(folder)