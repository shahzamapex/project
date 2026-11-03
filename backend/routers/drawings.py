from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, List, Optional
from core.security import get_current_user
from database.supabase_client import db_service
from services.auth_service import rbac_service
from models.schemas import MarkupCreate

router = APIRouter(prefix="/drawings", tags=["Drawing & Markup Center"])

@router.get("")
def list_drawings(project_id: Optional[str] = None, current_user: Dict[str, Any] = Depends(get_current_user)):
    return db_service.get_drawings(project_id)

@router.get("/{drawing_id}")
def get_drawing_details(drawing_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    drawing = next((d for d in db_service.drawings if d["id"] == drawing_id), None)
    if not drawing:
        raise HTTPException(status_code=404, detail="Drawing not found")
    markups = db_service.get_markups(drawing_id)
    return {"drawing": drawing, "markups": markups}

@router.get("/{drawing_id}/markups")
def get_drawing_markups(drawing_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    return db_service.get_markups(drawing_id)

@router.post("/{drawing_id}/markups", status_code=status.HTTP_201_CREATED)
def save_markup(
    drawing_id: str,
    payload: MarkupCreate,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Saves a vector markup layer generated from Flutter CustomPaint / GestureDetector
    (cloud callouts, freehand strokes, measurements, and text notes).
    """
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    markup_data = {
        "drawing_id": drawing_id,
        "author_id": current_user.get("id", "u-eng-001"),
        "author_name": current_user.get("full_name", "Site Engineer"),
        "author_role": current_user.get("role", "engineer"),
        "layer_data": payload.layer_data,
        "comment": payload.comment or ""
    }
    return db_service.create_markup(markup_data)
