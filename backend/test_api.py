import sys
import os
import json

# Ensure backend root is in sys.path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def run_tests():
    print("=" * 60)
    print("RUNNING BACKEND TEST SUITE FOR INTERIORCRAFT PLATFORM")
    print("=" * 60)

    # 1. Health & Root
    print("\n[1/7] Testing Root & Health Check...")
    r = client.get("/")
    assert r.status_code == 200, f"Root failed: {r.text}"
    print(" -> Root endpoint status 200: OK")

    r = client.get("/health")
    assert r.status_code == 200, f"Health check failed: {r.text}"
    print(" -> Health check status 200: OK")

    # 2. Authentication & Dynamic RBAC
    print("\n[2/7] Testing Auth & RBAC...")
    login_resp = client.post("/api/auth/login", json={"email": "owner@interiorcraft.com", "password": "password123"})
    assert login_resp.status_code == 200, f"Login failed: {login_resp.text}"
    auth_data = login_resp.json()
    token = auth_data["access_token"]
    role = auth_data["user"]["role"]
    permissions = auth_data["permissions"]
    print(f" -> Authenticated as {role.upper()}: Token generated.")
    print(f" -> Active permissions for {role}: {permissions}")
    headers = {"Authorization": f"Bearer {token}"}

    # Test dynamic role assignment
    print(" -> Testing Dynamic Role Assignment by Owner...")
    assign_resp = client.post(
        "/api/auth/assign-role",
        headers=headers,
        json={"target_user_id": "u-eng-002", "new_role": "owner"}
    )
    assert assign_resp.status_code == 200, f"Role assignment failed: {assign_resp.text}"
    print(f" -> Role dynamically assigned: {assign_resp.json()['message']}")

    # 3. Project Management
    print("\n[3/7] Testing Project Management...")
    proj_resp = client.get("/api/projects", headers=headers)
    assert proj_resp.status_code == 200
    projects = proj_resp.json()
    print(f" -> Successfully retrieved {len(projects)} projects.")
    first_proj_id = projects[0]["id"]
    print(f" -> Primary Project: {projects[0]['title']} (Budget: ${projects[0]['budget']:,.2f})")

    # 4. Scikit-Learn AI Predictive Analytics Engine
    print("\n[4/7] Testing Scikit-Learn AI Delay Prediction & Resource Allocation...")
    ai_resp = client.get(f"/api/analytics/predict-delays/{first_proj_id}", headers=headers)
    assert ai_resp.status_code == 200, f"AI analysis failed: {ai_resp.text}"
    ai_data = ai_resp.json()
    print(f" -> Project Health Score: {ai_data['health_score']}/100")
    print(f" -> Overall Delay Probability: {ai_data['overall_delay_probability']}%")
    print(f" -> Predicted Schedule Variance: +{ai_data['days_variance']} days")
    print(f" -> Critical Path Tasks Flagged: {len(ai_data['critical_path_tasks'])}")
    print(f" -> Generated AI Recommendations ({len(ai_data['recommendations'])}):")
    for rec in ai_data["recommendations"]:
        print(f"     [{rec['severity'].upper()}] {rec['title']}: {rec['action']}")

    # 5. OCR Task Automation Engine
    print("\n[5/7] Testing OCR Task Automation...")
    sample_pdf_text = b"""
    ARCHITECTURAL SPECIFICATION PUNCH LIST: PENTHOUSE 42
    1. Verify bookmatched Calacatta Viola slabs for kitchen island - 4 days - Critical
    2. Recessed plaster cove LED extrusion channels - 3 days - High
    3. Install Dornbracht Tara brushed brass concealed thermostatic mixers - 2 days - Medium
    4. Fit acoustic felt panels in master screening room - 5 days - Medium
    """
    files = {"file": ("punch_list_specs.txt", sample_pdf_text, "text/plain")}
    data = {"project_id": first_proj_id, "auto_save": "true"}
    ocr_resp = client.post("/api/tasks/upload-ocr", headers=headers, files=files, data=data)
    assert ocr_resp.status_code == 200, f"OCR endpoint failed: {ocr_resp.text}"
    ocr_result = ocr_resp.json()
    print(f" -> Document: {ocr_result['document_name']}")
    print(f" -> Extraction Method: {ocr_result['extraction_method']}")
    print(f" -> Tasks Detected & Auto-Saved: {ocr_result['tasks_detected_count']}")
    for t in ocr_result["tasks"][:3]:
        print(f"     - [{t['priority']}] {t['title']} (Due: {t['due_date']})")

    # 6. Inventory & Warehouse System
    print("\n[6/7] Testing Warehouse Inventory & Stock Dispatch...")
    inv_resp = client.get("/api/inventory", headers=headers)
    assert inv_resp.status_code == 200
    inv_items = inv_resp.json()
    print(f" -> Total SKUs in Warehouse: {len(inv_items)}")
    
    # Record dispatch
    first_item = inv_items[0]
    tx_resp = client.post(
        "/api/inventory/transactions",
        headers=headers,
        json={
            "item_id": first_item["id"],
            "project_id": first_proj_id,
            "transaction_type": "OUT_DISPATCH",
            "quantity": 2,
            "notes": "Dispatched to site for island fabrication"
        }
    )
    assert tx_resp.status_code == 201
    print(f" -> Dispatched 2 units of '{first_item['name']}'. New stock: {tx_resp.json()['updated_inventory_item']['quantity']}")

    # 7. Client Portal & Invoicing
    print("\n[7/8] Testing Client Portal & Invoices...")
    appr_resp = client.get(f"/api/client-portal/approvals?project_id={first_proj_id}", headers=headers)
    assert appr_resp.status_code == 200
    approvals = appr_resp.json()
    print(f" -> Client Design Approvals: {len(approvals)} records")
    
    inv_resp = client.get(f"/api/client-portal/invoices?project_id={first_proj_id}", headers=headers)
    assert inv_resp.status_code == 200
    invoices = inv_resp.json()
    pending_invoice = next((i for i in invoices if i["status"] == "Pending"), None)
    if pending_invoice:
        pay_resp = client.post(
            f"/api/client-portal/invoices/{pending_invoice['id']}/pay",
            headers=headers,
            json={"payment_method": "Wire Transfer (JPMorgan)", "notes": "Approved by client"}
        )
        assert pay_resp.status_code == 200
        print(f" -> Milestone invoice '{pending_invoice['invoice_number']}' paid successfully. Notification triggered.")

    # 8. Advanced Inventory-to-Site Fulfillment & Installation Tracking (MRP Module)
    print("\n[8/8] Testing Inventory-to-Site Fulfillment & Installation Tracking (MRP)...")
    
    # 8.1 Ingest site material specification
    print(" -> Ingesting site material requirement via POST /api/v1/projects/{id}/materials...")
    ingest_resp = client.post(
        f"/api/v1/projects/{first_proj_id}/materials",
        headers=headers,
        json={
            "item_name": "American Black Walnut Veneer Panels",
            "item_category": "Finishes & Paint",
            "specification_details": {"location": "Master Lounge", "finish": "Matte Polyurethane"},
            "required_quantity": 5.0
        }
    )
    assert ingest_resp.status_code == 201, f"Ingest failed: {ingest_resp.text}"
    req_data = ingest_resp.json()
    req_id = req_data["id"]
    print(f"    Created requirement '{req_data['item_name']}' (ID: {req_id}, Required: {req_data['required_quantity']})")

    # 8.2 Test Branch A: In-Stock Allocation
    print(" -> Testing Branch A (In-Stock Allocation) via POST /api/v1/materials/{id}/allocate...")
    alloc_resp = client.post(
        f"/api/v1/materials/{req_id}/allocate",
        headers=headers,
        json={"requested_quantity": 5.0}
    )
    assert alloc_resp.status_code == 200, f"Allocate failed: {alloc_resp.text}"
    alloc_result = alloc_resp.json()
    assert alloc_result["branch"] == "IN_STOCK"
    assert alloc_result["fulfillment_status"] == "FULFILLED_WAREHOUSE"
    assert alloc_result["allocation"]["status"] == "RESERVED"
    allocation_id = alloc_result["allocation"]["id"]
    print(f"    Branch A verified! Reserved 5 units. Allocation ID: {allocation_id}, Status: RESERVED")

    # 8.3 Test Branch B: Stock Deficit
    print(" -> Testing Branch B (Stock Deficit) via POST /api/v1/materials/{id}/allocate...")
    deficit_ingest = client.post(
        f"/api/v1/projects/{first_proj_id}/materials",
        headers=headers,
        json={
            "item_name": "Flos IC Lights Pendant (Brass Finish)",
            "item_category": "Lighting",
            "specification_details": {"location": "Grand Entry Gallery"},
            "required_quantity": 50.0
        }
    )
    deficit_req_id = deficit_ingest.json()["id"]
    deficit_alloc_resp = client.post(
        f"/api/v1/materials/{deficit_req_id}/allocate",
        headers=headers,
        json={"requested_quantity": 50.0}
    )
    assert deficit_alloc_resp.status_code == 200
    deficit_result = deficit_alloc_resp.json()
    assert deficit_result["branch"] == "STOCK_DEFICIT"
    assert deficit_result["fulfillment_status"] == "PROCUREMENT_PENDING"
    assert "purchase_order" in deficit_result
    print(f"    Branch B verified! Deficit detected ({deficit_result['deficit_quantity']} units). Status: PROCUREMENT_PENDING. PO: {deficit_result['purchase_order']['po_number']}")

    # 8.4 Test Dispatch Allocation (Gate Pass generated, stock decremented)
    print(" -> Testing Dispatch via POST /api/v1/allocations/{id}/dispatch...")
    dispatch_resp = client.post(
        f"/api/v1/allocations/{allocation_id}/dispatch",
        headers=headers,
        json={"gate_pass_number": "GP-2026-TEST-99"}
    )
    assert dispatch_resp.status_code == 200
    dispatch_result = dispatch_resp.json()
    assert dispatch_result["allocation"]["status"] == "DISPATCHED_TO_SITE"
    print(f"    Dispatch verified! Status: DISPATCHED_TO_SITE under Gate Pass {dispatch_result['gate_pass_number']}")

    # 8.5 Test Site Engineer Installation Confirmation
    print(" -> Testing Site Engineer Fitment Confirmation via POST /api/v1/materials/{id}/confirm-installation...")
    install_resp = client.post(
        f"/api/v1/materials/{req_id}/confirm-installation",
        headers=headers,
        json={
            "quantity": 5.0,
            "notes": "Fastened and aligned to gallery perimeter framing with concealed clips.",
            "proof_attachment_url": "https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600"
        }
    )
    assert install_resp.status_code == 200
    install_result = install_resp.json()
    assert install_result["installation_status"] == "INSTALLED_CONFIRMED"
    print(f"    Installation confirmed! Requirement Status: INSTALLED_CONFIRMED. Installed: {install_result['installed_quantity']} units.")

    print("\n" + "=" * 60)
    print("ALL 8 TEST SUITES (INCLUDING ADVANCED MRP MODULE) PASSED FLAWLESSLY!")
    print("============================================================")

if __name__ == "__main__":
    run_tests()

