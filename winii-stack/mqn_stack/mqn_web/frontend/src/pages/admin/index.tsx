import React, { useState } from 'react';
import Head from 'next/head';
import { motion } from 'framer-motion';
import { 
  BarChart3, 
  Users, 
  MessageSquare, 
  Package, 
  Settings, 
  LogOut,
  Plus,
  Search,
  Filter,
  Calendar,
  Clock,
  CheckCircle,
  AlertCircle,
  XCircle,
  TrendingUp,
  DollarSign,
  FileText,
  Palette,
  Printer,
  Zap
} from 'lucide-react';

export default function AdminDashboard() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const stats = [
    { title: 'Conversaciones Activas', value: '24', icon: MessageSquare, color: 'blue', change: '+12%' },
    { title: 'Pedidos Pendientes', value: '18', icon: Package, color: 'yellow', change: '+5%' },
    { title: 'Clientes Nuevos', value: '156', icon: Users, color: 'green', change: '+23%' },
    { title: 'Ingresos del Mes', value: '$45,230', icon: DollarSign, color: 'purple', change: '+18%' }
  ];

  const recentConversations = [
    { id: 1, client: 'María González', message: 'Necesito cotización para letreros...', time: '2 min', status: 'nuevo' },
    { id: 2, client: 'Carlos Mendoza', message: '¿Cuándo estará listo mi pedido?', time: '15 min', status: 'respondido' },
    { id: 3, client: 'Ana Rodríguez', message: 'Quiero cambiar el diseño...', time: '1 hora', status: 'pendiente' },
    { id: 4, client: 'Luis Pérez', message: 'Excelente trabajo, gracias!', time: '2 horas', status: 'completado' }
  ];

  const recentOrders = [
    { id: 'MQN-001', client: 'Restaurante El Sabor', amount: '$2,450', status: 'en_producción', progress: 75 },
    { id: 'MQN-002', client: 'Auto Servicio Express', amount: '$1,890', status: 'diseño', progress: 30 },
    { id: 'MQN-003', client: 'Boutique Elegance', amount: '$3,120', status: 'aprobado', progress: 10 },
    { id: 'MQN-004', client: 'Farmacia Central', amount: '$980', status: 'completado', progress: 100 }
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'nuevo': return 'bg-blue-100 text-blue-800';
      case 'respondido': return 'bg-green-100 text-green-800';
      case 'pendiente': return 'bg-yellow-100 text-yellow-800';
      case 'completado': return 'bg-gray-100 text-gray-800';
      case 'en_producción': return 'bg-purple-100 text-purple-800';
      case 'diseño': return 'bg-indigo-100 text-indigo-800';
      case 'aprobado': return 'bg-orange-100 text-orange-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'nuevo': return <AlertCircle className="w-4 h-4" />;
      case 'respondido': return <CheckCircle className="w-4 h-4" />;
      case 'pendiente': return <Clock className="w-4 h-4" />;
      case 'completado': return <CheckCircle className="w-4 h-4" />;
      case 'en_producción': return <Printer className="w-4 h-4" />;
      case 'diseño': return <Palette className="w-4 h-4" />;
      case 'aprobado': return <CheckCircle className="w-4 h-4" />;
      default: return <Clock className="w-4 h-4" />;
    }
  };

  return (
    <>
      <Head>
        <title>Administración - Media Quality Net</title>
        <meta name="description" content="Panel de administración del ecosistema MQN" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      <div className="min-h-screen bg-gray-50">
        {/* Sidebar */}
        <div className={`fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'} transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0`}>
          <div className="flex items-center justify-between h-16 px-6 border-b border-gray-200">
            <div className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-gradient-to-br from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-sm">MQN</span>
              </div>
              <span className="text-lg font-semibold text-gray-900">Admin</span>
            </div>
            <button
              onClick={() => setSidebarOpen(false)}
              className="lg:hidden p-2 rounded-md text-gray-400 hover:text-gray-600"
            >
              <XCircle className="w-5 h-5" />
            </button>
          </div>
          
          <nav className="mt-6 px-3">
            <div className="space-y-1">
              {[
                { id: 'dashboard', name: 'Dashboard', icon: BarChart3 },
                { id: 'conversations', name: 'Conversaciones', icon: MessageSquare },
                { id: 'clients', name: 'Clientes', icon: Users },
                { id: 'orders', name: 'Pedidos', icon: Package },
                { id: 'workflows', name: 'Flujos de Trabajo', icon: Zap },
                { id: 'inventory', name: 'Inventario', icon: Package },
                { id: 'reports', name: 'Reportes', icon: FileText },
                { id: 'settings', name: 'Configuración', icon: Settings }
              ].map((item) => (
                <button
                  key={item.id}
                  onClick={() => setActiveTab(item.id)}
                  className={`w-full flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    activeTab === item.id
                      ? 'bg-blue-100 text-blue-700'
                      : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                  }`}
                >
                  <item.icon className="w-5 h-5 mr-3" />
                  {item.name}
                </button>
              ))}
            </div>
          </nav>
        </div>

        {/* Main Content */}
        <div className="lg:pl-64">
          {/* Top Bar */}
          <div className="sticky top-0 z-40 bg-white border-b border-gray-200">
            <div className="flex items-center justify-between h-16 px-4 sm:px-6 lg:px-8">
              <button
                onClick={() => setSidebarOpen(true)}
                className="lg:hidden p-2 rounded-md text-gray-400 hover:text-gray-600"
              >
                <BarChart3 className="w-6 h-6" />
              </button>
              
              <div className="flex items-center space-x-4">
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <input
                    type="text"
                    placeholder="Buscar..."
                    className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
                
                <button className="flex items-center space-x-2 text-gray-600 hover:text-gray-900">
                  <span className="text-sm font-medium">Admin MQN</span>
                  <LogOut className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>

          {/* Page Content */}
          <main className="p-4 sm:p-6 lg:p-8">
            {activeTab === 'dashboard' && (
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="space-y-6"
              >
                {/* Stats Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                  {stats.map((stat, index) => (
                    <motion.div
                      key={stat.title}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.1 }}
                      className="bg-white rounded-xl p-6 shadow-soft"
                    >
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="text-sm font-medium text-gray-600">{stat.title}</p>
                          <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                        </div>
                        <div className={`w-12 h-12 bg-${stat.color}-100 rounded-lg flex items-center justify-center`}>
                          <stat.icon className={`w-6 h-6 text-${stat.color}-600`} />
                        </div>
                      </div>
                      <div className="mt-4 flex items-center">
                        <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
                        <span className="text-sm text-green-600">{stat.change}</span>
                        <span className="text-sm text-gray-500 ml-1">vs mes anterior</span>
                      </div>
                    </motion.div>
                  ))}
                </div>

                {/* Main Content Grid */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                  {/* Recent Conversations */}
                  <div className="bg-white rounded-xl shadow-soft">
                    <div className="p-6 border-b border-gray-200">
                      <div className="flex items-center justify-between">
                        <h2 className="text-lg font-semibold text-gray-900">Conversaciones Recientes</h2>
                        <button className="text-blue-600 hover:text-blue-700 text-sm font-medium">
                          Ver todas
                        </button>
                      </div>
                    </div>
                    <div className="p-6">
                      <div className="space-y-4">
                        {recentConversations.map((conversation) => (
                          <div key={conversation.id} className="flex items-start space-x-3">
                            <div className="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center">
                              <span className="text-sm font-medium text-gray-600">
                                {conversation.client.charAt(0)}
                              </span>
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="text-sm font-medium text-gray-900">{conversation.client}</p>
                              <p className="text-sm text-gray-600 truncate">{conversation.message}</p>
                              <div className="flex items-center space-x-2 mt-1">
                                <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(conversation.status)}`}>
                                  {getStatusIcon(conversation.status)}
                                  <span className="ml-1">{conversation.status}</span>
                                </span>
                                <span className="text-xs text-gray-500">{conversation.time}</span>
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Recent Orders */}
                  <div className="bg-white rounded-xl shadow-soft">
                    <div className="p-6 border-b border-gray-200">
                      <div className="flex items-center justify-between">
                        <h2 className="text-lg font-semibold text-gray-900">Pedidos Recientes</h2>
                        <button className="text-blue-600 hover:text-blue-700 text-sm font-medium">
                          Ver todos
                        </button>
                      </div>
                    </div>
                    <div className="p-6">
                      <div className="space-y-4">
                        {recentOrders.map((order) => (
                          <div key={order.id} className="border border-gray-200 rounded-lg p-4">
                            <div className="flex items-center justify-between mb-2">
                              <span className="text-sm font-medium text-gray-900">{order.id}</span>
                              <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(order.status)}`}>
                                {getStatusIcon(order.status)}
                                <span className="ml-1">{order.status.replace('_', ' ')}</span>
                              </span>
                            </div>
                            <p className="text-sm text-gray-600 mb-2">{order.client}</p>
                            <div className="flex items-center justify-between">
                              <span className="text-sm font-semibold text-gray-900">{order.amount}</span>
                              <div className="flex items-center space-x-2">
                                <div className="w-20 bg-gray-200 rounded-full h-2">
                                  <div 
                                    className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                                    style={{ width: `${order.progress}%` }}
                                  ></div>
                                </div>
                                <span className="text-xs text-gray-500">{order.progress}%</span>
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Quick Actions */}
                <div className="bg-white rounded-xl shadow-soft p-6">
                  <h2 className="text-lg font-semibold text-gray-900 mb-4">Acciones Rápidas</h2>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <button className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                      <Plus className="w-8 h-8 text-blue-600 mb-2" />
                      <span className="text-sm font-medium text-gray-700">Nuevo Cliente</span>
                    </button>
                    <button className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                      <FileText className="w-8 h-8 text-green-600 mb-2" />
                      <span className="text-sm font-medium text-gray-700">Nueva Cotización</span>
                    </button>
                    <button className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                      <Package className="w-8 h-8 text-purple-600 mb-2" />
                      <span className="text-sm font-medium text-gray-700">Nuevo Pedido</span>
                    </button>
                    <button className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                      <Zap className="w-8 h-8 text-yellow-600 mb-2" />
                      <span className="text-sm font-medium text-gray-700">Nuevo Flujo</span>
                    </button>
                  </div>
                </div>
              </motion.div>
            )}

            {activeTab === 'conversations' && (
              <div className="bg-white rounded-xl shadow-soft p-6">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Gestión de Conversaciones</h2>
                <p className="text-gray-600">Panel para gestionar todas las conversaciones de WhatsApp</p>
              </div>
            )}

            {activeTab === 'clients' && (
              <div className="bg-white rounded-xl shadow-soft p-6">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Gestión de Clientes</h2>
                <p className="text-gray-600">Administración completa de la base de clientes</p>
              </div>
            )}

            {activeTab === 'orders' && (
              <div className="bg-white rounded-xl shadow-soft p-6">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Gestión de Pedidos</h2>
                <p className="text-gray-600">Seguimiento y gestión de todos los pedidos</p>
              </div>
            )}

            {activeTab === 'workflows' && (
              <div className="bg-white rounded-xl shadow-soft p-6">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Flujos de Trabajo</h2>
                <p className="text-gray-600">Gestión de procesos y asignación de tareas</p>
              </div>
            )}

            {activeTab === 'inventory' && (
              <div className="bg-white rounded-xl shadow-soft p-6">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Inventario</h2>
                <p className="text-gray-600">Control de materiales y stock</p>
              </div>
            )}

            {activeTab === 'reports' && (
              <div className="bg-white rounded-xl shadow-soft p-6">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Reportes</h2>
                <p className="text-gray-600">Análisis y métricas del negocio</p>
              </div>
            )}

            {activeTab === 'settings' && (
              <div className="bg-white rounded-xl shadow-soft p-6">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Configuración</h2>
                <p className="text-gray-600">Ajustes del sistema y preferencias</p>
              </div>
            )}
          </main>
        </div>
      </div>
    </>
  );
}
