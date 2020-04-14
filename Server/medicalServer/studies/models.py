import os
from django.db import models
from django.conf import settings
from django.contrib.auth.models import User
def studies_path():
    return os.path.join(settings.LOCAL_FILE_DIR, 'studies')#change local file directory to where /studies/ is located
    




class Study(models.Model):
    pub_date = models.DateField()
    isProcessing = models.BooleanField(default=False)
    name = models.CharField(max_length=200)
    patient = models.CharField(max_length=25)
    data_loc = models.FilePathField(path=studies_path)
    docs = models.ManyToManyField(settings.AUTH_USER_MODEL)
    _id = models.CharField(max_length=200)

    def __str__(self):
        return self.name

class StudyAccess(models.Model):
    user = models.CharField(max_length=200,default='Unknown')
    study = models.ForeignKey(
        'Study',
        on_delete=models.CASCADE,
    )

    time = models.DateTimeField()


