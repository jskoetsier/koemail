import json

import bcrypt
from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator
from django.db.models import Count, Sum
from django.http import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt

from .models import Alias, Domain, QuotaUsage, SystemSetting, User


# Authentication views
def login_view(request):
    if request.method == "POST":
        email = request.POST.get("email")
        password = request.POST.get("password")

        try:
            user = User.objects.get(email=email, active=True, admin=True)
            if bcrypt.checkpw(password.encode("utf-8"), user.password.encode("utf-8")):
                # Store user info in session
                request.session["user_id"] = user.id
                request.session["user_email"] = user.email
                request.session["user_name"] = user.name
                request.session["is_admin"] = user.admin

                # Update last login
                user.last_login = timezone.now()
                user.save()

                messages.success(request, "Login successful!")
                return redirect("dashboard")
            else:
                messages.error(request, "Invalid email or password.")
        except User.DoesNotExist:
            messages.error(request, "Invalid email or password.")

    return render(request, "dashboard/login.html")


def logout_view(request):
    request.session.flush()
    messages.success(request, "You have been logged out.")
    return redirect("login")


def require_admin(view_func):
    """Decorator to require admin login"""

    def wrapper(request, *args, **kwargs):
        if not request.session.get("user_id") or not request.session.get("is_admin"):
            return redirect("login")
        return view_func(request, *args, **kwargs)

    return wrapper


# Dashboard views
@require_admin
def dashboard(request):
    # Get statistics
    stats = {
        "users": User.objects.filter(active=True).count(),
        "domains": Domain.objects.filter(active=True).count(),
        "aliases": Alias.objects.filter(active=True).count(),
        "storage": QuotaUsage.objects.aggregate(total=Sum("bytes_used"))["total"] or 0,
    }

    # Get recent users
    recent_users = User.objects.order_by("-created_at")[:5]

    context = {
        "stats": stats,
        "recent_users": recent_users,
        "user_name": request.session.get("user_name", "Administrator"),
    }
    return render(request, "dashboard/dashboard.html", context)


@require_admin
def users_list(request):
    users = (
        User.objects.select_related("domain")
        .prefetch_related("quotausage")
        .order_by("-created_at")
    )

    # Search functionality
    search = request.GET.get("search")
    if search:
        users = users.filter(email__icontains=search)

    # Pagination
    paginator = Paginator(users, 25)
    page_number = request.GET.get("page")
    page_obj = paginator.get_page(page_number)

    context = {
        "page_obj": page_obj,
        "search": search,
    }
    return render(request, "dashboard/users_list.html", context)


@require_admin
def user_create(request):
    if request.method == "POST":
        try:
            email = request.POST.get("email")
            password = request.POST.get("password")
            name = request.POST.get("name")
            domain_id = request.POST.get("domain_id")
            quota = (
                int(request.POST.get("quota", 1)) * 1024 * 1024 * 1024
            )  # Convert GB to bytes
            admin = request.POST.get("admin") == "on"
            active = request.POST.get("active") == "on"

            # Hash password
            hashed_password = bcrypt.hashpw(
                password.encode("utf-8"), bcrypt.gensalt()
            ).decode("utf-8")

            # Create user
            user = User.objects.create(
                email=email,
                password=hashed_password,
                name=name,
                domain_id=domain_id,
                quota=quota,
                admin=admin,
                active=active,
            )

            # Create quota usage record
            QuotaUsage.objects.create(user=user, bytes_used=0, message_count=0)

            messages.success(request, f"User {email} created successfully!")
            return redirect("users_list")

        except Exception as e:
            messages.error(request, f"Error creating user: {str(e)}")

    domains = Domain.objects.filter(active=True).order_by("domain")
    return render(
        request, "dashboard/user_form.html", {"domains": domains, "action": "Create"}
    )


@require_admin
def user_edit(request, user_id):
    user = get_object_or_404(User, id=user_id)

    if request.method == "POST":
        try:
            user.name = request.POST.get("name")
            user.quota = (
                int(request.POST.get("quota", 1)) * 1024 * 1024 * 1024
            )  # Convert GB to bytes
            user.admin = request.POST.get("admin") == "on"
            user.active = request.POST.get("active") == "on"

            # Update password if provided
            password = request.POST.get("password")
            if password:
                user.password = bcrypt.hashpw(
                    password.encode("utf-8"), bcrypt.gensalt()
                ).decode("utf-8")

            user.save()
            messages.success(request, f"User {user.email} updated successfully!")
            return redirect("users_list")

        except Exception as e:
            messages.error(request, f"Error updating user: {str(e)}")

    domains = Domain.objects.filter(active=True).order_by("domain")
    context = {
        "user": user,
        "domains": domains,
        "action": "Edit",
        "quota_gb": user.quota // (1024 * 1024 * 1024),  # Convert bytes to GB
    }
    return render(request, "dashboard/user_form.html", context)


@require_admin
def user_delete(request, user_id):
    user = get_object_or_404(User, id=user_id)

    # Prevent deleting self
    if user.id == request.session.get("user_id"):
        messages.error(request, "Cannot delete your own account.")
        return redirect("users_list")

    if request.method == "POST":
        email = user.email
        user.delete()
        messages.success(request, f"User {email} deleted successfully!")
        return redirect("users_list")

    return render(request, "dashboard/user_confirm_delete.html", {"user": user})


@require_admin
def domains_list(request):
    domains = Domain.objects.annotate(user_count=Count("user")).order_by("domain")

    context = {"domains": domains}
    return render(request, "dashboard/domains_list.html", context)


@require_admin
def domain_create(request):
    if request.method == "POST":
        try:
            domain = request.POST.get("domain").lower()
            description = request.POST.get("description")
            active = request.POST.get("active") == "on"

            Domain.objects.create(domain=domain, description=description, active=active)

            messages.success(request, f"Domain {domain} created successfully!")
            return redirect("domains_list")

        except Exception as e:
            messages.error(request, f"Error creating domain: {str(e)}")

    return render(request, "dashboard/domain_form.html", {"action": "Create"})


@require_admin
def domain_edit(request, domain_id):
    domain = get_object_or_404(Domain, id=domain_id)

    if request.method == "POST":
        try:
            domain.description = request.POST.get("description")
            domain.active = request.POST.get("active") == "on"
            domain.save()

            messages.success(request, f"Domain {domain.domain} updated successfully!")
            return redirect("domains_list")

        except Exception as e:
            messages.error(request, f"Error updating domain: {str(e)}")

    return render(
        request, "dashboard/domain_form.html", {"domain": domain, "action": "Edit"}
    )


@require_admin
def settings_list(request):
    settings = SystemSetting.objects.all().order_by("key")

    # Group settings by category
    grouped_settings = {}
    for setting in settings:
        category = get_setting_category(setting.key)
        if category not in grouped_settings:
            grouped_settings[category] = []
        grouped_settings[category].append(setting)

    context = {"grouped_settings": grouped_settings}
    return render(request, "dashboard/settings_list.html", context)


@require_admin
def setting_update(request, key):
    setting = get_object_or_404(SystemSetting, key=key)

    if request.method == "POST":
        try:
            setting.value = request.POST.get("value")
            setting.save()
            messages.success(request, f"Setting {key} updated successfully!")
        except Exception as e:
            messages.error(request, f"Error updating setting: {str(e)}")

    return redirect("settings_list")


def get_setting_category(key):
    """Categorize settings for better organization"""
    if "smtp" in key:
        return "SMTP"
    elif "spam" in key:
        return "Spam Filter"
    elif "virus" in key:
        return "Antivirus"
    elif "quota" in key or "size" in key:
        return "Storage"
    elif "backup" in key or "retention" in key:
        return "Maintenance"
    elif "rate" in key or "limit" in key:
        return "Limits"
    elif "dkim" in key or "spf" in key or "dmarc" in key:
        return "Security"
    else:
        return "General"


def health_check(request):
    """Health check endpoint for Docker"""
    return HttpResponse("OK")


def format_bytes(bytes_value):
    """Helper function to format bytes"""
    if bytes_value == 0:
        return "0 B"

    units = ["B", "KB", "MB", "GB", "TB"]
    unit_index = 0
    value = float(bytes_value)

    while value >= 1024 and unit_index < len(units) - 1:
        value /= 1024
        unit_index += 1

    return f"{value:.1f} {units[unit_index]}"
