from django.urls import path

from .views import TaskView

urlpatterns = [
    path('', TaskView.as_view()),
]