#!/usr/bin/env python3
"""
Django management script to create a test user directly
This bypasses the web form to test if the backend is working
"""

import os
import django
import bcrypt

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'koemail_admin.settings')
django.setup()

from dashboard.models import User, Domain, QuotaUsage

def create_test_user():
    try:
        # Get available domains
        domains = Domain.objects.filter(active=True).order_by('domain')
        
        print("Available domains:")
        for domain in domains:
            print(f"  - ID: {domain.id}, Domain: {domain.domain}")
        
        if not domains.exists():
            print("❌ No active domains found! Please create a domain first.")
            return False
        
        # Use the first domain
        domain = domains.first()
        
        # Check if test user already exists
        test_email = f"testuser@{domain.domain}"
        if User.objects.filter(email=test_email).exists():
            print(f"❌ Test user {test_email} already exists. Deleting...")
            User.objects.filter(email=test_email).delete()
        
        # Create test user
        hashed_password = bcrypt.hashpw(
            "testpass123".encode('utf-8'), 
            bcrypt.gensalt()
        ).decode('utf-8')
        
        user = User.objects.create(
            email=test_email,
            password=hashed_password,
            name="Test User",
            domain_id=domain.id,
            quota=1073741824,  # 1GB in bytes
            admin=False,
            active=True
        )
        
        # Create quota usage record
        QuotaUsage.objects.create(
            user=user, 
            bytes_used=0, 
            message_count=0
        )
        
        print("✅ Test user created successfully!")
        print(f"   Email: {test_email}")
        print(f"   Password: testpass123")
        print(f"   Name: Test User")
        print(f"   Domain: {domain.domain}")
        print(f"   Admin: No")
        print(f"   Active: Yes")
        
        return True
        
    except Exception as e:
        print(f"❌ Error creating test user: {str(e)}")
        return False

def list_all_users():
    """List all users in the system"""
    print("\nAll users in the system:")
    print("-" * 50)
    
    users = User.objects.select_related('domain').order_by('email')
    
    if not users.exists():
        print("No users found.")
        return
    
    for user in users:
        print(f"Email: {user.email}")
        print(f"  Name: {user.name}")
        print(f"  Domain: {user.domain.domain}")
        print(f"  Admin: {'Yes' if user.admin else 'No'}")
        print(f"  Active: {'Yes' if user.active else 'No'}")
        print(f"  Created: {user.created_at}")
        print()

if __name__ == "__main__":
    print("KoeMail User Creation Test")
    print("=" * 30)
    
    # Create test user
    success = create_test_user()
    
    # List all users
    list_all_users()
    
    if success:
        print("✅ Backend user creation is working correctly!")
        print("   The issue is likely with the web form frontend.")
    else:
        print("❌ Backend user creation failed!")
        print("   There's an issue with the database or models.")