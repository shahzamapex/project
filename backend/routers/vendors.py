import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, List
from core.security import get_current_user
from database.supabase_client import db_service
from services.auth_service import rbac_service
from models.schemas import VendorCreate, PurchaseOrderCreate

router = APIRouter(prefix="/vendors", tags=["Vendor & Purchase Order Management"])

@router.get("")
def list_vendors(current_user: Dict[str, Any] = Depends(get_current_user)):
    return db_service.vendors

@router.post("", status_code=status.HTTP_201_CREATED)
def create_vendor(payload: VendorCreate, current_user: Dict[str, Any] = Depends(get_current_user)):
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    vendor_dict = payload.dict()
    vendor_dict["id"] = f"ven-{str(uuid.uuid4())[:6]}"
    vendor_dict["is_active"] = True
    vendor_dict["created_at"] = datetime.now().isoformat()
    db_service.vendors.append(vendor_dict)
    return vendor_dict

@router.get("/purchase-orders")
def list_purchase_orders(current_user: Dict[str, Any] = Depends(get_current_user)):
    return db_service.purchase_orders

@router.post("/purchase-orders", status_code=status.HTTP_201_CREATED)
def create_purchase_order(payload: PurchaseOrderCreate, current_user: Dict[str, Any] = Depends(get_current_user)):
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    po_dict = payload.dict()
    po_dict["id"] = f"po-{str(uuid.uuid4())[:6]}"
    po_dict["status"] = "Issued"
    po_dict["order_date"] = datetime.now().strftime("%Y-%m-%d")
    db_service.purchase_orders.insert(0, po_dict)
    return po_dict

@router.get("/notifications/logs")
def get_notification_logs(current_user: Dict[str, Any] = Depends(get_current_user)):
    """View all transactional emails sent via SendGrid / dispatched queue."""
    return db_service.dispatched_emails
