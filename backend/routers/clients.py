from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, List, Optional
from core.security import get_current_user
from database.supabase_client import db_service
from services.auth_service import rbac_service
from services.email_service import email_service
from models.schemas import ApprovalDecisionRequest, InvoicePaymentRequest

router = APIRouter(prefix="/client-portal", tags=["Client Portal & Financial Records"])

@router.get("/approvals")
def list_client_approvals(project_id: Optional[str] = None, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Fetches 3D renders, moodboards, and material palettes for client sign-off."""
    return db_service.get_client_approvals(project_id)

@router.post("/approvals/{approval_id}/decide")
def submit_approval_decision(
    approval_id: str,
    payload: ApprovalDecisionRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Client approves a design or requests revisions with feedback."""
    updated = db_service.update_approval_status(approval_id, payload.status, payload.feedback)
    if not updated:
        raise HTTPException(status_code=404, detail="Approval item not found")
        
    return {
        "message": f"Design review submitted successfully with status '{payload.status}'.",
        "approval": updated
    }

@router.get("/invoices")
def list_invoices(project_id: Optional[str] = None, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Fetches milestone invoices and payment records."""
    return db_service.get_invoices(project_id)

@router.post("/invoices/{invoice_id}/pay")
def pay_invoice(
    invoice_id: str,
    payload: InvoicePaymentRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Marks invoice as paid and triggers a SendGrid confirmation receipt."""
    invoice = next((i for i in db_service.invoices_payments if i["id"] == invoice_id), None)
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
        
    invoice["status"] = "Paid"
    invoice["paid_at"] = datetime.now().isoformat()
    invoice["payment_method"] = payload.payment_method
    if payload.notes:
        invoice["notes"] = payload.notes
        
    # Update project spent amount
    project = db_service.get_project_by_id(invoice["project_id"])
    if project:
        project["spent"] = float(project.get("spent", 0)) + float(invoice["amount"])

    # Trigger SendGrid payment receipt notification
    client_name = current_user.get("full_name", "Valued Client")
    client_email = current_user.get("email", "client@aurorainvest.com")
    email_service.send_payment_milestone_invoice(
        client_email=client_email,
        client_name=client_name,
        invoice_number=invoice["invoice_number"],
        milestone_name=invoice["milestone_name"],
        amount=invoice["amount"],
        due_date=invoice["due_date"]
    )

    return {
        "message": f"Payment of ${invoice['amount']:,.2f} recorded successfully for {invoice['invoice_number']}.",
        "invoice": invoice
    }
