-- =====================================================
-- DATABASE HỢP TÁC XÃ NÔNG NGHIỆP - FULL SCHEMA
-- NOT NULL cho FK quan trọng, ràng buộc ngày,
-- triggers tự tính total_*, updated_at, quản lý tồn kho,
-- giữ lịch sử tài chính/hợp đồng (RESTRICT), index FK,
-- unique-case-insensitive cho email/username, UNIQUE logic.
-- =====================================================

BEGIN;

-- ========== 1) BẢNG NGƯỜI DÙNG ==========
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'member', 'customer', 'manager')),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ========== 2) THÀNH VIÊN HTX ==========
CREATE TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    member_code VARCHAR(20) UNIQUE NOT NULL,
    join_date DATE NOT NULL,
    share_capital DECIMAL(15,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ========== 3) SẢN PHẨM ==========
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(20) NOT NULL CHECK (category IN ('vegetable', 'fruit', 'grain', 'livestock', 'other')),
    description TEXT,
    unit VARCHAR(20) NOT NULL,
    member_id INTEGER REFERENCES members(id), -- cho phép NULL nếu là sản phẩm chung của HTX
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ========== 4) THU HOẠCH ==========
CREATE TABLE IF NOT EXISTS harvests (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    member_id  INTEGER NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    harvest_date DATE NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    quality_grade VARCHAR(20) DEFAULT 'A' CHECK (quality_grade IN ('A', 'B', 'C')),
    price_per_unit DECIMAL(10,2),
    total_value DECIMAL(15,2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ========== 5) HỢP ĐỒNG ==========
CREATE TABLE IF NOT EXISTS contracts (
    id SERIAL PRIMARY KEY,
    contract_code VARCHAR(50) UNIQUE NOT NULL,
    member_id   INTEGER NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    customer_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT, -- giữ lịch sử KH
    title VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date   DATE NOT NULL,
    total_value DECIMAL(15,2),
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'completed', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_contract_dates CHECK (end_date >= start_date)
);

-- ========== 6) CHI TIẾT HỢP ĐỒNG ==========
CREATE TABLE IF NOT EXISTS contract_items (
    id SERIAL PRIMARY KEY,
    contract_id INTEGER NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    product_id  INTEGER NOT NULL REFERENCES products(id)  ON DELETE CASCADE,
    quantity    DECIMAL(10,2) NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    delivery_date DATE,
    notes TEXT,
    -- Cho phép cùng 1 sản phẩm giao nhiều đợt khác ngày
    CONSTRAINT uq_contract_items UNIQUE (contract_id, product_id, delivery_date)
);

-- ========== 7) GIAO DỊCH TÀI CHÍNH ==========
CREATE TABLE IF NOT EXISTS financial_transactions (
    id SERIAL PRIMARY KEY,
    transaction_code VARCHAR(50) UNIQUE NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT, -- giữ lịch sử user tạo GD
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('income', 'expense', 'investment', 'dividend')),
    category VARCHAR(30) NOT NULL CHECK (category IN ('sales', 'membership_fee', 'government_subsidy', 'operating_cost', 'equipment', 'maintenance', 'utilities', 'share_capital', 'equipment_purchase', 'profit_sharing')),
    amount DECIMAL(15,2) NOT NULL,
    description TEXT NOT NULL,
    transaction_date DATE NOT NULL,
    reference_document VARCHAR(200),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ========== 8) DANH MỤC VẬT TƯ ==========
CREATE TABLE IF NOT EXISTS inventory_items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('material', 'equipment', 'tool', 'seed', 'fertilizer', 'pesticide')),
    description TEXT,
    unit VARCHAR(20) NOT NULL,
    current_quantity DECIMAL(10,2) DEFAULT 0,
    min_quantity     DECIMAL(10,2) DEFAULT 0,
    unit_price DECIMAL(10,2),
    supplier VARCHAR(100),
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_inventory_items_nonneg CHECK (current_quantity >= 0 AND min_quantity >= 0)
);

-- ========== 9) GIAO DỊCH KHO ==========
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('IN', 'OUT', 'ADJUSTMENT')),
    quantity   DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2),
    total_value DECIMAL(15,2),
    reference VARCHAR(100),
    notes TEXT,
    transaction_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT chk_inventory_tx_qty_pos CHECK (
      (transaction_type IN ('IN','OUT') AND quantity > 0)
      OR (transaction_type = 'ADJUSTMENT' AND quantity <> 0)
    ),
    CONSTRAINT chk_inventory_tx_price_nonneg CHECK (unit_price IS NULL OR unit_price >= 0)
);

-- ========== 10) MÙA VỤ ==========
CREATE TABLE IF NOT EXISTS seasons (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    season_type VARCHAR(20) NOT NULL CHECK (season_type IN ('spring', 'summer', 'autumn', 'winter')),
    year INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_season_dates CHECK (end_date >= start_date)
);

-- ========== 11) CÔNG VIỆC THEO MÙA ==========
CREATE TABLE IF NOT EXISTS season_tasks (
    id SERIAL PRIMARY KEY,
    season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date   DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    assigned_to VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ========== 12) CHỨNG NHẬN ==========
CREATE TABLE IF NOT EXISTS certifications (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    certification_type VARCHAR(20) NOT NULL CHECK (certification_type IN ('organic', 'gap', 'globalgap', 'vietgap', 'iso', 'other')),
    issuing_authority VARCHAR(200) NOT NULL,
    certificate_number VARCHAR(100) UNIQUE NOT NULL,
    issue_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'expired', 'rejected')),
    description TEXT,
    file_path VARCHAR(500),
    qr_code VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ========== 13) CHỨNG NHẬN SẢN PHẨM ==========
CREATE TABLE IF NOT EXISTS product_certifications (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    certification_id INTEGER NOT NULL REFERENCES certifications(id) ON DELETE CASCADE,
    batch_number VARCHAR(100),
    harvest_date DATE,
    qr_code VARCHAR(200) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uq_prod_cert UNIQUE (product_id, certification_id, batch_number)
);

-- =====================================================
-- INDEX BỔ SUNG (FK + bộ lọc hay dùng)
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_lower    ON users (lower(email));
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username_lower ON users (lower(username));

CREATE INDEX IF NOT EXISTS idx_members_code ON members(member_code);

CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_member   ON products(member_id);

CREATE INDEX IF NOT EXISTS idx_harvests_date    ON harvests(harvest_date);
CREATE INDEX IF NOT EXISTS idx_harvests_product ON harvests(product_id);
CREATE INDEX IF NOT EXISTS idx_harvests_member  ON harvests(member_id);

CREATE INDEX IF NOT EXISTS idx_contracts_code     ON contracts(contract_code);
CREATE INDEX IF NOT EXISTS idx_contracts_status   ON contracts(status);
CREATE INDEX IF NOT EXISTS idx_contracts_member   ON contracts(member_id);
CREATE INDEX IF NOT EXISTS idx_contracts_customer ON contracts(customer_id);

CREATE INDEX IF NOT EXISTS idx_citems_contract  ON contract_items(contract_id);
CREATE INDEX IF NOT EXISTS idx_citems_product   ON contract_items(product_id);

CREATE INDEX IF NOT EXISTS idx_financial_type ON financial_transactions(transaction_type);
CREATE INDEX IF NOT EXISTS idx_financial_date ON financial_transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_financial_user ON financial_transactions(user_id);

CREATE INDEX IF NOT EXISTS idx_inventory_type ON inventory_items(item_type);

CREATE INDEX IF NOT EXISTS idx_invtx_item ON inventory_transactions(item_id);

CREATE INDEX IF NOT EXISTS idx_seasons_year ON seasons(year);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON season_tasks(status);

CREATE INDEX IF NOT EXISTS idx_certifications_type ON certifications(certification_type);
CREATE INDEX IF NOT EXISTS idx_pcert_product ON product_certifications(product_id);
CREATE INDEX IF NOT EXISTS idx_pcert_cert    ON product_certifications(certification_id);

-- =====================================================
-- TRIGGERS NGHIỆP VỤ
-- =====================================================

-- 1) Tự cập nhật updated_at
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'users','members','products','harvests','contracts',
    'financial_transactions','inventory_items','seasons',
    'season_tasks','certifications'
  ]
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%1$s_set_updated_at ON %1$s;', t);
    EXECUTE format('CREATE TRIGGER trg_%1$s_set_updated_at BEFORE UPDATE ON %1$s FOR EACH ROW EXECUTE FUNCTION set_updated_at();', t);
  END LOOP;
END $$;

-- 2) Tự tính tổng tiền cho harvests/contract_items/inventory_transactions
CREATE OR REPLACE FUNCTION trg_calc_harvest_total() RETURNS trigger AS $$
BEGIN
  IF NEW.price_per_unit IS NULL THEN
    NEW.total_value := NULL;
  ELSE
    NEW.total_value := ROUND(NEW.quantity * NEW.price_per_unit, 2);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_harvests_calc_total ON harvests;
CREATE TRIGGER trg_harvests_calc_total
BEFORE INSERT OR UPDATE ON harvests
FOR EACH ROW EXECUTE FUNCTION trg_calc_harvest_total();

CREATE OR REPLACE FUNCTION trg_calc_citem_total() RETURNS trigger AS $$
BEGIN
  NEW.total_price := ROUND(NEW.quantity * NEW.unit_price, 2);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_citems_calc_total ON contract_items;
CREATE TRIGGER trg_citems_calc_total
BEFORE INSERT OR UPDATE ON contract_items
FOR EACH ROW EXECUTE FUNCTION trg_calc_citem_total();

CREATE OR REPLACE FUNCTION trg_calc_invtx_total() RETURNS trigger AS $$
BEGIN
  IF NEW.unit_price IS NULL THEN
    NEW.total_value := NULL;
  ELSE
    NEW.total_value := ROUND(NEW.quantity * COALESCE(NEW.unit_price,0), 2);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_invtx_calc_total ON inventory_transactions;
CREATE TRIGGER trg_invtx_calc_total
BEFORE INSERT OR UPDATE ON inventory_transactions
FOR EACH ROW EXECUTE FUNCTION trg_calc_invtx_total();

-- 3) Áp giao dịch kho vào tồn và chặn âm kho
CREATE OR REPLACE FUNCTION inv_apply_tx() RETURNS trigger AS $$
DECLARE
  cur NUMERIC(10,2);
  delta NUMERIC(10,2);
  item_id_int INT;
BEGIN
  IF TG_OP = 'DELETE' THEN
    item_id_int := OLD.item_id;
    SELECT current_quantity INTO cur FROM inventory_items WHERE id = item_id_int FOR UPDATE;
    IF OLD.transaction_type = 'IN' THEN
      delta := -OLD.quantity;
    ELSIF OLD.transaction_type = 'OUT' THEN
      delta :=  OLD.quantity;
    ELSE -- ADJUSTMENT đảo chiều
      delta := -OLD.quantity;
    END IF;
    IF cur + delta < 0 THEN
      RAISE EXCEPTION 'Reversing transaction makes negative stock for item %', item_id_int;
    END IF;
    UPDATE inventory_items SET current_quantity = cur + delta, updated_at = NOW() WHERE id = item_id_int;
    RETURN OLD;
  ELSE
    item_id_int := NEW.item_id;
    SELECT current_quantity INTO cur FROM inventory_items WHERE id = item_id_int FOR UPDATE;
    IF NEW.transaction_type = 'IN' THEN
      delta := NEW.quantity;
    ELSIF NEW.transaction_type = 'OUT' THEN
      delta := -NEW.quantity;
    ELSE -- ADJUSTMENT: chênh lệch (+/-)
      delta := NEW.quantity;
    END IF;
    IF cur + delta < 0 THEN
      RAISE EXCEPTION 'Insufficient stock for item %: current=%, change=%', item_id_int, cur, delta;
    END IF;
    UPDATE inventory_items SET current_quantity = cur + delta, updated_at = NOW() WHERE id = item_id_int;
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_invtx_apply_insupd ON inventory_transactions;
CREATE TRIGGER trg_invtx_apply_insupd
AFTER INSERT OR UPDATE ON inventory_transactions
FOR EACH ROW EXECUTE FUNCTION inv_apply_tx();

DROP TRIGGER IF EXISTS trg_invtx_apply_del ON inventory_transactions;
CREATE TRIGGER trg_invtx_apply_del
AFTER DELETE ON inventory_transactions
FOR EACH ROW EXECUTE FUNCTION inv_apply_tx();

-- =====================================================
-- DỮ LIỆU MẪU
-- =====================================================

-- User admin
INSERT INTO users (username, email, full_name, hashed_password, role) 
VALUES ('admin', 'admin@htx.com', 'Quản trị viên HTX', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj9/4eXq8Wya', 'admin')
ON CONFLICT (username) DO NOTHING;

-- Users member
INSERT INTO users (username, email, full_name, phone, address, hashed_password, role) 
VALUES 
('nguyenvana', 'nguyenvana@email.com', 'Nguyễn Văn A', '0901234567', 'Xã A, Huyện B, Tỉnh C', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj9/4eXq8Wya', 'member'),
('tranthib',  'tranthib@email.com',  'Trần Thị B', '0907654321', 'Xã D, Huyện E, Tỉnh F', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj9/4eXq8Wya', 'member')
ON CONFLICT (username) DO NOTHING;

-- Members
INSERT INTO members (user_id, member_code, join_date, share_capital, notes)
VALUES 
(2, 'HTX001', '2023-01-15', 5000000, 'Thành viên sáng lập, chuyên trồng lúa'),
(3, 'HTX002', '2023-03-20', 3000000, 'Chuyên trồng rau màu và cây ăn quả')
ON CONFLICT (member_code) DO NOTHING;

-- Products
INSERT INTO products (name, category, description, unit, member_id)
VALUES 
('Lúa Jasmine',  'grain',     'Lúa thơm chất lượng cao', 'kg', 1),
('Rau cải xanh', 'vegetable', 'Rau cải xanh sạch',       'kg', 2),
('Cam sành',     'fruit',     'Cam sành ngọt tự nhiên',  'kg', 2)
ON CONFLICT DO NOTHING;

-- Seasons
INSERT INTO seasons (name, season_type, year, start_date, end_date, description)
VALUES 
('Vụ Đông Xuân 2024', 'winter', 2024, '2024-01-01', '2024-05-31', 'Mùa vụ chính của năm'),
('Vụ Mùa  2024',      'summer', 2024, '2024-06-01', '2024-10-31', 'Mùa vụ phụ')
ON CONFLICT DO NOTHING;

-- Financial transactions
INSERT INTO financial_transactions (transaction_code, user_id, transaction_type, category, amount, description, transaction_date)
VALUES 
('TXN001', 2, 'income',  'sales',         15000000, 'Bán lúa vụ đông xuân', '2024-05-15'),
('TXN002', 3, 'expense', 'operating_cost', 2000000, 'Mua phân bón',         '2024-02-10')
ON CONFLICT (transaction_code) DO NOTHING;

-- Inventory items
INSERT INTO inventory_items (name, item_type, description, unit, current_quantity, min_quantity, unit_price, supplier)
VALUES 
('Phân DAP',    'fertilizer', 'Phân lân dinh dưỡng',           'bao',   50, 10,  450000,   'Công ty TNHH Phân bón ABC'),
('Máy cày mini','equipment',  'Máy cày nhỏ cho ruộng nhỏ',     'chiếc',  2,  1, 15000000, 'Đại lý máy nông nghiệp XYZ')
ON CONFLICT DO NOTHING;

COMMIT;

-- Thông tin cuối
SELECT 'Database HTX Nông Nghiệp đã được tạo/hoàn thiện thành công!' AS message;
SELECT COUNT(*) AS total_tables FROM information_schema.tables WHERE table_schema = 'public';
