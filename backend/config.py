# -*- coding: utf-8 -*-
"""
Configuration module for Sapiencial Backend
Centralizes all configuration and environment variables
"""
import os
from typing import List
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class Config:
    """Application configuration class"""
    
    # JWT Configuration
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "default_secret_change_in_production")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    JWT_EXPIRATION_HOURS: int = int(os.getenv("JWT_EXPIRATION_HOURS", "24"))
    
    # Teacher Authentication
    TEACHER_ACCESS_TOKEN: str = os.getenv("TEACHER_ACCESS_TOKEN", "profesor2026")
    TEACHER_USERNAME: str = os.getenv("TEACHER_USERNAME", "admin")
    TEACHER_PASSWORD: str = os.getenv("TEACHER_PASSWORD", "admin123")
    
    # Database Configuration (for future implementation)
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./sapiencial.db")
    
    # CORS Configuration
    ALLOWED_ORIGINS: List[str] = [
        origin.strip() for origin in 
        os.getenv("ALLOWED_ORIGINS", "http://localhost:3000,https://yourdomain.netlify.app").split(",")
        if origin.strip()
    ]
    
    # Application Configuration
    DEBUG: bool = os.getenv("DEBUG", "false").lower() == "true"
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    
    # WebSocket Configuration
    WS_HEARTBEAT_INTERVAL: int = 30
    WS_CONNECTION_TIMEOUT: int = 300
    
    # Rate Limiting
    RATE_LIMIT_REQUESTS: int = 100
    RATE_LIMIT_WINDOW: int = 60  # seconds
    
    # File Upload Configuration
    MAX_FILE_SIZE: int = 10 * 1024 * 1024  # 10MB
    ALLOWED_FILE_TYPES: List[str] = [".jpg", ".jpeg", ".png", ".pdf", ".doc", ".docx"]
    
    # Progress File
    PROGRESS_FILE: str = "student_progress.json"
    
    @classmethod
    def validate_config(cls) -> bool:
        """Validate critical configuration values"""
        errors = []
        
        if cls.JWT_SECRET_KEY == "default_secret_change_in_production":
            errors.append("JWT_SECRET_KEY must be changed from default")
        
        if not cls.ALLOWED_ORIGINS:
            errors.append("ALLOWED_ORIGINS cannot be empty")
        
        if cls.JWT_EXPIRATION_HOURS < 1 or cls.JWT_EXPIRATION_HOURS > 168:
            errors.append("JWT_EXPIRATION_HOURS must be between 1 and 168 hours")
        
        if errors:
            print("?? Configuration Errors:")
            for error in errors:
                print(f"  - {error}")
            return False
        
        return True
    
    @classmethod
    def get_cors_config(cls) -> dict:
        """Get CORS configuration for FastAPI"""
        return {
            "allow_origins": cls.ALLOWED_ORIGINS,
            "allow_credentials": True,
            "allow_methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["*"],
        }

# Initialize and validate configuration
config = Config()

if not config.validate_config():
    raise RuntimeError("Invalid configuration. Please check your environment variables.")