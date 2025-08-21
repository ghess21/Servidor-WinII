import React from 'react';
import Head from 'next/head';
import { motion } from 'framer-motion';
import { 
  Printer, 
  Palette, 
  Zap, 
  Users, 
  Award, 
  Phone,
  MessageCircle,
  ArrowRight,
  CheckCircle,
  Star,
  Shield,
  Clock
} from 'lucide-react';

export default function Home() {
  const services = [
    {
      icon: Printer,
      title: 'Impresión Gran Formato',
      description: 'Impresiones de alta calidad en materiales especiales hasta 3m de ancho',
      features: ['Láminas', 'Banners', 'Viniles', 'Lonas']
    },
    {
      icon: Palette,
      title: 'Diseño Gráfico',
      description: 'Creación de diseños profesionales y creativos para tu marca',
      features: ['Logos', 'Identidad Visual', 'Material Publicitario', 'Packaging']
    },
    {
      icon: Zap,
      title: 'Letreros y Señalización',
      description: 'Letreros personalizados con técnicas avanzadas de producción',
      features: ['Acrílico', 'PVC', 'Aluminio', 'Neón Flex']
    },
    {
      icon: Users,
      title: 'Sublimación y DTF',
      description: 'Personalización de productos textiles y promocionales',
      features: ['Tazas', 'Camisetas', 'Gorras', 'Accesorios']
    }
  ];

  const techniques = [
    'Impresión Laser A3',
    'Impresión Inkjet A4',
    'Sublimación Textil',
    'DTF UV',
    'Serigrafía',
    'Foil Reactivo',
    'Hot Stamping',
    'Offset Digital',
    'CNC Router 120x120',
    'Laser CO2 110x110',
    'Impresión 3D 4 Colores'
  ];

  const testimonials = [
    {
      name: 'María González',
      company: 'Restaurante El Sabor',
      text: 'Excelente trabajo en nuestros letreros. El diseño superó nuestras expectativas.',
      rating: 5
    },
    {
      name: 'Carlos Mendoza',
      company: 'Auto Servicio Express',
      text: 'Materialización de ideas en su máxima expresión. Muy profesionales.',
      rating: 5
    },
    {
      name: 'Ana Rodríguez',
      company: 'Boutique Elegance',
      text: 'Calidad excepcional en impresiones y acabados. Altamente recomendados.',
      rating: 5
    }
  ];

  return (
    <>
      <Head>
        <title>Media Quality Net - Materializando tus ideas</title>
        <meta name="description" content="Empresa líder en publicidad impresa, diseño gráfico y señalización. Ofrecemos impresión gran formato, letreros personalizados, sublimación y más." />
        <meta name="keywords" content="impresión, letreros, diseño gráfico, sublimación, DTF, serigrafía, publicidad" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
        
        {/* SEO Meta Tags */}
        <meta property="og:title" content="Media Quality Net - Materializando tus ideas" />
        <meta property="og:description" content="Empresa líder en publicidad impresa, diseño gráfico y señalización" />
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://www.mediaquality.net" />
        <meta property="og:image" content="/og-image.jpg" />
        
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="Media Quality Net" />
        <meta name="twitter:description" content="Materializando tus ideas en publicidad impresa" />
      </Head>

      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
        {/* Header */}
        <header className="bg-white shadow-soft sticky top-0 z-50">
          <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center h-16">
              <motion.div 
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                className="flex items-center space-x-2"
              >
                <div className="w-10 h-10 bg-gradient-to-br from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-xl">MQN</span>
                </div>
                <span className="text-2xl font-display font-bold text-gray-900">Media Quality Net</span>
              </motion.div>
              
              <div className="hidden md:flex items-center space-x-8">
                <a href="#servicios" className="text-gray-700 hover:text-blue-600 transition-colors">Servicios</a>
                <a href="#tecnologias" className="text-gray-700 hover:text-blue-600 transition-colors">Tecnologías</a>
                <a href="#contacto" className="text-gray-700 hover:text-blue-600 transition-colors">Contacto</a>
                <a 
                  href="/admin" 
                  className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Administración
                </a>
              </div>
            </div>
          </nav>
        </header>

        {/* Hero Section */}
        <section className="relative py-20 px-4 sm:px-6 lg:px-8">
          <div className="max-w-7xl mx-auto text-center">
            <motion.h1 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
              className="text-5xl md:text-7xl font-display font-bold text-gray-900 mb-6"
            >
              Materializando
              <span className="block text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600">
                tus ideas
              </span>
            </motion.h1>
            
            <motion.p 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="text-xl md:text-2xl text-gray-600 mb-8 max-w-3xl mx-auto"
            >
              Somos especialistas en publicidad impresa, diseño gráfico y señalización. 
              Convertimos tus visiones en realidad con la más alta calidad y tecnología avanzada.
            </motion.p>
            
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className="flex flex-col sm:flex-row gap-4 justify-center"
            >
              <a 
                href="#contacto" 
                className="bg-blue-600 text-white px-8 py-4 rounded-xl text-lg font-semibold hover:bg-blue-700 transition-all transform hover:scale-105 shadow-medium"
              >
                Solicitar Cotización
              </a>
              <a 
                href="#servicios" 
                className="border-2 border-blue-600 text-blue-600 px-8 py-4 rounded-xl text-lg font-semibold hover:bg-blue-50 transition-all"
              >
                Ver Servicios
              </a>
            </motion.div>
          </div>
        </section>

        {/* Services Section */}
        <section id="servicios" className="py-20 px-4 sm:px-6 lg:px-8 bg-white">
          <div className="max-w-7xl mx-auto">
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="text-center mb-16"
            >
              <h2 className="text-4xl md:text-5xl font-display font-bold text-gray-900 mb-4">
                Nuestros Servicios
              </h2>
              <p className="text-xl text-gray-600 max-w-2xl mx-auto">
                Ofrecemos soluciones integrales en publicidad impresa y diseño gráfico
              </p>
            </motion.div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
              {services.map((service, index) => (
                <motion.div
                  key={service.title}
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.1 }}
                  className="bg-white rounded-2xl p-6 shadow-soft hover:shadow-medium transition-all transform hover:-translate-y-2 border border-gray-100"
                >
                  <div className="w-16 h-16 bg-blue-100 rounded-xl flex items-center justify-center mb-6">
                    <service.icon className="w-8 h-8 text-blue-600" />
                  </div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-3">{service.title}</h3>
                  <p className="text-gray-600 mb-4">{service.description}</p>
                  <ul className="space-y-2">
                    {service.features.map((feature) => (
                      <li key={feature} className="flex items-center text-sm text-gray-500">
                        <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                        {feature}
                      </li>
                    ))}
                  </ul>
                </motion.div>
              ))}
            </div>
          </div>
        </section>

        {/* Technologies Section */}
        <section id="tecnologias" className="py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-br from-blue-50 to-indigo-50">
          <div className="max-w-7xl mx-auto">
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="text-center mb-16"
            >
              <h2 className="text-4xl md:text-5xl font-display font-bold text-gray-900 mb-4">
                Tecnologías Avanzadas
              </h2>
              <p className="text-xl text-gray-600 max-w-2xl mx-auto">
                Contamos con el equipamiento más moderno para garantizar la máxima calidad
              </p>
            </motion.div>
            
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              {techniques.map((technique, index) => (
                <motion.div
                  key={technique}
                  initial={{ opacity: 0, scale: 0.9 }}
                  whileInView={{ opacity: 1, scale: 1 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.05 }}
                  className="bg-white rounded-xl p-4 shadow-soft text-center hover:shadow-medium transition-all"
                >
                  <span className="text-sm font-medium text-gray-700">{technique}</span>
                </motion.div>
              ))}
            </div>
          </div>
        </section>

        {/* Testimonials Section */}
        <section className="py-20 px-4 sm:px-6 lg:px-8 bg-white">
          <div className="max-w-7xl mx-auto">
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="text-center mb-16"
            >
              <h2 className="text-4xl md:text-5xl font-display font-bold text-gray-900 mb-4">
                Lo que dicen nuestros clientes
              </h2>
              <p className="text-xl text-gray-600 max-w-2xl mx-auto">
                La satisfacción de nuestros clientes es nuestra mayor recompensa
              </p>
            </motion.div>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {testimonials.map((testimonial, index) => (
                <motion.div
                  key={testimonial.name}
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.2 }}
                  className="bg-gray-50 rounded-2xl p-6 shadow-soft"
                >
                  <div className="flex items-center mb-4">
                    {[...Array(testimonial.rating)].map((_, i) => (
                      <Star key={i} className="w-5 h-5 text-yellow-400 fill-current" />
                    ))}
                  </div>
                  <p className="text-gray-700 mb-4 italic">"{testimonial.text}"</p>
                  <div>
                    <p className="font-semibold text-gray-900">{testimonial.name}</p>
                    <p className="text-sm text-gray-600">{testimonial.company}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-blue-600 to-purple-600">
          <div className="max-w-4xl mx-auto text-center">
            <motion.h2 
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="text-4xl md:text-5xl font-display font-bold text-white mb-6"
            >
              ¿Listo para materializar tu idea?
            </motion.h2>
            <motion.p 
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.2 }}
              className="text-xl text-blue-100 mb-8"
            >
              Contáctanos hoy mismo y descubre cómo podemos ayudarte a hacer realidad tu proyecto
            </motion.p>
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.4 }}
              className="flex flex-col sm:flex-row gap-4 justify-center"
            >
              <a 
                href="#contacto" 
                className="bg-white text-blue-600 px-8 py-4 rounded-xl text-lg font-semibold hover:bg-gray-100 transition-all transform hover:scale-105 shadow-medium"
              >
                Contactar Ahora
              </a>
              <a 
                href="/admin" 
                className="border-2 border-white text-white px-8 py-4 rounded-xl text-lg font-semibold hover:bg-white hover:text-blue-600 transition-all"
              >
                Acceso Administración
              </a>
            </motion.div>
          </div>
        </section>

        {/* Contact Section */}
        <section id="contacto" className="py-20 px-4 sm:px-6 lg:px-8 bg-white">
          <div className="max-w-7xl mx-auto">
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="text-center mb-16"
            >
              <h2 className="text-4xl md:text-5xl font-display font-bold text-gray-900 mb-4">
                Contáctanos
              </h2>
              <p className="text-xl text-gray-600 max-w-2xl mx-auto">
                Estamos aquí para ayudarte a materializar tus ideas
              </p>
            </motion.div>
            
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
              <motion.div
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                className="space-y-6"
              >
                <div className="flex items-center space-x-4">
                  <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                    <Phone className="w-6 h-6 text-blue-600" />
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">Teléfono</h3>
                    <p className="text-gray-600">+52 (55) 1234-5678</p>
                  </div>
                </div>
                
                <div className="flex items-center space-x-4">
                  <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                    <MessageCircle className="w-6 h-6 text-blue-600" />
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">WhatsApp</h3>
                    <p className="text-gray-600">+52 (55) 1234-5678</p>
                  </div>
                </div>
                
                <div className="flex items-center space-x-4">
                  <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                    <Award className="w-6 h-6 text-blue-600" />
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">Horario</h3>
                    <p className="text-gray-600">Lunes a Viernes: 9:00 AM - 6:00 PM</p>
                  </div>
                </div>
              </motion.div>
              
              <motion.div
                initial={{ opacity: 0, x: 20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                className="bg-gray-50 rounded-2xl p-8"
              >
                <h3 className="text-2xl font-semibold text-gray-900 mb-6">Envíanos un mensaje</h3>
                <form className="space-y-4">
                  <div>
                    <input
                      type="text"
                      placeholder="Nombre completo"
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <input
                      type="email"
                      placeholder="Correo electrónico"
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <textarea
                      rows={4}
                      placeholder="Describe tu proyecto"
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    ></textarea>
                  </div>
                  <button
                    type="submit"
                    className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
                  >
                    Enviar Mensaje
                  </button>
                </form>
              </motion.div>
            </div>
          </div>
        </section>

        {/* Footer */}
        <footer className="bg-gray-900 text-white py-12 px-4 sm:px-6 lg:px-8">
          <div className="max-w-7xl mx-auto">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
              <div>
                <div className="flex items-center space-x-2 mb-4">
                  <div className="w-10 h-10 bg-gradient-to-br from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
                    <span className="text-white font-bold text-xl">MQN</span>
                  </div>
                  <span className="text-xl font-display font-bold">Media Quality Net</span>
                </div>
                <p className="text-gray-400">
                  Materializando tus ideas con la más alta calidad y tecnología avanzada.
                </p>
              </div>
              
              <div>
                <h3 className="text-lg font-semibold mb-4">Servicios</h3>
                <ul className="space-y-2 text-gray-400">
                  <li>Impresión Gran Formato</li>
                  <li>Letreros Personalizados</li>
                  <li>Diseño Gráfico</li>
                  <li>Sublimación y DTF</li>
                </ul>
              </div>
              
              <div>
                <h3 className="text-lg font-semibold mb-4">Empresa</h3>
                <ul className="space-y-2 text-gray-400">
                  <li>Sobre Nosotros</li>
                  <li>Nuestro Equipo</li>
                  <li>Casos de Éxito</li>
                  <li>Blog</li>
                </ul>
              </div>
              
              <div>
                <h3 className="text-lg font-semibold mb-4">Contacto</h3>
                <ul className="space-y-2 text-gray-400">
                  <li>+52 (55) 1234-5678</li>
                  <li>info@mediaquality.net</li>
                  <li>Ciudad de México, México</li>
                </ul>
              </div>
            </div>
            
            <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
              <p>&copy; 2024 Media Quality Net. Todos los derechos reservados.</p>
            </div>
          </div>
        </footer>
      </div>
    </>
  );
}
