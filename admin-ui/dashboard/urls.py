from django.urls import path

from . import views

urlpatterns = [
    # Authentication
    path("login/", views.login_view, name="login"),
    path("logout/", views.logout_view, name="logout"),
    # Dashboard
    path("", views.dashboard, name="dashboard"),
    # Users
    path("users/", views.users_list, name="users_list"),
    path("users/create/", views.user_create, name="user_create"),
    path("users/<int:user_id>/edit/", views.user_edit, name="user_edit"),
    path("users/<int:user_id>/delete/", views.user_delete, name="user_delete"),
    # Domains
    path("domains/", views.domains_list, name="domains_list"),
    path("domains/create/", views.domain_create, name="domain_create"),
    path("domains/<int:domain_id>/edit/", views.domain_edit, name="domain_edit"),
    # Settings
    path("settings/", views.settings_list, name="settings_list"),
    path("settings/<str:key>/update/", views.setting_update, name="setting_update"),
    # Health check
    path("health/", views.health_check, name="health_check"),
]
