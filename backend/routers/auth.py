from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, List
from core.security import create_access_token, get_current_user
from database.supabase_client import db_service
from services.auth_service import rbac_service
from models.schemas import LoginRequest, TokenResponse, RoleAssignmentRequest, PermissionModifyRequest

router = APIRouter(prefix="/auth", tags=["Authentication & Dynamic RBAC"])

@router.post("/login", response_model=TokenResponse)
def login(request: LoginRequest):
    """
    Authenticate user and issue JWT token with role and dynamic permissions.
    """
    user = next((u for u in db_service.users if u["email"].lower() == request.email.lower()), None)
    if not user:
        # Convenient demo login fallback: generate user with matching role or default
        role = "owner"
        if "eng" in request.email.lower():
            role = "engineer"
        elif "client" in request.email.lower():
            role = "client"
            
        user = {
            "id": f"u-{role}-demo",
            "email": request.email,
            "full_name": request.email.split("@")[0].replace(".", " ").title(),
            "role": role,
            "phone": "+1 (555) 000-0000",
            "avatar_url": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150"
        }
        db_service.users.append(user)

    permissions = rbac_service.get_user_permissions(user["role"])
    token = create_access_token({"sub": user["id"], "email": user["email"], "role": user["role"], "full_name": user["full_name"]})
    
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": user,
        "permissions": permissions
    }

@router.get("/me")
def get_profile(current_user: Dict[str, Any] = Depends(get_current_user)):
    user_record = next((u for u in db_service.users if u["id"] == current_user.get("id") or u["email"] == current_user.get("email")), None)
    if not user_record:
        user_record = current_user
    permissions = rbac_service.get_user_permissions(user_record.get("role", "client"))
    return {"user": user_record, "permissions": permissions}

@router.get("/users")
def list_users(current_user: Dict[str, Any] = Depends(get_current_user)):
    """Owner administrative endpoint: view all team members and clients."""
    rbac_service.enforce_role(current_user, ["owner"])
    return db_service.get_users()

@router.post("/assign-role")
def assign_role(payload: RoleAssignmentRequest, current_user: Dict[str, Any] = Depends(get_current_user)):
    """
    Owner administrative endpoint: dynamically change a user's role and permissions.
    """
    return rbac_service.assign_user_role(current_user, payload.target_user_id, payload.new_role)

@router.get("/permissions")
def get_all_permissions(current_user: Dict[str, Any] = Depends(get_current_user)):
    rbac_service.enforce_role(current_user, ["owner"])
    return db_service.roles_permissions

@router.post("/modify-permission")
def modify_permission(payload: PermissionModifyRequest, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Owner administrative endpoint: dynamically grant or revoke permissions for a role."""
    return rbac_service.modify_role_permission(current_user, payload.role, payload.permission, payload.action, payload.description or "")
