"""
WSGI config for processingServer project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/3.0/howto/deployment/wsgi/
"""

import os
from multiprocessing import Process
from django.core.wsgi import get_wsgi_application
from task.models import Task
from task.processStuff import ManageJobs


qs = Task.objects.all()
qs.update(isProcessing=False)#server shut down so nothing is running
p = Process(target=ManageJobs, args=())
p.start()


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'processingServer.settings')

application = get_wsgi_application()
