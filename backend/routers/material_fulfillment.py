from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, List, Optional
from core.security import get_current_user
from database.supabase_client import db_service
from services.auth_service import rbac_service
from models.schemas import (
    MaterialRequirementCreate,
    MaterialRequirementBatchCreate,
    MaterialAllocationRequest,
    AllocationDispatchRequest,
    BatchDispatchRequest,
    ConfirmInstallationRequest
)

router = APIRouter(tags=["Material Requirements Planning & Installation Tracking"])

# =========================================================================
# 1. SITE MATERIAL SPECIFICATIONS INGESTION
# =========================================================================

@router.get("/projects/{project_id}/materials")
def list_project_materials(
    project_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Lists all site material requirements and linked allocations for a project."""
    return db_service.get_material_requirements(project_id)

@router.post("/projects/{project_id}/materials", status_code=status.HTTP_201_CREATED)
def ingest_site_materials(
    project_id: str,
    payload: MaterialRequirementCreate,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    1. POST /api/v1/projects/{project_id}/materials
    Ingests site material specifications (Site Bill of Materials).
    """
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    req_dict = payload.dict()
    req_dict["project_id"] = project_id
    created = db_service.create_material_requirement(req_dict)
    return created

@router.post("/projects/{project_id}/materials/batch", status_code=status.HTTP_201_CREATED)
def ingest_site_materials_batch(
    project_id: str,
    payload: MaterialRequirementBatchCreate,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Batch ingestion of multiple site material specifications."""
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    created_list = []
    for req in payload.requirements:
        req_dict = req.dict()
        req_dict["project_id"] = project_id
        created = db_service.create_material_requirement(req_dict)
        created_list.append(created)
    return {"message": f"Successfully ingested {len(created_list)} site material requirements.", "requirements": created_list}

@router.post("/projects/{project_id}/materials/auto-match")
def auto_match_and_allocate(
    project_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Action Button: Auto-Match & Allocate
    Scans project specifications against warehouse inventory and executes allocation transactions.
    """
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    return db_service.auto_match_project_materials(project_id, current_user.get("id", "u-owner-001"))

# =========================================================================
# 2. INVENTORY ALLOCATION TRANSACTION LOGIC
# =========================================================================

@router.post("/materials/{requirement_id}/allocate")
def allocate_material(
    requirement_id: str,
    payload: MaterialAllocationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    2. POST /api/v1/materials/{requirement_id}/allocate
    Transaction Logic:
    - Query inventory_items, check available_stock >= requested_quantity.
    - Branch A (In-Stock): Increment reserved stock, update requirement to FULFILLED_WAREHOUSE,
      insert audit record in material_allocations with status RESERVED.
    - Branch B (Stock Deficit): Update status to PROCUREMENT_PENDING, auto-generate procurement Purchase Order.
    """
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    result = db_service.allocate_material_transaction(
        requirement_id=requirement_id,
        requested_quantity=payload.requested_quantity,
        allocated_by=current_user.get("id", "u-owner-001")
    )
    if "error" in result:
        raise HTTPException(status_code=404, detail=result["error"])
    return result

# =========================================================================
# 3. WAREHOUSE DISPATCH & GATE PASS
# =========================================================================

@router.get("/allocations/reserved")
def list_reserved_allocations(
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Warehouse Dispatcher: List all RESERVED allocations awaiting site dispatch."""
    return db_service.get_allocations(status="RESERVED")

@router.post("/allocations/{allocation_id}/dispatch")
def dispatch_allocation(
    allocation_id: str,
    payload: Optional[AllocationDispatchRequest] = None,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    3. POST /api/v1/allocations/{allocation_id}/dispatch
    Updates status to DISPATCHED_TO_SITE, decrements total_stock and reserved_stock appropriately.
    """
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    gp = payload.gate_pass_number if payload else None
    result = db_service.dispatch_allocation(allocation_id, gate_pass_number=gp)
    if "error" in result:
        raise HTTPException(status_code=404, detail=result["error"])
    return result

@router.post("/allocations/batch-dispatch")
def batch_dispatch_allocations(
    payload: BatchDispatchRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Batch action: Generate Site Gate Pass & Dispatch to convert reservations into active transit.
    """
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    result = db_service.batch_dispatch_allocations(payload.allocation_ids, gate_pass_number=payload.gate_pass_number)
    return result

# =========================================================================
# 4. SITE INSTALLATION & FITMENT CONFIRMATION
# =========================================================================

@router.get("/allocations/in-transit")
def list_in_transit_allocations(
    project_id: Optional[str] = None,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Site Engineer: List all items marked DISPATCHED_TO_SITE awaiting installation verification."""
    return db_service.get_allocations(status="DISPATCHED_TO_SITE", project_id=project_id)

@router.post("/materials/{requirement_id}/confirm-installation")
def confirm_installation(
    requirement_id: str,
    payload: ConfirmInstallationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    4. POST /api/v1/materials/{requirement_id}/confirm-installation
    Invoked by Site Engineer:
    - Inputs quantity, optional photo attachment, engineer notes.
    - Updates installed_quantity.
    - If requirement installed_quantity >= required_quantity, updates status to INSTALLED_CONFIRMED.
    - Logs actions.
    """
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    result = db_service.confirm_installation(
        requirement_id=requirement_id,
        quantity=payload.quantity,
        installed_by=current_user.get("id", "u-eng-001"),
        notes=payload.notes,
        proof_attachment_url=payload.proof_attachment_url
    )
    if "error" in result:
        raise HTTPException(status_code=404, detail=result["error"])
    return result
