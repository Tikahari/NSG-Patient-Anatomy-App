from django.urls import path

from .views import UpdateStudy

urlpatterns = [
    path('', UpdateStudy.as_view()),
]