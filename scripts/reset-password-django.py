#!/usr/bin/env python3
"""
Django management script to reset admin password properly
This script should be run inside the admin-ui container
"""

import os
import django
import bcrypt

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'koemail_admin.settings')
django.setup()

from dashboard.models import User

def reset_admin_password(email, new_password):
    try:
        # Find the user
        user = User.objects.get(email=email)
        
        # Generate bcrypt hash
        hashed_password = bcrypt.hashpw(
            new_password.encode('utf-8'), 
            bcrypt.gensalt()
        ).decode('utf-8')
        
        # Update password
        user.password = hashed_password
        user.save()
        
        print(f"✓ Password updated successfully for {email}")
        print(f"New password: {new_password}")
        print(f"Hash length: {len(hashed_password)}")
        print(f"Hash: {hashed_password}")
        
    except User.DoesNotExist:
        print(f"✗ User {email} not found")
    except Exception as e:
        print(f"✗ Error: {str(e)}")

if __name__ == "__main__":
    reset_admin_password("postmaster@koemail.local", "admin123")