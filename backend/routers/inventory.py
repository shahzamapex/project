import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, List, Optional
from core.security import get_current_user
from database.supabase_client import db_service
from services.auth_service import rbac_service
from models.schemas import InventoryItemCreate, InventoryTransactionCreate

router = APIRouter(prefix="/inventory", tags=["Warehouse & Inventory System"])

@router.get("")
def list_inventory(category: Optional[str] = None, low_stock_only: bool = False, current_user: Dict[str, Any] = Depends(get_current_user)):
    items = db_service.get_inventory()
    if category:
        items = [i for i in items if i["category"].lower() == category.lower()]
    if low_stock_only:
        items = [i for i in items if i["status"] in ["Low Stock", "Out of Stock"]]
    return items

@router.post("", status_code=status.HTTP_201_CREATED)
def create_inventory_item(payload: InventoryItemCreate, current_user: Dict[str, Any] = Depends(get_current_user)):
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    item_dict = payload.dict()
    item_dict["id"] = f"inv-{str(uuid.uuid4())[:6]}"
    item_dict["status"] = "In Stock" if item_dict["quantity"] > item_dict["min_threshold"] else ("Low Stock" if item_dict["quantity"] > 0 else "Out of Stock")
    db_service.inventory_items.append(item_dict)
    return item_dict

@router.post("/transactions", status_code=status.HTTP_201_CREATED)
def record_warehouse_transaction(payload: InventoryTransactionCreate, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Records stock dispatch to site or warehouse restock, and auto-updates item stock levels."""
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    
    delta = payload.quantity if payload.transaction_type in ["IN_RESTOCK", "RETURN"] else -payload.quantity
    updated_item = db_service.update_inventory_quantity(payload.item_id, delta)
    if not updated_item:
        raise HTTPException(status_code=404, detail="Inventory item not found")
        
    tx = {
        "id": f"tx-{str(uuid.uuid4())[:6]}",
        "item_id": payload.item_id,
        "item_name": updated_item["name"],
        "project_id": payload.project_id,
        "transaction_type": payload.transaction_type,
        "quantity": payload.quantity,
        "date": datetime.now().strftime("%Y-%m-%d"),
        "recorded_by": current_user.get("id"),
        "notes": payload.notes or ""
    }
    db_service.warehouse_transactions.insert(0, tx)
    
    return {
        "transaction": tx,
        "updated_inventory_item": updated_item
    }

@router.get("/transactions")
def list_warehouse_transactions(current_user: Dict[str, Any] = Depends(get_current_user)):
    return db_service.warehouse_transactions
