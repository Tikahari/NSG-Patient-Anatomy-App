from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.http import JsonResponse,HttpResponse
from django.core.files.storage import FileSystemStorage
from rest_framework.views import APIView
from .models import Task
from .processStuff import ManageJobs, sendProcessedData
from django.conf import settings
import os
from multiprocessing import Process
from rest_framework.decorators import api_view

running = False
class TaskView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]



    def post(self, request, format=None):
        studyName = request.POST.get('studyName', None)
        studyID = request.POST.get('studyID', None)
        patientName = request.POST.get('patientName', None)
        fileUpload = request.FILES.get('fileUpload', None)
        if studyID is not None and fileUpload is not None and (studyName is None or patientName is None):
            qs = Task.objects.filter(studyID=studyID)
            if qs:
                task = qs[0]
                if task.isProcessing:
                    return HttpResponse(status=400) # can't interrupt processing?
                else:
                    saveName = str(task.patientName) + '_' + str(task.studyName) + '_' + str(task.studyID) + '.tar.xz'
                    fs = FileSystemStorage(location=settings.UNPROCESSED_DATA_DIR)
                    saveName = fs.save(saveName,fileUpload)
                    task.unprocessedData = os.path.join(settings.UNPROCESSED_DATA_DIR, saveName)
                    task.save()
                    return HttpResponse(status=200)
            return HttpResponse(status=400)
        elif studyName is None or patientName is None or fileUpload is None:
            return HttpResponse(status=400)

        saveName = str(patientName) + '_' + str(studyName) + '_' + str(studyID) + '.tar.xz'
        fs = FileSystemStorage(location=settings.UNPROCESSED_DATA_DIR)
        saveName = fs.save(saveName,fileUpload)

        newTask = Task(
            studyName = studyName,
            patientName = patientName,
            studyID = studyID,
            unprocessedData = os.path.join(settings.UNPROCESSED_DATA_DIR, saveName)
            )
        newTask.save()
        return HttpResponse(status=200)


    def get(self, request, format=None):
        studyID = request.GET.get('studyID',None)
        startProc = request.GET.get('startProc',None)
        if startProc is not None:
            if running == False:
                p = Process(target=ManageJobs, args=())
                p.start()
                p.join()
                running = True
                return HttpResponse(status=200)
            return HttpResponse(status=400)

        if studyID is not None:
            qs = Task.objects.filter(studyID=studyID)
            if qs:
                task = qs[0]
                if not task.isGoodData:
                    return HttpResponse(status=406) 
                elif not task.isAvailable:
                    if task.isProcessing:
                        return HttpResponse(status=202) #not ready, but processing
                    return HttpResponse(status=403)# not processing
                else:
                    sendProcessedData(task)
                    return HttpResponse(status=200) ## TO DO serve html file

            return HttpResponse(status=404)
        return HttpResponse(status=400)


                

                        