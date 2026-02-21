# -*- coding: utf-8 -*-
"""
Authentication module for Sapiencial Backend
Implements JWT-based authentication with proper security
"""
import jwt
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from hashlib import sha256
import secrets

from config import config

class AuthenticationError(Exception):
    """Custom exception for authentication errors"""
    pass

class JWTManager:
    """Manages JWT token creation and validation"""
    
    def __init__(self):
        self.secret_key = config.JWT_SECRET_KEY
        self.algorithm = config.JWT_ALGORITHM
        self.expiration_hours = config.JWT_EXPIRATION_HOURS
    
    def create_access_token(self, payload: Dict[str, Any]) -> str:
        """Create a JWT access token"""
        try:
            # Add expiration time
            expire = datetime.utcnow() + timedelta(hours=self.expiration_hours)
            payload.update({"exp": expire, "iat": datetime.utcnow()})
            
            # Create token
            token = jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
            return token
            
        except Exception as e:
            raise AuthenticationError(f"Error creating token: {str(e)}")
    
    def verify_token(self, token: str) -> Dict[str, Any]:
        """Verify and decode JWT token"""
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            return payload
            
        except jwt.ExpiredSignatureError:
            raise AuthenticationError("Token has expired")
        except jwt.InvalidTokenError:
            raise AuthenticationError("Invalid token")
        except Exception as e:
            raise AuthenticationError(f"Error verifying token: {str(e)}")
    
    def refresh_token(self, token: str) -> str:
        """Refresh an existing token"""
        try:
            payload = self.verify_token(token)
            # Remove exp and iat from payload to generate new token
            payload.pop("exp", None)
            payload.pop("iat", None)
            return self.create_access_token(payload)
            
        except AuthenticationError:
            raise AuthenticationError("Cannot refresh invalid token")

class TeacherAuth:
    """Handles teacher authentication with improved security"""
    
    def __init__(self):
        self.access_token = config.TEACHER_ACCESS_TOKEN
        self.username = config.TEACHER_USERNAME
        self.password = config.TEACHER_PASSWORD
        self.jwt_manager = JWTManager()
        
        # Generate secure token hash
        self.token_hash = sha256(self.access_token.encode()).hexdigest()
        
        # Store failed attempts for rate limiting
        self.failed_attempts = {}
        self.max_attempts = 5
        self.lockout_duration = 300  # 5 minutes
    
    def validate_token(self, token: str, role: str) -> bool:
        """Validate token with improved security"""
        if role == "teacher":
            # Check rate limiting
            if self._is_rate_limited(token):
                raise AuthenticationError("Too many failed attempts. Please try again later.")
            
            # Validate token hash
            token_hash = sha256(token.encode()).hexdigest()
            is_valid = token_hash == self.token_hash
            
            if not is_valid:
                self._record_failed_attempt(token)
                return False
            
            # Reset failed attempts on success
            self._reset_failed_attempts(token)
            return True
            
        elif role == "student":
            # Students don't require token for now (future improvement)
            return True
            
        return False
    
    def authenticate_teacher(self, username: str, password: str) -> Optional[str]:
        """Authenticate teacher and return JWT token"""
        if username != self.username or password != self.password:
            raise AuthenticationError("Invalid credentials")
        
        # Create JWT token for authenticated teacher
        payload = {
            "sub": username,
            "role": "teacher",
            "type": "access"
        }
        
        return self.jwt_manager.create_access_token(payload)
    
    def verify_jwt_token(self, token: str) -> Optional[Dict[str, Any]]:
        """Verify JWT token and return payload"""
        try:
            payload = self.jwt_manager.verify_token(token)
            
            # Validate token type and role
            if payload.get("type") != "access" or payload.get("role") != "teacher":
                raise AuthenticationError("Invalid token type")
            
            return payload
            
        except AuthenticationError:
            raise
        except Exception as e:
            raise AuthenticationError(f"Error verifying JWT: {str(e)}")
    
    def _is_rate_limited(self, identifier: str) -> bool:
        """Check if identifier is rate limited"""
        if identifier not in self.failed_attempts:
            return False
        
        attempts = self.failed_attempts[identifier]
        if len(attempts) >= self.max_attempts:
            last_attempt = attempts[-1]
            time_diff = datetime.utcnow().timestamp() - last_attempt
            return time_diff < self.lockout_duration
        
        return False
    
    def _record_failed_attempt(self, identifier: str):
        """Record a failed authentication attempt"""
        if identifier not in self.failed_attempts:
            self.failed_attempts[identifier] = []
        
        self.failed_attempts[identifier].append(datetime.utcnow().timestamp())
        
        # Keep only recent attempts
        cutoff = datetime.utcnow().timestamp() - self.lockout_duration
        self.failed_attempts[identifier] = [
            attempt for attempt in self.failed_attempts[identifier]
            if attempt > cutoff
        ]
    
    def _reset_failed_attempts(self, identifier: str):
        """Reset failed attempts for identifier"""
        if identifier in self.failed_attempts:
            del self.failed_attempts[identifier]

class StudentAuth:
    """Handles student authentication (basic implementation)"""
    
    def __init__(self):
        self.jwt_manager = JWTManager()
    
    def create_student_token(self, student_data: Dict[str, Any]) -> str:
        """Create token for authenticated student"""
        payload = {
            "sub": student_data.get("session_id"),
            "name": student_data.get("name"),
            "role": "student",
            "type": "access"
        }
        
        return self.jwt_manager.create_access_token(payload)
    
    def verify_student_token(self, token: str) -> Optional[Dict[str, Any]]:
        """Verify student JWT token"""
        try:
            payload = self.jwt_manager.verify_token(token)
            
            if payload.get("type") != "access" or payload.get("role") != "student":
                raise AuthenticationError("Invalid token type")
            
            return payload
            
        except AuthenticationError:
            raise
        except Exception as e:
            raise AuthenticationError(f"Error verifying student JWT: {str(e)}")

# Global authentication instances
teacher_auth = TeacherAuth()
student_auth = StudentAuth()

def generate_secure_token(length: int = 32) -> str:
    """Generate a cryptographically secure random token"""
    return secrets.token_urlsafe(length)

def hash_password(password: str, salt: Optional[str] = None) -> tuple[str, str]:
    """Hash password with salt (for future implementation)"""
    if salt is None:
        salt = secrets.token_hex(16)
    
    # Use SHA-256 with salt (upgrade to bcrypt in production)
    salted_password = password + salt
    password_hash = sha256(salted_password.encode()).hexdigest()
    
    return password_hash, salt

def verify_password(password: str, password_hash: str, salt: str) -> bool:
    """Verify password against hash"""
    expected_hash = sha256((password + salt).encode()).hexdigest()
    return expected_hash == password_hash