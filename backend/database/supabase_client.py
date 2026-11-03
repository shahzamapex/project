import os
import uuid
from datetime import datetime, date, timedelta
from typing import Dict, List, Any, Optional
from core.config import settings

try:
    from supabase import create_client, Client
    SUPABASE_LIB_AVAILABLE = True
except ImportError:
    SUPABASE_LIB_AVAILABLE = False
    Client = Any

class SupabaseService:
    def __init__(self):
        self.is_connected = False
        self.client: Optional[Client] = None
        self._init_connection()
        # Resilient local state store initialized with interior design seed data
        self._init_mock_store()

    def _init_connection(self):
        url = (settings.SUPABASE_URL or "").strip()
        key = (settings.SUPABASE_KEY or "").strip()
        if SUPABASE_LIB_AVAILABLE and url and key and not url.startswith("https://your-") and "your-supabase" not in key:
            try:
                self.client = create_client(url, key)
                self.is_connected = True
                print(f"[Supabase] Connected to live Supabase instance: {url}")
            except Exception as e:
                self.is_connected = False
                print(f"[Supabase] Failed to connect to live Supabase: {e}. Falling back to resilient local store.")
        else:
            self.is_connected = False

    def check_connection(self) -> Dict[str, Any]:
        url = (settings.SUPABASE_URL or "").strip()
        is_placeholder = url.startswith("https://your-") or not url or "your-supabase" in (settings.SUPABASE_KEY or "")
        if is_placeholder:
            return {
                "connected": False,
                "supabase_url": url or "Not configured",
                "status": "using_mock_fallback",
                "message": "Supabase credentials are placeholder. Set SUPABASE_URL and SUPABASE_KEY in backend/.env or Vercel Environment Variables."
            }
        
        if not self.is_connected or not self.client:
            self._init_connection()

        if not self.is_connected or not self.client:
            return {
                "connected": False,
                "supabase_url": url,
                "status": "connection_failed",
                "message": "Unable to initialize Supabase client with current credentials."
            }

        try:
            res = self.client.table("projects").select("id").limit(1).execute()
            return {
                "connected": True,
                "supabase_url": url,
                "status": "connected_live",
                "message": "Successfully connected to live Supabase PostgreSQL database.",
                "sample_count": len(res.data) if res.data else 0
            }
        except Exception as e:
            return {
                "connected": True,
                "supabase_url": url,
                "status": "connected_schema_pending",
                "warning": str(e),
                "message": f"Connected to Supabase client, but query returned: {e}. Please ensure backend/database/schema.sql has been executed in the Supabase SQL editor."
            }

    def _init_mock_store(self):
        """Seed rich domain data for interior design company demo & development."""
        self.users = [
            {"id": "u-owner-001", "email": "owner@interiorcraft.com", "full_name": "Elena Vance", "role": "owner", "phone": "+1 (555) 234-5678", "avatar_url": "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150"},
            {"id": "u-eng-001", "email": "marcus.lee@interiorcraft.com", "full_name": "Marcus Lee", "role": "engineer", "phone": "+1 (555) 876-5432", "avatar_url": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150"},
            {"id": "u-eng-002", "email": "sarah.chen@interiorcraft.com", "full_name": "Sarah Chen", "role": "engineer", "phone": "+1 (555) 432-1098", "avatar_url": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150"},
            {"id": "u-client-001", "email": "david.sterling@aurorainvest.com", "full_name": "David Sterling", "role": "client", "phone": "+1 (555) 998-1122", "avatar_url": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150"},
            {"id": "u-client-002", "email": "claire.fontaine@voguerealty.com", "full_name": "Claire Fontaine", "role": "client", "phone": "+1 (555) 334-7766", "avatar_url": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150"},
        ]

        self.roles_permissions = [
            {"role": "owner", "permission": "all_access", "description": "Full access to all modules and system settings"},
            {"role": "owner", "permission": "manage_users", "description": "Assign roles, modify user access and permissions"},
            {"role": "owner", "permission": "view_analytics", "description": "Access AI predictive models and company financials"},
            {"role": "engineer", "permission": "view_assigned_sites", "description": "Access assigned sites and blueprints"},
            {"role": "engineer", "permission": "update_site_progress", "description": "Submit task completion and site logs"},
            {"role": "engineer", "permission": "annotate_drawings", "description": "Create and edit drawing markups"},
            {"role": "client", "permission": "view_project_portal", "description": "View progress, moodboards, and renders"},
            {"role": "client", "permission": "approve_designs", "description": "Sign off on designs or request revisions"},
            {"role": "client", "permission": "view_invoices", "description": "View and pay milestone invoices"},
        ]

        self.projects = [
            {
                "id": "proj-001",
                "title": "Skyline Penthouse 42 - Tribeca",
                "client_id": "u-client-001",
                "client_name": "David Sterling",
                "status": "In Progress",
                "budget": 485000.00,
                "spent": 248000.00,
                "start_date": "2026-09-01",
                "target_end_date": "2026-12-15",
                "progress_percent": 68,
                "site_address": "450 Greenwich St, Penthouse B, New York, NY",
                "description": "High-end minimalist bespoke residence featuring Calacatta marble finishes, custom walnut millwork, smart Lutron lighting, and floor-to-ceiling Italian glass partitions.",
                "created_at": "2026-09-01T08:00:00Z"
            },
            {
                "id": "proj-002",
                "title": "Atelier Fontaine Haute Couture Showroom",
                "client_id": "u-client-002",
                "client_name": "Claire Fontaine",
                "status": "In Progress",
                "budget": 320000.00,
                "spent": 115000.00,
                "start_date": "2026-10-10",
                "target_end_date": "2027-01-20",
                "progress_percent": 42,
                "site_address": "820 Madison Ave, Floor 3, New York, NY",
                "description": "Parisian neoclassical aesthetic with brass bespoke fixtures, acoustic herringbone oak parquet, velvet dressing suites, and integrated architectural runway lighting.",
                "created_at": "2026-10-10T09:30:00Z"
            },
            {
                "id": "proj-003",
                "title": "Villa Seraphina - Hudson Valley Retreat",
                "client_id": "u-client-001",
                "client_name": "David Sterling",
                "status": "Planning",
                "budget": 750000.00,
                "spent": 45000.00,
                "start_date": "2026-11-15",
                "target_end_date": "2027-05-30",
                "progress_percent": 15,
                "site_address": "120 Whispering Pines Rd, Rhinebeck, NY",
                "description": "Sustainable modern sanctuary blending brutalist poured concrete, reclaimed cedar beams, geothermal HVAC, and Japanese garden courtyards.",
                "created_at": "2026-10-25T11:00:00Z"
            }
        ]

        self.sites = [
            {
                "id": "site-001",
                "project_id": "proj-001",
                "name": "Penthouse 42 - Main Residence",
                "location": "Tribeca, NY",
                "engineer_id": "u-eng-001",
                "status": "Active",
                "last_inspection_date": "2026-11-01T14:00:00Z",
                "notes": "Custom walnut cabinetry installation underway in master dressing room. HVAC diffuser grilles inspected."
            },
            {
                "id": "site-002",
                "project_id": "proj-002",
                "name": "Madison Ave Showroom Suite",
                "location": "Upper East Side, NY",
                "engineer_id": "u-eng-002",
                "status": "Active",
                "last_inspection_date": "2026-10-29T10:30:00Z",
                "notes": "Herringbone parquet subfloor leveled and moisture-barrier tested. Ready for brass trim alignment."
            }
        ]

        self.tasks = [
            {"id": "task-101", "project_id": "proj-001", "site_id": "site-001", "title": "Inspect Calacatta Viola Marble slabs upon delivery", "description": "Verify slab veining continuity and bookmatch alignment for kitchen waterfall island.", "assigned_to": "u-eng-001", "priority": "High", "status": "Completed", "planned_days": 2, "actual_days": 2, "due_date": "2026-10-15", "completion_percent": 100, "source_document": "Procurement_Spec_v2.pdf", "confidence_score": 98.5},
            {"id": "task-102", "project_id": "proj-001", "site_id": "site-001", "title": "Install concealed Lutron Palladiom motorized shading", "description": "Recessed ceiling pocket wiring and sensor alignment in master suite.", "assigned_to": "u-eng-001", "priority": "Medium", "status": "In Progress", "planned_days": 4, "actual_days": 5, "due_date": "2026-11-06", "completion_percent": 75, "source_document": "Electrical_Lighting_Plan.pdf", "confidence_score": 94.0},
            {"id": "task-103", "project_id": "proj-001", "site_id": "site-001", "title": "Custom fluted walnut paneling in living gallery", "description": "Millwork fastening and acoustic backing installation.", "assigned_to": "u-eng-001", "priority": "High", "status": "In Progress", "planned_days": 6, "actual_days": 7, "due_date": "2026-11-08", "completion_percent": 60, "source_document": "Millwork_Specs_DWG.pdf", "confidence_score": 96.2},
            {"id": "task-104", "project_id": "proj-001", "site_id": "site-001", "title": "Apply microcement finish to guest powder room", "description": "Three-coat seamless artisanal waterproof microcement with matte polyurethane sealer.", "assigned_to": "u-eng-001", "priority": "Medium", "status": "To Do", "planned_days": 3, "actual_days": 0, "due_date": "2026-11-12", "completion_percent": 0, "source_document": "Finishes_Schedule.pdf", "confidence_score": 92.8},
            {"id": "task-105", "project_id": "proj-002", "site_id": "site-002", "title": "Mount brass architectural showcase racks", "description": "Anchor brushed champagne brass hanging rails to reinforced perimeter studs.", "assigned_to": "u-eng-002", "priority": "High", "status": "In Progress", "planned_days": 3, "actual_days": 2, "due_date": "2026-11-05", "completion_percent": 50, "source_document": "Showroom_Fixture_BOQ.pdf", "confidence_score": 97.0},
            {"id": "task-106", "project_id": "proj-002", "site_id": "site-002", "title": "Acoustic ceiling paneling in VIP fitting lounges", "description": "Kvadrat upholstered acoustical baffles with integrated LED edge glow.", "assigned_to": "u-eng-002", "priority": "Medium", "status": "To Do", "planned_days": 4, "actual_days": 0, "due_date": "2026-11-18", "completion_percent": 0, "source_document": "Acoustic_Report_v1.pdf", "confidence_score": 89.4},
        ]

        self.drawings = [
            {
                "id": "dwg-001",
                "project_id": "proj-001",
                "title": "Architectural Plan - Penthouse Floor 42 Layout",
                "revision": "Rev C",
                "sheet_number": "A-102",
                "file_url": "https://raw.githubusercontent.com/mozilla/pdf.js/ba2edeae/web/compressed.tracemonkey-pldi-09.pdf",
                "file_type": "application/pdf",
                "uploaded_by": "u-owner-001",
                "created_at": "2026-09-05T10:00:00Z"
            },
            {
                "id": "dwg-002",
                "project_id": "proj-001",
                "title": "Reflected Ceiling & Lighting Blueprint",
                "revision": "Rev B",
                "sheet_number": "E-201",
                "file_url": "https://raw.githubusercontent.com/mozilla/pdf.js/ba2edeae/web/compressed.tracemonkey-pldi-09.pdf",
                "file_type": "application/pdf",
                "uploaded_by": "u-eng-001",
                "created_at": "2026-09-12T14:30:00Z"
            },
            {
                "id": "dwg-003",
                "project_id": "proj-002",
                "title": "Bespoke Fixture Millwork Section & Elevations",
                "revision": "Rev A",
                "sheet_number": "ID-304",
                "file_url": "https://raw.githubusercontent.com/mozilla/pdf.js/ba2edeae/web/compressed.tracemonkey-pldi-09.pdf",
                "file_type": "application/pdf",
                "uploaded_by": "u-owner-001",
                "created_at": "2026-10-15T11:20:00Z"
            }
        ]

        self.drawing_markups = [
            {
                "id": "mk-001",
                "drawing_id": "dwg-001",
                "author_id": "u-eng-001",
                "author_name": "Marcus Lee",
                "author_role": "engineer",
                "layer_data": {
                    "strokes": [
                        {"tool": "cloud", "color": "#E53E3E", "stroke_width": 3.0, "points": [{"x": 120.0, "y": 240.0}, {"x": 310.0, "y": 240.0}, {"x": 310.0, "y": 380.0}, {"x": 120.0, "y": 380.0}]},
                        {"tool": "pen", "color": "#D4AF37", "stroke_width": 2.5, "points": [{"x": 310.0, "y": 310.0}, {"x": 380.0, "y": 350.0}]},
                    ],
                    "annotations": [
                        {"id": "note-1", "x": 385.0, "y": 350.0, "text": "Re-check plumbing chase clearance for Dornbracht wall valve.", "color": "#E53E3E"}
                    ]
                },
                "comment": "Site structural column dimensions require 40mm offset from original CAD spec.",
                "created_at": "2026-10-28T16:15:00Z"
            }
        ]

        self.inventory_items = [
            {"id": "inv-001", "sku": "MRB-CAL-01", "name": "Calacatta Viola Marble Slabs (20mm)", "category": "Flooring & Marble", "quantity": 18, "total_stock": 18.0, "reserved_stock": 2.0, "available_stock": 16.0, "unit": "slabs", "min_threshold": 6, "unit_price": 2850.00, "warehouse_zone": "Zone A-Heavy", "status": "In Stock"},
            {"id": "inv-002", "sku": "WD-WAL-92", "name": "American Black Walnut Veneer Panels", "category": "Finishes & Paint", "quantity": 42, "total_stock": 42.0, "reserved_stock": 10.0, "available_stock": 32.0, "unit": "sheets", "min_threshold": 15, "unit_price": 195.00, "warehouse_zone": "Zone B-Wood", "status": "In Stock"},
            {"id": "inv-003", "sku": "LGT-FLS-08", "name": "Flos IC Lights Pendant (Brass Finish)", "category": "Lighting", "quantity": 4, "total_stock": 4.0, "reserved_stock": 4.0, "available_stock": 0.0, "unit": "fixtures", "min_threshold": 5, "unit_price": 940.00, "warehouse_zone": "Zone C-Fragile", "status": "Low Stock"},
            {"id": "inv-004", "sku": "FAB-KVD-14", "name": "Kvadrat Steelcut Trio 3 Upholstery Fabric", "category": "Fabrics & Textiles", "quantity": 85, "total_stock": 85.0, "reserved_stock": 0.0, "available_stock": 85.0, "unit": "meters", "min_threshold": 30, "unit_price": 145.00, "warehouse_zone": "Zone D-Textiles", "status": "In Stock"},
            {"id": "inv-005", "sku": "HRD-DBT-44", "name": "Dornbracht Tara Wall-Mounted Mixer (Brushed Brass)", "category": "Hardware & Fixtures", "quantity": 2, "total_stock": 2.0, "reserved_stock": 2.0, "available_stock": 0.0, "unit": "sets", "min_threshold": 4, "unit_price": 1680.00, "warehouse_zone": "Zone E-Plumbing", "status": "Low Stock"},
            {"id": "inv-006", "sku": "FNT-MIN-21", "name": "Minotti Freeman Custom Sectional Modular Base", "category": "Furniture", "quantity": 1, "total_stock": 1.0, "reserved_stock": 0.0, "available_stock": 1.0, "unit": "units", "min_threshold": 1, "unit_price": 18500.00, "warehouse_zone": "Zone A-Furniture", "status": "In Stock"},
        ]

        # 5A. Site Bill of Materials (Material Requirements Planning)
        self.site_material_requirements = [
            {
                "id": "req-001",
                "project_id": "proj-001",
                "item_name": "Calacatta Viola Bookmatched Marble Slabs (20mm)",
                "item_category": "Flooring & Marble",
                "specification_details": {"finish": "Honed", "slab_thickness": "20mm", "location": "Chef Kitchen Island", "supplier": "Carrara Stone SpA"},
                "required_quantity": 6.0,
                "allocated_quantity": 6.0,
                "installed_quantity": 0.0,
                "fulfillment_status": "FULFILLED_WAREHOUSE",
                "installation_status": "PENDING_DELIVERY",
                "created_at": "2026-10-12T09:00:00Z",
                "updated_at": "2026-10-14T10:00:00Z"
            },
            {
                "id": "req-002",
                "project_id": "proj-001",
                "item_name": "American Black Walnut Veneer Panels",
                "item_category": "Finishes & Paint",
                "specification_details": {"pattern": "Fluted Acoustic", "fire_rating": "Class A", "location": "Living Gallery", "finish": "Matte Polyurethane"},
                "required_quantity": 30.0,
                "allocated_quantity": 30.0,
                "installed_quantity": 15.0,
                "fulfillment_status": "FULFILLED_WAREHOUSE",
                "installation_status": "PENDING_DELIVERY",
                "created_at": "2026-10-15T11:00:00Z",
                "updated_at": "2026-10-28T16:00:00Z"
            },
            {
                "id": "req-003",
                "project_id": "proj-001",
                "item_name": "Flos IC Lights Pendant (Brass Finish)",
                "item_category": "Lighting",
                "specification_details": {"voltage": "120V", "cct": "2700K Warm", "location": "Dining Pavilion", "dimming": "0-10V Lutron"},
                "required_quantity": 8.0,
                "allocated_quantity": 4.0,
                "installed_quantity": 0.0,
                "fulfillment_status": "PROCUREMENT_PENDING",
                "installation_status": "PENDING_DELIVERY",
                "created_at": "2026-10-20T14:00:00Z",
                "updated_at": "2026-10-20T14:30:00Z"
            },
            {
                "id": "req-004",
                "project_id": "proj-001",
                "item_name": "Dornbracht Tara Wall-Mounted Mixer (Brushed Brass)",
                "item_category": "Hardware & Fixtures",
                "specification_details": {"finish": "Brushed Durabrass", "rough_in": "35 707 970-90", "location": "Powder Room Suite"},
                "required_quantity": 4.0,
                "allocated_quantity": 2.0,
                "installed_quantity": 0.0,
                "fulfillment_status": "PROCUREMENT_PENDING",
                "installation_status": "PENDING_DELIVERY",
                "created_at": "2026-10-22T08:30:00Z",
                "updated_at": "2026-10-22T09:00:00Z"
            },
            {
                "id": "req-005",
                "project_id": "proj-001",
                "item_name": "Kvadrat Steelcut Trio 3 Upholstery Fabric",
                "item_category": "Fabrics & Textiles",
                "specification_details": {"color_code": "0133 Charcoal Beige", "rub_count": "100000 Martindale", "location": "VIP Screening Lounge"},
                "required_quantity": 40.0,
                "allocated_quantity": 0.0,
                "installed_quantity": 0.0,
                "fulfillment_status": "UNFULFILLED",
                "installation_status": "PENDING_DELIVERY",
                "created_at": "2026-10-25T10:00:00Z",
                "updated_at": "2026-10-25T10:00:00Z"
            }
        ]

        # 5B. Material Allocations (Junction / Audit Ledger)
        self.material_allocations = [
            {
                "id": "alloc-001",
                "requirement_id": "req-001",
                "inventory_item_id": "inv-001",
                "item_name": "Calacatta Viola Marble Slabs (20mm)",
                "project_id": "proj-001",
                "allocated_quantity": 6.0,
                "status": "DISPATCHED_TO_SITE",
                "allocated_by": "u-owner-001",
                "installed_by": None,
                "proof_attachment_url": None,
                "gate_pass_number": "GP-2026-081",
                "notes": "Full waterfall slab lot dispatched via Flatbed Transporter",
                "created_at": "2026-10-14T08:30:00Z",
                "updated_at": "2026-10-14T11:00:00Z"
            },
            {
                "id": "alloc-002",
                "requirement_id": "req-002",
                "inventory_item_id": "inv-002",
                "item_name": "American Black Walnut Veneer Panels",
                "project_id": "proj-001",
                "allocated_quantity": 30.0,
                "status": "DISPATCHED_TO_SITE",
                "allocated_by": "u-owner-001",
                "installed_by": "u-eng-001",
                "proof_attachment_url": "https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600",
                "gate_pass_number": "GP-2026-082",
                "notes": "15 panels confirmed installed on gallery partition framing",
                "created_at": "2026-10-18T09:15:00Z",
                "updated_at": "2026-10-28T16:00:00Z"
            },
            {
                "id": "alloc-003",
                "requirement_id": "req-003",
                "inventory_item_id": "inv-003",
                "item_name": "Flos IC Lights Pendant (Brass Finish)",
                "project_id": "proj-001",
                "allocated_quantity": 4.0,
                "status": "RESERVED",
                "allocated_by": "u-owner-001",
                "installed_by": None,
                "proof_attachment_url": None,
                "gate_pass_number": None,
                "notes": "Reserved in Zone C-Fragile pending Site Ceiling grid inspection",
                "created_at": "2026-10-20T14:30:00Z",
                "updated_at": "2026-10-20T14:30:00Z"
            }
        ]

        self.warehouse_transactions = [
            {"id": "tx-001", "item_id": "inv-001", "project_id": "proj-001", "transaction_type": "OUT_DISPATCH", "quantity": 6, "date": "2026-10-14", "recorded_by": "u-eng-001", "notes": "Dispatched to Tribeca Penthouse for master kitchen island fabrication"},
            {"id": "tx-002", "item_id": "inv-003", "project_id": "proj-001", "transaction_type": "IN_RESTOCK", "quantity": 8, "date": "2026-10-20", "recorded_by": "u-owner-001", "notes": "Air shipment received from Milan warehouse"},
        ]

        self.client_approvals = [
            {
                "id": "appr-001",
                "project_id": "proj-001",
                "title": "Master Living Pavilion 3D Photorealistic Render",
                "stage": "3D Render",
                "media_url": "https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=1200",
                "description": "Showcasing the custom floor-to-ceiling walnut gallery wall, limestone hearth fireplace, and integrated ambient cove lighting.",
                "status": "Approved",
                "client_feedback": "The walnut warmth and fireplace stone choice are sublime. Approved for millwork cutting.",
                "submitted_at": "2026-10-18T11:00:00Z",
                "responded_at": "2026-10-19T14:30:00Z"
            },
            {
                "id": "appr-002",
                "project_id": "proj-001",
                "title": "Chef Kitchen Calacatta Viola Waterfall Island & Cabinetry",
                "stage": "Material Palette",
                "media_url": "https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=1200",
                "description": "Matching the deep burgundy veining of Calacatta Viola marble with brushed brass handleless reveals and fluted smoked glass uppers.",
                "status": "Approved",
                "client_feedback": "Stunning veining selection. Make sure edges are mitered at 45 degrees.",
                "submitted_at": "2026-10-22T09:00:00Z",
                "responded_at": "2026-10-23T16:00:00Z"
            },
            {
                "id": "appr-003",
                "project_id": "proj-002",
                "title": "Showroom Central Runway & Brass Display Modules",
                "stage": "3D Render",
                "media_url": "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200",
                "description": "Illuminated floating display rails, herringbone white oak floor layout, and fluted acoustic champagne archways.",
                "status": "Pending",
                "client_feedback": "",
                "submitted_at": "2026-10-30T15:00:00Z",
                "responded_at": None
            }
        ]

        self.invoices_payments = [
            {"id": "invp-001", "project_id": "proj-001", "invoice_number": "INV-2026-101", "milestone_name": "Milestone 1: Architectural Concept & Design Sign-off", "amount": 120000.00, "due_date": "2026-09-15", "status": "Paid", "paid_at": "2026-09-14T10:15:00Z", "payment_method": "Wire Transfer (Chase Bank)", "notes": "Received and credited."},
            {"id": "invp-002", "project_id": "proj-001", "invoice_number": "INV-2026-102", "milestone_name": "Milestone 2: Rough-In Mechanical, Electrical & Drywall Complete", "amount": 145000.00, "due_date": "2026-10-30", "status": "Paid", "paid_at": "2026-10-28T14:40:00Z", "payment_method": "Wire Transfer (Chase Bank)", "notes": "Approved upon site inspection."},
            {"id": "invp-003", "project_id": "proj-001", "invoice_number": "INV-2026-103", "milestone_name": "Milestone 3: Millwork, Marble Cladding & Lighting Fixture Delivery", "amount": 130000.00, "due_date": "2026-11-20", "status": "Pending", "paid_at": None, "payment_method": None, "notes": "Due upon completion of living pavilion millwork."},
            {"id": "invp-004", "project_id": "proj-002", "invoice_number": "INV-2026-201", "milestone_name": "Milestone 1: Haute Couture Space Planning & Material Procurement", "amount": 95000.00, "due_date": "2026-10-25", "status": "Paid", "paid_at": "2026-10-24T18:00:00Z", "payment_method": "ACH Direct", "notes": "Received in full."},
            {"id": "invp-005", "project_id": "proj-002", "invoice_number": "INV-2026-202", "milestone_name": "Milestone 2: Brass Architectural Millwork & Parquet Installation", "amount": 110000.00, "due_date": "2026-11-25", "status": "Pending", "paid_at": None, "payment_method": None, "notes": "Pending showroom rough fitting completion."},
        ]

        self.vendors = [
            {"id": "ven-001", "name": "Carrara Stone & Marmi SpA", "contact_person": "Gianluca Rossi", "email": "gianluca@carraramarmi.it", "phone": "+39 0585 84210", "category": "Natural Stone & Marble", "rating": 4.9},
            {"id": "ven-002", "name": "Lutron Architectural Systems", "contact_person": "Amanda Miller", "email": "amiller@lutron-dealers.com", "phone": "+1 (800) 523-9466", "category": "Lighting & Automation", "rating": 4.8},
            {"id": "ven-003", "name": "Dornbracht Fittings Group", "contact_person": "Stefan Bauer", "email": "orders@dornbracht-usa.com", "phone": "+1 (800) 774-1181", "category": "Luxury Plumbing Fixtures", "rating": 4.7},
            {"id": "ven-004", "name": "Atelier Fluted Woodcraft LLC", "contact_person": "Robert Vance", "email": "robert@ateliermillwork.com", "phone": "+1 (212) 555-8833", "category": "Custom Architectural Millwork", "rating": 4.9},
        ]

        self.purchase_orders = [
            {"id": "po-001", "vendor_id": "ven-001", "project_id": "proj-001", "po_number": "PO-2026-8801", "total_amount": 42750.00, "status": "Delivered", "order_date": "2026-09-18", "expected_delivery": "2026-10-12"},
            {"id": "po-002", "vendor_id": "ven-002", "project_id": "proj-001", "po_number": "PO-2026-8802", "total_amount": 26800.00, "status": "Partially Fulfilled", "order_date": "2026-10-02", "expected_delivery": "2026-11-04"},
            {"id": "po-003", "vendor_id": "ven-004", "project_id": "proj-001", "po_number": "PO-2026-8803", "total_amount": 68000.00, "status": "Issued", "order_date": "2026-10-15", "expected_delivery": "2026-11-15"},
        ]

        self.dispatched_emails = []

    # Supabase table helper methods
    def get_projects(self) -> List[Dict[str, Any]]:
        if self.is_connected and self.client:
            try:
                res = self.client.table("projects").select("*").execute()
                if res.data:
                    return res.data
            except Exception as e:
                print(f"[Supabase] get_projects query notice: {e}")
        return self.projects

    def get_project_by_id(self, project_id: str) -> Optional[Dict[str, Any]]:
        if self.is_connected and self.client:
            try:
                res = self.client.table("projects").select("*").eq("id", project_id).execute()
                if res.data:
                    return res.data[0]
            except Exception as e:
                print(f"[Supabase] get_project_by_id query notice: {e}")
        return next((p for p in self.projects if p["id"] == project_id), None)

    def create_project(self, data: Dict[str, Any]) -> Dict[str, Any]:
        data["id"] = data.get("id", f"proj-{str(uuid.uuid4())[:8]}")
        data["created_at"] = datetime.now().isoformat()
        if self.is_connected and self.client:
            try:
                res = self.client.table("projects").insert(data).execute()
                if res.data:
                    return res.data[0]
            except Exception as e:
                print(f"[Supabase] create_project query notice: {e}")
        self.projects.append(data)
        return data

    def update_project(self, project_id: str, updates: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        if self.is_connected and self.client:
            try:
                res = self.client.table("projects").update(updates).eq("id", project_id).execute()
                if res.data:
                    return res.data[0]
            except Exception as e:
                print(f"[Supabase] update_project query notice: {e}")
        proj = self.get_project_by_id(project_id)
        if proj:
            proj.update(updates)
        return proj

    def get_tasks(self, project_id: Optional[str] = None) -> List[Dict[str, Any]]:
        if self.is_connected and self.client:
            try:
                q = self.client.table("tasks").select("*")
                if project_id:
                    q = q.eq("project_id", project_id)
                res = q.execute()
                if res.data:
                    return res.data
            except Exception as e:
                print(f"[Supabase] get_tasks query notice: {e}")
        if project_id:
            return [t for t in self.tasks if t["project_id"] == project_id]
        return self.tasks

    def get_task_by_id(self, task_id: str) -> Optional[Dict[str, Any]]:
        if self.is_connected and self.client:
            try:
                res = self.client.table("tasks").select("*").eq("id", task_id).execute()
                if res.data:
                    return res.data[0]
            except Exception as e:
                print(f"[Supabase] get_task_by_id query notice: {e}")
        return next((t for t in self.tasks if t["id"] == task_id), None)

    def create_task(self, data: Dict[str, Any]) -> Dict[str, Any]:
        data["id"] = data.get("id", f"task-{str(uuid.uuid4())[:8]}")
        data["created_at"] = datetime.now().isoformat()
        data["updated_at"] = datetime.now().isoformat()
        if self.is_connected and self.client:
            try:
                res = self.client.table("tasks").insert(data).execute()
                if res.data:
                    return res.data[0]
            except Exception as e:
                print(f"[Supabase] create_task query notice: {e}")
        self.tasks.append(data)
        return data

    def update_task(self, task_id: str, updates: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        if self.is_connected and self.client:
            try:
                res = self.client.table("tasks").update(updates).eq("id", task_id).execute()
                if res.data:
                    return res.data[0]
            except Exception as e:
                print(f"[Supabase] update_task query notice: {e}")
        task = self.get_task_by_id(task_id)
        if task:
            task.update(updates)
            task["updated_at"] = datetime.now().isoformat()
        return task

    def get_drawings(self, project_id: Optional[str] = None) -> List[Dict[str, Any]]:
        if project_id:
            return [d for d in self.drawings if d["project_id"] == project_id]
        return self.drawings

    def get_markups(self, drawing_id: str) -> List[Dict[str, Any]]:
        return [m for m in self.drawing_markups if m["drawing_id"] == drawing_id]

    def create_markup(self, data: Dict[str, Any]) -> Dict[str, Any]:
        data["id"] = data.get("id", f"mk-{str(uuid.uuid4())[:8]}")
        data["created_at"] = datetime.now().isoformat()
        self.drawing_markups.append(data)
        return data

    def get_inventory(self) -> List[Dict[str, Any]]:
        return self.inventory_items

    def update_inventory_quantity(self, item_id: str, delta: int) -> Optional[Dict[str, Any]]:
        item = next((i for i in self.inventory_items if i["id"] == item_id), None)
        if item:
            item["quantity"] = max(0, item["quantity"] + delta)
            if item["quantity"] == 0:
                item["status"] = "Out of Stock"
            elif item["quantity"] <= item["min_threshold"]:
                item["status"] = "Low Stock"
            else:
                item["status"] = "In Stock"
        return item

    def get_client_approvals(self, project_id: Optional[str] = None) -> List[Dict[str, Any]]:
        if project_id:
            return [a for a in self.client_approvals if a["project_id"] == project_id]
        return self.client_approvals

    def update_approval_status(self, approval_id: str, status: str, feedback: str) -> Optional[Dict[str, Any]]:
        appr = next((a for a in self.client_approvals if a["id"] == approval_id), None)
        if appr:
            appr["status"] = status
            appr["client_feedback"] = feedback
            appr["responded_at"] = datetime.now().isoformat()
        return appr

    def get_invoices(self, project_id: Optional[str] = None) -> List[Dict[str, Any]]:
        if project_id:
            return [i for i in self.invoices_payments if i["project_id"] == project_id]
        return self.invoices_payments

    def get_users(self) -> List[Dict[str, Any]]:
        return self.users

    def update_user_role(self, user_id: str, new_role: str) -> Optional[Dict[str, Any]]:
        user = next((u for u in self.users if u["id"] == user_id), None)
        if user:
            user["role"] = new_role
        return user

    # =========================================================================
    # ADVANCED INVENTORY-TO-SITE FULFILLMENT & INSTALLATION METHODS
    # =========================================================================

    def get_material_requirements(self, project_id: Optional[str] = None) -> List[Dict[str, Any]]:
        results = self.site_material_requirements
        if project_id:
            results = [r for r in results if r["project_id"] == project_id]
        
        # Attach linked active allocations
        enhanced = []
        for req in results:
            req_copy = dict(req)
            req_copy["allocations"] = [a for a in self.material_allocations if a["requirement_id"] == req["id"]]
            enhanced.append(req_copy)
        return enhanced

    def get_requirement_by_id(self, requirement_id: str) -> Optional[Dict[str, Any]]:
        return next((r for r in self.site_material_requirements if r["id"] == requirement_id), None)

    def create_material_requirement(self, data: Dict[str, Any]) -> Dict[str, Any]:
        data["id"] = data.get("id", f"req-{str(uuid.uuid4())[:8]}")
        data["allocated_quantity"] = float(data.get("allocated_quantity", 0.0))
        data["installed_quantity"] = float(data.get("installed_quantity", 0.0))
        data["required_quantity"] = float(data.get("required_quantity", 1.0))
        data["fulfillment_status"] = data.get("fulfillment_status", "UNFULFILLED")
        data["installation_status"] = data.get("installation_status", "PENDING_DELIVERY")
        data["specification_details"] = data.get("specification_details", {})
        data["created_at"] = datetime.now().isoformat()
        data["updated_at"] = datetime.now().isoformat()
        self.site_material_requirements.append(data)
        return data

    def get_allocations(self, requirement_id: Optional[str] = None, status: Optional[str] = None, project_id: Optional[str] = None) -> List[Dict[str, Any]]:
        results = self.material_allocations
        if requirement_id:
            results = [a for a in results if a["requirement_id"] == requirement_id]
        if status:
            results = [a for a in results if a["status"].upper() == status.upper()]
        if project_id:
            results = [a for a in results if a.get("project_id") == project_id]
        return results

    def get_allocation_by_id(self, allocation_id: str) -> Optional[Dict[str, Any]]:
        return next((a for a in self.material_allocations if a["id"] == allocation_id), None)

    def allocate_material_transaction(self, requirement_id: str, requested_quantity: float, allocated_by: str) -> Dict[str, Any]:
        """
        MRP Transaction Logic:
        Query inventory_items, check available_stock >= requested_quantity.
        Branch A (In-Stock): Increment reserved_stock, update fulfillment_status to FULFILLED_WAREHOUSE, insert audit record in material_allocations (RESERVED).
        Branch B (Stock Deficit): Update status to PROCUREMENT_PENDING, auto-generate procurement Purchase Order.
        """
        requirement = self.get_requirement_by_id(requirement_id)
        if not requirement:
            return {"error": f"Material requirement {requirement_id} not found."}

        req_name_lower = requirement["item_name"].lower()
        req_cat_lower = requirement["item_category"].lower()

        # Find matching inventory item
        matched_item = None
        for item in self.inventory_items:
            item_name_lower = item["name"].lower()
            if (req_name_lower in item_name_lower or item_name_lower in req_name_lower or 
                item["category"].lower() == req_cat_lower):
                matched_item = item
                break
        
        # Fallback to first item if none matched
        if not matched_item and self.inventory_items:
            matched_item = self.inventory_items[0]

        available = float(matched_item.get("available_stock", matched_item["total_stock"] - matched_item["reserved_stock"]))

        if available >= requested_quantity:
            # =========================================================================
            # BRANCH A: IN-STOCK (Available stock >= Requested Quantity)
            # =========================================================================
            matched_item["reserved_stock"] = float(matched_item["reserved_stock"]) + requested_quantity
            matched_item["available_stock"] = float(matched_item["total_stock"]) - float(matched_item["reserved_stock"])
            
            requirement["allocated_quantity"] = float(requirement["allocated_quantity"]) + requested_quantity
            if requirement["allocated_quantity"] >= requirement["required_quantity"]:
                requirement["fulfillment_status"] = "FULFILLED_WAREHOUSE"
            requirement["updated_at"] = datetime.now().isoformat()

            new_allocation = {
                "id": f"alloc-{str(uuid.uuid4())[:8]}",
                "requirement_id": requirement["id"],
                "inventory_item_id": matched_item["id"],
                "item_name": matched_item["name"],
                "project_id": requirement["project_id"],
                "allocated_quantity": requested_quantity,
                "status": "RESERVED",
                "allocated_by": allocated_by,
                "installed_by": None,
                "proof_attachment_url": None,
                "gate_pass_number": None,
                "notes": f"Stock reserved in {matched_item['warehouse_zone']} for project site.",
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            self.material_allocations.insert(0, new_allocation)

            return {
                "branch": "IN_STOCK",
                "status": "success",
                "fulfillment_status": requirement["fulfillment_status"],
                "allocation": new_allocation,
                "inventory_item": matched_item,
                "requirement": requirement,
                "message": f"Successfully reserved {requested_quantity} {matched_item['unit']} of '{matched_item['name']}' in {matched_item['warehouse_zone']}."
            }
        else:
            # =========================================================================
            # BRANCH B: STOCK DEFICIT (Available stock < Requested Quantity)
            # =========================================================================
            deficit = requested_quantity - max(0.0, available)
            requirement["fulfillment_status"] = "PROCUREMENT_PENDING"
            requirement["updated_at"] = datetime.now().isoformat()

            # Auto-generate Procurement Purchase Order request
            po_id = f"po-auto-{str(uuid.uuid4())[:6]}"
            auto_po = {
                "id": po_id,
                "vendor_id": "ven-001" if "marble" in req_name_lower else ("ven-002" if "light" in req_name_lower else "ven-004"),
                "project_id": requirement["project_id"],
                "po_number": f"PO-MRP-{datetime.now().strftime('%Y%m')}-{str(uuid.uuid4())[:4].upper()}",
                "total_amount": round(deficit * float(matched_item.get("unit_price", 150.0)), 2),
                "status": "Issued",
                "order_date": datetime.now().strftime("%Y-%m-%d"),
                "expected_delivery": (datetime.now() + timedelta(days=14)).strftime("%Y-%m-%d"),
                "notes": f"Auto-generated MRP Procurement Request for deficit of {deficit} units of '{requirement['item_name']}'."
            }
            self.purchase_orders.insert(0, auto_po)

            return {
                "branch": "STOCK_DEFICIT",
                "status": "procurement_pending",
                "fulfillment_status": "PROCUREMENT_PENDING",
                "available_stock": available,
                "requested_quantity": requested_quantity,
                "deficit_quantity": deficit,
                "purchase_order": auto_po,
                "requirement": requirement,
                "message": f"Stock deficit of {deficit} units detected. Status set to PROCUREMENT_PENDING. Purchase Order {auto_po['po_number']} automatically created."
            }

    def dispatch_allocation(self, allocation_id: str, gate_pass_number: Optional[str] = None) -> Dict[str, Any]:
        """
        Dispatches reserved materials to site:
        Updates status to DISPATCHED_TO_SITE, decrements total_stock and reserved_stock.
        """
        allocation = self.get_allocation_by_id(allocation_id)
        if not allocation:
            return {"error": f"Allocation {allocation_id} not found."}

        if allocation["status"] == "DISPATCHED_TO_SITE":
            return {"message": "Allocation already dispatched.", "allocation": allocation}

        qty = float(allocation["allocated_quantity"])
        gp = gate_pass_number or f"GP-{datetime.now().strftime('%Y%m%d')}-{str(uuid.uuid4())[:4].upper()}"

        allocation["status"] = "DISPATCHED_TO_SITE"
        allocation["gate_pass_number"] = gp
        allocation["updated_at"] = datetime.now().isoformat()

        # Decrement inventory stock
        if allocation.get("inventory_item_id"):
            item = next((i for i in self.inventory_items if i["id"] == allocation["inventory_item_id"]), None)
            if item:
                item["total_stock"] = max(0.0, float(item["total_stock"]) - qty)
                item["reserved_stock"] = max(0.0, float(item["reserved_stock"]) - qty)
                item["available_stock"] = float(item["total_stock"]) - float(item["reserved_stock"])
                item["quantity"] = int(item["total_stock"])
                if item["total_stock"] == 0:
                    item["status"] = "Out of Stock"
                elif item["total_stock"] <= item["min_threshold"]:
                    item["status"] = "Low Stock"

        # Log warehouse transaction
        tx = {
            "id": f"tx-{str(uuid.uuid4())[:6]}",
            "item_id": allocation.get("inventory_item_id", ""),
            "project_id": allocation.get("project_id"),
            "transaction_type": "OUT_DISPATCH",
            "quantity": int(qty),
            "date": datetime.now().strftime("%Y-%m-%d"),
            "recorded_by": allocation.get("allocated_by"),
            "notes": f"Site Gate Pass {gp} generated for allocation {allocation_id}"
        }
        self.warehouse_transactions.insert(0, tx)

        return {
            "status": "success",
            "gate_pass_number": gp,
            "allocation": allocation,
            "message": f"Material dispatched under Gate Pass {gp}. Inventory decremented by {qty} units."
        }

    def batch_dispatch_allocations(self, allocation_ids: List[str], gate_pass_number: Optional[str] = None) -> Dict[str, Any]:
        gp = gate_pass_number or f"GP-{datetime.now().strftime('%Y%m%d')}-{str(uuid.uuid4())[:4].upper()}"
        dispatched = []
        for aid in allocation_ids:
            res = self.dispatch_allocation(aid, gate_pass_number=gp)
            if "allocation" in res:
                dispatched.append(res["allocation"])
        return {
            "status": "success",
            "gate_pass_number": gp,
            "dispatched_count": len(dispatched),
            "allocations": dispatched
        }

    def confirm_installation(self, requirement_id: str, quantity: float, installed_by: str, notes: Optional[str] = None, proof_attachment_url: Optional[str] = None) -> Dict[str, Any]:
        """
        Invoked by Site Engineer:
        Inputs quantity, optional photo attachment, engineer notes.
        Updates installed_quantity, updates status to INSTALLED_CONFIRMED, logs actions.
        """
        requirement = self.get_requirement_by_id(requirement_id)
        if not requirement:
            return {"error": f"Requirement {requirement_id} not found."}

        requirement["installed_quantity"] = float(requirement["installed_quantity"]) + quantity
        if requirement["installed_quantity"] >= requirement["required_quantity"]:
            requirement["installation_status"] = "INSTALLED_CONFIRMED"
        requirement["updated_at"] = datetime.now().isoformat()

        # Update matching dispatched allocation
        linked_alloc = next((a for a in self.material_allocations if a["requirement_id"] == requirement_id and a["status"] == "DISPATCHED_TO_SITE"), None)
        if linked_alloc:
            linked_alloc["status"] = "CONSUMED_INSTALLED"
            linked_alloc["installed_by"] = installed_by
            linked_alloc["proof_attachment_url"] = proof_attachment_url
            if notes:
                linked_alloc["notes"] = f"{linked_alloc.get('notes', '')} | Fitment note: {notes}".strip(" |")
            linked_alloc["updated_at"] = datetime.now().isoformat()

        # Log activity
        log_entry = {
            "id": f"log-{str(uuid.uuid4())[:6]}",
            "user_id": installed_by,
            "action": "INSTALLATION_CONFIRMED",
            "entity_type": "site_material_requirements",
            "entity_id": requirement_id,
            "details": {
                "quantity_installed": quantity,
                "total_installed": requirement["installed_quantity"],
                "notes": notes,
                "proof_url": proof_attachment_url
            },
            "created_at": datetime.now().isoformat()
        }

        return {
            "status": "success",
            "requirement": requirement,
            "installation_status": requirement["installation_status"],
            "installed_quantity": requirement["installed_quantity"],
            "allocation": linked_alloc,
            "message": f"Confirmed fitment of {quantity} units for '{requirement['item_name']}'. Total installed: {requirement['installed_quantity']}."
        }

    def auto_match_project_materials(self, project_id: str, allocated_by: str) -> Dict[str, Any]:
        """
        Scans all unfulfilled/pending requirements in a project and matches them against warehouse stock.
        """
        requirements = [r for r in self.site_material_requirements if r["project_id"] == project_id and r["fulfillment_status"] != "FULFILLED_WAREHOUSE"]
        results = []
        for req in requirements:
            remaining = float(req["required_quantity"]) - float(req["allocated_quantity"])
            if remaining > 0:
                tx_result = self.allocate_material_transaction(req["id"], remaining, allocated_by)
                results.append(tx_result)
        return {
            "status": "success",
            "project_id": project_id,
            "processed_count": len(results),
            "results": results
        }

# Global instance
db_service = SupabaseService()
db = db_service
