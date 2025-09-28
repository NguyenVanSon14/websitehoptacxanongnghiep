import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { 
  HomeIcon,
  UsersIcon,
  CubeIcon,
  DocumentTextIcon,
  CurrencyDollarIcon,
  ChartBarIcon,
  CogIcon,
  QrCodeIcon,
  CalendarIcon,
  TruckIcon
} from '@heroicons/react/24/outline';

const Sidebar: React.FC = () => {
  const location = useLocation();

  const navigation = [
    { name: 'Tổng quan', href: '/dashboard', icon: HomeIcon },
    { name: 'Thành viên', href: '/members', icon: UsersIcon },
    { name: 'Sản phẩm', href: '/products', icon: CubeIcon },
    { name: 'Thu hoạch', href: '/harvests', icon: ChartBarIcon },
    { name: 'Hợp đồng', href: '/contracts', icon: DocumentTextIcon },
    { name: 'Tài chính', href: '/financial', icon: CurrencyDollarIcon },
    { name: 'Kho vật tư', href: '/inventory', icon: TruckIcon },
    { name: 'Mùa vụ', href: '/seasons', icon: CalendarIcon },
    { name: 'Chứng nhận', href: '/certifications', icon: QrCodeIcon },
    { name: 'Cài đặt', href: '/settings', icon: CogIcon },
  ];

  return (
    <div className="w-64 bg-gray-900 text-white min-h-screen">
      <div className="p-6">
        <h2 className="text-lg font-semibold">Menu chính</h2>
      </div>
      
      <nav className="mt-6">
        {navigation.map((item) => {
          const isActive = location.pathname === item.href;
          return (
            <Link
              key={item.name}
              to={item.href}
              className={`flex items-center px-6 py-3 text-sm font-medium transition-colors ${
                isActive
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-300 hover:bg-gray-800 hover:text-white'
              }`}
            >
              <item.icon className="w-5 h-5 mr-3" />
              {item.name}
            </Link>
          );
        })}
      </nav>
    </div>
  );
};

export default Sidebar;
