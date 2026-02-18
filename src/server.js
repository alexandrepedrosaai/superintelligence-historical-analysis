const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const compression = require('compression');
const morgan = require('morgan');
const timelineRouter = require('./routes/timeline');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware de segurança
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(morgan('combined'));
app.use(express.json());

// Health check endpoint para Kubernetes
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.APP_VERSION || '1.0.0'
  });
});

// Readiness check
app.get('/ready', (req, res) => {
  res.status(200).json({
    status: 'ready',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'Superintelligence Timeline API',
    version: '1.0.0',
    description: 'Constitutional Timeline of the OS-Algorithmic-Mesh (2023–2026)',
    author: 'Alexandre Pedrosa Guimarães',
    endpoints: {
      health: '/health',
      ready: '/ready',
      timeline: '/api/timeline',
      timelineImage: '/api/timeline/image',
      narrative: '/api/narrative'
    }
  });
});

// Routes
app.use('/api', timelineRouter);

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: {
      message: err.message || 'Internal Server Error',
      status: err.status || 500
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: {
      message: 'Endpoint not found',
      status: 404,
      path: req.path
    }
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Superintelligence Timeline API running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});

module.exports = app;
