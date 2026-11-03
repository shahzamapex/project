from typing import List, Dict, Any, Optional
from fastapi import HTTPException, status
from database.supabase_client import db_service

class RBACService:
    def __init__(self):
        # Role hierarchy and default baseline capabilities
        self.role_hierarchy = {
            "owner": 3,
            "engineer": 2,
            "client": 1
        }

    def get_user_permissions(self, role: str) -> List[str]:
        """
        Dynamically fetches permissions assigned to the specified role from Supabase.
        """
        perms = [p["permission"] for p in db_service.roles_permissions if p["role"] == role.lower()]
        return perms

    def check_permission(self, current_user: Dict[str, Any], required_permission: str) -> bool:
        """
        Verifies if current user's role has the requested permission.
        Owners automatically inherit all permissions.
        """
        role = current_user.get("role", "").lower()
        if role == "owner":
            return True
            
        user_permissions = self.get_user_permissions(role)
        if required_permission in user_permissions:
            return True
            
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Role '{role}' is not authorized to perform this operation. Required permission: {required_permission}"
        )

    def enforce_role(self, current_user: Dict[str, Any], allowed_roles: List[str]) -> bool:
        role = current_user.get("role", "").lower()
        if role not in [r.lower() for r in allowed_roles]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied for role '{role}'. Allowed roles: {', '.join(allowed_roles)}"
            )
        return True

    def assign_user_role(self, owner_user: Dict[str, Any], target_user_id: str, new_role: str) -> Dict[str, Any]:
        """
        Administrative function: Allows Owner to dynamically reassign user roles.
        """
        self.enforce_role(owner_user, ["owner"])
        if new_role not in ["owner", "engineer", "client"]:
            raise HTTPException(status_code=400, detail="Invalid role specified. Must be owner, engineer, or client.")
        
        updated_user = db_service.update_user_role(target_user_id, new_role)
        if not updated_user:
            raise HTTPException(status_code=404, detail=f"User {target_user_id} not found.")
        
        return {
            "message": f"Role for user {updated_user['full_name']} updated to {new_role}.",
            "user": updated_user,
            "permissions": self.get_user_permissions(new_role)
        }

    def modify_role_permission(self, owner_user: Dict[str, Any], role: str, permission: str, action: str = "ADD", description: str = "") -> Dict[str, Any]:
        """
        Administrative function: Allows Owner to dynamically grant or revoke permissions for a role.
        """
        self.enforce_role(owner_user, ["owner"])
        role = role.lower()
        
        if action.upper() == "ADD":
            # Check if exists
            exists = any(p["role"] == role and p["permission"] == permission for p in db_service.roles_permissions)
            if not exists:
                db_service.roles_permissions.append({
                    "role": role,
                    "permission": permission,
                    "description": description or f"Custom dynamic permission {permission}"
                })
            return {"message": f"Permission '{permission}' granted to '{role}'.", "active_permissions": self.get_user_permissions(role)}
        
        elif action.upper() == "REMOVE":
            db_service.roles_permissions = [
                p for p in db_service.roles_permissions 
                if not (p["role"] == role and p["permission"] == permission)
            ]
            return {"message": f"Permission '{permission}' revoked from '{role}'.", "active_permissions": self.get_user_permissions(role)}
        else:
            raise HTTPException(status_code=400, detail="Action must be ADD or REMOVE.")

rbac_service = RBACService()
