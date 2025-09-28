# Website Quản Lý Hợp Tác Xã Nông Nghiệp

Hệ thống quản lý toàn diện cho hợp tác xã nông nghiệp với các chức năng quản lý thành viên, sản phẩm, tài chính, hợp đồng và tích hợp AI.

## 🚀 Tính năng chính

### Quản lý cơ bản
- ✅ Quản lý tài khoản (thành viên, khách hàng, quản trị)
- ✅ Quản lý sản phẩm và sản lượng
- ✅ Quản lý tài chính (thu chi, vốn góp, chia lợi nhuận)
- ✅ Quản lý hợp đồng và tiêu thụ sản phẩm

### Báo cáo và thống kê
- ✅ Dashboard với báo cáo trực quan
- ✅ Biểu đồ thống kê doanh thu, sản lượng
- ✅ Xuất báo cáo PDF

### Quản lý nâng cao
- 🔄 Quản lý kho vật tư, nông cụ
- 🔄 Quản lý lịch mùa vụ, nhắc việc
- 🔄 Quản lý khách hàng & CRM mini
- 🔄 Quản lý chứng nhận & truy xuất nguồn gốc QR Code

### Tích hợp AI
- 🔄 Chatbot AI tư vấn nông nghiệp
- 🔄 Gợi ý mùa vụ dựa trên thời tiết
- 🔄 Dự đoán sản lượng và giá cả

## 🛠️ Công nghệ sử dụng

### Frontend
- **React 19** với TypeScript
- **Vite** - Build tool nhanh
- **TailwindCSS** - Styling framework
- **React Router** - Routing
- **Axios** - HTTP client
- **Heroicons** - Icon library
- **Recharts** - Charts và biểu đồ

### Backend
- **FastAPI** - Web framework Python
- **SQLAlchemy** - ORM
- **PostgreSQL** - Database chính
- **Redis** - Cache và realtime
- **JWT** - Authentication
- **WebSocket** - Real-time communication

### AI & Analytics
- **OpenAI API** - AI chatbot
- **Google Gemini** - AI suggestions
- **Matplotlib/Seaborn** - Data visualization
- **Pandas/NumPy** - Data processing

## 📁 Cấu trúc dự án

```
websitequanlyhoptacxanongnghiep/
├── backend/
│   ├── app/
│   │   ├── models/          # Database models
│   │   ├── schemas/         # Pydantic schemas
│   │   ├── routers/         # API routes
│   │   ├── auth.py          # Authentication
│   │   ├── database.py      # Database config
│   │   └── main.py          # FastAPI app
│   ├── requirements.txt     # Python dependencies
│   └── env.example         # Environment variables
├── frontend/
│   ├── src/
│   │   ├── components/      # React components
│   │   ├── pages/          # Page components
│   │   ├── services/       # API services
│   │   ├── contexts/       # React contexts
│   │   ├── types/          # TypeScript types
│   │   └── utils/          # Utility functions
│   ├── package.json        # Node dependencies
│   └── vite.config.ts      # Vite config
└── README.md
```

## 🚀 Cài đặt và chạy

### Yêu cầu hệ thống
- Python 3.9+
- Node.js 18+
- PostgreSQL 13+
- Redis 6+

### 1. Cài đặt Backend

```bash
# Di chuyển vào thư mục backend
cd backend

# Tạo virtual environment
python -m venv venv

# Kích hoạt virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Cài đặt dependencies
pip install -r requirements.txt

# Sao chép file env
copy env.example .env
# Linux/Mac: cp env.example .env

# Chỉnh sửa file .env với thông tin database của bạn
DATABASE_URL=postgresql://username:password@localhost/htx_agri
SECRET_KEY=your-secret-key-here
```

### 2. Cài đặt Database

```bash
# Tạo database PostgreSQL
createdb htx_agri

# Chạy script tạo tables
python app/create_tables.py
```

### 3. Cài đặt Frontend

```bash
# Di chuyển vào thư mục frontend
cd frontend

# Cài đặt dependencies
npm install

# Hoặc sử dụng yarn
yarn install
```

### 4. Chạy ứng dụng

#### Backend
```bash
cd backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Frontend
```bash
cd frontend
npm run dev
# Hoặc
yarn dev
```

#### Redis (cho cache và realtime)
```bash
redis-server
```

### 5. Truy cập ứng dụng

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

## 🔐 Tài khoản mặc định

Sau khi chạy lần đầu, bạn có thể tạo tài khoản admin thông qua API:

```bash
curl -X POST "http://localhost:8000/auth/register" \
     -H "Content-Type: application/json" \
     -d '{
       "username": "admin",
       "email": "admin@htx.com",
       "full_name": "Quản trị viên",
       "password": "admin123",
       "role": "admin"
     }'
```

## 📊 API Endpoints

### Authentication
- `POST /auth/login` - Đăng nhập
- `POST /auth/register` - Đăng ký
- `GET /auth/me` - Thông tin user hiện tại

### Members
- `GET /members/` - Danh sách thành viên
- `POST /members/` - Tạo thành viên mới
- `GET /members/{id}` - Chi tiết thành viên
- `PUT /members/{id}` - Cập nhật thành viên
- `DELETE /members/{id}` - Xóa thành viên

### Products
- `GET /products/` - Danh sách sản phẩm
- `POST /products/` - Tạo sản phẩm mới
- `GET /products/{id}` - Chi tiết sản phẩm
- `PUT /products/{id}` - Cập nhật sản phẩm
- `DELETE /products/{id}` - Xóa sản phẩm

## 🔧 Phát triển

### Thêm model mới

1. Tạo model trong `backend/app/models/`
2. Tạo schema trong `backend/app/schemas/`
3. Tạo router trong `backend/app/routers/`
4. Thêm vào `backend/app/main.py`

### Thêm trang mới

1. Tạo component trong `frontend/src/pages/`
2. Thêm route vào `frontend/src/App.tsx`
3. Thêm menu item vào `frontend/src/components/Layout/Sidebar.tsx`

## 📝 Ghi chú phát triển

- Sử dụng TypeScript cho type safety
- Tuân thủ RESTful API conventions
- Sử dụng JWT cho authentication
- Implement proper error handling
- Thêm validation cho tất cả inputs
- Viết tests cho các chức năng quan trọng

## 🤝 Đóng góp

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Liên hệ

- Email: support@htx-agri.com
- Website: https://htx-agri.com
