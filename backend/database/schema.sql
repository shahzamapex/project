-- =========================================================================
-- SUPABASE POSTGRESQL SCHEMA FOR INTERIOR DESIGN PROJECT MANAGEMENT PLATFORM
-- Multi-role (Owner, Engineer, Client) with Row Level Security (RLS)
-- =========================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Profiles & RBAC
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('owner', 'engineer', 'client')),
    phone TEXT,
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Dynamic Permissions Table
CREATE TABLE IF NOT EXISTS roles_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role TEXT NOT NULL,
    permission TEXT NOT NULL,
    description TEXT,
    UNIQUE(role, permission)
);

-- 2. Projects & Sites
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    client_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    client_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'In Progress' CHECK (status IN ('Planning', 'In Progress', 'Under Review', 'Completed', 'On Hold')),
    budget NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    spent NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    start_date DATE NOT NULL,
    target_end_date DATE NOT NULL,
    progress_percent INTEGER DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
    site_address TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    engineer_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN ('Pending', 'Active', 'Inspection Needed', 'Closed')),
    last_inspection_date TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tasks (Populated manually or via OCR Task Automation Engine)
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    site_id UUID REFERENCES sites(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    assigned_to UUID REFERENCES profiles(id) ON DELETE SET NULL,
    priority TEXT NOT NULL DEFAULT 'Medium' CHECK (priority IN ('Low', 'Medium', 'High', 'Critical')),
    status TEXT NOT NULL DEFAULT 'To Do' CHECK (status IN ('To Do', 'In Progress', 'In Review', 'Completed', 'Blocked')),
    planned_days INTEGER DEFAULT 5,
    actual_days INTEGER DEFAULT 0,
    due_date DATE NOT NULL,
    completion_percent INTEGER DEFAULT 0 CHECK (completion_percent BETWEEN 0 AND 100),
    source_document TEXT, -- Document name if extracted via OCR
    confidence_score NUMERIC(5, 2), -- OCR extraction confidence
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Architectural Drawings & Markups
CREATE TABLE IF NOT EXISTS drawings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    revision TEXT NOT NULL DEFAULT 'Rev A',
    file_url TEXT NOT NULL,
    file_type TEXT NOT NULL DEFAULT 'application/pdf',
    sheet_number TEXT,
    uploaded_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS drawing_markups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    drawing_id UUID NOT NULL REFERENCES drawings(id) ON DELETE CASCADE,
    author_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    author_name TEXT NOT NULL,
    author_role TEXT NOT NULL,
    layer_data JSONB NOT NULL, -- Serialized vector strokes, shapes, callouts, text
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Inventory & Warehouse Management (Extended for MRP & Site Allocation)
CREATE TABLE IF NOT EXISTS inventory_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('Furniture', 'Lighting', 'Flooring & Marble', 'Fabrics & Textiles', 'Hardware & Fixtures', 'Finishes & Paint', 'Electrical')),
    quantity INTEGER NOT NULL DEFAULT 0, -- Legacy alias
    total_stock NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    reserved_stock NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    available_stock NUMERIC(10, 2) GENERATED ALWAYS AS (total_stock - reserved_stock) STORED,
    unit TEXT NOT NULL DEFAULT 'pcs',
    min_threshold INTEGER NOT NULL DEFAULT 10,
    unit_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    warehouse_zone TEXT NOT NULL DEFAULT 'Zone A',
    status TEXT NOT NULL DEFAULT 'In Stock' CHECK (status IN ('In Stock', 'Low Stock', 'Out of Stock', 'Dispatched')),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5A. Site Bill of Materials (Material Requirements Planning)
CREATE TABLE IF NOT EXISTS site_material_requirements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    item_name TEXT NOT NULL,
    item_category TEXT NOT NULL,
    specification_details JSONB DEFAULT '{}'::jsonb,
    required_quantity NUMERIC(10, 2) NOT NULL,
    allocated_quantity NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    installed_quantity NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    fulfillment_status TEXT NOT NULL DEFAULT 'UNFULFILLED' CHECK (fulfillment_status IN ('UNFULFILLED', 'FULFILLED_WAREHOUSE', 'PROCUREMENT_PENDING')),
    installation_status TEXT NOT NULL DEFAULT 'PENDING_DELIVERY' CHECK (installation_status IN ('PENDING_DELIVERY', 'INSTALLED_CONFIRMED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5B. Material Allocations (Junction / Audit Ledger)
CREATE TABLE IF NOT EXISTS material_allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requirement_id UUID NOT NULL REFERENCES site_material_requirements(id) ON DELETE CASCADE,
    inventory_item_id UUID REFERENCES inventory_items(id) ON DELETE SET NULL,
    allocated_quantity NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'RESERVED' CHECK (status IN ('RESERVED', 'DISPATCHED_TO_SITE', 'CONSUMED_INSTALLED')),
    allocated_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    installed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    proof_attachment_url TEXT,
    gate_pass_number TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS warehouse_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('IN_RESTOCK', 'OUT_DISPATCH', 'RETURN', 'ADJUSTMENT')),
    quantity INTEGER NOT NULL,
    recorded_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Client Portal: Design Approvals, Invoices & Payments
CREATE TABLE IF NOT EXISTS client_approvals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    stage TEXT NOT NULL CHECK (stage IN ('Moodboard', '3D Render', 'Material Palette', 'Technical Layout', 'Final Handover')),
    media_url TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Revision Requested')),
    client_feedback TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS invoices_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    invoice_number TEXT UNIQUE NOT NULL,
    milestone_name TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    due_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Paid', 'Overdue')),
    paid_at TIMESTAMP WITH TIME ZONE,
    payment_method TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Vendors & Purchase Orders
CREATE TABLE IF NOT EXISTS vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    contact_person TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    category TEXT NOT NULL,
    rating NUMERIC(2, 1) DEFAULT 4.5,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    po_number TEXT UNIQUE NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'Draft' CHECK (status IN ('Draft', 'Issued', 'Partially Fulfilled', 'Delivered', 'Cancelled')),
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expected_delivery DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Activity & Audit Logs
CREATE TABLE IF NOT EXISTS activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =========================================================================
-- SEED DEFAULT PERMISSIONS
-- =========================================================================
INSERT INTO roles_permissions (role, permission, description) VALUES
('owner', 'all_access', 'Full administrative privileges across all modules'),
('owner', 'manage_users', 'Invite and assign roles and permissions to users'),
('owner', 'view_analytics', 'Access AI predictive delay and budget analytics'),
('owner', 'manage_finance', 'Manage invoices, payments, and budgets'),
('engineer', 'view_assigned_sites', 'View assigned project sites and blueprints'),
('engineer', 'update_site_progress', 'Update task progress and upload site logs'),
('engineer', 'annotate_drawings', 'Add and edit markups on architectural drawings'),
('client', 'view_project_portal', 'View project milestones and real-time progress'),
('client', 'approve_designs', 'Approve 3D renders and request revisions'),
('client', 'view_invoices', 'Access billing milestones and submit payments')
ON CONFLICT (role, permission) DO NOTHING;

-- Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE drawing_markups ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices_payments ENABLE ROW LEVEL SECURITY;

-- Sample RLS Policies (Postgres Supabase format)
CREATE POLICY "Owner has full access to all profiles"
ON profiles FOR ALL USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'owner'
);

CREATE POLICY "Users can read own profile"
ON profiles FOR SELECT USING (
    id = auth.uid()
);

CREATE POLICY "Engineers and Owners can view project tasks"
ON tasks FOR SELECT USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) IN ('owner', 'engineer')
);

CREATE POLICY "Clients can view own project client approvals"
ON client_approvals FOR SELECT USING (
    project_id IN (SELECT id FROM projects WHERE client_id = auth.uid())
    OR (SELECT role FROM profiles WHERE id = auth.uid()) = 'owner'
);
