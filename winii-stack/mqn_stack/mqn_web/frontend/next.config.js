/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  
  // Configuración para exportación estática (para Cloudflare)
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true
  },
  
  // Configuración de headers para SEO y seguridad
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin'
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(), geolocation=()'
          }
        ]
      }
    ];
  },
  
  // Configuración de redirecciones
  async redirects() {
    return [
      {
        source: '/admin',
        destination: '/admin/',
        permanent: true
      }
    ];
  },
  
  // Configuración de rewrites para API
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://localhost:8001/:path*'
      }
    ];
  },
  
  // Configuración de variables de entorno
  env: {
    CUSTOM_KEY: process.env.CUSTOM_KEY,
  },
  
  // Configuración de webpack
  webpack: (config, { isServer }) => {
    // Configuración para archivos estáticos
    config.module.rules.push({
      test: /\.(pdf|doc|docx|xls|xlsx|ppt|pptx)$/,
      use: [
        {
          loader: 'file-loader',
          options: {
            publicPath: '/_next/static/files/',
            outputPath: 'static/files/',
          },
        },
      ],
    });
    
    return config;
  },
  
  // Configuración de experimental features
  experimental: {
    appDir: false,
    optimizeCss: true,
    scrollRestoration: true,
  },
  
  // Configuración de compresión
  compress: true,
  
  // Configuración de powered by
  poweredByHeader: false,
  
  // Configuración de tipos
  typescript: {
    ignoreBuildErrors: false,
  },
  
  // Configuración de ESLint
  eslint: {
    ignoreDuringBuilds: false,
  },
};

module.exports = nextConfig;
