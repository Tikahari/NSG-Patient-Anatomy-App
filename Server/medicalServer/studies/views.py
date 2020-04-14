from django.shortcuts import render

# Create your views here.
import json
from django.shortcuts import render
import datetime
from django.contrib.auth import authenticate, login, get_user_model
from studies.models import Study, StudyAccess
from django.contrib.auth.models import User
# Create your views here.
from django.http import JsonResponse,HttpResponse


def index(request):
    if request.user.is_authenticated:
        studyID = request.GET.get('studyID', None)
        studies = request.user.study_set.all()
        print(request.user)
        if studyID is None:
            #print all studies this user can see
            s = list()
            i = 0
            for study in studies:
                #s = {"studyName" : "' + str(study.name) + '", "patientName" : "' + str(study.patient) + '", "studyID" : " + str(study._id) + " }
                s.append({
                    "studyName" : str(study.name),
                    "patientName" : str(study.patient),
                    "studyID" : str(study._id)
                })
                i = i + 1
                  
            return JsonResponse(s,safe=False)
            
        else:
            for study in studies:
                if studyID == study._id:
                     my_data =  open(study.data_loc, 'rb')
                     response = HttpResponse(my_data.read(), content_type='application/octet-stream')
                     response['Content-Encoding'] = 'tar'
                     response['Content-Disposition'] = 'attachment; filename="study' + str(study._id) +'.tar.xz"'
                     saveAccess = StudyAccess(study = study, time = datetime.datetime.now(), user = request.user)
                     saveAccess.save()
                     return response

            return HttpResponse(status=404)

    else: 
        return HttpResponse(status=401)

{"StudyName": "" ,
 "PatientName" : "",
 "StudyID" : ""}