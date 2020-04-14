from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.http import JsonResponse,HttpResponse
from django.core.files.storage import FileSystemStorage
from rest_framework.views import APIView
from studies.models import Study
from django.conf import settings
import requests
import os

class UpdateStudy(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request, format=None):
        studyID = request.POST.get('studyID', None)
        dataFile = request.FILES.get('fileUpload',None)
        
        if studyID is not None and dataFile is not None:
            qs = Study.objects.filter(id=studyID)
            if qs:
                study = qs[0]
                saveName = 'result_' + str(study.patientName) + '_' + str(study.studyName) + '_' + str(study.studyID) + '.tar.xz'
                fs = FileSystemStorage(location=settings.PROC_DATA_SAVE_DIR)
                saveName = fs.save(saveName,dataFile)
                study.save_loc = os.path.join(settings.PROC_DATA_SAVE_DIR,saveName)
                study.save()
                return HttpResponse(status=200)
        
        return HttpResponse(status=400)


    def get(self, request, format=None):
        studyID = request.GET.get('studyID',None)
        qs = Study.objects.filter(id=studyID)
        if qs:
            study = qs[0]
            headers = { 'Authorization' : 'Token ' + settings.PROCESSING_SERVER_TOKEN }
            res = requests.get(settings.PROCESSING_SERVER + '/task?studyID=' + str(study.id),headers=headers)
            if res.status_code == 200:
                return HttpResponse(status=200)# file server
            elif res.status_code == 406:
                study.status='Bad data, please re-submit following the proper guidelines'
                study.save()
                return HttpResponse(status=406)
            elif res.status_code == 403:
                study.status='Study has been submitted but has not start processing'
                study.save()
                return HttpResponse(status=403)
            elif res.status_code == 202:
                study.status='Study is  processing'
                study.save()
                return HttpResponse(status=202)
            elif res.status_code == 404:
                study.status='Study has never been submitted'
                study.save()
                return HttpResponse(status=404)

        return HttpResponse(status=400)

        

