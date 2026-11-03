from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, List, Optional
from core.security import get_current_user
from database.supabase_client import db_service
from services.auth_service import rbac_service
from models.schemas import ProjectCreate, ProjectUpdate

router = APIRouter(prefix="/projects", tags=["Project & Site Management"])

@router.get("")
def list_projects(current_user: Dict[str, Any] = Depends(get_current_user)):
    role = current_user.get("role", "client").lower()
    projects = db_service.get_projects()
    
    # If client, only return their projects
    if role == "client":
        client_email = current_user.get("email")
        user_record = next((u for u in db_service.users if u["email"] == client_email), None)
        client_id = user_record["id"] if user_record else None
        return [p for p in projects if p.get("client_id") == client_id or p.get("client_name", "").lower() in current_user.get("full_name", "").lower()]
        
    return projects

@router.get("/{project_id}")
def get_project_details(project_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    project = db_service.get_project_by_id(project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
        
    tasks = db_service.get_tasks(project_id)
    drawings = db_service.get_drawings(project_id)
    approvals = db_service.get_client_approvals(project_id)
    invoices = db_service.get_invoices(project_id)
    sites = [s for s in db_service.sites if s["project_id"] == project_id]
    
    return {
        "project": project,
        "sites": sites,
        "tasks_count": len(tasks),
        "drawings_count": len(drawings),
        "approvals_count": len(approvals),
        "invoices_count": len(invoices),
    }

@router.post("", status_code=status.HTTP_201_CREATED)
def create_project(payload: ProjectCreate, current_user: Dict[str, Any] = Depends(get_current_user)):
    rbac_service.enforce_role(current_user, ["owner"])
    new_project = db_service.create_project(payload.dict())
    
    # Auto-create default site
    default_site = {
        "id": f"site-{new_project['id'][-4:]}",
        "project_id": new_project["id"],
        "name": f"{payload.title} - Main Site",
        "location": payload.site_address,
        "engineer_id": None,
        "status": "Active",
        "notes": "Initial site inspection pending."
    }
    db_service.sites.append(default_site)
    
    return new_project

@router.patch("/{project_id}")
def update_project(project_id: str, payload: ProjectUpdate, current_user: Dict[str, Any] = Depends(get_current_user)):
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    updates = {k: v for k, v in payload.dict().items() if v is not None}
    updated = db_service.update_project(project_id, updates)
    if not updated:
        raise HTTPException(status_code=404, detail="Project not found")
    return updated

@router.get("/{project_id}/sites")
def list_project_sites(project_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    return [s for s in db_service.sites if s["project_id"] == project_id]
