import os
from typing import Optional
from dotenv import load_dotenv

# Load .env if present
load_dotenv()

class Settings:
    APP_NAME: str = "InteriorCraft Project Management Platform API"
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    API_V1_STR: str = "/api"
    
    # JWT & Auth
    SECRET_KEY: str = os.getenv("JWT_SECRET", "super-secret-interior-design-key-2026-xyz-change-in-prod")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    
    # Supabase credentials
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "")
    SUPABASE_BUCKET_DRAWINGS: str = "architectural-drawings"
    SUPABASE_BUCKET_DOCS: str = "project-documents"
    
    # SendGrid credentials
    SENDGRID_API_KEY: str = os.getenv("SENDGRID_API_KEY", "")
    SENDGRID_FROM_EMAIL: str = os.getenv("SENDGRID_FROM_EMAIL", "notifications@interiorcraft.com")
    
    # Tesseract OCR path (optional override for Windows or custom environments)
    TESSERACT_CMD: Optional[str] = os.getenv("TESSERACT_CMD", None)

settings = Settings()
