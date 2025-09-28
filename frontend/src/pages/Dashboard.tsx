import React, { useState, useEffect } from 'react';
import Layout from '../components/Layout/Layout';
import { 
  UsersIcon, 
  CubeIcon, 
  CurrencyDollarIcon, 
  DocumentTextIcon,
  TrendingUpIcon,
  TrendingDownIcon
} from '@heroicons/react/24/outline';
import { dashboardApi } from '../services/api';
import { DashboardStats } from '../types';

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        // Mock data for now - replace with actual API call
        setStats({
          total_members: 45,
          total_products: 128,
          total_revenue: 1250000000,
          active_contracts: 23
        });
      } catch (error) {
        console.error('Error fetching dashboard stats:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(amount);
  };

  const statCards = [
    {
      name: 'Tổng thành viên',
      value: stats?.total_members || 0,
      icon: UsersIcon,
      change: '+12%',
      changeType: 'increase' as const,
      color: 'blue'
    },
    {
      name: 'Sản phẩm',
      value: stats?.total_products || 0,
      icon: CubeIcon,
      change: '+8%',
      changeType: 'increase' as const,
      color: 'green'
    },
    {
      name: 'Doanh thu',
      value: formatCurrency(stats?.total_revenue || 0),
      icon: CurrencyDollarIcon,
      change: '+15%',
      changeType: 'increase' as const,
      color: 'yellow'
    },
    {
      name: 'Hợp đồng hoạt động',
      value: stats?.active_contracts || 0,
      icon: DocumentTextIcon,
      change: '+3%',
      changeType: 'increase' as const,
      color: 'purple'
    }
  ];

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
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Tổng quan hệ thống</h1>
          <p className="mt-1 text-sm text-gray-500">
            Chào mừng bạn đến với hệ thống quản lý hợp tác xã nông nghiệp
          </p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {statCards.map((card) => (
            <div key={card.name} className="card">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className={`p-3 rounded-lg bg-${card.color}-100`}>
                    <card.icon className={`h-6 w-6 text-${card.color}-600`} />
                  </div>
                </div>
                <div className="ml-4 flex-1">
                  <p className="text-sm font-medium text-gray-500">{card.name}</p>
                  <p className="text-2xl font-semibold text-gray-900">{card.value}</p>
                </div>
              </div>
              <div className="mt-4">
                <div className="flex items-center text-sm">
                  {card.changeType === 'increase' ? (
                    <TrendingUpIcon className="h-4 w-4 text-green-500 mr-1" />
                  ) : (
                    <TrendingDownIcon className="h-4 w-4 text-red-500 mr-1" />
                  )}
                  <span className={`font-medium ${
                    card.changeType === 'increase' ? 'text-green-600' : 'text-red-600'
                  }`}>
                    {card.change}
                  </span>
                  <span className="text-gray-500 ml-1">so với tháng trước</span>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Recent Activity */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="card">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Hoạt động gần đây</h3>
            <div className="space-y-4">
              <div className="flex items-center space-x-3">
                <div className="flex-shrink-0">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm text-gray-900">Thành viên mới đăng ký</p>
                  <p className="text-xs text-gray-500">Nguyễn Văn A - 2 giờ trước</p>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <div className="flex-shrink-0">
                  <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm text-gray-900">Hợp đồng mới được tạo</p>
                  <p className="text-xs text-gray-500">Hợp đồng #HTX-001 - 4 giờ trước</p>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <div className="flex-shrink-0">
                  <div className="w-2 h-2 bg-yellow-500 rounded-full"></div>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm text-gray-900">Thu hoạch mới</p>
                  <p className="text-xs text-gray-500">Lúa - 500kg - 6 giờ trước</p>
                </div>
              </div>
            </div>
          </div>

          <div className="card">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Thống kê nhanh</h3>
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-600">Sản phẩm đang bán</span>
                <span className="text-sm font-medium text-gray-900">85</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-600">Hợp đồng sắp hết hạn</span>
                <span className="text-sm font-medium text-red-600">3</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-600">Thành viên hoạt động</span>
                <span className="text-sm font-medium text-green-600">42/45</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-600">Doanh thu tháng này</span>
                <span className="text-sm font-medium text-gray-900">125M VND</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default Dashboard;
