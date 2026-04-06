-- Workforce Management Database Schema (SQLite)

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT CHECK (role IN ('manager', 'employee')) NOT NULL DEFAULT 'employee',
    company_name TEXT,
    join_code TEXT,
    is_active BOOLEAN DEFAULT 1,
    company_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL
);

-- Companies table
CREATE TABLE IF NOT EXISTS companies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    industry TEXT,
    size TEXT,
    description TEXT,
    created_by INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Invitations table
CREATE TABLE IF NOT EXISTS invitations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    role TEXT CHECK (role IN ('manager', 'employee')) NOT NULL DEFAULT 'employee',
    token TEXT UNIQUE NOT NULL,
    message TEXT,
    status TEXT CHECK (status IN ('pending', 'accepted', 'expired')) DEFAULT 'pending',
    invited_by INTEGER NOT NULL,
    accepted_by INTEGER,
    accepted_at DATETIME,
    expires_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (invited_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (accepted_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Schedules table
CREATE TABLE IF NOT EXISTS schedules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    shift_start TEXT NOT NULL, -- HH:MM format
    shift_end TEXT NOT NULL,   -- HH:MM format
    days_of_week TEXT NOT NULL, -- JSON array of days
    late_threshold INTEGER DEFAULT 15, -- minutes
    location_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE SET NULL
);

-- Overtime Alerts table
CREATE TABLE IF NOT EXISTS overtime_alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    employee_name TEXT NOT NULL,
    employee_email TEXT NOT NULL,
    clock_in_time DATETIME NOT NULL,
    clock_out_time DATETIME NOT NULL,
    total_hours REAL NOT NULL,
    regular_hours REAL NOT NULL,
    overtime_hours REAL NOT NULL,
    alert_level TEXT CHECK (alert_level IN ('low', 'medium', 'high')) NOT NULL,
    message TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Overtime Settings table
CREATE TABLE IF NOT EXISTS overtime_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    manager_id INTEGER NOT NULL,
    overtime_threshold REAL DEFAULT 8, -- Standard workday hours
    alert_levels TEXT NOT NULL, -- JSON object with low, medium, high thresholds
    email_notifications BOOLEAN DEFAULT 1,
    real_time_alerts BOOLEAN DEFAULT 1,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Breaks table
CREATE TABLE IF NOT EXISTS breaks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    break_type TEXT CHECK (break_type IN ('lunch', 'coffee', 'rest', 'personal', 'other')) NOT NULL,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Holiday Requests table
CREATE TABLE IF NOT EXISTS holiday_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    holiday_type TEXT CHECK (holiday_type IN ('annual', 'sick', 'personal', 'maternity', 'paternity', 'bereavement', 'other')) NOT NULL,
    reason TEXT NOT NULL,
    notes TEXT,
    status TEXT CHECK (status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
    approved_by INTEGER,
    approved_at DATETIME,
    rejected_by INTEGER,
    rejection_reason TEXT,
    rejected_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (rejected_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Locations table
CREATE TABLE IF NOT EXISTS locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    address TEXT,
    qr_code TEXT UNIQUE,
    latitude REAL,
    longitude REAL,
    geofence_radius INTEGER DEFAULT 100, -- Radius in meters
    geofence_enabled BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Shifts table
CREATE TABLE IF NOT EXISTS shifts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    clock_in_time DATETIME NOT NULL,
    clock_out_time DATETIME,
    gps_lat REAL,
    gps_lng REAL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(id)
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    location_id INTEGER NOT NULL,
    requires_photo BOOLEAN DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES locations(id)
);

-- Task Completions table
CREATE TABLE IF NOT EXISTS task_completions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    shift_id INTEGER NOT NULL,
    photo_url TEXT,
    completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE
);

-- User Task Assignments (optional: for pre-assigning tasks to users)
CREATE TABLE IF NOT EXISTS user_task_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    assigned_by INTEGER,
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    UNIQUE(user_id, task_id)
);

-- Subscriptions table for billing
CREATE TABLE IF NOT EXISTS subscriptions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    employee_count INTEGER NOT NULL DEFAULT 1,
    monthly_price DECIMAL(10,2) NOT NULL DEFAULT 5.00,
    currency VARCHAR(3) NOT NULL DEFAULT 'GBP',
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- 'active', 'paid', 'cancelled'
    stripe_subscription_id VARCHAR(255),
    purchase_token VARCHAR(255), -- Google Play Store purchase token
    last_payment_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Password reset tokens table
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Payment records table
CREATE TABLE IF NOT EXISTS payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subscription_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'GBP',
    payment_method VARCHAR(50) NOT NULL, -- 'card', 'google_pay', 'apple_pay', 'bank_transfer'
    payment_provider_id VARCHAR(255), -- ID from payment provider
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'completed', 'failed', 'refunded'
    processed_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_shifts_user_id ON shifts(user_id);
CREATE INDEX IF NOT EXISTS idx_shifts_location_id ON shifts(location_id);
CREATE INDEX IF NOT EXISTS idx_shifts_clock_in_time ON shifts(clock_in_time);
CREATE INDEX IF NOT EXISTS idx_tasks_location_id ON tasks(location_id);
CREATE INDEX IF NOT EXISTS idx_task_completions_task_id ON task_completions(task_id);
CREATE INDEX IF NOT EXISTS idx_task_completions_user_id ON task_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_task_completions_shift_id ON task_completions(shift_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_payments_subscription_id ON payments(subscription_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

-- Insert sample data (only if tables are empty)
INSERT OR IGNORE INTO users (name, email, password, role) VALUES 
('John Manager', 'manager@company.com', '$2a$10$rOzJqQjQjQjQjQjQjQjQjOzJqQjQjQjQjQjQjQjQjQjQjQjQjQjQ', 'manager'),
('Jane Employee', 'employee@company.com', '$2a$10$H3A32GLtxdBMgQYhfHQbOOf9vdtvKjrls0ZkYnJ9x2/4.gyhTqmFC', 'employee');

INSERT OR IGNORE INTO locations (name, address, qr_code, latitude, longitude, geofence_radius, geofence_enabled) VALUES 
('Main Office', '123 Business St, City, State 12345', 'LOC001', 40.7128, -74.0060, 100, 1),
('Warehouse', '456 Storage Ave, City, State 12345', 'LOC002', 40.7580, -73.9855, 150, 1),
('Retail Store', '789 Shop Blvd, City, State 12345', 'LOC003', 40.7489, -73.9680, 50, 1);

INSERT OR IGNORE INTO tasks (title, description, location_id, requires_photo) VALUES 
('Check Inventory', 'Count all items in storage area', 2, 1),
('Clean Workspace', 'Clean and organize work area', 1, 0),
('Customer Service', 'Assist customers and handle inquiries', 3, 1),
('Security Check', 'Verify all security measures are in place', 1, 1),
('Stock Shelves', 'Restock products on shelves', 3, 0);
