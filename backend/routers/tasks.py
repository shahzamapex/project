from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status
from typing import Dict, Any, List, Optional
from core.security import get_current_user
from database.supabase_client import db_service
from services.auth_service import rbac_service
from services.ocr_service import ocr_service
from services.email_service import email_service
from models.schemas import TaskCreate, TaskUpdate, TaskBatchInsertRequest

router = APIRouter(prefix="/tasks", tags=["Tasks & OCR Automation"])

@router.get("")
def list_tasks(
    project_id: Optional[str] = None,
    status: Optional[str] = None,
    assigned_to: Optional[str] = None,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    tasks = db_service.get_tasks(project_id)
    if status:
        tasks = [t for t in tasks if t["status"].lower() == status.lower()]
    if assigned_to:
        tasks = [t for t in tasks if t.get("assigned_to") == assigned_to]
    return tasks

@router.post("", status_code=status.HTTP_201_CREATED)
def create_task(payload: TaskCreate, current_user: Dict[str, Any] = Depends(get_current_user)):
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    new_task = db_service.create_task(payload.dict())
    
    # Send email notification if Critical priority
    if payload.priority.lower() == "critical":
        project = db_service.get_project_by_id(payload.project_id)
        proj_title = project["title"] if project else "Interior Architecture Project"
        email_service.send_task_deadline_alert(
            engineer_email=current_user.get("email", "engineer@interiorcraft.com"),
            engineer_name=current_user.get("full_name", "Site Engineer"),
            task_title=payload.title,
            due_date=payload.due_date,
            project_title=proj_title
        )
        
    return new_task

@router.patch("/{task_id}")
def update_task(task_id: str, payload: TaskUpdate, current_user: Dict[str, Any] = Depends(get_current_user)):
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    updates = {k: v for k, v in payload.dict().items() if v is not None}
    
    updated = db_service.update_task(task_id, updates)
    if not updated:
        raise HTTPException(status_code=404, detail="Task not found")
        
    # If engineer marked task completed, check if project progress should be recalculated
    if updates.get("completion_percent") is not None or updates.get("status") == "Completed":
        project_tasks = db_service.get_tasks(updated["project_id"])
        if project_tasks:
            avg_progress = int(sum(t.get("completion_percent", 0) for t in project_tasks) / len(project_tasks))
            db_service.update_project(updated["project_id"], {"progress_percent": avg_progress})
            
    return updated

@router.post("/upload-ocr")
async def upload_document_for_ocr(
    project_id: str = Form(...),
    auto_save: bool = Form(False),
    file: UploadFile = File(...),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    OCR Task Automation Module:
    Accepts PDF specifications, BoQs, or architectural punch lists.
    Extracts text using Tesseract OCR / PyMuPDF layout parsing.
    Structures tasks automatically and inserts them into Supabase 'tasks' table mapped to the project.
    """
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    
    file_bytes = await file.read()
    if not file_bytes:
        raise HTTPException(status_code=400, detail="Uploaded file is empty.")

    filename = file.filename or "uploaded_spec.pdf"
    
    # 1. Extract raw text with OCR / Parser
    raw_text, method, confidence = ocr_service.extract_text_from_file(file_bytes, filename)
    
    # 2. Parse extracted text to structured tasks
    extracted_tasks = ocr_service.parse_extracted_text_to_tasks(raw_text, project_id, filename, confidence)
    
    saved_tasks = []
    if auto_save:
        for t in extracted_tasks:
            created = db_service.create_task(t)
            saved_tasks.append(created)

    return {
        "status": "success",
        "document_name": filename,
        "extraction_method": method,
        "base_confidence_score": confidence,
        "tasks_detected_count": len(extracted_tasks),
        "auto_saved": auto_save,
        "tasks": saved_tasks if auto_save else extracted_tasks,
        "raw_text_preview": raw_text[:400] + ("..." if len(raw_text) > 400 else "")
    }

@router.post("/batch-insert")
def batch_insert_tasks(payload: TaskBatchInsertRequest, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Inserts a batch of confirmed tasks extracted from OCR into the project."""
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    inserted = []
    for t in payload.tasks:
        t["project_id"] = payload.project_id
        task_rec = db_service.create_task(t)
        inserted.append(task_rec)
    return {"message": f"Successfully inserted {len(inserted)} tasks.", "tasks": inserted}
