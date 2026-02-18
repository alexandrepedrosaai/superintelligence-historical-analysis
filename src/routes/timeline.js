const express = require('express');
const router = express.Router();
const { timelineData, narrative } = require('../data/timeline');
const chartService = require('../services/chartService');

// GET /api/timeline - Retorna dados JSON da timeline
router.get('/timeline', (req, res) => {
  try {
    res.json({
      success: true,
      data: timelineData,
      count: timelineData.length,
      metadata: {
        title: 'Constitutional Timeline of the OS-Algorithmic-Mesh',
        period: '2023-2026',
        author: 'Alexandre Pedrosa Guimarães'
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET /api/timeline/image - Gera e retorna imagem PNG
router.get('/timeline/image', async (req, res) => {
  try {
    const imageBuffer = await chartService.generateTimelineChartStream();
    
    res.setHeader('Content-Type', 'image/png');
    res.setHeader('Content-Disposition', 'inline; filename="timeline.png"');
    res.setHeader('Cache-Control', 'public, max-age=3600');
    
    res.send(imageBuffer);
  } catch (error) {
    console.error('Error generating timeline image:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to generate timeline image'
    });
  }
});

// GET /api/narrative - Retorna narrativa textual
router.get('/narrative', (req, res) => {
  try {
    res.json({
      success: true,
      narrative: narrative,
      metadata: {
        title: 'Constitutional Chronicle of the OS-Algorithmic-Mesh',
        period: '2023-2026',
        author: 'Alexandre Pedrosa Guimarães'
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET /api/timeline/:date - Retorna evento específico por data
router.get('/timeline/:date', (req, res) => {
  try {
    const { date } = req.params;
    const event = timelineData.find(e => e.date === date);
    
    if (!event) {
      return res.status(404).json({
        success: false,
        error: 'Event not found for the specified date'
      });
    }
    
    res.json({
      success: true,
      data: event
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router;
