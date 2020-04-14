from django.shortcuts import render

# Create your views here.
import os
import json
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
import datetime
from django.contrib.auth import authenticate, login, get_user_model
from studies.models import Study, StudyAccess
from django.contrib.auth.models import User
from django.core.files.storage import FileSystemStorage
# Create your views here.
from django.http import JsonResponse,HttpResponse
from rest_framework.views import APIView
from django.conf import settings
import requests


@csrf_exempt
def index(request):
    if request.user.is_authenticated:
        if request.method == "POST":
            studyName = request.POST.get('studyName', None)
            patientName = request.POST.get('patientName', None)
            studyID = request.POST.get('studyID', None)
            fileUpload = request.FILES.get('fileUpload', None)
            if studyID is not None and fileUpload is not None:
                qs = Study.objects.filter(studyID=studyID)
                if qs:
                    study = qs[0]
                    saveName = str(patientName) + '_' + str(studyName) + '_' + str(newStudy.id) + '.tar.xz'
                    fs = FileSystemStorage()
                    saveName = fs.save(saveName,fileUpload)
                    payload = { 'studyID' : str(studyID) }
                    headers = { 'Authorization' : 'Token ' + settings.PROCESSING_SERVER_TOKEN }
                    with open(os.path.join(settings.UNPROC_DATA_SAVE_DIR,saveName), 'rb') as f:
                        res = requests.post(settings.PROCESSING_SERVER + 'task',headers=headers, data=payload,files={'fileUpload': f})
                        return HttpResponse(status=res.status_code)
                else:
                    HttpResponse(status=404)

            if studyName is None or patientName is None or fileUpload is None:
                return HttpResponse(status=400)
            newStudy = Study(pub_date = datetime.datetime.now(),
            name = studyName,
            patient = patientName
            )
            newStudy.save()
            saveName = str(patientName) + '_' + str(studyName) + '_' + str(newStudy.id) + '.tar.xz'
            print('1:' + saveName)
            fs = FileSystemStorage()
            saveName = fs.save(saveName,fileUpload)
            print('2:' + saveName)
            ##need to add doctor to the study somehow??
            ##post request to other server now
            payload = {
                'studyName' : str(studyName),
                'studyID' : str(newStudy.id),
                'patientName' : str(patientName)
                 }
            headers = { 'Authorization' : 'Token ' + settings.PROCESSING_SERVER_TOKEN }
            with open(os.path.join(settings.UNPROC_DATA_SAVE_DIR,saveName), 'rb') as f:
                requests.post(settings.PROCESSING_SERVER + '/task',headers=headers, data=payload,files={'fileUpload': f})

            return HttpResponse(status=200)
            


        elif request.method != "GET": #no other requests allowed
            return HttpResponse(status=400)
        
        #below handle Handle GET for /studies and
        
        studyID = request.GET.get('studyID', None) 
        studies = request.user.study_set.all() #gets only the studies the user has accessed to
        if studyID is None:
            #print all studies this user can see
            s = list()
            for study in studies:
                s.append({
                "studyName" : str(study.name),
                "patientName" : str(study.patient),
                "studyID" : str(study.id),
                "studyStatus": str(study.status)
                })
                
                  
            return JsonResponse(s,safe=False)
            
        else: # handle /studies?studyID=num 
            try:
                studyID = int(studyID)#studyID comes in as string for some reason, must cast it.
            except:
                return HttpResponse(status=404)#if it can't cast, invalid query sent so we will return not found
            for study in studies:
                if studyID == study.id:
                    if not study.available:
                        if study.isProcessing:
                            return HttpResponse('Not ready')
                        else:
                            return HttpResponse('No data processing and no study available')

                    my_data =  open(study.data_loc, 'rb')
                    response = HttpResponse(my_data.read(), content_type='application/octet-stream')
                    response['Content-Encoding'] = 'tar'
                    response['Content-Disposition'] = 'attachment; filename="study' + str(study.id) +'.tar.xz"'
                    saveAccess = StudyAccess(study = study, time = datetime.datetime.now(), user = request.user)
                    saveAccess.save()
                    return response

            return HttpResponse(status=404) #not found

    else: 
        return HttpResponse(status=401)

