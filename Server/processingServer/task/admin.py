from django.contrib import admin
from rest_framework.authtoken.models import Token
from .models import Task
admin.site.register(Task)
# Register your models here.
