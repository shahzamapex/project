import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from core.config import settings
from routers import auth, projects, tasks, analytics, drawings, inventory, clients, vendors, material_fulfillment

app = FastAPI(
    title=settings.APP_NAME,
    description="Cloud-based Interior Design Project Management Platform with OCR Task Automation, Scikit-Learn Predictive Delays, and Supabase / SendGrid integrations.",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Enable CORS for Flutter Web frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(projects.router, prefix=settings.API_V1_STR)
app.include_router(tasks.router, prefix=settings.API_V1_STR)
app.include_router(analytics.router, prefix=settings.API_V1_STR)
app.include_router(drawings.router, prefix=settings.API_V1_STR)
app.include_router(inventory.router, prefix=settings.API_V1_STR)
app.include_router(clients.router, prefix=settings.API_V1_STR)
app.include_router(vendors.router, prefix=settings.API_V1_STR)
app.include_router(material_fulfillment.router, prefix="/api/v1")
app.include_router(material_fulfillment.router, prefix=settings.API_V1_STR)

@app.get("/")
def root():
    return {
        "app": settings.APP_NAME,
        "status": "online",
        "version": "2.0.0",
        "documentation": "/docs",
        "modules": [
            "OCR Task Automation Engine",
            "Scikit-Learn AI Delay Prediction & Resource Allocation",
            "Dynamic RBAC (Owner, Engineer, Client)",
            "Architectural Drawing & Vector Markup System",
            "Warehouse Inventory & Zone Management",
            "Client Portal (Approvals, Invoices, Payments)",
            "SendGrid Transactional Notifications"
        ]
    }

@app.get("/health")
def health_check():
    return {"status": "healthy", "environment": settings.ENVIRONMENT}

@app.get("/health/supabase")
@app.get("/api/health/supabase")
def supabase_health():
    from database.supabase_client import db
    return db.check_connection()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
