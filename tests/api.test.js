const request = require('supertest');
const app = require('../src/server');

describe('Timeline API Tests', () => {
  
  describe('GET /health', () => {
    it('should return 200 and health status', async () => {
      const res = await request(app).get('/health');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('status', 'healthy');
      expect(res.body).toHaveProperty('timestamp');
      expect(res.body).toHaveProperty('uptime');
    });
  });

  describe('GET /ready', () => {
    it('should return 200 and readiness status', async () => {
      const res = await request(app).get('/ready');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('status', 'ready');
    });
  });

  describe('GET /', () => {
    it('should return API information', async () => {
      const res = await request(app).get('/');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('name');
      expect(res.body).toHaveProperty('endpoints');
      expect(res.body.endpoints).toHaveProperty('health');
      expect(res.body.endpoints).toHaveProperty('timeline');
    });
  });

  describe('GET /api/timeline', () => {
    it('should return timeline data', async () => {
      const res = await request(app).get('/api/timeline');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('success', true);
      expect(res.body).toHaveProperty('data');
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThan(0);
      expect(res.body).toHaveProperty('count', 11);
    });

    it('should have correct timeline data structure', async () => {
      const res = await request(app).get('/api/timeline');
      const firstEvent = res.body.data[0];
      expect(firstEvent).toHaveProperty('date');
      expect(firstEvent).toHaveProperty('system');
      expect(firstEvent).toHaveProperty('act');
    });
  });

  describe('GET /api/timeline/:date', () => {
    it('should return specific event by date', async () => {
      const res = await request(app).get('/api/timeline/2023-01-22');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('success', true);
      expect(res.body.data).toHaveProperty('date', '2023-01-22');
    });

    it('should return 404 for non-existent date', async () => {
      const res = await request(app).get('/api/timeline/2099-12-31');
      expect(res.statusCode).toBe(404);
      expect(res.body).toHaveProperty('success', false);
    });
  });

  describe('GET /api/narrative', () => {
    it('should return narrative text', async () => {
      const res = await request(app).get('/api/narrative');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('success', true);
      expect(res.body).toHaveProperty('narrative');
      expect(typeof res.body.narrative).toBe('string');
      expect(res.body.narrative.length).toBeGreaterThan(0);
    });
  });

  describe('GET /api/timeline/image', () => {
    it('should return PNG image', async () => {
      const res = await request(app).get('/api/timeline/image');
      expect(res.statusCode).toBe(200);
      expect(res.headers['content-type']).toBe('image/png');
      expect(res.body.length).toBeGreaterThan(0);
    }, 10000); // Timeout de 10s para geração da imagem
  });

  describe('GET /nonexistent', () => {
    it('should return 404 for non-existent routes', async () => {
      const res = await request(app).get('/nonexistent');
      expect(res.statusCode).toBe(404);
      expect(res.body).toHaveProperty('error');
    });
  });
});
