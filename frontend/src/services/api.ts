import axios from 'axios';
import { 
  User, 
  UserCreate, 
  LoginRequest, 
  AuthResponse, 
  Member, 
  MemberCreate, 
  Product, 
  ProductCreate,
  DashboardStats
} from '../types';

const API_BASE_URL = '/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('access_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authApi = {
  login: (credentials: LoginRequest): Promise<{ data: AuthResponse }> =>
    api.post('/auth/login', new URLSearchParams({
      username: credentials.username,
      password: credentials.password
    })),
  
  register: (userData: UserCreate): Promise<{ data: User }> =>
    api.post('/auth/register', userData),
  
  getMe: (): Promise<{ data: User }> =>
    api.get('/auth/me'),
};

// Members API
export const membersApi = {
  getAll: (): Promise<{ data: Member[] }> =>
    api.get('/members/'),
  
  getById: (id: number): Promise<{ data: Member }> =>
    api.get(`/members/${id}`),
  
  create: (memberData: MemberCreate): Promise<{ data: Member }> =>
    api.post('/members/', memberData),
  
  update: (id: number, memberData: Partial<MemberCreate>): Promise<{ data: Member }> =>
    api.put(`/members/${id}`, memberData),
  
  delete: (id: number): Promise<{ data: { message: string } }> =>
    api.delete(`/members/${id}`),
};

// Products API
export const productsApi = {
  getAll: (): Promise<{ data: Product[] }> =>
    api.get('/products/'),
  
  getById: (id: number): Promise<{ data: Product }> =>
    api.get(`/products/${id}`),
  
  create: (productData: ProductCreate): Promise<{ data: Product }> =>
    api.post('/products/', productData),
  
  update: (id: number, productData: Partial<ProductCreate>): Promise<{ data: Product }> =>
    api.put(`/products/${id}`, productData),
  
  delete: (id: number): Promise<{ data: { message: string } }> =>
    api.delete(`/products/${id}`),
};

// Dashboard API
export const dashboardApi = {
  getStats: (): Promise<{ data: DashboardStats }> =>
    api.get('/dashboard/stats'),
};

export default api;
