from multiprocessing import Process, Queue
import os
from .models import Task
import requests
from django.conf import settings
import subprocess
import tarfile
import dicom2nifti
import shutil



def checkForDICOM(directory):
    for fileN in os.listdir(directory):
        filePath = os.path.join(directory, fileN)
        if fileN.endswith(".dcm"):
            return directory
        elif os.path.isdir(filePath):
            temp = checkForDICOM(filePath)
            if temp is not None:
                return temp
    return None

def getNifti(directory):
    for fileN in os.listdir(directory):
        filePath = os.path.join(directory, fileN)
        if fileN.endswith(".nii.gz"):
            return filePath
        elif os.path.isdir(filePath):
            temp = getNifti(filePath)
            if temp is not None:
                return temp
    return None

def getNii(directory):
    for fileN in os.listdir(directory):
        filePath = os.path.join(directory, fileN)
        if fileN.endswith(".nii"):
            return filePath
        elif os.path.isdir(filePath):
            temp = getNii(filePath)
            if temp is not None:
                return temp
    return None


def getTaskToRun():
    qs = Task.objects.filter(isProcessing=False,isGoodData=True).order_by('studyID')
    if qs:
        return qs[0]
    else: 
        return None
    
def sendProcessedData(task):
    payload = {'studyID' : str(task.studyID) }
    headers = { 'Authorization' : 'Token ' + settings.OTHER_SERVER_TOKEN }
    with open(task.processedData, 'rb') as f:
        requests.post(settings.OTHER_SERVER + '/updateStudy',headers=headers, data=payload,files={'fileUpload': f})

def runTask(task):
    patientName = task.patientName
    studyName = task.studyName
    studyID = task.studyID
    saveName = task.unprocessedData
    subject = str(patientName) + '_' + str(studyName) + '_' + str(studyID)
    extractPath = settings.PROCESSED_SAVE_DIR + subject
    outputPath = extractPath + '/output/'
    if not task.recon_started:
        if not os.path.exists(extractPath):
            os.mkdir(extractPath)
        try:
            tar = tarfile.open(saveName,mode='r:xz')
            tar.extractall(path=extractPath)
        except:
            print('Error with dicoms')
            task.isProcessing = False
            task.isGoodData = False
            task.status = 'couldnt extract'
            task.save()
            return
        dicomDIR =  checkForDICOM(extractPath)
        if dicomDIR is None:
            task.status = 'could not find dicoms'
            task.isGoodData = False
            task.isProcessing = False
            task.save()
            return

        print(dicomDIR)
        if not os.path.exists(outputPath):
            os.mkdir(outputPath)
        try:
            dicom2nifti.convert_directory(dicomDIR, outputPath,compression=False, reorient=True)
            print('done dicom')
        except:
            print('Error with dicoms')
            task.isProcessing = False
            task.status = 'Bad dicoms'
            task.isGoodData = False
            task.save()
            return
        niiFile = getNii(outputPath)
        if niiFile is None:
            task.status = 'dicoms could not be converted to nii'
            task.isGoodData = False
            task.isProcessing = False
            task.save()
            return
    

        task.recon_started = True
        task.save()
        f = open(outputPath + 'free_surfer_output.txt', "w+")
        try:
            subprocess.run(["recon-all","-i",niiFile,"-subject", subject, "-all"],stdout=f)
        except:
            print('failed')
            try:
                #free surfer doesn't like it when you try to give new data for the same subject, so we delete the subject file here
                #I didn't really test this yet....
                shutil.rmtree(settings.FREESURFER_SUBJECT_PATH + subject)#
            except:
                print('could not delete freesurfer subject file')
            task.status = 'recon_all failed'
            task.isGoodData = False
            task.isProcessing = False
            task.recon_started = False
            task.save()
            return
    #print('recon-all -i' + ' \'' + getNii(extractPath + '/output') + '\' -subject ' + str(patientName) + '_' + str(studyName) + '_' + str(studyID) + ' -all')
    else:
        #in case of random failure below is active
        runningCheck = settings.FREESURFER_SUBJECT_PATH + subject + '/scripts/IsRunning.lh+rh'
        if os.path.exists(runningCheck):
            os.remove(runningCheck)
        f = open(outputPath + 'free_surfer_output.txt', "w+")
        try:
            print('restarting recon-all')
            #sucks to restart completely. With more time it would be possible to check the log and set up a continuation
            subprocess.run(["recon-all", "-subject", subject, "-all"],stdout=f)
        except:
            print('failed')
            try:
                shutil.rmtree(settings.FREESURFER_SUBJECT_PATH + subject)#same idea as above
            except:
                print('could not delete freesurfer subject file')
            task.status = 'recon_all failed'
            task.isGoodData = False
            task.isProcessing = False
            task.recon_started = False
            task.save()
            return
     #blow code is commented out for debug purposes, should be uncommented in release verison 
    #task.isDone = True
    #task.isProcessing = False
    #task.isAvailable = True
    #task.save()
    #sendProcessedData(task)#update medicalServer with the data


def ManageJobs():
    runningTasks = list()

    while True:
        if len(runningTasks) < settings.THREAD_LIMIT:
            newTask = getTaskToRun()
            if newTask is not None:
                p = Process(target=runTask, args=[newTask])
                p.start()
                runningTasks.append(newTask)
                newTask.isProcessing = True
                newTask.status = 'Started processing'
                newTask.save()
        for task in runningTasks:
            if task.isDone == True:
                runningTasks.remove(task)
