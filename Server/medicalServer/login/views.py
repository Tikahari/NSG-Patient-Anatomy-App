# userauth/views.py

import json
                             
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import login, logout
from django.contrib.auth import authenticate
from django.conf import settings
from studies.models import Study

import numpy as np
import nibabel as nib
import skimage.measure as measure
import os
import json
                             
from rest_framework import status
                             
from . import serializers
from . import models


def test_path():
    return os.path.join(settings.LOCAL_FILE_DIR, 'example.nii.gz') #change local file directory to where /studies/ is located

                             
                             
@csrf_exempt
def auth_login(request):
    """Client attempts to login
                             
     - Check for username and password
     - Return serialized user data
    """
    print(request.POST)
    username = request.POST.get('username',None)
    password = request.POST.get('password', None)
    user = authenticate(username=username, password=password)
                             
    if user:
        login(request,user)
        #serializer = serializers.UserSerializer(user)
        # ????? 
        # studies = request.user.study_set.all() #gets only the studies the user has accessed to:
        #print all studies this user can see
        # s = list()
        # for study in studies:
        #     #s = {"studyName" : "' + str(study.name) + '", "patientName" : "' + str(study.patient) + '", "studyID" : " + str(study._id) + " }
        #     s.append({
        #         "patientName" : str(study.patient),
        #         "studyID" : str(study.id),
        #         "studyStatus": str(study.status)
        #         })
                  
        # print(s)
        # Open the nifti file
        img = nib.load(test_path())
        np_img = np.array(img.dataobj).astype(np.float64)
        vertices, faces, normals, val = measure.marching_cubes(np_img)
        s = ()
        s = {
            # "data": data.tolist(),
            # "data_shape": np.array(data_shape).tolist(),
            "size": len(vertices),
            "vertices": vertices.tolist(),
            "faces": faces.tolist(),
            "normals": normals.tolist(),
            "val": val.tolist()
        }
        # For testing purposes, An array containing 2 of the same example scan are being sent back on login. This should be changed to have the login return a number of scans, and on scan selection the data for that particular scan should be passed back.
        scans = list()
        scans.append(s)
        # scans.append(s)
        response = ()
        response = {
            "scans": scans
        }

        # Send it back
        print("Vertices sent in reponse to login.")
        return JsonResponse(response,safe=False)
    return HttpResponse(status=401)

def auth_logout(request):
    """Clears the session """
    logout(request)
    return HttpResponse(status=200)