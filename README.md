# InteriorCraft — Cloud-Based Interior Design Project Management Platform

A modern, cloud-based web application tailored for luxury interior architecture and interior design firms. The platform streamlines end-to-end studio project management, automates task creation from architectural documents via OCR, tracks site progress in real time, manages multi-zone warehouse inventory, provides a dedicated luxury client portal, and enforces strict dynamic role-based access control (RBAC).

---

## 🏛️ Technology Stack & Architecture

| Layer | Technology | Key Capabilities & Rationale |
| :--- | :--- | :--- |
| **Front-End / UI** | **Flutter Web (Single-Page App)** | Bespoke obsidian & warm gold architectural palette, reactive `Provider` state management, `InteractiveViewer` blueprint pan & zoom, and `CustomPaint` + `GestureDetector` vector markup layers. |
| **Back-End API** | **Python (FastAPI)** | Async REST API designed for high performance and deployment as serverless functions on **Vercel** (`api/index.py`). |
| **Database & Storage** | **Supabase (PostgreSQL + RLS)** | Relational schema with Row Level Security (RLS) for users, projects, sites, tasks, inventory, client sign-offs, milestone invoices, and vector markups. |
| **AI / Machine Learning** | **Scikit-Learn (Python)** | Machine learning models (`RandomForestRegressor`, `GradientBoostingClassifier`) analyzing task complexity, engineer velocity, material lead times, and forecasting delay probability & resource recommendations. |
| **OCR Task Automation** | **Tesseract OCR & PyMuPDF** | Automated extraction of task lists, specification schedules, and Bills of Quantities (BoQs) from PDF/image uploads into structured Supabase tasks. |
| **Email Service** | **SendGrid API** | Automated transactional emails for milestone payments, impending deadlines, and AI delay warnings. |

---

## 📁 Repository Structure

```text
Project Manegement/
├── backend/
│   ├── api/
│   │   └── index.py               # Vercel Python serverless entrypoint
│   ├── core/
│   │   ├── config.py              # Environment configuration (.env loader)
│   │   └── security.py            # JWT token generation, verification & auth
│   ├── database/
│   │   ├── schema.sql             # Complete Supabase PostgreSQL schema with RLS & seed data
│   │   └── supabase_client.py     # Supabase connector with resilient local state fallback
│   ├── models/
│   │   └── schemas.py             # Pydantic validation schemas
│   ├── services/
│   │   ├── ocr_service.py         # Tesseract OCR & PDF text parsing pipeline
│   │   ├── ai_service.py          # Scikit-Learn predictive model & resource allocator
│   │   ├── auth_service.py        # Dynamic RBAC permission engine (Owner, Engineer, Client)
│   │   └── email_service.py       # SendGrid transactional email dispatcher
│   ├── routers/
│   │   ├── auth.py                # JWT login, profiles, dynamic role governance
│   │   ├── projects.py            # Project lifecycle and site assignments
│   │   ├── tasks.py               # Task CRUD, engineer updates, and OCR upload endpoint
│   │   ├── analytics.py           # Scikit-Learn project delay forecasts & executive metrics
│   │   ├── drawings.py            # Blueprint drawings & vector markup persistence
│   │   ├── inventory.py           # Stock tracking, warehouse zones & dispatch transactions
│   │   ├── clients.py             # Client design sign-offs, milestone invoices & payments
│   │   ├── vendors.py             # Vendor directory & purchase orders
│   │   └── material_fulfillment.py # Advanced MRP, inventory allocation & installation API
│   ├── main.py                    # FastAPI root application & CORS configuration
│   ├── vercel.json                # Vercel serverless deployment routing
│   ├── requirements.txt           # Python backend dependencies
│   ├── .env.example               # Configuration template
│   └── test_api.py                # Comprehensive test suite covering all modules
├── frontend/
│   ├── lib/
│   │   ├── models/                # Dart domain models (User, Project, MaterialRequirement, etc.)
│   │   ├── services/              # ApiService with resilient offline fallback
│   │   ├── providers/             # AppState ChangeNotifier provider
│   │   ├── theme/                 # Architectural luxury theme (Obsidian & Gold)
│   │   ├── widgets/
│   │   │   ├── markup_canvas.dart # CustomPaint & GestureDetector vector drawing engine
│   │   │   ├── metric_card.dart   # KPI metric card widgets
│   │   │   └── status_badge.dart  # Contextual status badges
│   │   ├── screens/
│   │   │   ├── dashboard_shell.dart            # Responsive SPA navigation shell & role switcher
│   │   │   ├── fulfillment_matrix_screen.dart  # PM View: Site Specification & Fulfillment Matrix
│   │   │   ├── installation_signoff_screen.dart # Site Engineer Interface: Fitment & Installation Sign-off
│   │   │   ├── warehouse_dispatcher_screen.dart # Warehouse Dispatcher Dashboard & Gate Pass Generation
│   │   │   ├── owner_dashboard.dart            # Owner executive view & dynamic RBAC dialog
│   │   │   ├── engineer_dashboard.dart         # Engineer site punch list & progress slider
│   │   │   ├── client_portal_screen.dart       # Client 3D renders, sign-offs, and invoices
│   │   │   ├── drawing_markup_center.dart      # InteractiveViewer CAD plan & markup canvas
│   │   │   ├── ocr_task_automation_screen.dart # Document upload, OCR extraction & task import
│   │   │   ├── ai_analytics_screen.dart        # Scikit-Learn delay forecasts & recommendations
│   │   │   ├── inventory_warehouse_screen.dart # Warehouse zones, stock levels & site dispatch
│   │   │   ├── site_management_screen.dart     # Site operations & engineer allocation
│   │   │   └── vendor_management_screen.dart   # Vendor directory & purchase order tracking
│   │   └── main.dart
│   ├── web/
│   │   └── index.html             # Web app manifest, SEO tags, and luxury splash screen
│   └── pubspec.yaml               # Flutter dependencies
└── README.md
```

---

## ⚡ Key Modules & Capabilities

### 1. OCR Task Automation Module
- **Endpoint**: `POST /api/tasks/upload-ocr`
- Uploads PDF drawings, specifications, or Bills of Quantities (BoQs).
- Extracts text via **Tesseract OCR** (or high-fidelity digital stream with PyMuPDF).
- Custom heuristic NLP algorithms extract Task Titles, Trade Complexity, Planned Duration, Due Dates, and Priority classification.
- Tasks are automatically validated and inserted into the Supabase `tasks` table mapped to the project.

### 2. AI Predictive Analytics Engine
- **Endpoint**: `GET /api/analytics/predict-delays/{project_id}`
- Integrates **Scikit-Learn** (`RandomForestRegressor` and `GradientBoostingClassifier`).
- Continuously learns from historical site velocity, trade complexity, and real-time engineer progress submissions.
- Calculates:
  - **Project Health Score** (0 - 100)
  - **Delay Probability Percentage** (e.g. 46.5%)
  - **Schedule Variance** (e.g. +3.4 business days)
  - **Flagged Critical Path Tasks**
  - **Actionable Resource Allocation Recommendations** (e.g., *"Shift 2 master joinery finishers from completed Site B to Penthouse living gallery to recover 3.5 days"*).

### 3. Dynamic Role-Based Access Control (RBAC)
- **Roles**:
  - 👑 **Owner**: Full administrative access, financial health, company-wide AI analytics, and dynamic user role governance.
  - 📐 **Engineer**: Site punch lists, task progress slider (0 - 100%), drawing markups, and inspection log submissions.
  - 🌟 **Client**: Dedicated luxury portal to inspect 3D renders, approve designs / request revisions, review billing milestones, and submit payments.
- **Dynamic Governance**: The Owner can dynamically promote, reassign roles, and configure permissions via `POST /api/auth/assign-role`.

### 4. Architectural Drawing & Markup Center
- Incorporates `InteractiveViewer` for smooth 2D panning and zooming up to 4x on high-resolution architectural drawings and CAD blueprints.
- Integrated `CustomPaint` and `GestureDetector` markup engine (`MarkupCanvas`):
  - **Freehand Pen**: Precision site annotation strokes.
  - **Revision Clouds**: Scalloped boundary arcs flagging architectural changes.
  - **Arrow Pointers**: Dimension lines and callout indicators.
  - **Highlighter**: Semi-transparent layer highlighting architectural elements.
  - **Text Callout Notes**: Click-to-place comments on specific blueprint coordinates.
  - **Vector Storage**: Markups are serialized as JSON vector layers into Supabase `drawing_markups`.

### 5. Warehouse & Inventory Management
- Categorized stock tracking across 5 warehouse zones (Zone A Heavy Stone, Zone B Woodcraft Veneers, Zone C Lighting, Zone D Textiles, Zone E Plumbing & Hardware).
- Real-time stock status (`In Stock`, `Low Stock`, `Out of Stock`).
- **Site Dispatch**: Instantly dispatch materials directly to active project sites, generating audit transaction records and updating stock levels.

### 6. Luxury Client Portal & Financial Services
- **Design Review Carousel**: Photorealistic 3D renders, moodboards, and material palettes.
- **Client Sign-off Action**: Interactive "Approve Design" or "Request Revision" with client feedback notes.
- **Milestone Billing**: Review invoice breakdowns and submit payments via simulated Wire Transfer or ACH Direct, triggering automated SendGrid confirmation receipts.

### 7. Advanced Inventory-to-Site Fulfillment & Installation Tracking (MRP Module)
End-to-end Material Requirements Planning linking site specifications directly to warehouse inventory reservations, Gate Pass dispatching, and field engineer fitment verification.

#### Architecture & Data Schema (Supabase)
- **`site_material_requirements` (Site Bill of Materials)**:
  - `id` (UUID), `project_id` (UUID), `item_name` (Text), `item_category` (Text), `specification_details` (JSONB)
  - `required_quantity` (Number), `allocated_quantity` (Number, default 0), `installed_quantity` (Number, default 0)
  - `fulfillment_status` (`UNFULFILLED`, `FULFILLED_WAREHOUSE`, `PROCUREMENT_PENDING`)
  - `installation_status` (`PENDING_DELIVERY`, `INSTALLED_CONFIRMED`), timestamps.
- **`inventory_items` (Warehouse Extension)**:
  - `sku`, `name`, `total_stock`, `reserved_stock` (default 0), `available_stock` (computed: `total_stock - reserved_stock`).
- **`material_allocations` (Junction & Audit Ledger)**:
  - `id`, `requirement_id`, `inventory_item_id`, `allocated_quantity`, `gate_pass_number`
  - `status` (`RESERVED`, `DISPATCHED_TO_SITE`, `CONSUMED_INSTALLED`)
  - `allocated_by`, `installed_by`, `proof_attachment_url`, `notes`, timestamps.

#### Back-End API Specifications (FastAPI)
- `POST /api/v1/projects/{project_id}/materials`: Ingests site material specifications into the Bill of Materials.
- `POST /api/v1/materials/{requirement_id}/allocate`:
  - **Transaction Logic**: Checks `available_stock >= requested_quantity`.
  - **Branch A (In-Stock)**: Increments `reserved_stock`, marks requirement `FULFILLED_WAREHOUSE`, logs allocation with status `RESERVED`.
  - **Branch B (Stock Deficit)**: Marks requirement `PROCUREMENT_PENDING`, auto-generates Purchase Order (`PO-MRP-...`).
- `POST /api/v1/projects/{project_id}/materials/auto-match`: Batch auto-matches all project site specifications against matching warehouse SKUs.
- `GET /api/v1/allocations/reserved`: Retrieves all `RESERVED` allocations awaiting site dispatch.
- `POST /api/v1/allocations/{allocation_id}/dispatch`: Authorizes Gate Pass, converts allocation to `DISPATCHED_TO_SITE`, decrements `total_stock` and `reserved_stock`.
- `POST /api/v1/allocations/batch-dispatch`: Groups multiple site allocations under a single auto-generated Site Gate Pass (`GP-SITE-...`).
- `POST /api/v1/materials/{requirement_id}/confirm-installation`: Invoked by Site Engineer with installed quantity, quality notes, and verification photo proof. Updates `installed_quantity`, sets `INSTALLED_CONFIRMED`, and logs fitment sign-off.

#### Front-End Interface Modules (Flutter Web)
1. **Project Manager View: Site Specification & Fulfillment Matrix** (`FulfillmentMatrixScreen`):
   - Interactive table of all site items with real-time status badges (`Fulfilled`, `Partially Fulfilled`, `Procurement Pending / Out of Stock`, `Installed Confirmed`).
   - Action buttons: **Auto-Match & Allocate**, **Add Site Specification**, and **Raise Vendor PO**.
2. **Site Engineer Interface: Material Check-in & Installation Sign-off** (`InstallationSignoffScreen`):
   - Dedicated checklist of items marked `DISPATCHED_TO_SITE`.
   - Single-tap **Confirm Fitment** flow with interactive quantity counter (`+`/`-`), camera photo verification preview, and inspection notes.
   - Automatically moves items to confirmed status upon sign-off.
3. **Warehouse Dispatcher Dashboard** (`WarehouseDispatcherScreen`):
   - Real-time list of all `RESERVED` allocations grouped by Project Site.
   - Multi-select batch action: **Generate Site Gate Pass & Dispatch** with vehicle & driver assignment to authorize active transit.

---

## 🚀 Quickstart Guide

### 1. Back-End Setup (FastAPI & Python)

```bash
cd backend

# (Optional) Create virtual environment
python -m venv venv
venv\Scripts\activate   # On Windows
source venv/bin/activate # On macOS / Linux

# Install dependencies
pip install -r requirements.txt

# Run backend test suite (Verifies OCR, AI models, RBAC, and Supabase client)
python test_api.py

# Launch FastAPI development server
uvicorn main:app --reload --port 8000
```
- API Documentation (Swagger UI): `http://localhost:8000/docs`
- ReDoc Interactive Documentation: `http://localhost:8000/redoc`

### 2. Front-End Setup (Flutter Web)

```bash
cd frontend

# Install Flutter packages
flutter pub get

# Run in Chrome (Web)
flutter run -d chrome

# Or build production Web bundle
flutter build web
```

---

## ☁️ Deployment Configurations

### Supabase Setup
1. Create a project at [supabase.com](https://supabase.com).
2. Open the **SQL Editor** in your Supabase dashboard.
3. Paste and run the entire SQL script from `backend/database/schema.sql`.
4. Copy your **Project URL** and **API Key (anon or service_role)**.
5. Create a `.env` file in `backend/` using `backend/.env.example`.

### Vercel Serverless Deployment
The backend includes `backend/api/index.py` and `backend/vercel.json` configured for the Vercel Python runtime:
```bash
cd backend
vercel deploy
```
Set environment variables (`SUPABASE_URL`, `SUPABASE_KEY`, `SENDGRID_API_KEY`, `JWT_SECRET`) in your Vercel Project Settings.
