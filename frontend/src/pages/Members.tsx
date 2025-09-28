import React, { useState, useEffect } from 'react';
import Layout from '../components/Layout/Layout';
import { 
  PlusIcon, 
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon
} from '@heroicons/react/24/outline';
import { membersApi } from '../services/api';
import { Member } from '../types';

const Members: React.FC = () => {
  const [members, setMembers] = useState<Member[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showAddModal, setShowAddModal] = useState(false);

  useEffect(() => {
    fetchMembers();
  }, []);

  const fetchMembers = async () => {
    try {
      const response = await membersApi.getAll();
      setMembers(response.data);
    } catch (error) {
      console.error('Error fetching members:', error);
      // Mock data for now
      setMembers([
        {
          id: 1,
          user_id: 1,
          member_code: 'HTX001',
          join_date: '2023-01-15',
          share_capital: 5000000,
          is_active: true,
          notes: 'Thành viên sáng lập',
          created_at: '2023-01-15T00:00:00',
          user: {
            id: 1,
            username: 'nguyenvana',
            email: 'nguyenvana@email.com',
            full_name: 'Nguyễn Văn A',
            phone: '0901234567',
            address: 'Huyện A, Tỉnh B',
            role: 'member' as const,
            is_active: true,
            is_verified: true,
            created_at: '2023-01-15T00:00:00'
          }
        },
        {
          id: 2,
          user_id: 2,
          member_code: 'HTX002',
          join_date: '2023-03-20',
          share_capital: 3000000,
          is_active: true,
          notes: 'Chuyên trồng lúa',
          created_at: '2023-03-20T00:00:00',
          user: {
            id: 2,
            username: 'tranthib',
            email: 'tranthib@email.com',
            full_name: 'Trần Thị B',
            phone: '0907654321',
            address: 'Huyện C, Tỉnh D',
            role: 'member' as const,
            is_active: true,
            is_verified: true,
            created_at: '2023-03-20T00:00:00'
          }
        }
      ]);
    } finally {
      setLoading(false);
    }
  };

  const filteredMembers = members.filter(member =>
    member.user?.full_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    member.member_code.toLowerCase().includes(searchTerm.toLowerCase()) ||
    member.user?.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('vi-VN');
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Quản lý thành viên</h1>
            <p className="mt-1 text-sm text-gray-500">
              Quản lý thông tin các thành viên trong hợp tác xã
            </p>
          </div>
          <button
            onClick={() => setShowAddModal(true)}
            className="btn-primary flex items-center space-x-2"
          >
            <PlusIcon className="w-5 h-5" />
            <span>Thêm thành viên</span>
          </button>
        </div>

        {/* Search and Filters */}
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <div className="relative">
                <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  placeholder="Tìm kiếm theo tên, mã thành viên, email..."
                  className="input-field pl-10"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
            </div>
            <div className="flex space-x-2">
              <select className="input-field">
                <option value="">Tất cả trạng thái</option>
                <option value="active">Đang hoạt động</option>
                <option value="inactive">Không hoạt động</option>
              </select>
              <select className="input-field">
                <option value="">Sắp xếp theo</option>
                <option value="name">Tên</option>
                <option value="join_date">Ngày tham gia</option>
                <option value="share_capital">Vốn góp</option>
              </select>
            </div>
          </div>
        </div>

        {/* Members Table */}
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="table">
              <thead>
                <tr>
                  <th>Mã thành viên</th>
                  <th>Tên thành viên</th>
                  <th>Email</th>
                  <th>Số điện thoại</th>
                  <th>Ngày tham gia</th>
                  <th>Vốn góp</th>
                  <th>Trạng thái</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {filteredMembers.map((member) => (
                  <tr key={member.id} className="hover:bg-gray-50">
                    <td className="font-medium text-blue-600">
                      {member.member_code}
                    </td>
                    <td>
                      <div>
                        <div className="font-medium text-gray-900">
                          {member.user?.full_name}
                        </div>
                        <div className="text-sm text-gray-500">
                          @{member.user?.username}
                        </div>
                      </div>
                    </td>
                    <td>{member.user?.email}</td>
                    <td>{member.user?.phone}</td>
                    <td>{formatDate(member.join_date)}</td>
                    <td className="font-medium">
                      {formatCurrency(member.share_capital)}
                    </td>
                    <td>
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        member.is_active
                          ? 'bg-green-100 text-green-800'
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {member.is_active ? 'Hoạt động' : 'Không hoạt động'}
                      </span>
                    </td>
                    <td>
                      <div className="flex space-x-2">
                        <button className="text-blue-600 hover:text-blue-900">
                          <EyeIcon className="w-4 h-4" />
                        </button>
                        <button className="text-blue-600 hover:text-blue-900">
                          <PencilIcon className="w-4 h-4" />
                        </button>
                        <button className="text-red-600 hover:text-red-900">
                          <TrashIcon className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Pagination */}
        <div className="flex items-center justify-between">
          <div className="text-sm text-gray-700">
            Hiển thị <span className="font-medium">1</span> đến{' '}
            <span className="font-medium">{filteredMembers.length}</span> trong tổng số{' '}
            <span className="font-medium">{filteredMembers.length}</span> kết quả
          </div>
          <div className="flex space-x-2">
            <button className="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50">
              Trước
            </button>
            <button className="px-3 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700">
              1
            </button>
            <button className="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50">
              Sau
            </button>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default Members;
