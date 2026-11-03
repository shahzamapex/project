from fastapi import APIRouter, Depends, HTTPException
from typing import Dict, Any, List
from core.security import get_current_user
from database.supabase_client import db_service
from services.auth_service import rbac_service
from services.ai_service import ai_engine
from services.email_service import email_service

router = APIRouter(prefix="/analytics", tags=["AI Predictive Analytics"])

@router.get("/predict-delays/{project_id}")
def predict_project_delays(project_id: str, trigger_email_if_critical: bool = False, current_user: Dict[str, Any] = Depends(get_current_user)):
    """
    AI Predictive Analytics Engine:
    Evaluates real-time engineer progress, task completion, and trade velocity with Scikit-Learn.
    Assesses task progress against deadlines, automatically flags site delays, and provides resource allocation recommendations.
    """
    rbac_service.enforce_role(current_user, ["owner", "engineer"])
    prediction = ai_engine.assess_project_prediction(project_id)
    
    if "error" in prediction:
        raise HTTPException(status_code=404, detail=prediction["error"])
        
    # Trigger SendGrid AI Risk Warning if requested or if overall delay probability is critical (> 50%)
    if trigger_email_if_critical and prediction["overall_delay_probability"] > 40.0:
        first_rec = prediction["recommendations"][0]["action"] if prediction["recommendations"] else "Review critical path tasks."
        email_service.send_ai_delay_warning(
            owner_email="owner@interiorcraft.com",
            project_title=prediction["project_title"],
            delay_days=prediction["days_variance"],
            delay_probability=prediction["overall_delay_probability"],
            recommendation=first_rec
        )

    return prediction

@router.get("/company-overview")
def get_company_overview(current_user: Dict[str, Any] = Depends(get_current_user)):
    """Executive metrics for Owner dashboard."""
    rbac_service.enforce_role(current_user, ["owner"])
    projects = db_service.get_projects()
    tasks = db_service.get_tasks()
    inventory = db_service.get_inventory()
    invoices = db_service.get_invoices()

    total_budget = sum(p.get("budget", 0) for p in projects)
    total_spent = sum(p.get("spent", 0) for p in projects)
    total_revenue_collected = sum(i.get("amount", 0) for i in invoices if i.get("status") == "Paid")
    
    low_stock_count = sum(1 for item in inventory if item.get("status") in ["Low Stock", "Out of Stock"])
    completed_tasks = sum(1 for t in tasks if t.get("status") == "Completed")
    in_progress_tasks = sum(1 for t in tasks if t.get("status") == "In Progress")

    # Run AI analysis on active projects to obtain aggregate risk
    active_projects = [p for p in projects if p["status"] == "In Progress"]
    project_predictions = [ai_engine.assess_project_prediction(p["id"]) for p in active_projects]
    avg_company_delay_risk = round(sum(p["overall_delay_probability"] for p in project_predictions) / max(1, len(project_predictions)), 1)

    return {
        "active_projects_count": len(active_projects),
        "total_projects_count": len(projects),
        "total_budget": total_budget,
        "total_spent": total_spent,
        "total_revenue_collected": total_revenue_collected,
        "burn_rate_percent": round((total_spent / max(1, total_budget)) * 100, 1),
        "tasks_summary": {
            "total": len(tasks),
            "completed": completed_tasks,
            "in_progress": in_progress_tasks,
            "completion_rate_percent": round((completed_tasks / max(1, len(tasks))) * 100, 1)
        },
        "inventory_alerts_count": low_stock_count,
        "avg_company_delay_risk": avg_company_delay_risk,
        "active_sites_count": len(db_service.sites),
        "predictions_summary": project_predictions
    }
