
import os
from django.db import models
from django.conf import settings
def processed_path():
    return os.path.join(settings.PROCESSED_SAVE_DIR, '')#change local file directory to where /studies/ is located
def unprocessed_path():
    return os.path.join(settings.UNPROCESSED_DATA_DIR, '')#change local file directory to where /studies/ is located
    






class Task(models.Model):
    studyName = models.CharField(max_length=200)
    patientName = models.CharField(max_length=200)
    isDone = models.BooleanField(default=False)
    isProcessing = models.BooleanField(default=False)
    isAvailable = models.BooleanField(default=False)
    recon_started = models.BooleanField(default=False)
    isGoodData = models.BooleanField(default=True)
    status = models.CharField(max_length=200,default ='Not started')
    unprocessedData = models.FilePathField(path=unprocessed_path,blank=True)
    processedData = models.FilePathField(path=processed_path,blank=True)
    studyID = models.IntegerField()
