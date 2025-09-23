"""koemail_admin URL Configuration"""

from django.contrib import admin
from django.urls import path, include
from django.views.generic import RedirectView

urlpatterns = [
    path('', include('dashboard.urls')),
    path('admin/', admin.site.urls),
]