// User Types
export interface User {
  id: number;
  username: string;
  email: string;
  full_name: string;
  phone?: string;
  address?: string;
  role: 'admin' | 'member' | 'customer' | 'manager';
  is_active: boolean;
  is_verified: boolean;
  created_at: string;
  updated_at?: string;
}

export interface UserCreate {
  username: string;
  email: string;
  full_name: string;
  phone?: string;
  address?: string;
  role: 'admin' | 'member' | 'customer' | 'manager';
  password: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface AuthResponse {
  access_token: string;
  token_type: string;
}

// Member Types
export interface Member {
  id: number;
  user_id: number;
  member_code: string;
  join_date: string;
  share_capital: number;
  is_active: boolean;
  notes?: string;
  created_at: string;
  updated_at?: string;
  user?: User;
}

export interface MemberCreate {
  user_id: number;
  member_code: string;
  join_date: string;
  share_capital: number;
  notes?: string;
}

// Product Types
export interface Product {
  id: number;
  name: string;
  category: 'vegetable' | 'fruit' | 'grain' | 'livestock' | 'other';
  description?: string;
  unit: string;
  member_id?: number;
  is_active: boolean;
  created_at: string;
  updated_at?: string;
  member?: Member;
}

export interface ProductCreate {
  name: string;
  category: 'vegetable' | 'fruit' | 'grain' | 'livestock' | 'other';
  description?: string;
  unit: string;
  member_id?: number;
}

// Harvest Types
export interface Harvest {
  id: number;
  product_id: number;
  member_id: number;
  harvest_date: string;
  quantity: number;
  quality_grade?: string;
  price_per_unit?: number;
  total_value?: number;
  notes?: string;
  created_at: string;
  updated_at?: string;
  product?: Product;
  member?: Member;
}

// Contract Types
export interface Contract {
  id: number;
  contract_code: string;
  member_id: number;
  customer_id: number;
  title: string;
  description?: string;
  start_date: string;
  end_date: string;
  total_value?: number;
  status: 'draft' | 'active' | 'completed' | 'cancelled';
  notes?: string;
  created_at: string;
  updated_at?: string;
  member?: Member;
  customer?: User;
  contract_items?: ContractItem[];
}

export interface ContractItem {
  id: number;
  contract_id: number;
  product_id: number;
  quantity: number;
  unit_price: number;
  total_price: number;
  delivery_date?: string;
  notes?: string;
  product?: Product;
}

// Financial Types
export interface FinancialTransaction {
  id: number;
  transaction_code: string;
  user_id: number;
  transaction_type: 'income' | 'expense' | 'investment' | 'dividend';
  category: string;
  amount: number;
  description: string;
  transaction_date: string;
  reference_document?: string;
  notes?: string;
  created_at: string;
  updated_at?: string;
  user?: User;
}

// Dashboard Types
export interface DashboardStats {
  total_members: number;
  total_products: number;
  total_revenue: number;
  active_contracts: number;
}

// API Response Types
export interface ApiResponse<T> {
  data: T;
  message?: string;
  success: boolean;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}
