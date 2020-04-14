import os
from django.db import models
from django.conf import settings
from django.contrib.auth.models import User
def studies_path():
    return os.path.join(settings.PROC_DATA_SAVE_DIR, '')#change local file directory to where /studies/ is located




class Study(models.Model):
    pub_date = models.DateTimeField()
    isProcessing = models.BooleanField(default=False)
    available = models.BooleanField(default=False)
    status = models.CharField(max_length=200,default ='Not started')
    name = models.CharField(max_length=200)
    patient = models.CharField(max_length=25)
    data_loc = models.FilePathField(path=studies_path, blank=True)
    docs = models.ManyToManyField(settings.AUTH_USER_MODEL)

    def __str__(self):
        return self.name

class StudyAccess(models.Model):
    user = models.CharField(max_length=200,default='Unknown')
    study = models.ForeignKey(
        'Study',
        on_delete=models.CASCADE,
    )

    time = models.DateTimeField()


