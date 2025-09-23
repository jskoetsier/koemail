from django.db import models


class Domain(models.Model):
    domain = models.CharField(max_length=255, unique=True)
    description = models.TextField(blank=True)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "domains"

    def __str__(self):
        return self.domain


class User(models.Model):
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    domain = models.ForeignKey(Domain, on_delete=models.CASCADE)
    quota = models.BigIntegerField(default=1073741824)  # 1GB default
    active = models.BooleanField(default=True)
    admin = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_login = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "users"

    def __str__(self):
        return self.email


class Alias(models.Model):
    source = models.CharField(max_length=255)
    destination = models.CharField(max_length=255)
    domain = models.ForeignKey(Domain, on_delete=models.CASCADE)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "aliases"

    def __str__(self):
        return f"{self.source} -> {self.destination}"


class QuotaUsage(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    bytes_used = models.BigIntegerField(default=0)
    message_count = models.IntegerField(default=0)
    last_updated = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "quota_usage"


class SystemSetting(models.Model):
    key = models.CharField(max_length=100, primary_key=True)
    value = models.TextField()
    type = models.CharField(max_length=20, default="string")
    description = models.TextField(blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "system_settings"

    def __str__(self):
        return self.key
