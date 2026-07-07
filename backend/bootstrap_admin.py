#!/usr/bin/env python3
"""
Bootstrap script to initialize the admin user in the database.
Usage: python bootstrap_admin.py [username] [password]
"""

import sys
import os
from datetime import datetime

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from main import Base, SessionLocal, engine, AdminUser, hash_password

def bootstrap_admin(username: str = None, password: str = None):
    """Create or update the admin user."""
    if username is None:
        username = os.getenv("LOKATION_ADMIN_USER", "admin")
    if password is None:
        password = os.getenv("LOKATION_ADMIN_PASSWORD", "admin123")
    
    # Create tables if they don't exist
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        # Check if user exists
        existing = db.query(AdminUser).filter(AdminUser.username == username).first()
        
        if existing:
            print(f"Admin user '{username}' already exists. Updating password...")
            existing.hashed_password = hash_password(password)
            db.commit()
            print(f"✓ Password updated for user '{username}'")
        else:
            print(f"Creating admin user '{username}'...")
            admin = AdminUser(
                username=username,
                hashed_password=hash_password(password),
                created_at=datetime.utcnow(),
            )
            db.add(admin)
            db.commit()
            print(f"✓ Admin user '{username}' created successfully")
        
        # Verify
        user = db.query(AdminUser).filter(AdminUser.username == username).first()
        if user:
            print(f"\nAdmin credentials:")
            print(f"  Username: {username}")
            print(f"  Password: {password}")
        
    except Exception as e:
        print(f"✗ Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    username = sys.argv[1] if len(sys.argv) > 1 else None
    password = sys.argv[2] if len(sys.argv) > 2 else None
    bootstrap_admin(username, password)
