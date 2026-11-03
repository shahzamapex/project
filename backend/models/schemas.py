from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List, Dict, Any
from datetime import date, datetime

# Auth Schemas
class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: Dict[str, Any]
    permissions: List[str]

class RoleAssignmentRequest(BaseModel):
    target_user_id: str
    new_role: str = Field(..., pattern="^(owner|engineer|client)$")

class PermissionModifyRequest(BaseModel):
    role: str
    permission: str
    action: str = Field("ADD", pattern="^(ADD|REMOVE)$")
    description: Optional[str] = None

# Project Schemas
class ProjectCreate(BaseModel):
    title: str
    client_name: str
    client_id: Optional[str] = None
    budget: float = 100000.00
    start_date: str
    target_end_date: str
    site_address: str
    description: Optional[str] = None

class ProjectUpdate(BaseModel):
    title: Optional[str] = None
    status: Optional[str] = None
    budget: Optional[float] = None
    spent: Optional[float] = None
    progress_percent: Optional[int] = None
    target_end_date: Optional[str] = None

# Task Schemas
class TaskCreate(BaseModel):
    project_id: str
    site_id: Optional[str] = None
    title: str
    description: Optional[str] = None
    assigned_to: Optional[str] = None
    priority: str = "Medium"
    planned_days: int = 5
    due_date: str

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    priority: Optional[str] = None
    status: Optional[str] = None
    completion_percent: Optional[int] = None
    actual_days: Optional[int] = None
    assigned_to: Optional[str] = None

class TaskBatchInsertRequest(BaseModel):
    project_id: str
    tasks: List[Dict[str, Any]]

# Drawing & Markup Schemas
class MarkupCreate(BaseModel):
    drawing_id: str
    layer_data: Dict[str, Any]
    comment: Optional[str] = None

# Inventory Schemas
class InventoryItemCreate(BaseModel):
    sku: str
    name: str
    category: str
    quantity: int = 0
    unit: str = "pcs"
    min_threshold: int = 10
    unit_price: float = 0.00
    warehouse_zone: str = "Zone A"

class InventoryTransactionCreate(BaseModel):
    item_id: str
    project_id: Optional[str] = None
    transaction_type: str = Field(..., pattern="^(IN_RESTOCK|OUT_DISPATCH|RETURN|ADJUSTMENT)$")
    quantity: int
    notes: Optional[str] = None

# Client Portal Schemas
class ApprovalDecisionRequest(BaseModel):
    status: str = Field(..., pattern="^(Approved|Revision Requested)$")
    feedback: str

class InvoicePaymentRequest(BaseModel):
    payment_method: str = "Wire Transfer"
    notes: Optional[str] = None

# Vendor Schemas
class VendorCreate(BaseModel):
    name: str
    contact_person: str
    email: EmailStr
    phone: str
    category: str
    rating: float = 5.0

class PurchaseOrderCreate(BaseModel):
    vendor_id: str
    project_id: Optional[str] = None
    po_number: str
    total_amount: float
    expected_delivery: Optional[str] = None

# Material Requirements Planning (MRP) & Site Allocation Schemas
class MaterialRequirementCreate(BaseModel):
    item_name: str
    item_category: str
    specification_details: Optional[Dict[str, Any]] = None
    required_quantity: float = Field(..., gt=0)

class MaterialRequirementBatchCreate(BaseModel):
    requirements: List[MaterialRequirementCreate]

class MaterialAllocationRequest(BaseModel):
    requested_quantity: float = Field(..., gt=0)

class AllocationDispatchRequest(BaseModel):
    gate_pass_number: Optional[str] = None

class BatchDispatchRequest(BaseModel):
    allocation_ids: List[str]
    gate_pass_number: Optional[str] = None

class ConfirmInstallationRequest(BaseModel):
    quantity: float = Field(..., gt=0)
    notes: Optional[str] = None
    proof_attachment_url: Optional[str] = None

